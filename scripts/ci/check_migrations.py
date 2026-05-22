#!/usr/bin/env python3
"""
Static analyzer for SQL drift.

Builds a model of the live schema by parsing app/database/schemas/ + applying
migrations, then walks every function body and flags references to
columns/tables that don't exist in the final model.

This is the single test that catches "function body references a dropped
column" — the bug class that broke recalculate_exercise_prs_from_projections_v1
and friends after the 20260526a migration.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Iterable

# ----------------------------------------------------------------------------
# Schema model
# ----------------------------------------------------------------------------

Tables = dict[str, set[str]]


def parse_create_table(sql: str, tables: Tables) -> None:
    """Find CREATE TABLE blocks and record their columns."""
    pattern = re.compile(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?"
        r"(?:public\.)?(\w+)\s*\((.*?)\)\s*;",
        re.IGNORECASE | re.DOTALL,
    )
    for m in pattern.finditer(sql):
        table = m.group(1)
        body = m.group(2)
        cols: set[str] = set()
        # Split on top-level commas (commas inside () are skipped).
        depth = 0
        buf = []
        parts = []
        for ch in body:
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
            if ch == "," and depth == 0:
                parts.append("".join(buf).strip())
                buf = []
            else:
                buf.append(ch)
        if buf:
            parts.append("".join(buf).strip())
        for part in parts:
            # Skip constraints / inline indexes / table-level constraints
            if re.match(
                r"^(CONSTRAINT|PRIMARY\s+KEY|UNIQUE|CHECK|FOREIGN\s+KEY|EXCLUDE)\b",
                part, re.IGNORECASE):
                continue
            # First identifier is the column name.
            cm = re.match(r"^\"?(\w+)\"?\s+", part)
            if cm:
                cols.add(cm.group(1))
        if cols:
            tables.setdefault(table, set()).update(cols)


def apply_migrations(tables: Tables, migrations: list[str]) -> None:
    """Evolve the schema model by applying migration SQL.

    Handles the operations relevant to drift detection:
      - CREATE TABLE … (adds table)
      - DROP TABLE … (removes table)
      - ALTER TABLE … DROP COLUMN col
      - ALTER TABLE … ADD COLUMN col
      - ALTER TABLE … RENAME COLUMN x TO y

    Other ALTER TABLE variants (constraints, defaults, types) are ignored —
    they don't change the column inventory.
    """
    # Patterns we recognize, paired with handlers that mutate `tables`. Each
    # migration is walked in **source order** — drop-then-create-in-one-file
    # has to land in the right state, which the previous "all CREATEs first,
    # all DROPs second" pass didn't model correctly.
    create_table_pat = re.compile(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?"
        r"(?:public\.)?(\w+)\s*\((.*?)\)\s*;",
        re.IGNORECASE | re.DOTALL,
    )
    drop_table_pat = re.compile(
        r"DROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?(?:public\.)?(\w+)",
        re.IGNORECASE,
    )
    drop_col_pat = re.compile(
        r"ALTER\s+TABLE\s+(?:public\.)?(\w+)\s+DROP\s+COLUMN\s+"
        r"(?:IF\s+EXISTS\s+)?(\w+)",
        re.IGNORECASE,
    )
    add_col_pat = re.compile(
        r"ALTER\s+TABLE\s+(?:public\.)?(\w+)\s+ADD\s+COLUMN\s+"
        r"(?:IF\s+NOT\s+EXISTS\s+)?(\w+)\s+\S+",
        re.IGNORECASE,
    )
    rename_col_pat = re.compile(
        r"ALTER\s+TABLE\s+(?:public\.)?(\w+)\s+RENAME\s+COLUMN\s+"
        r"(\w+)\s+TO\s+(\w+)",
        re.IGNORECASE,
    )
    rename_table_pat = re.compile(
        r"ALTER\s+TABLE\s+(?:IF\s+EXISTS\s+)?(?:public\.)?(\w+)\s+"
        r"RENAME\s+TO\s+(\w+)",
        re.IGNORECASE,
    )

    def apply_create_table(match: re.Match[str]) -> None:
        # Use the existing parse_create_table on the matched fragment so we
        # reuse the constraint/column-splitting logic.
        parse_create_table(match.group(0), tables)

    def apply_drop_table(match: re.Match[str]) -> None:
        tables.pop(match.group(1), None)

    def apply_drop_col(match: re.Match[str]) -> None:
        tbl, col = match.group(1), match.group(2)
        if tbl in tables:
            tables[tbl].discard(col)

    def apply_add_col(match: re.Match[str]) -> None:
        tbl, col = match.group(1), match.group(2)
        tables.setdefault(tbl, set()).add(col)

    def apply_rename_col(match: re.Match[str]) -> None:
        tbl, old, new = match.group(1), match.group(2), match.group(3)
        if tbl in tables and old in tables[tbl]:
            tables[tbl].discard(old)
            tables[tbl].add(new)

    def apply_rename_table(match: re.Match[str]) -> None:
        old, new = match.group(1), match.group(2)
        if old in tables:
            tables[new] = tables.pop(old)

    handlers = [
        (create_table_pat, apply_create_table),
        (drop_table_pat, apply_drop_table),
        (drop_col_pat, apply_drop_col),
        (add_col_pat, apply_add_col),
        (rename_col_pat, apply_rename_col),
        (rename_table_pat, apply_rename_table),
    ]

    for sql in migrations:
        # Collect every DDL statement we recognize, paired with its position
        # in the source. Sort by position → process in execution order.
        events: list[tuple[int, re.Match[str], object]] = []
        for pat, fn in handlers:
            for m in pat.finditer(sql):
                events.append((m.start(), m, fn))
        events.sort(key=lambda e: e[0])
        for _, m, fn in events:
            fn(m)  # type: ignore[operator]


# ----------------------------------------------------------------------------
# Function body analyzer
# ----------------------------------------------------------------------------

# Match `alias.column_name` inside a function body, where `alias` is the
# table alias the function uses (e.g. `ws.distance_m`, `w.profile_id`).
# We need to map the alias back to its underlying table to verify.
ALIAS_REF = re.compile(r"\b(\w+)\.(\w+)\b")

# Match table aliases: `FROM public.tbl ws` or `JOIN public.tbl w`.
ALIAS_BINDING = re.compile(
    r"\b(?:FROM|JOIN)\s+(?:public\.)?(\w+)\s+(?:AS\s+)?([a-z_][a-z0-9_]*)\b",
    re.IGNORECASE,
)

# Match direct `public.tbl.col` references that don't go through an alias.
QUALIFIED_REF = re.compile(
    r"\bpublic\.(\w+)\.(\w+)\b",
)

# Built-in / non-table prefixes that show up as `x.y` but aren't column refs.
NON_TABLE_PREFIXES = {
    "auth", "extensions", "pg_catalog", "information_schema",
    "current_setting", "jsonb_build_object", "jsonb_each_text",
    "jsonb_array_elements", "jsonb_array_elements_text",
    # Type casts that look like prefixes after split: timestamptz, etc.
}

# Column-like identifiers commonly used as scalar variables, params, or
# functions. Suppress them from the dead-ref report — they aren't column refs.
COMMON_NOISE = {
    # PL/pgSQL keywords as alias-like.
    "new", "old", "tg",
    # Common control flow.
    "now", "extract", "coalesce", "nullif", "to_jsonb", "jsonb",
    "array", "string", "md5", "lag", "lead", "max", "min", "sum",
    "count", "avg", "row", "case", "when", "then", "else", "end",
    "select", "from", "where", "and", "or", "not", "in", "is",
    "true", "false", "null", "as", "by", "on", "having", "group",
    "order", "asc", "desc", "limit", "offset", "with", "insert",
    "into", "update", "delete", "set", "values", "returning",
    # JSON-path / cast like `(payload->>'foo')::uuid`.
    "uuid", "text", "integer", "bigint", "boolean", "date",
    "timestamptz", "timestamp", "numeric", "double", "real", "jsonb",
}


CTE_NAME = re.compile(
    r"(?:^|\bWITH\b|,)\s*(\w+)\s+AS\s*\(",
    re.IGNORECASE,
)
# `CREATE TEMP TABLE foo` / `CREATE TEMPORARY TABLE foo` — function-local
# scratch tables. Treat them as virtual tables we trust the function for.
TEMP_TABLE = re.compile(
    r"CREATE\s+(?:TEMP|TEMPORARY)\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(\w+)",
    re.IGNORECASE,
)
# `FROM (SELECT ...) alias` — derived-table alias. We can't validate
# columns from a subquery; mark these aliases as opaque and skip them.
DERIVED_ALIAS = re.compile(
    r"\bFROM\s*\(\s*SELECT\b.*?\)\s+([a-z_][a-z0-9_]*)",
    re.IGNORECASE | re.DOTALL,
)

LINE_COMMENT = re.compile(r"--[^\n]*")
BLOCK_COMMENT = re.compile(r"/\*.*?\*/", re.DOTALL)


def strip_sql_comments(sql: str) -> str:
    """Drop `-- line` and `/* block */` comments so regexes don't trip on
    them (esp. CTE detection where a comment can sit between `,` and the
    next CTE name)."""
    sql = BLOCK_COMMENT.sub("", sql)
    sql = LINE_COMMENT.sub("", sql)
    return sql
# `FROM function_name(args) alias` — bind alias to the function's name
# rather than treat it as a real table reference.
FUNCTION_FROM = re.compile(
    r"\b(?:FROM|JOIN)\s+(?:public\.)?(\w+)\s*\([^)]*\)\s+(?:AS\s+)?([a-z_][a-z0-9_]*)",
    re.IGNORECASE,
)


def find_cte_names(body: str) -> set[str]:
    """Identify CTE / WITH-clause names so we don't flag aliases that bind
    to them as missing tables. Also includes function-local TEMP TABLEs."""
    return (
        {m.group(1).lower() for m in CTE_NAME.finditer(body)}
        | {m.group(1).lower() for m in TEMP_TABLE.finditer(body)}
    )


def find_function_aliases(body: str) -> set[str]:
    """Aliases bound to a function call's return table (e.g.
    `FROM compute_xp(...) c`) or to a subquery `FROM (SELECT ...) c`."""
    out = {m.group(2).lower() for m in FUNCTION_FROM.finditer(body)}
    out |= {m.group(1).lower() for m in DERIVED_ALIAS.finditer(body)}
    return out


def find_alias_map(
    body: str,
    cte_names: set[str],
    function_aliases: set[str],
) -> tuple[dict[str, str], set[str]]:
    """Build alias → table_name map from FROM / JOIN clauses, skipping
    CTEs and function-returning aliases. Also returns the set of aliases
    that bind to multiple distinct tables in the same function — those
    are ambiguous and we can't validate columns through them."""
    bindings: dict[str, set[str]] = {}
    for m in ALIAS_BINDING.finditer(body):
        table, alias = m.group(1), m.group(2).lower()
        if alias in COMMON_NOISE:
            continue
        if table.lower() in cte_names:
            continue
        if alias in function_aliases:
            continue
        bindings.setdefault(alias, set()).add(table)
    ambiguous = {a for a, ts in bindings.items() if len(ts) > 1}
    out = {a: next(iter(ts)) for a, ts in bindings.items() if a not in ambiguous}
    return out, ambiguous


def find_dead_refs(
    function_name: str,
    body: str,
    tables: Tables,
) -> list[str]:
    """Return human-readable strings for each dead reference found."""
    issues: list[str] = []

    # 1. Qualified references: public.tbl.col (rare but happens).
    for m in QUALIFIED_REF.finditer(body):
        table, col = m.group(1), m.group(2)
        if table in NON_TABLE_PREFIXES:
            continue
        if table not in tables:
            issues.append(
                f"{function_name}: references unknown table public.{table}"
            )
        elif col not in tables[table]:
            issues.append(
                f"{function_name}: references unknown column "
                f"public.{table}.{col}"
            )

    # 2. Aliased references: alias.col → resolve alias back to table.
    cte_names = find_cte_names(body)
    function_aliases = find_function_aliases(body)
    alias_map, ambiguous = find_alias_map(body, cte_names, function_aliases)
    for m in ALIAS_REF.finditer(body):
        prefix, col = m.group(1).lower(), m.group(2)
        if prefix in NON_TABLE_PREFIXES or prefix in COMMON_NOISE:
            continue
        if prefix in cte_names:
            # alias.col where alias is a CTE / TEMP table — can't validate
            # without parsing the CTE's column list. Trust it.
            continue
        if prefix in function_aliases:
            # alias.col where alias binds to a function's return table or
            # a derived subquery — can't validate without resolving.
            continue
        if prefix in ambiguous:
            # Same alias bound to multiple tables in this function (common
            # in UNION ALL fan-outs like sync_pull_v4). Can't tell which
            # binding is in scope at this reference — skip.
            continue
        if prefix not in alias_map:
            # PL/pgSQL record variable, jsonb path, etc.
            continue
        table = alias_map[prefix]
        if table not in tables:
            issues.append(
                f"{function_name}: alias `{prefix}` binds to unknown table "
                f"public.{table}"
            )
            continue
        if col not in tables[table]:
            issues.append(
                f"{function_name}: `{prefix}.{col}` → column not in "
                f"public.{table}"
            )

    return issues


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------

def read_all(paths: Iterable[Path]) -> str:
    return "\n\n".join(p.read_text(encoding="utf-8") for p in paths)


def main(db_dir: str) -> int:
    db = Path(db_dir)
    schemas_dir = db / "schemas"
    migrations_dir = db / "migrations"
    functions_dir = db / "functions"

    if not schemas_dir.exists():
        print(f"✗ {schemas_dir} not found", file=sys.stderr)
        return 1

    # Build the schema model.
    tables: Tables = {}
    for f in sorted(schemas_dir.glob("*.sql")):
        parse_create_table(f.read_text(encoding="utf-8"), tables)

    migration_sqls = [
        p.read_text(encoding="utf-8") for p in sorted(migrations_dir.glob("*.sql"))
    ]
    apply_migrations(tables, migration_sqls)

    if not tables:
        print("✗ no tables parsed from schemas/", file=sys.stderr)
        return 1

    # Walk every function body, collect dead refs.
    all_issues: list[str] = []
    for f in sorted(functions_dir.glob("*.sql")):
        body = strip_sql_comments(f.read_text(encoding="utf-8"))
        fname = f.stem.replace("_function", "")
        all_issues.extend(find_dead_refs(fname, body, tables))

    # Dedupe — same `ws.foo` may appear many times in one function.
    seen: set[str] = set()
    unique: list[str] = []
    for issue in all_issues:
        if issue not in seen:
            seen.add(issue)
            unique.append(issue)

    if unique:
        print(f"✗ {len(unique)} dead SQL reference(s) in app/database/functions/:")
        for issue in unique:
            print(f"  {issue}")
        print()
        print(
            "  These are function bodies referencing columns/tables that "
            "don't exist in\n"
            "  the current schema (schemas/ + migrations/). Either fix the "
            "function or\n"
            "  write a migration to restore the missing structure."
        )
        return 1

    print(
        f"✓ migrations check clean "
        f"({len(tables)} tables modeled, "
        f"{sum(len(c) for c in tables.values())} columns, "
        f"{len(list(functions_dir.glob('*.sql')))} functions scanned)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
