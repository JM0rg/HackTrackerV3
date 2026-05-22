#!/usr/bin/env node

/**
 * Script to fetch foreign key relationships from Supabase and save to a summary file
 * 
 * Usage:
 *   node scripts/fetch-foreign-keys.js
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
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'foreign_keys');
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
      '4. Replace [YOUR-PASSWORD] with your actual database password'
    );
  }

  const urlMatch = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.co/);
  if (!urlMatch) {
    throw new Error(
      'Invalid SUPABASE_URL format. Expected: https://[PROJECT-REF].supabase.co\n' +
      'Alternatively, use SUPABASE_DB_URL with the full PostgreSQL connection string.'
    );
  }

  const projectRef = urlMatch[1];
  const connectionString = `postgresql://postgres:${encodeURIComponent(dbPassword)}@db.${projectRef}.supabase.co:5432/postgres`;
  
  return connectionString;
}

/**
 * Get all foreign key relationships
 */
async function getForeignKeys(client) {
  const query = `
    SELECT
      tc.table_name AS from_table,
      kcu.column_name AS from_column,
      ccu.table_schema AS to_table_schema,
      ccu.table_name AS to_table,
      ccu.column_name AS to_column,
      tc.constraint_name,
      rc.update_rule,
      rc.delete_rule
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    LEFT JOIN information_schema.referential_constraints AS rc
      ON rc.constraint_name = tc.constraint_name
      AND rc.constraint_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND tc.table_schema = $1
    ORDER BY tc.table_name, tc.constraint_name, kcu.ordinal_position;
  `;

  const result = await client.query(query, [SCHEMA_NAME]);
  return result.rows;
}

/**
 * Generate markdown documentation
 */
function generateMarkdown(foreignKeys) {
  let md = `# Foreign Key Relationships\n\n`;
  md += `Generated: ${new Date().toISOString()}\n\n`;
  md += `This document shows all foreign key relationships in the database, including cascade delete rules.\n\n`;
  md += `---\n\n`;

  // Group by from_table
  const grouped = {};
  foreignKeys.forEach(fk => {
    if (!grouped[fk.from_table]) {
      grouped[fk.from_table] = [];
    }
    grouped[fk.from_table].push(fk);
  });

  // Generate sections for each table
  Object.keys(grouped).sort().forEach(tableName => {
    md += `## ${tableName}\n\n`;
    
    const fks = grouped[tableName];
    const uniqueConstraints = {};
    
    // Group by constraint name (for composite keys)
    fks.forEach(fk => {
      if (!uniqueConstraints[fk.constraint_name]) {
        uniqueConstraints[fk.constraint_name] = {
          fromColumns: [],
          toTable: fk.to_table,
          toColumns: [],
          updateRule: fk.update_rule,
          deleteRule: fk.delete_rule
        };
      }
      uniqueConstraints[fk.constraint_name].fromColumns.push(fk.from_column);
      uniqueConstraints[fk.constraint_name].toColumns.push(fk.to_column);
    });

    Object.entries(uniqueConstraints).forEach(([constraintName, fk]) => {
      md += `**Constraint:** \`${constraintName}\`\n\n`;
      md += `- **From:** \`${tableName}.${fk.fromColumns.join(', ')}\`\n`;
      md += `- **To:** \`${fk.toTable}.${fk.toColumns.join(', ')}\`\n`;
      
      if (fk.updateRule && fk.updateRule !== 'NO ACTION') {
        md += `- **On Update:** ${fk.updateRule}\n`;
      }
      
      if (fk.deleteRule && fk.deleteRule !== 'NO ACTION') {
        md += `- **On Delete:** ${fk.deleteRule}\n`;
      } else {
        md += `- **On Delete:** RESTRICT (default)\n`;
      }
      
      md += `\n`;
    });
    
    md += `---\n\n`;
  });

  // Add cascade delete chain visualization
  md += `## Cascade Delete Chains\n\n`;
  md += `When a profile is deleted, the following cascade chain occurs:\n\n`;

  const cascadeChains = buildCascadeChains(foreignKeys);
  cascadeChains.forEach(chain => {
    md += `### ${chain.root}\n\n`;
    chain.paths.forEach(path => {
      md += `\`${path.join(' → ')}\`\n\n`;
    });
  });

  return md;
}

/**
 * Build cascade delete chains starting from profiles
 */
function buildCascadeChains(foreignKeys) {
  const chains = [];
  
  // Find all tables that reference profiles with CASCADE
  const profileReferences = foreignKeys.filter(fk => 
    fk.to_table === 'profiles' && fk.delete_rule === 'CASCADE'
  );

  profileReferences.forEach(ref => {
    const chain = {
      root: ref.from_table,
      paths: []
    };

    // Build cascade paths
    function buildPath(currentTable, path) {
      path.push(currentTable);
      
      // Find all tables that reference currentTable with CASCADE
      const nextRefs = foreignKeys.filter(fk => 
        fk.to_table === currentTable && fk.delete_rule === 'CASCADE'
      );

      if (nextRefs.length === 0) {
        chain.paths.push([...path]);
        return;
      }

      nextRefs.forEach(nextRef => {
        buildPath(nextRef.from_table, [...path]);
      });
    }

    buildPath(ref.from_table, ['profiles']);
    chains.push(chain);
  });

  return chains;
}

/**
 * Generate SQL summary
 */
function generateSQL(foreignKeys) {
  let sql = `-- Foreign Key Relationships Summary\n`;
  sql += `-- Generated: ${new Date().toISOString()}\n\n`;
  sql += `-- This file contains all foreign key relationships for reference\n\n`;

  // Group by from_table
  const grouped = {};
  foreignKeys.forEach(fk => {
    if (!grouped[fk.from_table]) {
      grouped[fk.from_table] = [];
    }
    grouped[fk.from_table].push(fk);
  });

  Object.keys(grouped).sort().forEach(tableName => {
    sql += `-- Foreign keys from ${tableName}\n`;
    
    const fks = grouped[tableName];
    const uniqueConstraints = {};
    
    fks.forEach(fk => {
      if (!uniqueConstraints[fk.constraint_name]) {
        uniqueConstraints[fk.constraint_name] = {
          fromColumns: [],
          toTable: fk.to_table,
          toColumns: [],
          updateRule: fk.update_rule,
          deleteRule: fk.delete_rule
        };
      }
      uniqueConstraints[fk.constraint_name].fromColumns.push(fk.from_column);
      uniqueConstraints[fk.constraint_name].toColumns.push(fk.to_column);
    });

    Object.entries(uniqueConstraints).forEach(([constraintName, fk]) => {
      sql += `-- Constraint: ${constraintName}\n`;
      sql += `--   ${tableName}.${fk.fromColumns.join(', ')} → ${fk.toTable}.${fk.toColumns.join(', ')}\n`;
      if (fk.deleteRule && fk.deleteRule !== 'NO ACTION') {
        sql += `--   ON DELETE: ${fk.deleteRule}\n`;
      }
      sql += `\n`;
    });
  });

  return sql;
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching foreign key relationships from Supabase...\n');

  // Ensure database directory exists
  if (!fs.existsSync(DATABASE_DIR)) {
    fs.mkdirSync(DATABASE_DIR, { recursive: true });
    console.log(`📁 Created directory: ${DATABASE_DIR}`);
  }

  // Get connection string
  let connectionString;
  try {
    connectionString = getConnectionString();
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

    // Get foreign keys
    const foreignKeys = await getForeignKeys(client);
    console.log(`📋 Found ${foreignKeys.length} foreign key relationship(s)\n`);

    // Generate markdown
    const markdown = generateMarkdown(foreignKeys);
    const mdPath = path.join(DATABASE_DIR, 'foreign_keys.md');
    fs.writeFileSync(mdPath, markdown, 'utf8');
    console.log(`✅ Created: ${mdPath}`);

    // Generate SQL summary
    const sql = generateSQL(foreignKeys);
    const sqlPath = path.join(DATABASE_DIR, 'foreign_keys.sql');
    fs.writeFileSync(sqlPath, sql, 'utf8');
    console.log(`✅ Created: ${sqlPath}`);

    console.log(`\n✨ Successfully fetched foreign key relationships!`);
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

module.exports = { main };

