#!/usr/bin/env node

/**
 * Script to fetch all database indexes from Supabase and save them to a file
 * 
 * Usage:
 *   node scripts/fetch-indexes.js
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
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'indexes');
const INDEXES_FILE = path.join(DATABASE_DIR, 'indexes.sql');
const SCHEMA_NAME = 'public'; // Default schema

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
  // URL format: https://[PROJECT-REF].supabase.co
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
  
  // Try old format (may not work for newer Supabase projects)
  const connectionString = `postgresql://postgres:${encodeURIComponent(dbPassword)}@db.${projectRef}.supabase.co:5432/postgres`;
  
  return connectionString;
}

/**
 * Get all indexes from the database
 */
async function getIndexes(client) {
  const query = `
    SELECT
      schemaname,
      tablename,
      indexname,
      indexdef
    FROM pg_indexes
    WHERE schemaname = $1
    ORDER BY tablename, indexname;
  `;

  const result = await client.query(query, [SCHEMA_NAME]);
  return result.rows;
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching database indexes from Supabase...\n');

  // Ensure database directory exists
  if (!fs.existsSync(DATABASE_DIR)) {
    fs.mkdirSync(DATABASE_DIR, { recursive: true });
    console.log(`📁 Created directory: ${DATABASE_DIR}`);
  }

  // Get connection string with validation
  let connectionString;
  try {
    connectionString = getConnectionString();
    
    // Debug: Check if connection string was retrieved (without exposing password)
    if (!connectionString || connectionString.trim() === '') {
      throw new Error(
        'Connection string is empty.\n' +
        'Please check your .env file contains SUPABASE_DB_URL or both SUPABASE_URL and SUPABASE_DB_PASSWORD.'
      );
    }
    
    // Validate it's a valid URL format
    if (!connectionString.startsWith('postgresql://') && !connectionString.startsWith('postgres://')) {
      throw new Error(
        `Connection string must start with postgresql:// or postgres://\n` +
        `Got: ${connectionString.substring(0, 50)}...`
      );
    }
    
    // Debug: Show connection string (masked password)
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

    // Get all indexes
    const indexes = await getIndexes(client);
    console.log(`📋 Found ${indexes.length} index(es)\n`);

    if (indexes.length === 0) {
      console.log('⚠️  No indexes found in the database.');
      return;
    }

    // Group indexes by table for better organization
    const indexesByTable = {};
    indexes.forEach(idx => {
      if (!indexesByTable[idx.tablename]) {
        indexesByTable[idx.tablename] = [];
      }
      indexesByTable[idx.tablename].push(idx);
    });

    // Build SQL file content
    let sql = `-- Database Indexes\n`;
    sql += `-- Generated: ${new Date().toISOString()}\n`;
    sql += `-- Schema: ${SCHEMA_NAME}\n\n`;
    sql += `-- Total indexes: ${indexes.length}\n\n`;

    // Add indexes grouped by table
    Object.keys(indexesByTable).sort().forEach(tableName => {
      const tableIndexes = indexesByTable[tableName];
      sql += `-- Indexes for table: ${SCHEMA_NAME}.${tableName}\n`;
      sql += `-- Count: ${tableIndexes.length}\n\n`;
      
      tableIndexes.forEach(idx => {
        // Skip primary key indexes (they're created automatically with PRIMARY KEY constraint)
        if (idx.indexname.endsWith('_pkey')) {
          sql += `-- Primary key index (auto-created): ${idx.indexname}\n`;
          sql += `-- ${idx.indexdef}\n\n`;
        } else {
          sql += `${idx.indexdef};\n\n`;
        }
      });
      
      sql += '\n';
    });

    // Write to file
    const fileExists = fs.existsSync(INDEXES_FILE);
    fs.writeFileSync(INDEXES_FILE, sql, 'utf8');

    if (fileExists) {
      console.log(`✅ Updated: ${INDEXES_FILE}`);
    } else {
      console.log(`✅ Created: ${INDEXES_FILE}`);
    }

    console.log(`\n✨ Successfully fetched ${indexes.length} index(es)!`);
    console.log(`📂 File saved to: ${INDEXES_FILE}`);
    console.log(`\n📊 Summary by table:`);
    Object.keys(indexesByTable).sort().forEach(tableName => {
      const count = indexesByTable[tableName].length;
      console.log(`   ${tableName}: ${count} index(es)`);
    });

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

