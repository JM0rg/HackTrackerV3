#!/usr/bin/env node

/**
 * Script to fetch database schemas from Supabase and save them to individual files
 * 
 * Usage:
 *   node scripts/fetch-schemas.js
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
const DATABASE_DIR = path.join(__dirname, '..', '..', 'app', 'database', 'schemas');
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
  
  // Try the newer Supabase connection format first (connection pooling)
  // Format: postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[region].pooler.supabase.com:5432/postgres
  // But we don't have the region, so we'll try the old format and suggest using SUPABASE_DB_URL
  
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
 * Get CREATE TABLE statement for a table
 */
async function getTableSchema(client, tableName) {
  // Get column information
  const columnsQuery = `
    SELECT 
      column_name,
      data_type,
      character_maximum_length,
      is_nullable,
      column_default,
      udt_name,
      udt_schema,
      domain_name
    FROM information_schema.columns
    WHERE table_schema = $1 AND table_name = $2
    ORDER BY ordinal_position;
  `;

  const columns = await client.query(columnsQuery, [SCHEMA_NAME, tableName]);

  // Get constraints (primary keys, foreign keys, unique, check)
  const constraintsQuery = `
    SELECT
      tc.constraint_name,
      tc.constraint_type,
      kcu.column_name,
      ccu.table_name AS foreign_table_name,
      ccu.column_name AS foreign_column_name,
      cc.check_clause,
      rc.update_rule,
      rc.delete_rule
    FROM information_schema.table_constraints AS tc
    LEFT JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    LEFT JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    LEFT JOIN information_schema.check_constraints AS cc
      ON cc.constraint_name = tc.constraint_name
      AND cc.constraint_schema = tc.table_schema
    LEFT JOIN information_schema.referential_constraints AS rc
      ON rc.constraint_name = tc.constraint_name
      AND rc.constraint_schema = tc.table_schema
    WHERE tc.table_schema = $1 AND tc.table_name = $2
    ORDER BY tc.constraint_type, tc.constraint_name, kcu.ordinal_position;
  `;

  const constraints = await client.query(constraintsQuery, [SCHEMA_NAME, tableName]);

  // Get indexes
  const indexesQuery = `
    SELECT
      indexname,
      indexdef
    FROM pg_indexes
    WHERE schemaname = $1 AND tablename = $2
    AND indexname NOT LIKE '%_pkey'
    ORDER BY indexname;
  `;

  const indexes = await client.query(indexesQuery, [SCHEMA_NAME, tableName]);

  // Get triggers
  const triggersQuery = `
    SELECT
      trigger_name,
      action_timing,
      event_manipulation,
      action_statement
    FROM information_schema.triggers
    WHERE trigger_schema = $1 AND trigger_name LIKE '%' || $2 || '%'
    ORDER BY trigger_name;
  `;

  const triggers = await client.query(triggersQuery, [SCHEMA_NAME, tableName]);

  // Build CREATE TABLE statement
  let sql = `-- Table: ${SCHEMA_NAME}.${tableName}\n`;
  sql += `-- Generated: ${new Date().toISOString()}\n\n`;
  sql += `CREATE TABLE ${SCHEMA_NAME}.${tableName} (\n`;

  // Add columns
  const columnDefs = columns.rows.map(col => {
    let def = `  ${col.column_name} `;

    // Map data types
    let dataType = col.data_type;
    if (col.data_type === 'USER-DEFINED' && col.udt_name) {
      dataType = col.udt_schema && col.udt_schema !== 'public'
        ? `${col.udt_schema}.${col.udt_name}`
        : col.udt_name;
    } else if (col.udt_name === 'text') {
      dataType = 'text';
    } else if (col.udt_name === 'varchar') {
      dataType = col.character_maximum_length 
        ? `varchar(${col.character_maximum_length})`
        : 'varchar';
    } else if (col.udt_name === 'int4') {
      dataType = 'integer';
    } else if (col.udt_name === 'int8') {
      dataType = 'bigint';
    } else if (col.udt_name === 'float8') {
      dataType = 'double precision';
    } else if (col.udt_name === 'bool') {
      dataType = 'boolean';
    } else if (col.udt_name === 'timestamp') {
      dataType = col.data_type === 'timestamp with time zone' 
        ? 'timestamp with time zone'
        : 'timestamp';
    } else if (col.udt_name === 'jsonb') {
      dataType = 'jsonb';
    } else {
      dataType = col.data_type;
    }

    def += dataType;

    // Add NOT NULL
    if (col.is_nullable === 'NO') {
      def += ' NOT NULL';
    }

    // Add default value
    if (col.column_default) {
      // Clean up default value (remove ::type casts for readability)
      let defaultValue = col.column_default;
      defaultValue = defaultValue.replace(/::\w+(?:\[\])?/g, '');
      def += ` DEFAULT ${defaultValue}`;
    }

    return def;
  });

  sql += columnDefs.join(',\n');

  // Add primary key constraint (handle composite keys)
  const primaryKeys = constraints.rows.filter(c => c.constraint_type === 'PRIMARY KEY');
  if (primaryKeys.length > 0) {
    const pkColumns = Array.from(
      new Set(
        primaryKeys
          .map(pk => pk.column_name)
          .filter(Boolean)
      )
    ).join(', ');
    sql += `,\n  CONSTRAINT ${primaryKeys[0].constraint_name} PRIMARY KEY (${pkColumns})`;
  }

  // Add unique constraints (handle composite keys)
  const uniqueConstraints = constraints.rows.filter(c => c.constraint_type === 'UNIQUE');
  const uniqueGroups = {};
  uniqueConstraints.forEach(uc => {
    if (!uniqueGroups[uc.constraint_name]) {
      uniqueGroups[uc.constraint_name] = [];
    }
    // Deduplicate columns (in case query returns duplicates)
    if (!uniqueGroups[uc.constraint_name].includes(uc.column_name)) {
    uniqueGroups[uc.constraint_name].push(uc.column_name);
    }
  });
  Object.entries(uniqueGroups).forEach(([constraintName, columns]) => {
    sql += `,\n  CONSTRAINT ${constraintName} UNIQUE (${columns.join(', ')})`;
  });

  // Add check constraints
  const checkConstraints = constraints.rows.filter(c => c.constraint_type === 'CHECK');
  const seenCheckConstraintNames = new Set();
  checkConstraints.forEach(cc => {
    if (seenCheckConstraintNames.has(cc.constraint_name)) {
      return;
    }

    // Skip generated not-null checks; they are already represented in column defs.
    if (
      /_not_null$/i.test(cc.constraint_name) ||
      /^\d+_\d+_\d+_not_null$/i.test(cc.constraint_name) ||
      /\bis not null\b/i.test(cc.check_clause || '')
    ) {
      return;
    }

    seenCheckConstraintNames.add(cc.constraint_name);
    sql += `,\n  CONSTRAINT ${cc.constraint_name} CHECK (${cc.check_clause})`;
  });

  // Add foreign key constraints using pg_constraint for accurate cross-schema FK info (L25)
  // Query pg_constraint directly to handle auth.users and other cross-schema references
  const fkQuery = `
    SELECT
      con.conname AS constraint_name,
      att.attname AS column_name,
      ref_ns.nspname AS foreign_schema,
      ref_class.relname AS foreign_table,
      ref_att.attname AS foreign_column,
      CASE con.confupdtype
        WHEN 'a' THEN 'NO ACTION'
        WHEN 'r' THEN 'RESTRICT'
        WHEN 'c' THEN 'CASCADE'
        WHEN 'n' THEN 'SET NULL'
        WHEN 'd' THEN 'SET DEFAULT'
      END AS update_rule,
      CASE con.confdeltype
        WHEN 'a' THEN 'NO ACTION'
        WHEN 'r' THEN 'RESTRICT'
        WHEN 'c' THEN 'CASCADE'
        WHEN 'n' THEN 'SET NULL'
        WHEN 'd' THEN 'SET DEFAULT'
      END AS delete_rule
    FROM pg_constraint con
    JOIN pg_attribute att ON att.attnum = ANY(con.conkey) AND att.attrelid = con.conrelid
    JOIN pg_class ref_class ON ref_class.oid = con.confrelid
    JOIN pg_namespace ref_ns ON ref_ns.oid = ref_class.relnamespace
    JOIN pg_attribute ref_att ON ref_att.attnum = ANY(con.confkey) AND ref_att.attrelid = con.confrelid
    WHERE con.contype = 'f'
      AND con.conrelid = (
        SELECT oid FROM pg_class WHERE relname = $1 AND relnamespace = (
          SELECT oid FROM pg_namespace WHERE nspname = $2
        )
      )
    ORDER BY con.conname, att.attnum;
  `;
  
  const pgForeignKeys = await client.query(fkQuery, [tableName, SCHEMA_NAME]);
  const fkGroups = {};
  
  pgForeignKeys.rows.forEach(fk => {
    if (!fkGroups[fk.constraint_name]) {
      fkGroups[fk.constraint_name] = {
        columns: [],
        foreignSchema: fk.foreign_schema,
        foreignTable: fk.foreign_table,
        foreignColumns: [],
        updateRule: fk.update_rule,
        deleteRule: fk.delete_rule
      };
    }
    
    if (fk.column_name && !fkGroups[fk.constraint_name].columns.includes(fk.column_name)) {
      fkGroups[fk.constraint_name].columns.push(fk.column_name);
    }
    
    if (fk.foreign_column && !fkGroups[fk.constraint_name].foreignColumns.includes(fk.foreign_column)) {
      fkGroups[fk.constraint_name].foreignColumns.push(fk.foreign_column);
    }
  });

  Object.entries(fkGroups).forEach(([constraintName, fk]) => {
    sql += `,\n  CONSTRAINT ${constraintName} FOREIGN KEY (${fk.columns.join(', ')}) `;
    // Use correct schema prefix (handles auth.users and other cross-schema FKs)
    const foreignRef = `${fk.foreignSchema}.${fk.foreignTable}`;
    sql += `REFERENCES ${foreignRef} (${fk.foreignColumns.join(', ')})`;
    // PostgreSQL only supports ON DELETE, not ON UPDATE
    if (fk.deleteRule && fk.deleteRule !== 'NO ACTION') {
      sql += ` ON DELETE ${fk.deleteRule}`;
    }
  });

  sql += '\n);\n';

  // Add indexes
  if (indexes.rows.length > 0) {
    sql += '\n';
    indexes.rows.forEach(idx => {
      sql += `\n${idx.indexdef};\n`;
    });
  }

  // Add triggers
  if (triggers.rows.length > 0) {
    sql += '\n';
    triggers.rows.forEach(trigger => {
      sql += `\nCREATE TRIGGER ${trigger.trigger_name}\n`;
      sql += `  ${trigger.action_timing} ${trigger.event_manipulation}\n`;
      sql += `  ON ${SCHEMA_NAME}.${tableName}\n`;
      sql += `  FOR EACH ROW\n`;
      sql += `  EXECUTE FUNCTION ${trigger.action_statement.replace(/^EXECUTE FUNCTION /i, '')};\n`;
    });
  }

  return sql;
}

/**
 * Get all tables in the schema
 */
async function getTables(client) {
  const query = `
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = $1
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;
  `;

  const result = await client.query(query, [SCHEMA_NAME]);
  return result.rows.map(row => row.table_name);
}

/**
 * Main function
 */
async function main() {
  console.log('🔍 Fetching database schemas from Supabase...\n');

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

    // Get all tables
    const tables = await getTables(client);
    console.log(`📋 Found ${tables.length} table(s): ${tables.join(', ')}\n`);

    // Fetch schema for each table
    for (const tableName of tables) {
      console.log(`📝 Fetching schema for: ${tableName}...`);
      
      const schema = await getTableSchema(client, tableName);
      const filePath = path.join(DATABASE_DIR, `create_${tableName}_table.sql`);
      
      // Overwrite existing file if it exists
      const fileExists = fs.existsSync(filePath);
      fs.writeFileSync(filePath, schema, 'utf8');
      
      if (fileExists) {
        console.log(`   ✅ Updated: ${filePath}`);
      } else {
        console.log(`   ✅ Created: ${filePath}`);
      }
    }

    console.log(`\n✨ Successfully fetched ${tables.length} table schema(s)!`);
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

