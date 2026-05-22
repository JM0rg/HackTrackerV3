#!/usr/bin/env python3
"""
Liveness scanner for public Dart APIs.

Walks lib/, indexes every public method / top-level function declared,
then verifies each has at least one caller elsewhere. Flags dead ones.

This catches the failure class where a refactor orphans a method but the
test suite doesn't surface it (`getMostRecentExerciseIdForSkill` lingered
for a full migration cycle returning wrong data, never called).

Performance: single-pass index of all *.dart files → O(n) checks. ~3s
total even on a large repo. (The naive grep-per-declaration approach
took 2m40s — don't go back to it.)

Allowlist: scripts/ci/dead-public-api-allowlist.txt — one
`relative/path:identifier` per line. Used to grandfather legacy dead code
during the cleanup phase. New entries should be removed (delete the
method) rather than added.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


METHOD_DECL = re.compile(
    r"^\s*(?:static\s+)?(?:Future<[^>]+>|Stream<[^>]+>|"
    r"List<[^>]+>|Set<[^>]+>|Map<[^,]+,[^>]+>|"
    r"[A-Z]\w*\??|void|bool|int|double|String|num|dynamic)\s+"
    r"(\w+)\s*\(",
    re.MULTILINE,
)

GETTER_DECL = re.compile(
    r"^\s*(?:static\s+)?(?:Future<[^>]+>|Stream<[^>]+>|"
    r"List<[^>]+>|Set<[^>]+>|Map<[^,]+,[^>]+>|"
    r"[A-Z]\w*\??|bool|int|double|String|num|dynamic)\s+"
    r"get\s+(\w+)\s*(?:=>|\{)",
    re.MULTILINE,
)

TOP_LEVEL_FN = re.compile(
    r"^(?!\s)(?:Future<[^>]+>|Stream<[^>]+>|void|bool|int|"
    r"[A-Z]\w*\??|String|double|num|List<[^>]+>)\s+(\w+)\s*\(",
    re.MULTILINE,
)

EXEMPT_ANNOTATIONS = (
    "@override",
    "@visibleForTesting",
    "@protected",
    "@pragma",
    "@Riverpod",
    "@riverpod",
)

LIFECYCLE_NAMES = {
    "main", "build", "initState", "dispose", "didUpdateWidget",
    "didChangeDependencies", "createState", "reassemble", "deactivate",
    "activate", "toString", "noSuchMethod", "hashCode", "runtimeType",
    "call", "fromJson", "toJson", "copyWith", "fromDatabase",
    "fromMetadata", "fromDrift", "toDrift", "fromMap", "toMap",
    "fromString", "of", "maybeOf", "values", "name", "index",
    # Equality / comparison
    "operator", "compareTo",
}

SKIP_DECL_FILES = re.compile(
    r"\.g\.dart$|\.freezed\.dart$|musclemap_paths\.g?\.dart$"
)

# Word boundary that lets `.` count as the right side. Matches both
# `foo.bar(` and `foo(` and bare `foo` as identifier reads.
IDENTIFIER_USE = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\b")


def is_exempt(file_text: str, decl_line_idx: int) -> bool:
    lines = file_text.splitlines()
    start = max(0, decl_line_idx - 3)
    for i in range(start, decl_line_idx):
        if any(ann in lines[i] for ann in EXEMPT_ANNOTATIONS):
            return True
    return False


def collect_declarations(root: Path) -> list[tuple[str, Path, int]]:
    out: list[tuple[str, Path, int]] = []
    for f in root.rglob("*.dart"):
        if SKIP_DECL_FILES.search(f.name):
            continue
        text = f.read_text(encoding="utf-8")
        for pat in (METHOD_DECL, GETTER_DECL):
            for m in pat.finditer(text):
                name = m.group(1)
                if name.startswith("_") or name in LIFECYCLE_NAMES:
                    continue
                line_idx = text[: m.start()].count("\n")
                if is_exempt(text, line_idx):
                    continue
                out.append((name, f, line_idx))
        for m in TOP_LEVEL_FN.finditer(text):
            name = m.group(1)
            if name.startswith("_") or name in LIFECYCLE_NAMES:
                continue
            line_idx = text[: m.start()].count("\n")
            if is_exempt(text, line_idx):
                continue
            out.append((name, f, line_idx))
    return out


def build_usage_index(roots: list[Path]) -> dict[str, set[Path]]:
    """Map identifier → set of files that mention it (excluding the file
    itself when we check). One pass over every .dart file."""
    index: dict[str, set[Path]] = {}
    for root in roots:
        for f in root.rglob("*.dart"):
            # Don't skip .g.dart for usage indexing — generated code may
            # legitimately call a hand-written API. But DO skip the
            # declaration file when we resolve later.
            text = f.read_text(encoding="utf-8")
            for m in IDENTIFIER_USE.finditer(text):
                index.setdefault(m.group(1), set()).add(f)
    return index


def load_allowlist(allowlist_path: Path, repo_root: Path) -> set[tuple[Path, str]]:
    if not allowlist_path.exists():
        return set()
    out: set[tuple[Path, str]] = set()
    for line in allowlist_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            continue
        rel, name = line.split(":", 1)
        out.add(((repo_root / rel).resolve(), name.strip()))
    return out


def main(lib_path: str) -> int:
    lib = Path(lib_path).resolve()
    repo_root = lib.parent.parent
    test_root = repo_root / "app" / "test"
    allowlist_path = repo_root / "scripts" / "ci" / "dead-public-api-allowlist.txt"

    declarations = collect_declarations(lib)
    usage_index = build_usage_index([lib, test_root])
    allowlist = load_allowlist(allowlist_path, repo_root)

    dead: list[tuple[str, Path, int]] = []
    for name, file, line in declarations:
        users = usage_index.get(name, set())
        non_self_users = {u for u in users if u.resolve() != file.resolve()}
        if non_self_users:
            continue
        if (file.resolve(), name) in allowlist:
            continue
        dead.append((name, file, line))

    if dead:
        print(
            f"✗ {len(dead)} public declaration(s) with zero callers "
            f"(excluding {len(allowlist)} allowlisted):"
        )
        for name, file, line in sorted(dead, key=lambda t: (str(t[1]), t[2])):
            rel = file.relative_to(repo_root)
            print(f"  {rel}:{line + 1}  →  {name}")
        print()
        print(
            "  These public methods/getters/functions are declared but never\n"
            "  referenced. Either:\n"
            "    1. Delete them (preferred).\n"
            "    2. Mark @visibleForTesting / @protected / @override.\n"
            "    3. Add to scripts/ci/dead-public-api-allowlist.txt with a\n"
            "       comment explaining why (legacy debt, polymorphic-only,\n"
            "       called via generated code, etc.).\n"
        )
        return 1

    print(
        f"✓ liveness clean ({len(declarations)} public declarations, "
        f"{len(allowlist)} grandfathered)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
