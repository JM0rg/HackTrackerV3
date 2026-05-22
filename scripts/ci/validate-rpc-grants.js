#!/usr/bin/env node

/**
 * Validates GRANT integrity in app/database/grants/grants.sql.
 *
 * 1. Grant completeness (fail-closed): every app function in
 *    app/database/functions/*_function.sql MUST have at least one
 *    `GRANT ... ON FUNCTION public.<name> ...` line. `DROP FUNCTION`
 *    discards all privileges, so a migration that drops+recreates a
 *    function and forgets to re-GRANT it produces a function that exists
 *    but is uncallable by the client. `npm run fetch-all` then bakes that
 *    omission into grants.sql. This check catches exactly that regression.
 *
 * 2. No duplicate privileges in a single GRANT statement (defensive
 *    against generator drift).
 *
 * NOTE: this intentionally does NOT police `TO anon`. This project's
 * Supabase idiom is SECURITY DEFINER RPCs granted to anon that enforce
 * auth internally via auth.uid() — the live grants.sql does this for ~30
 * functions by design. Policing it here would be fail-on-every-push.
 *
 * Usage: node scripts/ci/validate-rpc-grants.js
 * Exit 0: clean. Exit 1: a function is missing grants, or a GRANT line
 * has duplicate privileges.
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..', '..');
const GRANTS_FILE = path.join(ROOT, 'app', 'database', 'grants', 'grants.sql');
const FUNCTIONS_DIR = path.join(ROOT, 'app', 'database', 'functions');

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function getAppFunctionNames() {
  if (!fs.existsSync(FUNCTIONS_DIR)) return [];
  return fs
    .readdirSync(FUNCTIONS_DIR)
    .filter((f) => f.endsWith('_function.sql'))
    .map((f) => f.replace(/_function\.sql$/, ''))
    .sort();
}

/** Functions present in app/database/functions/ but absent from any GRANT. */
function findUngrantedFunctions(content) {
  const ungranted = [];
  for (const name of getAppFunctionNames()) {
    // grants.sql format: `... ON FUNCTION public.<name> TO "role";`
    // \b after the name keeps `foo` from matching `foo_v2` (and `_` is a
    // word char, so `foo` won't match `foo_bar` either).
    const re = new RegExp(`ON FUNCTION public\\.${escapeRegex(name)}\\b`);
    if (!re.test(content)) ungranted.push(name);
  }
  return ungranted;
}

/** GRANT statements that list the same privilege twice. */
function findDuplicatePrivileges(content) {
  const duplicates = [];
  content.split('\n').forEach((line, i) => {
    if (!line.trim().startsWith('GRANT ')) return;
    const match = line.match(/^GRANT\s+(.+?)\s+ON\s+/);
    if (!match) return;
    const privs = match[1].split(',').map((p) => p.trim());
    const unique = [...new Set(privs)];
    if (privs.length !== unique.length) {
      duplicates.push({
        line: i + 1,
        content: line.trim(),
        dupes: privs.filter((p, idx) => privs.indexOf(p) !== idx),
      });
    }
  });
  return duplicates;
}

function main() {
  if (!fs.existsSync(GRANTS_FILE)) {
    console.error('Grants file not found:', GRANTS_FILE);
    process.exit(1);
  }
  const content = fs.readFileSync(GRANTS_FILE, 'utf8');

  let failed = false;

  const ungranted = findUngrantedFunctions(content);
  if (ungranted.length > 0) {
    failed = true;
    console.error(
      'RPC grant validation failed: app function(s) with NO grant in grants.sql.\n' +
        '(DROP FUNCTION discards grants — a migration likely recreated these without re-GRANTing.)\n',
    );
    for (const name of ungranted) {
      console.error(`  - public.${name} has no GRANT ... ON FUNCTION line`);
    }
    console.error(
      '\nAdd the GRANT to the migration that (re)creates the function, redeploy, then `npm run fetch-all`.',
    );
  }

  const duplicates = findDuplicatePrivileges(content);
  if (duplicates.length > 0) {
    failed = true;
    console.error('\nGrant validation failed: duplicate privileges detected.\n');
    for (const d of duplicates) {
      console.error(`  Line ${d.line}: ${d.content}`);
      console.error(`    Duplicate privileges: ${d.dupes.join(', ')}`);
    }
    console.error('\nRegenerate grants.sql to fix duplicates.');
  }

  if (failed) process.exit(1);

  const n = getAppFunctionNames().length;
  console.log(`OK: all ${n} app functions have grants; no duplicate privileges.`);
}

main();
