#!/usr/bin/env node

/**
 * Master script to fetch all database artifacts from Supabase
 *
 * This script:
 * 1. Clears all data from the database folders (including nested directories)
 * 2. Runs all fetch scripts to get fresh data
 * 3. Removes app/database/triggers/functions/ if present so trigger function bodies
 *    live only in app/database/functions/ (single source of truth). fetch-triggers.js
 *    writes only trigger DDL (*_triggers.sql); if it or another tool ever wrote
 *    *_trigger_function.sql under triggers/functions/, this step prevents drift.
 *
 * Usage:
 *   node scripts/database/fetch-all.js
 *
 * Environment variables required (in root .env file):
 *   SUPABASE_URL - Your Supabase project URL
 *   SUPABASE_DB_PASSWORD - Your Supabase database password (or use SUPABASE_DB_URL)
 *   SUPABASE_DB_URL - Full PostgreSQL connection string (alternative to URL + password)
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DATABASE_BASE_DIR = path.join(__dirname, '..', '..', 'app', 'database');
const FOLDERS = [
  'schemas',
  'functions',
  'indexes',
  'rls_policies',
  'grants',
  'views',
  'triggers',
  'foreign_keys',
  'types'
];

// Scripts to run (in order)
const SCRIPTS = [
  'fetch-schemas.js',
  'fetch-functions.js',
  'fetch-indexes.js',
  'fetch-rls-policies.js',
  'fetch-views.js',
  'fetch-triggers.js',
  'fetch-foreign-keys.js',
  'fetch-types.js',
  'fetch-grants.js'
];

/**
 * Clear all files from a directory (recursively)
 */
function clearDirectory(dirPath) {
  if (!fs.existsSync(dirPath)) {
    return 0;
  }

  function clearRecursive(currentPath) {
    let clearedCount = 0;
    const files = fs.readdirSync(currentPath);

    for (const file of files) {
      const filePath = path.join(currentPath, file);
      const stat = fs.statSync(filePath);

      if (stat.isDirectory()) {
        // Recursively clear subdirectories
        clearedCount += clearRecursive(filePath);
        // Remove empty subdirectory
        try {
          fs.rmdirSync(filePath);
        } catch (e) {
          // Directory might not be empty, that's okay
        }
      } else {
        fs.unlinkSync(filePath);
        clearedCount++;
      }
    }

    return clearedCount;
  }

  return clearRecursive(dirPath);
}

/**
 * Clear all database folders
 */
function clearAllFolders() {
  console.log('🧹 Clearing existing database files...\n');

  let totalCleared = 0;

  for (const folder of FOLDERS) {
    const folderPath = path.join(DATABASE_BASE_DIR, folder);
    const cleared = clearDirectory(folderPath);
    
    if (cleared > 0) {
      console.log(`   ✅ Cleared ${cleared} file(s) from ${folder}/`);
      totalCleared += cleared;
    } else {
      console.log(`   ℹ️  No files to clear in ${folder}/`);
    }
  }

  console.log(`\n✨ Cleared ${totalCleared} total file(s)\n`);
}

/**
 * Remove trigger function duplicate layer so it never persists after fetch.
 * Canonical home for trigger function definitions is app/database/functions/.
 */
function removeTriggerFunctionDuplicates() {
  const triggersFunctionsDir = path.join(DATABASE_BASE_DIR, 'triggers', 'functions');
  if (!fs.existsSync(triggersFunctionsDir)) {
    return;
  }
  const files = fs.readdirSync(triggersFunctionsDir);
  for (const file of files) {
    const filePath = path.join(triggersFunctionsDir, file);
    if (fs.statSync(filePath).isFile()) {
      fs.unlinkSync(filePath);
    }
  }
  try {
    fs.rmdirSync(triggersFunctionsDir);
  } catch (e) {
    // ignore if not empty or other error
  }
  console.log('   ✅ Removed app/database/triggers/functions/ (trigger bodies live in app/database/functions/)');
}

/**
 * Run a fetch script
 */
function runScript(scriptName) {
  const scriptPath = path.join(__dirname, scriptName);
  
  if (!fs.existsSync(scriptPath)) {
    console.error(`❌ Script not found: ${scriptPath}`);
    return false;
  }

  console.log(`\n${'='.repeat(60)}`);
  console.log(`📥 Running: ${scriptName}`);
  console.log('='.repeat(60));

  try {
    execSync(`node ${scriptPath}`, {
      stdio: 'inherit',
      cwd: path.join(__dirname, '..', '..')
    });
    console.log(`✅ Completed: ${scriptName}\n`);
    return true;
  } catch (error) {
    console.error(`❌ Failed: ${scriptName}`);
    console.error(`   Error: ${error.message}\n`);
    return false;
  }
}

/**
 * Main function
 */
async function main() {
  console.log('🚀 Starting database fetch process...\n');
  console.log('📋 Will fetch:');
  SCRIPTS.forEach(script => {
    console.log(`   - ${script}`);
  });
  console.log('');

  // Step 1: Clear all folders (including nested directories)
  clearAllFolders();

  // Step 2: Run all scripts
  console.log('📥 Fetching fresh data from Supabase...\n');

  const results = {
    success: [],
    failed: []
  };

  for (const script of SCRIPTS) {
    const success = runScript(script);
    if (success) {
      results.success.push(script);
    } else {
      results.failed.push(script);
    }
  }

  // Summary
  console.log('\n' + '='.repeat(60));
  console.log('📊 Summary');
  console.log('='.repeat(60));
  console.log(`✅ Successfully fetched: ${results.success.length} script(s)`);
  
  if (results.failed.length > 0) {
    console.log(`❌ Failed: ${results.failed.length} script(s)`);
    results.failed.forEach(script => {
      console.log(`   - ${script}`);
    });
    console.log('\n⚠️  Some scripts failed. Check the errors above.');
    process.exit(1);
  }

  // Step 3: Enforce single source of truth for trigger function bodies (no duplicates under triggers/functions/)
  console.log('\n🧹 Enforcing canonical trigger function location...');
  removeTriggerFunctionDuplicates();

  console.log('\n✨ All database artifacts fetched successfully!');
  console.log(`📂 Files saved to: ${DATABASE_BASE_DIR}`);
}

// Run the script
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

module.exports = { main };

