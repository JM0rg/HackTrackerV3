#!/usr/bin/env node

/**
 * Fetch GRANT statements from Supabase and produce:
 *   1. app/database/grants/grants_manifest.json  — structured manifest
 *   2. app/database/grants/grants.sql             — generated via generate-grants-from-manifest.js
 *
 * Queries information_schema for table, view, sequence, and function grants
 * in the public schema, filtering to app-relevant roles (authenticated,
 * service_role, anon) and excluding extension/system objects.
 *
 * Usage:
 *   node scripts/database/fetch-grants.js
 *
 * Environment variables required (in root .env file):
 *   SUPABASE_URL - Your Supabase project URL
 *   SUPABASE_DB_PASSWORD - Your Supabase database password (or use SUPABASE_DB_URL)
 *   SUPABASE_DB_URL - Full PostgreSQL connection string (alternative to URL + password)
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '..', '.env') });

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
const { execSync } = require('child_process');

const ROOT = path.join(__dirname, '..', '..');
const GRANTS_DIR = path.join(ROOT, 'app', 'database', 'grants');
const MANIFEST_FILE = path.join(GRANTS_DIR, 'grants_manifest.json');
const FUNCTIONS_DIR = path.join(ROOT, 'app', 'database', 'functions');

// Roles we care about — never grant to PUBLIC
const APP_ROLES = ['authenticated', 'service_role', 'anon'];

// Extension function prefixes to skip
const EXTENSION_PREFIXES = ['gbt_', 'gin_', 'gist_', 'spgist_', 'brin_', 'btree_', 'hash_', 'pg_'];

/**
 * Get database connection string from environment variables
 */
function getConnectionString() {
  if (process.env.SUPABASE_DB_URL) {
    return process.env.SUPABASE_DB_URL.trim();
  }

  const supabaseUrl = process.env.SUPABASE_URL;
  const dbPassword = process.env.SUPABASE_DB_PASSWORD;

  if (!supabaseUrl || !dbPassword) {
    throw new Error(
      'Missing required environment variables.\n' +
      'Either set SUPABASE_DB_URL (full connection string) or\n' +
      'set SUPABASE_URL and SUPABASE_DB_PASSWORD.\n'
    );
  }

  const urlMatch = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.co/);
  if (!urlMatch) {
    throw new Error(
      'Invalid SUPABASE_URL format. Expected: https://[PROJECT-REF].supabase.co'
    );
  }

  const projectRef = urlMatch[1];
  console.warn(
    '⚠️  Warning: Building connection string from SUPABASE_URL.\n' +
    '   For better reliability, use SUPABASE_DB_URL with the full connection string.\n'
  );

  return `postgresql://postgres:${encodeURIComponent(dbPassword)}@db.${projectRef}.supabase.co:5432/postgres`;
}

/**
 * Get set of app-owned function names from fetched function files
 */
function getAppFunctionNames() {
  if (!fs.existsSync(FUNCTIONS_DIR)) return new Set();
  const names = new Set();
  for (const f of fs.readdirSync(FUNCTIONS_DIR)) {
    if (!f.endsWith('_function.sql')) continue;
    const name = f.replace(/_function\.sql$/, '');
    if (!EXTENSION_PREFIXES.some(p => name.startsWith(p))) {
      names.add(name);
    }
  }
  return names;
}

/**
 * Fetch table/view grants from information_schema
 */
async function fetchTableGrants(client) {
  const query = `
    SELECT
      table_name,
      grantee,
      privilege_type
    FROM information_schema.role_table_grants
    WHERE table_schema = 'public'
      AND grantor <> grantee
      AND grantee = ANY($1)
    ORDER BY table_name, grantee, privilege_type;
  `;
  const result = await client.query(query, [APP_ROLES]);
  return result.rows;
}

/**
 * Fetch function grants from information_schema
 */
async function fetchFunctionGrants(client) {
  const query = `
    SELECT
      routine_name,
      grantee,
      privilege_type
    FROM information_schema.role_routine_grants
    WHERE routine_schema = 'public'
      AND grantor <> grantee
      AND grantee = ANY($1)
    ORDER BY routine_name, grantee;
  `;
  const result = await client.query(query, [APP_ROLES]);
  return result.rows;
}

/**
 * Fetch sequence grants
 */
async function fetchSequenceGrants(client) {
  const query = `
    SELECT
      object_name AS sequence_name,
      grantee
    FROM information_schema.role_usage_grants
    WHERE object_schema = 'public'
      AND object_type = 'SEQUENCE'
      AND grantee = ANY($1)
    ORDER BY object_name, grantee;
  `;
  const result = await client.query(query, [APP_ROLES]);
  return result.rows;
}

/**
 * Classify table rows into tables vs views using pg_class
 */
async function getTableTypes(client) {
  const query = `
    SELECT c.relname, c.relkind
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND c.relkind IN ('r', 'v', 'm');
  `;
  const result = await client.query(query);
  const types = {};
  for (const row of result.rows) {
    types[row.relname] = row.relkind === 'r' ? 'table' : 'view';
  }
  return types;
}

/**
 * Build the manifest structure from raw grant rows
 */
function buildManifest(tableGrants, functionGrants, sequenceGrants, tableTypes, appFunctions) {
  // -- Tables and views --
  const tables = {};
  const views = {};

  for (const row of tableGrants) {
    const name = row.table_name;
    const kind = tableTypes[name] || 'table';
    const target = kind === 'view' ? views : tables;

    if (!target[name]) target[name] = {};
    if (!target[name][row.grantee]) target[name][row.grantee] = [];
    if (!target[name][row.grantee].includes(row.privilege_type)) {
      target[name][row.grantee].push(row.privilege_type);
    }
  }

  // -- Sequences --
  const sequences = {};
  for (const row of sequenceGrants) {
    const name = row.sequence_name;
    if (!sequences[name]) sequences[name] = { roles: [] };
    if (!sequences[name].roles.includes(row.grantee)) {
      sequences[name].roles.push(row.grantee);
    }
  }

  // -- Functions --
  // Determine role bundles: group functions by which roles they're granted to
  const funcRoleMap = {}; // funcName -> Set<role>
  for (const row of functionGrants) {
    const name = row.routine_name;
    // Only include app-owned functions
    if (!appFunctions.has(name)) continue;
    if (!funcRoleMap[name]) funcRoleMap[name] = new Set();
    funcRoleMap[name].add(row.grantee);
  }

  // Build role bundles from unique role combinations
  const bundleMap = new Map(); // "role1,role2" -> bundleId
  const roleBundles = {};
  let bundleCounter = 0;

  for (const [funcName, roleSet] of Object.entries(funcRoleMap)) {
    const key = [...roleSet].sort().join(',');
    if (!bundleMap.has(key)) {
      const bundleId = roleSet.size === 1
        ? [...roleSet][0]
        : `bundle_${++bundleCounter}`;
      bundleMap.set(key, bundleId);
      roleBundles[bundleId] = { roles: [...roleSet].sort() };
    }
  }

  const functions = {};
  for (const [funcName, roleSet] of Object.entries(funcRoleMap)) {
    const key = [...roleSet].sort().join(',');
    functions[funcName] = bundleMap.get(key);
  }

  // Sort all objects alphabetically for stable diffs
  const sortObj = (obj) => {
    const sorted = {};
    for (const key of Object.keys(obj).sort()) {
      sorted[key] = obj[key];
    }
    return sorted;
  };

  return {
    _generated: new Date().toISOString(),
    _description: 'Auto-generated by fetch-grants.js. Do not edit manually.',
    roleBundles: sortObj(roleBundles),
    tables: sortObj(tables),
    views: sortObj(views),
    sequences: sortObj(sequences),
    functions: sortObj(functions),
  };
}

async function main() {
  console.log('🔍 Fetching grants from Supabase...\n');

  if (!fs.existsSync(GRANTS_DIR)) {
    fs.mkdirSync(GRANTS_DIR, { recursive: true });
    console.log(`📁 Created directory: ${GRANTS_DIR}`);
  }

  const connectionString = getConnectionString();
  const maskedConnection = connectionString.replace(/:([^:@]+)@/, ':***@');
  console.log(`🔗 Using connection: ${maskedConnection}\n`);

  const appFunctions = getAppFunctionNames();
  console.log(`📋 Found ${appFunctions.size} app functions to match against\n`);

  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false },
  });

  try {
    await client.connect();
    console.log('✅ Connected to database\n');

    const [tableGrants, functionGrants, sequenceGrants, tableTypes] = await Promise.all([
      fetchTableGrants(client),
      fetchFunctionGrants(client),
      fetchSequenceGrants(client),
      getTableTypes(client),
    ]);

    console.log(`📋 Found ${tableGrants.length} table/view grant rows`);
    console.log(`📋 Found ${functionGrants.length} function grant rows`);
    console.log(`📋 Found ${sequenceGrants.length} sequence grant rows\n`);

    const manifest = buildManifest(tableGrants, functionGrants, sequenceGrants, tableTypes, appFunctions);

    const tableCount = Object.keys(manifest.tables).length;
    const viewCount = Object.keys(manifest.views).length;
    const seqCount = Object.keys(manifest.sequences).length;
    const funcCount = Object.keys(manifest.functions).length;
    const bundleCount = Object.keys(manifest.roleBundles).length;

    // Write manifest
    fs.writeFileSync(MANIFEST_FILE, JSON.stringify(manifest, null, 2) + '\n', 'utf8');
    console.log(`✅ Wrote manifest: ${MANIFEST_FILE}`);
    console.log(`   Tables: ${tableCount}, Views: ${viewCount}, Sequences: ${seqCount}, Functions: ${funcCount}, Role bundles: ${bundleCount}\n`);

    // Run the generator to produce grants.sql
    console.log('📝 Generating grants.sql from manifest...\n');
    const generatorPath = path.join(__dirname, 'generate-grants-from-manifest.js');
    execSync(`node ${generatorPath}`, { stdio: 'inherit', cwd: ROOT });

    console.log('\n✨ Successfully fetched and generated grants!');
    console.log(`📂 Files saved to: ${GRANTS_DIR}`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.code === '28P01') {
      console.error('\n💡 Authentication failed. Check your database password.');
    } else if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      console.error('\n💡 Connection failed. Check your SUPABASE_URL and network connection.');
    }
    process.exit(1);
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

module.exports = { main, getConnectionString };
