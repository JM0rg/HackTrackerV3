# HackTracker

A mobile slowpitch softball **hitting stats tracker** for iOS and Android.

Coaches/team owners create teams, build rosters, schedule games, group games
into seasons and tournaments, and set lineups. Stat logging and player/fan
access are planned for later phases — this repo is the offline-first foundation.

## Stack

- **Flutter** (Dart) — single codebase for iOS + Android. App lives in [`app/`](app/).
- **Drift** (local SQLite) — on-device source of truth; the app works fully offline.
- **Supabase** (Postgres) — backend; the app syncs to it in the background.
- **Riverpod** — state management. **go_router** — navigation. **freezed** — immutable models.
- **Auth** — passwordless: Sign in with Apple, Google, and email magic-link/OTP.

## Architecture

Offline-first. The UI reads and writes **only** the local Drift database; a
background sync engine reconciles with Supabase when connectivity allows
(last-write-wins by `updated_at`, soft deletes, client-generated UUIDs). See
[`.claude/rules/folder-structure.md`](.claude/rules/folder-structure.md) for the
feature-first layout and [`CLAUDE.md`](CLAUDE.md) for conventions.

## Setup

### Flutter app
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen (drift/freezed/riverpod)
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_OAUTH_CLIENT_ID
```
Secrets are passed via `--dart-define`, never committed.

### Database scripts (optional, for schema introspection)
```bash
npm install
cp .env.example .env   # fill in Supabase credentials
npm run fetch-all      # pulls schema/functions/RLS/etc into app/database/ reference copies
```

## Database deploys

Schema changes are versioned SQL migration files in `app/database/migrations/`
(`YYYYMMDDHHMMSS_*.sql`) and deployed **via Supabase's GitHub integration** — never
the SQL editor or ad-hoc tooling. See
[`.claude/rules/migration-discipline.md`](.claude/rules/migration-discipline.md).

## CI / quality gates

`bash scripts/ci/check-all.sh` runs the full pre-push gate (formatter, analyzer,
feature-import boundaries, file-size cap, migration drift, RPC grants, Riverpod
conventions, dead-API). The `scripts/git-hooks/pre-push` hook runs it automatically.
