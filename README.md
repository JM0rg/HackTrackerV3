# HackTracker

Offline-first slowpitch softball stat tracker for iOS and Android. Score your lineup from the dugout with one thumb. Local scoring works without an account; cloud sync is under development.

## What it is

- **You** — home: a live game on top, one Start button, your numbers, your line on every game
- **Teams** — optional. Score a full lineup; opponents are names you type
- **Field Mode** — one batter, one diamond, one drag; quick outcomes with a sheet for detailed runner and batter corrections
- **Games** — history across teams and personal scorebooks, with live games first
- **Local first** — works with no signal; portable export and restore from settings

## Stack

Flutter (iOS + Android) · Drift SQLite · Supabase (Auth, Postgres, RLS) · optional email OTP sync

The secret API key is **never** shipped in the app. The client only receives `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## Run

```bash
# .env at repo root must include SUPABASE_URL and SUPABASE_ANON_KEY
# (plus your existing project id / secret for server-side work only)
bash scripts/run.sh
```

Codegen after schema changes:

```bash
cd app
dart run build_runner build
flutter test
```

Field Mode has golden renders. After a layout change:

```bash
cd app
flutter test --update-goldens test/features/scoring/field_mode_golden_test.dart
```

## Roles

| Role | Score | Edit roster / schedule | Billing |
| --- | --- | --- | --- |
| Owner | yes | yes | yes |
| Coach | yes | yes | no |
| Player | no | no | no |
| Fan | no | no | no |

Watch companions (Apple Watch / Wear OS) are a later native shell over the same scoring events. Flutter does not run on watchOS.

## Testing plans and field settings

In a development build, open **Account & settings → More → Plan preview** and choose Free, Player Plus, or Team Plus. The selection persists locally. It previews the product split, does not make purchases or grant backend entitlements, and is unavailable in release builds. Local scoring, statistics, and backups stay available on every plan.

More also contains Outdoor contrast and Reduce motion. Scoring drafts recover after reopening a game. See [current design and implementation limits](docs/design.md) for implemented behavior and the remaining cloud work.
