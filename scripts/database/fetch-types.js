#!/usr/bin/env node

/**
 * Script to fetch custom types and enums from Supabase and save them to files
 * 
 * Usage:
 *   node scripts/fetch-types.js
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
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'types');
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
 * Get all custom types (enums and composite types)
 */
async function getTypes(client) {
  // Get enum types
  const enumQuery = `
    SELECT
      t.typname AS type_name,
      e.enumlabel AS enum_value,
      t.typtype AS type_type
    FROM pg_type t
    JOIN pg_enum e ON t.oid = e.enumtypid
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = $1
      AND t.typtype = 'e'
    ORDER BY t.typname, e.enumsortorder;
  `;

  const enumResult = await client.query(enumQuery, [SCHEMA_NAME]);

  // Get composite types
  const compositeQuery = `
    SELECT
      t.typname AS type_name,
      a.attname AS attribute_name,
      pg_catalog.format_type(a.atttypid, a.atttypmod) AS attribute_type,
      a.attnotnull AS not_null
    FROM pg_type t
    JOIN pg_class c ON c.reltype = t.oid
    JOIN pg_attribute a ON a.attrelid = c.oid
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = $1
      AND t.typtype = 'c'
      AND a.attnum > 0
      AND NOT a.attisdropped
    ORDER BY t.typname, a.attnum;
  `;

  const compositeResult = await client.query(compositeQuery, [SCHEMA_NAME]);

  // Get where types are used
  const usageQuery = `
    SELECT
      t.typname AS type_name,
      c.table_name,
      c.column_name,
      c.data_type
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    JOIN information_schema.columns c ON c.udt_name = t.typname
    WHERE n.nspname = $1
      AND (t.typtype = 'e' OR t.typtype = 'c')
      AND c.table_schema = $1
    ORDER BY t.typname, c.table_name, c.column_name;
  `;

  const usageResult = await client.query(usageQuery, [SCHEMA_NAME]);

  return {
    enums: enumResult.rows,
    composites: compositeResult.rows,
    usage: usageResult.rows
  };
}

/**
 * Generate CREATE TYPE statements
 */
function generateSQL(types) {
  let sql = `-- Custom Types and Enums\n`;
  sql += `-- Generated: ${new Date().toISOString()}\n\n`;

  // Group enums by type name
  const enumGroups = {};
  types.enums.forEach(enumRow => {
    if (!enumGroups[enumRow.type_name]) {
      enumGroups[enumRow.type_name] = [];
    }
    enumGroups[enumRow.type_name].push(enumRow.enum_value);
  });

  // Generate CREATE TYPE statements for enums
  if (Object.keys(enumGroups).length > 0) {
    sql += `-- Enum Types\n\n`;
    Object.entries(enumGroups).forEach(([typeName, values]) => {
      sql += `CREATE TYPE ${SCHEMA_NAME}.${typeName} AS ENUM (\n`;
      const valueList = values.map(v => `  '${v}'`).join(',\n');
      sql += valueList;
      sql += `\n);\n\n`;
    });
  }

  // Group composite types by type name
  const compositeGroups = {};
  types.composites.forEach(compRow => {
    if (!compositeGroups[compRow.type_name]) {
      compositeGroups[compRow.type_name] = [];
    }
    compositeGroups[compRow.type_name].push({
      name: compRow.attribute_name,
      type: compRow.attribute_type,
      notNull: compRow.not_null
    });
  });

  // Generate CREATE TYPE statements for composite types
  if (Object.keys(compositeGroups).length > 0) {
    sql += `-- Composite Types\n\n`;
    Object.entries(compositeGroups).forEach(([typeName, attributes]) => {
      sql += `CREATE TYPE ${SCHEMA_NAME}.${typeName} AS (\n`;
      const attrList = attributes.map(attr => {
        let def = `  ${attr.name} ${attr.type}`;
        if (attr.notNull) {
          def += ' NOT NULL';
        }
        return def;
      }).join(',\n');
      sql += attrList;
      sql += `\n);\n\n`;
    });
  }

  return sql;
}

/**
 * Generate markdown documentation
 */
function generateMarkdown(types) {
  let md = `# Custom Types and Enums\n\n`;
  md += `Generated: ${new Date().toISOString()}\n\n`;
  md += `This document lists all custom types (enums and composite types) defined in the database.\n\n`;
  md += `---\n\n`;

  // Group enums by type name
  const enumGroups = {};
  types.enums.forEach(enumRow => {
    if (!enumGroups[enumRow.type_name]) {
      enumGroups[enumRow.type_name] = [];
    }
    enumGroups[enumRow.type_name].push(enumRow.enum_value);
  });

  // Group usage by type name
  const usageGroups = {};
  types.usage.forEach(usageRow => {
    if (!usageGroups[usageRow.type_name]) {
      usageGroups[usageRow.type_name] = [];
    }
    usageGroups[usageRow.type_name].push({
      table: usageRow.table_name,
      column: usageRow.column_name
    });
  });

  // Document enums
  if (Object.keys(enumGroups).length > 0) {
    md += `## Enum Types\n\n`;
    Object.entries(enumGroups).forEach(([typeName, values]) => {
      md += `### ${typeName}\n\n`;
      md += `**Values:**\n`;
      values.forEach(value => {
        md += `- \`${value}\`\n`;
      });
      
      if (usageGroups[typeName]) {
        md += `\n**Used in:**\n`;
        usageGroups[typeName].forEach(usage => {
          md += `- \`${usage.table}.${usage.column}\`\n`;
        });
      }
      
      md += `\n---\n\n`;
    });
  }

  // Group composite types by type name
  const compositeGroups = {};
  types.composites.forEach(compRow => {
    if (!compositeGroups[compRow.type_name]) {
      compositeGroups[compRow.type_name] = [];
    }
    compositeGroups[compRow.type_name].push({
      name: compRow.attribute_name,
      type: compRow.attribute_type,
      notNull: compRow.not_null
    });
  });

  // Document composite types
  if (Object.keys(compositeGroups).length > 0) {
    md += `## Composite Types\n\n`;
    Object.entries(compositeGroups).forEach(([typeName, attributes]) => {
      md += `### ${typeName}\n\n`;
      md += `**Attributes:**\n\n`;
      md += `| Name | Type | Nullable |\n`;
      md += `|------|------|----------|\n`;
      attributes.forEach(attr => {
        md += `| \`${attr.name}\` | \`${attr.type}\` | ${attr.notNull ? 'NO' : 'YES'} |\n`;
      });
      
      if (usageGroups[typeName]) {
        md += `\n**Used in:**\n`;
        usageGroups[typeName].forEach(usage => {
          md += `- \`${usage.table}.${usage.column}\`\n`;
        });
      }
      
      md += `\n---\n\n`;
    });
  }

  if (Object.keys(enumGroups).length === 0 && Object.keys(compositeGroups).length === 0) {
    md += `No custom types found in the database.\n\n`;
  }

  return md;
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching custom types and enums from Supabase...\n');

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

    // Get types
    const types = await getTypes(client);
    const enumCount = Object.keys(
      types.enums.reduce((acc, e) => {
        acc[e.type_name] = true;
        return acc;
      }, {})
    ).length;
    const compositeCount = Object.keys(
      types.composites.reduce((acc, c) => {
        acc[c.type_name] = true;
        return acc;
      }, {})
    ).length;

    console.log(`📋 Found ${enumCount} enum type(s) and ${compositeCount} composite type(s)\n`);

    // Generate SQL
    const sql = generateSQL(types);
    const sqlPath = path.join(DATABASE_DIR, 'types.sql');
    fs.writeFileSync(sqlPath, sql, 'utf8');
    console.log(`✅ Created: ${sqlPath}`);

    // Generate markdown
    const markdown = generateMarkdown(types);
    const mdPath = path.join(DATABASE_DIR, 'types.md');
    fs.writeFileSync(mdPath, markdown, 'utf8');
    console.log(`✅ Created: ${mdPath}`);

    console.log(`\n✨ Successfully fetched custom types!`);
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

