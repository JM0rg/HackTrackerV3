# HackTracker

Slowpitch softball stat tracker. Offline-first: Drift SQLite is the source of truth. Auth and sync are optional.

## Run

From the repo root (loads `.env` and passes only public dart-defines — never `SUPABASE_SECRET_API_KEY`):

```bash
chmod +x scripts/run.sh
./scripts/run.sh
```

Or from `app/` without Supabase (fully local):

```bash
cd app
flutter run
```

With Supabase:

```bash
cd app
flutter run \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
```

Copy `.env.example` to `.env` at the repo root. The Flutter client must only receive `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## Tests

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

## Scoring

Opens on **You** (personal hitting). Team is optional. Field Mode (`/games/:id/play`) scores our lineup only; the opponent is a name plus a run total.
