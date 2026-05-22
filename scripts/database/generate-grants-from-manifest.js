#!/usr/bin/env node

/**
 * Generate grants.sql from grants_manifest.json
 * 
 * This script replaces the raw database dump approach with a manifest-driven
 * generator that produces clean, deduped, app-only grants.
 * 
 * Features:
 * - Only app-owned objects (no extension/system functions)
 * - Deduped privileges (no "GRANT EXECUTE, EXECUTE")
 * - No PUBLIC grants (aligns with security requirements)
 * - Deterministic output for stable diffs
 * - Validation mode to check for duplicate privileges
 * 
 * Usage:
 *   node scripts/database/generate-grants-from-manifest.js
 *   node scripts/database/generate-grants-from-manifest.js --validate
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..', '..');
const MANIFEST_FILE = path.join(ROOT, 'app', 'database', 'grants', 'grants_manifest.json');
const GRANTS_FILE = path.join(ROOT, 'app', 'database', 'grants', 'grants.sql');
const FUNCTIONS_DIR = path.join(ROOT, 'app', 'database', 'functions');
const SCHEMAS_DIR = path.join(ROOT, 'app', 'database', 'schemas');

const EXTENSION_PREFIXES = ['gbt_', 'gin_', 'gist_', 'spgist_', 'brin_', 'btree_', 'hash_', 'pg_'];

/**
 * Load and validate the manifest
 */
function loadManifest() {
  if (!fs.existsSync(MANIFEST_FILE)) {
    throw new Error(`Manifest not found: ${MANIFEST_FILE}`);
  }

  const content = fs.readFileSync(MANIFEST_FILE, 'utf8');
  const manifest = JSON.parse(content);

  if (!manifest.tables || !manifest.functions) {
    throw new Error('Manifest must contain "tables" and "functions" sections');
  }

  return manifest;
}

/**
 * Strip DEFAULT clauses from parameter signature for GRANT statements
 * PostgreSQL GRANT doesn't accept DEFAULT values in function signatures
 */
function stripDefaultsFromSignature(signature) {
  if (!signature) return signature;
  
  // Remove DEFAULT clauses (e.g., "DEFAULT 1", "DEFAULT NULL::double precision")
  // Match: DEFAULT followed by value/expression until comma or end
  return signature
    .replace(/\s+DEFAULT\s+[^,)]+/gi, '')
    .trim();
}

/**
 * Get list of app-owned function names and their signatures from filesystem
 * Returns a Map of funcName -> array of signatures (with DEFAULT clauses removed)
 */
function getAppFunctionSignatures() {
  if (!fs.existsSync(FUNCTIONS_DIR)) {
    return new Map();
  }

  const functionMap = new Map();
  
  for (const file of fs.readdirSync(FUNCTIONS_DIR)) {
    if (!file.endsWith('_function.sql')) continue;
    const funcName = file.replace(/_function\.sql$/, '');
    
    // Exclude extension functions even if they somehow got a file
    if (EXTENSION_PREFIXES.some(prefix => funcName.startsWith(prefix))) {
      continue;
    }
    
    // Read the file to extract function signatures
    const filePath = path.join(FUNCTIONS_DIR, file);
    const content = fs.readFileSync(filePath, 'utf8');
    
    // Find all CREATE OR REPLACE FUNCTION declarations
    const signatureRegex = new RegExp(
      `CREATE OR REPLACE FUNCTION\\s+public\\.${funcName}\\s*\\(([^)]*)\\)`,
      'gi'
    );
    
    const signatures = [];
    let match;
    while ((match = signatureRegex.exec(content)) !== null) {
      const params = match[1].trim();
      // Strip DEFAULT clauses for GRANT compatibility
      const cleanParams = stripDefaultsFromSignature(params);
      signatures.push(cleanParams);
    }
    
    if (signatures.length > 0) {
      functionMap.set(funcName, signatures);
    }
  }

  return functionMap;
}

/**
 * Get list of app-owned function names (for backward compatibility)
 */
function getAppFunctionNames() {
  const sigMap = getAppFunctionSignatures();
  return new Set(sigMap.keys());
}

/**
 * Get list of app-owned table names from filesystem
 */
function getAppTableNames() {
  if (!fs.existsSync(SCHEMAS_DIR)) {
    return new Set();
  }

  const names = new Set();
  for (const file of fs.readdirSync(SCHEMAS_DIR)) {
    if (!file.startsWith('create_') || !file.endsWith('_table.sql')) continue;
    const tableName = file.replace(/^create_/, '').replace(/_table\.sql$/, '');
    names.add(tableName);
  }

  return names;
}

/**
 * Dedupe privileges and sort them deterministically
 */
function dedupePrivileges(privileges) {
  const uniquePrivs = [...new Set(privileges)];
  
  // Sort for deterministic output
  const order = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'REFERENCES', 'TRIGGER', 'TRUNCATE', 'USAGE', 'EXECUTE'];
  uniquePrivs.sort((a, b) => {
    const aIdx = order.indexOf(a);
    const bIdx = order.indexOf(b);
    if (aIdx !== -1 && bIdx !== -1) return aIdx - bIdx;
    if (aIdx !== -1) return -1;
    if (bIdx !== -1) return 1;
    return a.localeCompare(b);
  });

  return uniquePrivs;
}

/**
 * Validate that no line contains duplicate privileges
 */
function validateNoDuplicates(grantLines) {
  const errors = [];
  
  for (const line of grantLines) {
    if (!line.startsWith('GRANT ')) continue;
    
    const match = line.match(/^GRANT\s+(.+?)\s+ON\s+/);
    if (!match) continue;
    
    const privsPart = match[1];
    const privs = privsPart.split(',').map(p => p.trim());
    const uniquePrivs = [...new Set(privs)];
    
    if (privs.length !== uniquePrivs.length) {
      errors.push(`Duplicate privileges in: ${line.trim()}`);
    }
  }

  return errors;
}

/**
 * Generate grant statements for tables
 */
function generateTableGrants(manifest) {
  const lines = [];
  const tables = manifest.tables || {};
  
  // Group by (table, role) -> privileges
  const grantMap = new Map();
  
  for (const [tableName, rolePrivs] of Object.entries(tables)) {
    for (const [role, privileges] of Object.entries(rolePrivs)) {
      const key = `${tableName}::${role}`;
      grantMap.set(key, { tableName, role, privileges });
    }
  }

  // Sort by table name, then role
  const sorted = Array.from(grantMap.values()).sort((a, b) => {
    if (a.tableName !== b.tableName) return a.tableName.localeCompare(b.tableName);
    return a.role.localeCompare(b.role);
  });

  for (const { tableName, role, privileges } of sorted) {
    const dedupedPrivs = dedupePrivileges(privileges);
    lines.push(`GRANT ${dedupedPrivs.join(', ')} ON TABLE public.${tableName} TO "${role}";`);
  }

  return lines;
}

/**
 * Generate grant statements for views
 */
function generateViewGrants(manifest) {
  const lines = [];
  const views = manifest.views || {};
  
  const grantMap = new Map();
  
  for (const [viewName, rolePrivs] of Object.entries(views)) {
    for (const [role, privileges] of Object.entries(rolePrivs)) {
      const key = `${viewName}::${role}`;
      grantMap.set(key, { viewName, role, privileges });
    }
  }

  const sorted = Array.from(grantMap.values()).sort((a, b) => {
    if (a.viewName !== b.viewName) return a.viewName.localeCompare(b.viewName);
    return a.role.localeCompare(b.role);
  });

  for (const { viewName, role, privileges } of sorted) {
    const dedupedPrivs = dedupePrivileges(privileges);
    lines.push(`GRANT ${dedupedPrivs.join(', ')} ON TABLE public.${viewName} TO "${role}";`);
  }

  return lines;
}

/**
 * Generate grant statements for sequences
 */
function generateSequenceGrants(manifest) {
  const lines = [];
  const sequences = manifest.sequences || {};
  
  const grantMap = new Map();
  
  for (const [seqName, config] of Object.entries(sequences)) {
    for (const role of config.roles) {
      const key = `${seqName}::${role}`;
      grantMap.set(key, { seqName, role });
    }
  }

  const sorted = Array.from(grantMap.values()).sort((a, b) => {
    if (a.seqName !== b.seqName) return a.seqName.localeCompare(b.seqName);
    return a.role.localeCompare(b.role);
  });

  for (const { seqName, role } of sorted) {
    lines.push(`GRANT USAGE ON SEQUENCE public.${seqName} TO "${role}";`);
  }

  return lines;
}

/**
 * Generate grant statements for functions
 * Handles overloaded functions by emitting signature-specific grants
 */
function generateFunctionGrants(manifest, functionSignatures) {
  const lines = [];
  const functions = manifest.functions || {};
  const roleBundles = manifest.roleBundles || {};
  
  const grantMap = new Map();
  
  for (const [funcName, bundleId] of Object.entries(functions)) {
    // Validate function exists in app/database/functions
    if (!functionSignatures.has(funcName)) {
      console.warn(`Warning: Function "${funcName}" in manifest not found in ${FUNCTIONS_DIR}`);
      continue;
    }

    // Exclude extension functions by prefix
    if (EXTENSION_PREFIXES.some(prefix => funcName.startsWith(prefix))) {
      console.warn(`Warning: Skipping extension function "${funcName}"`);
      continue;
    }

    const bundle = roleBundles[bundleId];
    if (!bundle) {
      throw new Error(`Unknown role bundle "${bundleId}" for function "${funcName}"`);
    }

    const signatures = functionSignatures.get(funcName);
    
    // If function has multiple signatures (overloaded), emit signature-specific grants
    if (signatures.length > 1) {
      for (const signature of signatures) {
        for (const role of bundle.roles) {
          const key = `${funcName}(${signature})::${role}`;
          grantMap.set(key, { funcName, signature, role, isOverloaded: true });
        }
      }
    } else {
      // Single signature - emit without signature for cleaner output
      for (const role of bundle.roles) {
        const key = `${funcName}::${role}`;
        grantMap.set(key, { funcName, signature: null, role, isOverloaded: false });
      }
    }
  }

  const sorted = Array.from(grantMap.values()).sort((a, b) => {
    if (a.funcName !== b.funcName) return a.funcName.localeCompare(b.funcName);
    if (a.signature !== b.signature) {
      if (!a.signature) return -1;
      if (!b.signature) return 1;
      return a.signature.localeCompare(b.signature);
    }
    return a.role.localeCompare(b.role);
  });

  for (const { funcName, signature, role, isOverloaded } of sorted) {
    if (isOverloaded) {
      const normalizedSignature = signature ?? '';
      lines.push(`GRANT EXECUTE ON FUNCTION public.${funcName}(${normalizedSignature}) TO "${role}";`);
    } else {
      lines.push(`GRANT EXECUTE ON FUNCTION public.${funcName} TO "${role}";`);
    }
  }

  return lines;
}

/**
 * Generate the full grants.sql file
 */
function generateGrantsFile(manifest, functionSignatures) {
  const parts = [];
  
  // Header
  parts.push('-- Database GRANT Statements');
  parts.push('-- Generated from grants_manifest.json');
  parts.push(`-- Generated: ${new Date().toISOString()}`);
  parts.push('-- Schema: public');
  parts.push('--');
  parts.push('-- This file is generated. Do not edit manually.');
  parts.push('-- To modify grants: update grants_manifest.json and run:');
  parts.push('--   node scripts/database/generate-grants-from-manifest.js');
  parts.push('');

  // Tables
  const tableGrants = generateTableGrants(manifest);
  if (tableGrants.length > 0) {
    parts.push('-- Table Grants');
    parts.push(`-- Total: ${tableGrants.length}`);
    parts.push('');
    parts.push(...tableGrants);
    parts.push('');
  }

  // Sequences
  const sequenceGrants = generateSequenceGrants(manifest);
  if (sequenceGrants.length > 0) {
    parts.push('-- Sequence Grants');
    parts.push(`-- Total: ${sequenceGrants.length}`);
    parts.push('');
    parts.push(...sequenceGrants);
    parts.push('');
  }

  // Views
  const viewGrants = generateViewGrants(manifest);
  if (viewGrants.length > 0) {
    parts.push('-- View Grants');
    parts.push(`-- Total: ${viewGrants.length}`);
    parts.push('');
    parts.push(...viewGrants);
    parts.push('');
  }

  // Functions
  const functionGrants = generateFunctionGrants(manifest, functionSignatures);
  if (functionGrants.length > 0) {
    parts.push('-- Function Grants');
    parts.push(`-- Total: ${functionGrants.length}`);
    parts.push('');
    parts.push(...functionGrants);
    parts.push('');
  }

  return parts.join('\n');
}

/**
 * Main function
 */
function main() {
  const args = process.argv.slice(2);
  const validateOnly = args.includes('--validate');

  console.log('📋 Generating grants from manifest...\n');

  // Load manifest
  const manifest = loadManifest();
  console.log(`✅ Loaded manifest: ${MANIFEST_FILE}`);

  // Get app-owned function signatures
  const functionSignatures = getAppFunctionSignatures();
  console.log(`✅ Found ${functionSignatures.size} app functions in ${FUNCTIONS_DIR}`);
  
  // Count overloaded functions
  const overloadedCount = Array.from(functionSignatures.values()).filter(sigs => sigs.length > 1).length;
  if (overloadedCount > 0) {
    console.log(`   (${overloadedCount} overloaded functions will use signature-specific grants)`);
  }

  // Get app-owned table names
  const appTableNames = getAppTableNames();
  console.log(`✅ Found ${appTableNames.size} app tables in ${SCHEMAS_DIR}`);

  // Validate manifest tables exist
  const manifestTables = Object.keys(manifest.tables || {});
  for (const tableName of manifestTables) {
    if (!appTableNames.has(tableName)) {
      console.warn(`⚠️  Warning: Table "${tableName}" in manifest not found in ${SCHEMAS_DIR}`);
    }
  }

  // Generate grants
  const content = generateGrantsFile(manifest, functionSignatures);
  const lines = content.split('\n');

  // Validate no duplicates
  const validationErrors = validateNoDuplicates(lines);
  if (validationErrors.length > 0) {
    console.error('\n❌ Validation failed: duplicate privileges detected\n');
    for (const error of validationErrors) {
      console.error(`  ${error}`);
    }
    process.exit(1);
  }

  console.log('✅ Validation passed: no duplicate privileges');

  if (validateOnly) {
    console.log('\n✨ Validation complete (no file written)');
    return;
  }

  // Write to file
  fs.writeFileSync(GRANTS_FILE, content, 'utf8');
  
  const lineCount = lines.filter(l => l.trim() && !l.trim().startsWith('--')).length;
  console.log(`\n✅ Generated: ${GRANTS_FILE}`);
  console.log(`📊 Total grant statements: ${lineCount}`);
  console.log(`📏 Total lines: ${lines.length}`);
  
  const oldSize = fs.existsSync(GRANTS_FILE) ? fs.statSync(GRANTS_FILE).size : 0;
  const newSize = Buffer.byteLength(content, 'utf8');
  if (oldSize > 0) {
    const reduction = ((oldSize - newSize) / oldSize * 100).toFixed(1);
    console.log(`📉 Size reduction: ${reduction}%`);
  }

  console.log('\n✨ Successfully generated grants.sql from manifest!');
}

// Run the script
if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

module.exports = { 
  loadManifest,
  getAppFunctionNames,
  getAppFunctionSignatures,
  generateGrantsFile,
  validateNoDuplicates
};
