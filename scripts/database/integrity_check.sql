-- ============================================================================
-- Maxed Database Integrity Check Suite
-- Run after every migration, deploy, or sync incident.
-- All checks output rows only when a problem is detected.
-- Zero rows from every check = system is consistent.
-- ============================================================================
-- user_progress and xp_ledger no longer exist; checks that used them were removed.

-- ---------------------------------------------------------------------------
-- 1. Duplicate tombstone entries (catches tombstone dedup failures)
-- ---------------------------------------------------------------------------
SELECT
  'duplicate_tombstones' AS check_name,
  profile_id,
  entity_type,
  entity_id,
  COUNT(*) AS occurrences
FROM public.sync_deletions
GROUP BY profile_id, entity_type, entity_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- ============================================================================
-- End of integrity checks. Zero rows from all checks = consistent state.
-- ============================================================================
