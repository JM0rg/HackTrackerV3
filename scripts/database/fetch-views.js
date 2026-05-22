#!/usr/bin/env node

/**
 * Script to fetch views and materialized views from Supabase and save them to individual files
 * 
 * Usage:
 *   node scripts/fetch-views.js
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
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'views');
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
 * Get all views (regular and materialized)
 */
async function getViews(client) {
  // Regular views
  const viewsQuery = `
    SELECT
      table_name,
      view_definition
    FROM information_schema.views
    WHERE table_schema = $1
    ORDER BY table_name;
  `;

  const views = await client.query(viewsQuery, [SCHEMA_NAME]);

  // Materialized views
  const matViewsQuery = `
    SELECT
      c.relname AS table_name,
      pg_get_viewdef(c.oid, true) AS view_definition
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = $1
    AND c.relkind = 'm'
    ORDER BY c.relname;
  `;

  const matViews = await client.query(matViewsQuery, [SCHEMA_NAME]);

  return {
    regular: views.rows.map(row => ({ ...row, isMaterialized: false })),
    materialized: matViews.rows.map(row => ({ ...row, isMaterialized: true }))
  };
}

/**
 * Sanitize view name for filename
 */
function sanitizeFileName(name) {
  return name.replace(/[^a-zA-Z0-9_]/g, '_');
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching views and materialized views from Supabase...\n');

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

    // Get all views
    const { regular, materialized } = await getViews(client);
    const allViews = [...regular, ...materialized];
    
    console.log(`📋 Found ${regular.length} regular view(s)`);
    console.log(`📋 Found ${materialized.length} materialized view(s)\n`);

    if (allViews.length === 0) {
      console.log('ℹ️  No views found in the database.');
      return;
    }

    // Save each view to a file
    for (const view of allViews) {
      console.log(`📝 Fetching ${view.isMaterialized ? 'materialized ' : ''}view: ${view.table_name}...`);
      
      let sql = `-- ${view.isMaterialized ? 'Materialized ' : ''}View: ${SCHEMA_NAME}.${view.table_name}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n\n`;
      
      if (view.isMaterialized) {
        sql += `CREATE MATERIALIZED VIEW ${SCHEMA_NAME}.${view.table_name} AS\n`;
      } else {
        sql += `CREATE VIEW ${SCHEMA_NAME}.${view.table_name} AS\n`;
      }
      
      sql += view.view_definition;
      
      if (!view.view_definition.trim().endsWith(';')) {
        sql += ';';
      }
      sql += '\n';
      
      const sanitizedName = sanitizeFileName(view.table_name);
      const prefix = view.isMaterialized ? 'mat_' : '';
      const filePath = path.join(DATABASE_DIR, `create_${prefix}${sanitizedName}_view.sql`);
      
      const fileExists = fs.existsSync(filePath);
      fs.writeFileSync(filePath, sql, 'utf8');
      
      if (fileExists) {
        console.log(`   ✅ Updated: ${filePath}`);
      } else {
        console.log(`   ✅ Created: ${filePath}`);
      }
    }

    console.log(`\n✨ Successfully fetched ${allViews.length} view(s)!`);
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

