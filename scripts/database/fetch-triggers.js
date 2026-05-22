#!/usr/bin/env node

/**
 * Script to fetch trigger DDL (CREATE TRIGGER statements) from Supabase and save them by table.
 * Trigger function bodies (CREATE OR REPLACE FUNCTION) live in app/database/functions/ and
 * are fetched via fetch-functions.js, not here. This script only writes *_triggers.sql files.
 *
 * Usage:
 *   node scripts/database/fetch-triggers.js
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
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'triggers');
const SCHEMA_NAME = 'public'; // Default schema

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
      'set SUPABASE_URL and SUPABASE_DB_PASSWORD.'
    );
  }

  const urlMatch = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.co/);
  if (!urlMatch) {
    throw new Error(
      'Invalid SUPABASE_URL format. Expected: https://[PROJECT-REF].supabase.co'
    );
  }

  const projectRef = urlMatch[1];
  const connectionString = `postgresql://postgres:${encodeURIComponent(dbPassword)}@db.${projectRef}.supabase.co:5432/postgres`;
  
  return connectionString;
}

/**
 * Get all triggers
 */
async function getTriggers(client) {
  const query = `
    SELECT
      t.tgname AS trigger_name,
      c.relname AS table_name,
      pg_get_triggerdef(t.oid, true) AS trigger_def
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE NOT t.tgisinternal
      AND n.nspname = $1
    ORDER BY c.relname, t.tgname;
  `;

  const result = await client.query(query, [SCHEMA_NAME]);
  return result.rows;
}

/**
 * Generate CREATE TRIGGER statement
 */
function generateTriggerSQL(trigger) {
  let sql = `-- Trigger: ${trigger.trigger_name}\n`;
  sql += `-- Table: ${SCHEMA_NAME}.${trigger.table_name}\n`;
  sql += `-- Generated: ${new Date().toISOString()}\n\n`;
  sql += `${trigger.trigger_def};\n`;
  return sql;
}

/**
 * Sanitize name for filename
 */
function sanitizeFileName(name) {
  return name.replace(/[^a-zA-Z0-9_]/g, '_');
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching triggers and trigger functions from Supabase...\n');

  // Ensure database directory exists
  if (!fs.existsSync(DATABASE_DIR)) {
    fs.mkdirSync(DATABASE_DIR, { recursive: true });
    console.log(`📁 Created directory: ${DATABASE_DIR}`);
  }

  // Get connection string
  let connectionString;
  try {
    connectionString = getConnectionString();
    
    if (!connectionString || connectionString.trim() === '') {
      throw new Error('Connection string is empty.');
    }
    
    const maskedConnection = connectionString.replace(/:([^:@]+)@/, ':***@');
    console.log(`🔗 Using connection: ${maskedConnection}\n`);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }

  const client = new Client({
    connectionString: connectionString,
    ssl: {
      rejectUnauthorized: false
    }
  });

  try {
    await client.connect();
    console.log('✅ Connected to database\n');

    // Get all triggers (trigger function bodies live in app/database/functions/, fetched via fetch-functions.js)
    const triggers = await getTriggers(client);
    console.log(`📋 Found ${triggers.length} trigger(s)\n`);

    if (triggers.length === 0) {
      console.log('ℹ️  No triggers found in the database.');
      return;
    }

    // Group triggers by table
    const triggersByTable = {};
    triggers.forEach(trigger => {
      if (!triggersByTable[trigger.table_name]) {
        triggersByTable[trigger.table_name] = [];
      }
      triggersByTable[trigger.table_name].push(trigger);
    });

    // Save triggers grouped by table
    for (const [tableName, tableTriggers] of Object.entries(triggersByTable)) {
      console.log(`📝 Fetching triggers for table: ${tableName}...`);
      
      let sql = `-- Triggers for table: ${SCHEMA_NAME}.${tableName}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n`;
      sql += `-- Total triggers: ${tableTriggers.length}\n\n`;
      
      tableTriggers.forEach(trigger => {
        sql += generateTriggerSQL(trigger);
        sql += '\n';
      });
      
      const sanitizedName = sanitizeFileName(tableName);
      const filePath = path.join(DATABASE_DIR, `${sanitizedName}_triggers.sql`);
      
      const fileExists = fs.existsSync(filePath);
      fs.writeFileSync(filePath, sql, 'utf8');
      
      if (fileExists) {
        console.log(`   ✅ Updated: ${filePath}`);
      } else {
        console.log(`   ✅ Created: ${filePath}`);
      }
    }

    console.log(`\n✨ Successfully fetched ${triggers.length} trigger(s)!`);
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

