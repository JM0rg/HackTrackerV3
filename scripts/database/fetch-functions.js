#!/usr/bin/env node

/**
 * Script to fetch database functions from Supabase and save them to individual files
 * 
 * Usage:
 *   node scripts/fetch-functions.js
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
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'functions');
const SCHEMA_NAME = 'public'; // Default schema

/**
 * Get database connection string from environment variables
 * (Reused from fetch-schemas.js)
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
 * Get all functions in the schema
 */
async function getFunctions(client) {
  const query = `
    SELECT 
      p.proname AS function_name,
      pg_get_function_identity_arguments(p.oid) AS arguments,
      pg_get_functiondef(p.oid) AS function_definition,
      CASE 
        WHEN p.prokind = 'a' THEN 'aggregate'
        WHEN p.prokind = 'w' THEN 'window'
        WHEN p.prokind = 'p' THEN 'procedure'
        WHEN p.prokind = 'f' THEN 'function'
        ELSE 'unknown'
      END AS function_type,
      l.lanname AS language,
      p.provolatile AS volatility,
      CASE 
        WHEN p.provolatile = 'i' THEN 'IMMUTABLE'
        WHEN p.provolatile = 's' THEN 'STABLE'
        WHEN p.provolatile = 'v' THEN 'VOLATILE'
        ELSE 'VOLATILE'
      END AS volatility_text
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    LEFT JOIN pg_language l ON p.prolang = l.oid
    WHERE n.nspname = $1
    AND p.prokind IN ('f', 'p') -- Only functions and procedures (exclude aggregates/windows)
    AND p.proname NOT LIKE 'gbt_%' -- Exclude btree_gist extension functions
    AND p.proname NOT LIKE 'gbtreekey%' -- Exclude gbtreekey extension functions
    AND p.proname NOT LIKE '%_dist' -- Exclude distance operator functions (int2_dist, float8_dist, etc.)
    ORDER BY p.proname, pg_get_function_identity_arguments(p.oid);
  `;

  const result = await client.query(query, [SCHEMA_NAME]);
  return result.rows;
}

/**
 * Sanitize function name for filename
 */
function sanitizeFileName(name) {
  // Replace special characters with underscores
  return name.replace(/[^a-zA-Z0-9_]/g, '_');
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching database functions from Supabase...\n');

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

    // Get all functions
    const functions = await getFunctions(client);
    console.log(`📋 Found ${functions.length} function(s)\n`);

    if (functions.length === 0) {
      console.log('ℹ️  No functions found in the database.');
      return;
    }

    // Group functions by name (handle overloaded functions)
    const functionGroups = {};
    functions.forEach(func => {
      const key = func.function_name;
      if (!functionGroups[key]) {
        functionGroups[key] = [];
      }
      functionGroups[key].push(func);
    });

    // Fetch and save each function
    for (const [functionName, funcList] of Object.entries(functionGroups)) {
      console.log(`📝 Fetching function: ${functionName}...`);
      
      // If there's only one function with this name, save it directly
      // If there are multiple (overloaded), save them all in one file
      let sql = `-- Function: ${SCHEMA_NAME}.${functionName}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n`;
      
      if (funcList.length > 1) {
        sql += `-- Note: This function has ${funcList.length} overloaded versions\n`;
      }
      sql += '\n';

      funcList.forEach((func, index) => {
        if (funcList.length > 1) {
          sql += `-- Overload ${index + 1}: (${func.arguments || ''})\n`;
        }
        
        // Use the function definition from PostgreSQL
        sql += func.function_definition;
        
        if (!func.function_definition.trim().endsWith(';')) {
          sql += ';';
        }
        sql += '\n\n';
      });

      const sanitizedName = sanitizeFileName(functionName);
      const filePath = path.join(DATABASE_DIR, `${sanitizedName}_function.sql`);
      
      // Overwrite existing file if it exists
      const fileExists = fs.existsSync(filePath);
      fs.writeFileSync(filePath, sql, 'utf8');
      
      if (fileExists) {
        console.log(`   ✅ Updated: ${filePath}`);
      } else {
        console.log(`   ✅ Created: ${filePath}`);
      }
      
      if (funcList.length > 1) {
        console.log(`   ℹ️  Contains ${funcList.length} overloaded version(s)`);
      }
    }

    console.log(`\n✨ Successfully fetched ${functions.length} function(s)!`);
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

