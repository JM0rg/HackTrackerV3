## Migration Discipline

Two Supabase databases: **prod** (live users) and a **persistent `staging` branch** (E2E target). Schema sync is fully automatic via Supabase Branches + GitHub integration:

- **PR opened** → ephemeral preview branch spun up, all unmerged migrations applied to it, CI runs against it.
- **PR merged to main** → migrations auto-apply to prod AND to the persistent `staging` branch.
- **Never paste into the SQL editor** — bypasses the deploy pipeline and orphans prod from the migration history.

**Rules:**

1. **Any SQL change = migration file.** New function, function edit, table drop, trigger change — all go in numbered files in `app/database/migrations/` (Supabase CLI picks them up via `supabase/config.toml` or a `supabase/migrations` symlink).
2. **File names: `YYYYMMDDHHMMSS_description.sql`.** The Supabase CLI requires this format. Use `date +%Y%m%d%H%M%S` to generate the prefix.
3. **Migrations are self-contained and idempotent where possible.** Full `CREATE OR REPLACE FUNCTION` bodies, `DROP ... IF EXISTS`, `ALTER TABLE ... DROP COLUMN IF EXISTS`. Runnable as a single SQL script.
4. **Function files are read-only reference copies.** `app/database/functions/` is fetched from prod via `npm run fetch-all` after a successful deploy. Editing them locally without a migration changes nothing on the server.
5. **Static-check before pushing.** `bash scripts/ci/check-migrations.sh` walks every function body and flags references to dropped columns/tables. Catches the bug class where a function silently references a column that an earlier migration dropped.
6. **Deploy via `git push`, never the SQL editor or CLI directly.** The GitHub integration is the only sanctioned path. If you bypass it, prod's migration history diverges from the repo and Branches stops working.
7. **`supabase db push` to the persistent staging branch is fine** for local iteration before opening a PR. Just don't push directly to prod.
8. **`npm run fetch-all` runs after merge**, not before. It reads from prod; running it before the migration has deployed produces stale reference files.

**Anti-rules:**

- ❌ Pasting SQL into the Supabase dashboard SQL editor.
- ❌ Running `supabase db push --linked` against the prod project ref.
- ❌ Manually applying the same migration to both prod and staging — let the GitHub integration do it.
- ❌ Writing reverse-migration files. If a migration is wrong, write a *forward* migration that fixes it; never roll back prod by hand.

**When a migration fails on the preview branch:** read the error in the PR check. Fix the migration file. Push. The preview branch resets and replays.

**When a migration fails on prod after merge:** rare but possible if prod has data the preview branch didn't. Write a forward-fix migration immediately; do not revert the merge — the rollback would leave staging and prod out of sync.
