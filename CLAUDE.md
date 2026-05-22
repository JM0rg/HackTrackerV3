# HackTracker — Project Guide

Mobile slowpitch softball **hitting stats tracker** (iOS + Android). Flutter
frontend, Supabase backend, offline-first via Drift. This file is the entry
point; detailed conventions live in `.claude/rules/`.

## Domain

- **Team** — name, type (mens/womens/coed), logo, colors. A team plays across
  many leagues/locations over time, so league/location live on groups & games,
  NOT on the team.
- **Player** — a roster record (not an app user in the MVP): name, jersey number,
  throws (L/R), bats (L/R/switch), gender, status, default field positions,
  contact. `linked_user_id` is reserved for the future "player links their account".
- **Game** — opponent, park/location, start time, home/away, status, scores,
  notes. The W/L/T `result` is **computed** from the final score, never stored.
- **Group** — a season or tournament; carries league_name + location. Games map
  to groups **many-to-many** (a game can count toward a season AND a tournament).
- **Lineup** — an ordered batting list (variable length — supports batting the
  whole roster) plus an assigned field position per slot. Slowpitch positions:
  `P, C, 1B, 2B, 3B, SS, LF, LCF, RCF, RF` plus `EH` (extra hitter).

Stat logging, player/fan read-only access, team chat/calendar, and a
team-finder/free-agent feature are **future** — the schema is designed to absorb
them additively without rework.

## Layout

```
app/                  Flutter app (this is where the app lives — NOT repo root)
  lib/                core/ database/ features/ shell/ main.dart  (see folder-structure rule)
  database/           server-side SQL: migrations/, schemas/, functions/, rls_policies/, grants/, ...
scripts/database/     Node scripts to introspect Supabase schema (npm run fetch-all)
scripts/ci/           pre-push quality gates (check-all.sh)
.claude/rules/        the conventions below — read them
```

## Architecture (offline-first)

- Local **Drift** SQLite is the on-device source of truth. The UI reads/writes
  Drift only and **never blocks on the network**.
- A background **sync engine** (`core/services/sync/`) reconciles with Supabase:
  push dirty rows (upsert / soft-delete) then pull `where updated_at > cursor`.
  Conflicts resolve **last-write-wins by `updated_at`**.
- Every synced table carries: client-generatable `id uuid`, `created_at`,
  `updated_at` (server-authoritative via trigger), `deleted_at` (soft delete),
  and a local `sync_state` dirty flag.
- **RLS** scopes all access via `team_members` membership (`is_team_member`,
  `has_team_role`). MVP is single-owner; the role enum (owner/coach/player/fan)
  is built now so future joins need no migration.

## UI system (canonical primitives — `core/widgets/`, `core/theme/`)

Theme tokens are the only style source: `context.colors.*`, `context.text.*`,
`context.themeSpacing.*`, `context.themeRadii.*`. Never hardcode color/spacing/size.

Primitives: `AppButton`, `AppTextField`, `AppCard`, `AppDialog` (the only dialog
entry point), `ConfirmationDialog`, `SkeletonLoader` (no spinners), `EmptyState`,
`AppScaffold`, `OfflineBanner`, `SyncStatusIndicator`. Two themes: `light`, `dark`.

## Conventions (in `.claude/rules/`)

- **code-quality.md** — Tall Style formatting, freezed immutability, typed
  failures, Riverpod discipline, canonical primitives.
- **folder-structure.md** — feature-first layers; one-way imports (`shell → features → core`).
- **migration-discipline.md** — versioned SQL migrations, deploy via GitHub integration only.
- **testing-discipline.md** — less but better; pure-function/structural/wire-parity/E2E only.
- **ui-verification.md** — every UI change verified on the iOS Simulator (screenshot).
- **post-change-cycle.md** — implement → review → simplify → verify (`check-all.sh`).
- **dart-mcp.md** — prefer Dart MCP tools over CLI for the running app.

## Commands

- `cd app && flutter run --dart-define=...` — run (see README for keys)
- `cd app && dart run build_runner build --delete-conflicting-outputs` — codegen
- `bash scripts/ci/check-all.sh` — full pre-push gate
- `npm run fetch-all` — refresh `app/database/` reference copies after a deploy
