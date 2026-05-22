#!/usr/bin/env node

/**
 * Script to fetch RLS (Row Level Security) policies from Supabase and save them to individual files
 * 
 * Usage:
 *   node scripts/fetch-rls-policies.js
 * 
 * Environment variables required (in root .env file):
 *   SUPABASE_URL - Your Supabase project URL
 *   SUPABASE_DB_PASSWORD - Your Supabase database password (or use SUPABASE_DB_URL)
 *   SUPABASE_DB_URL - Full PostgreSQL connection string (alternative to URL + password)
 */

// Load environment variables from .env file
require('dotenv').config({ path: require('path').join(__dirname, '..', '..', '.env') });

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

// Configuration
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'rls_policies');
const SCHEMA_NAME = 'public'; // Default schema

function quoteIdentifier(identifier) {
  return `"${String(identifier).replace(/"/g, '""')}"`;
}

function parsePostgresArray(text) {
  if (typeof text !== 'string' || !text.startsWith('{') || !text.endsWith('}')) {
    return null;
  }

  const inner = text.slice(1, -1);
  if (!inner) return [];

  // Handles simple role arrays like {authenticated} and {"service_role"}.
  const parts = inner.split(',').map((part) => part.trim());
  return parts.map((part) => {
    if (part.startsWith('"') && part.endsWith('"')) {
      return part.slice(1, -1).replace(/\\"/g, '"');
    }
    return part;
  });
}

function formatRole(role) {
  const normalized = String(role).trim();
  if (!normalized) return null;
  if (/^[a-z_][a-z0-9_]*$/i.test(normalized)) {
    return normalized;
  }
  return quoteIdentifier(normalized);
}

/**
 * Get database connection string from environment variables
 */
function getConnectionString() {
  // Option 1: Use full connection string (recommended)
  if (process.env.SUPABASE_DB_URL) {
    return process.env.SUPABASE_DB_URL.trim();
  }

  // Option 2: Build from components
  const supabaseUrl = process.env.SUPABASE_URL;
  const dbPassword = process.env.SUPABASE_DB_PASSWORD;

  if (!supabaseUrl || !dbPassword) {
    throw new Error(
      'Missing required environment variables.\n' +
      'Either set SUPABASE_DB_URL (full connection string) or\n' +
      'set SUPABASE_URL and SUPABASE_DB_PASSWORD.\n\n' +
      'To get your database connection string:\n' +
      '1. Go to Supabase Dashboard > Settings > Database\n' +
      '2. Find "Connection string" section\n' +
      '3. Copy the "URI" or "Connection pooling" string\n' +
      '4. Replace [YOUR-PASSWORD] with your actual database password\n\n' +
      'Example formats:\n' +
      '  - Direct: postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[region].pooler.supabase.com:5432/postgres\n' +
      '  - Pooling: postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[region].pooler.supabase.com:6543/postgres\n' +
      '  - Or use SUPABASE_DB_URL with the full connection string'
    );
  }

  // Try to extract project reference from Supabase URL
  const urlMatch = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.co/);
  if (!urlMatch) {
    throw new Error(
      'Invalid SUPABASE_URL format. Expected: https://[PROJECT-REF].supabase.co\n' +
      'Alternatively, use SUPABASE_DB_URL with the full PostgreSQL connection string from Supabase Dashboard.'
    );
  }

  const projectRef = urlMatch[1];
  
  console.warn(
    '⚠️  Warning: Building connection string from SUPABASE_URL.\n' +
    '   For better reliability, use SUPABASE_DB_URL with the full connection string\n' +
    '   from Supabase Dashboard > Settings > Database > Connection string.\n'
  );
  
  const connectionString = `postgresql://postgres:${encodeURIComponent(dbPassword)}@db.${projectRef}.supabase.co:5432/postgres`;
  
  return connectionString;
}

/**
 * Get all RLS policies from the database
 */
async function getRLSPolicies(client) {
  const query = `
    SELECT
      schemaname,
      tablename,
      policyname,
      permissive,
      roles,
      cmd,
      qual,
      with_check
    FROM pg_policies
    WHERE schemaname = $1
    ORDER BY tablename, policyname;
  `;

  const result = await client.query(query, [SCHEMA_NAME]);
  return result.rows;
}

/**
 * Generate CREATE POLICY statement
 */
function generatePolicySQL(policy) {
  let sql = `-- Policy: ${policy.policyname}\n`;
  sql += `-- Table: ${policy.schemaname}.${policy.tablename}\n`;
  sql += `-- Generated: ${new Date().toISOString()}\n\n`;
  
  sql += `CREATE POLICY ${quoteIdentifier(policy.policyname)}\n`;
  sql += `  ON ${policy.schemaname}.${policy.tablename}\n`;
  
  // Add permissive/restrictive
  if (policy.permissive === 'PERMISSIVE') {
    sql += `  AS PERMISSIVE\n`;
  } else {
    sql += `  AS RESTRICTIVE\n`;
  }
  
  // Add command (SELECT, INSERT, UPDATE, DELETE, or ALL)
  sql += `  FOR ${policy.cmd}\n`;
  
  // Add roles - handle both array and string formats
  let roles = policy.roles;
  if (typeof roles === 'string') {
    // Try JSON first, then Postgres text array format.
    try {
      roles = JSON.parse(roles);
    } catch (e) {
      const pgArray = parsePostgresArray(roles);
      if (pgArray !== null) {
        roles = pgArray;
      } else {
        roles = roles ? [roles] : [];
      }
    }
  }
  if (!Array.isArray(roles)) {
    roles = roles ? [roles] : [];
  }
  
  if (roles && roles.length > 0) {
    const rolesList = roles
      .map(formatRole)
      .filter(Boolean)
      .join(', ');
    sql += `  TO ${rolesList}\n`;
  } else {
    sql += `  TO public\n`;
  }
  
  // Add USING clause (for SELECT, UPDATE, DELETE)
  if (policy.qual) {
    sql += `  USING (${policy.qual})\n`;
  }
  
  // Add WITH CHECK clause (for INSERT, UPDATE)
  if (policy.with_check) {
    sql += `  WITH CHECK (${policy.with_check})\n`;
  }
  
  sql += `;\n`;
  
  return sql;
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching RLS policies from Supabase...\n');

  // Ensure database directory exists
  if (!fs.existsSync(DATABASE_DIR)) {
    fs.mkdirSync(DATABASE_DIR, { recursive: true });
    console.log(`📁 Created directory: ${DATABASE_DIR}`);
  }

  // Get connection string with validation
  let connectionString;
  try {
    connectionString = getConnectionString();
    
    if (!connectionString || connectionString.trim() === '') {
      throw new Error(
        'Connection string is empty.\n' +
        'Please check your .env file contains SUPABASE_DB_URL or both SUPABASE_URL and SUPABASE_DB_PASSWORD.'
      );
    }
    
    if (!connectionString.startsWith('postgresql://') && !connectionString.startsWith('postgres://')) {
      throw new Error(
        `Connection string must start with postgresql:// or postgres://\n` +
        `Got: ${connectionString.substring(0, 50)}...`
      );
    }
    
    const maskedConnection = connectionString.replace(/:([^:@]+)@/, ':***@');
    console.log(`🔗 Using connection: ${maskedConnection}\n`);
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.message.includes('Missing required')) {
      console.error('\n💡 Make sure your .env file is in the root directory and contains:');
      console.error('   SUPABASE_DB_URL=postgresql://...');
      console.error('   OR');
      console.error('   SUPABASE_URL=https://...');
      console.error('   SUPABASE_DB_PASSWORD=...');
    }
    process.exit(1);
  }

  const client = new Client({
    connectionString: connectionString,
    ssl: {
      rejectUnauthorized: false // Supabase uses SSL
    }
  });

  try {
    await client.connect();
    console.log('✅ Connected to database\n');

    // Get all RLS policies
    const policies = await getRLSPolicies(client);
    console.log(`📋 Found ${policies.length} RLS policy/policies\n`);

    const filteredPolicies = policies.filter(policy => policy.policyname && policy.policyname !== '…');

    if (policies.length === 0) {
      console.log('ℹ️  No RLS policies found in the database.');
      return;
    }

    // Group policies by table
    const policiesByTable = {};
    filteredPolicies.forEach(policy => {
      if (!policiesByTable[policy.tablename]) {
        policiesByTable[policy.tablename] = [];
      }
      if (!policiesByTable[policy.tablename].some(existing => existing.policyname === policy.policyname)) {
      policiesByTable[policy.tablename].push(policy);
      }
    });

    // Save policies grouped by table
    for (const [tableName, tablePolicies] of Object.entries(policiesByTable)) {
      console.log(`📝 Fetching policies for table: ${tableName}...`);
      
      let sql = `-- RLS Policies for table: ${SCHEMA_NAME}.${tableName}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n`;
      sql += `-- Total policies: ${tablePolicies.length}\n\n`;
      
      // Check if RLS is enabled
      const rlsEnabledQuery = `
        SELECT relrowsecurity 
        FROM pg_class c
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = $1 AND c.relname = $2;
      `;
      const rlsCheck = await client.query(rlsEnabledQuery, [SCHEMA_NAME, tableName]);
      const rlsEnabled = rlsCheck.rows[0]?.relrowsecurity || false;
      
      if (!rlsEnabled) {
        sql += `-- Note: RLS is not enabled on this table\n`;
        sql += `-- Enable RLS with: ALTER TABLE ${SCHEMA_NAME}.${tableName} ENABLE ROW LEVEL SECURITY;\n\n`;
      }
      
      tablePolicies.forEach(policy => {
        sql += generatePolicySQL(policy);
        sql += '\n';
      });
      
      const sanitizedName = tableName.replace(/[^a-zA-Z0-9_]/g, '_');
      const filePath = path.join(DATABASE_DIR, `${sanitizedName}_rls_policies.sql`);
      
      const fileExists = fs.existsSync(filePath);
      fs.writeFileSync(filePath, sql, 'utf8');
      
      if (fileExists) {
        console.log(`   ✅ Updated: ${filePath}`);
      } else {
        console.log(`   ✅ Created: ${filePath}`);
      }
    }

    console.log(`\n✨ Successfully fetched ${policies.length} RLS policy/policies!`);
    console.log(`📂 Files saved to: ${DATABASE_DIR}`);

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

// Run the script
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

module.exports = { main, getConnectionString };

