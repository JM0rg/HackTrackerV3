# HackTracker

Offline-first slowpitch softball stat tracker for iOS and Android. Score your lineup from the dugout with one thumb. Cloud sync is optional.

## What it is

- **You** — personal hitting on this phone, no account, no setup
- **Team** — optional. Score a full lineup; opponents are names you type
- **Field Mode** — one batter, one diamond, one drag; corrections in words, never a modal
- **Local first** — works with no signal; sign in to back up and invite

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
