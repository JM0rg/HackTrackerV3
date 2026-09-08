# HackTracker — overhaul proposal

Proposal · September 8, 2026 · Based on the current working tree, including uncommitted work.

Approved roadmap. The findings below describe the proposal baseline; see [design.md](design.md) for current implementation and remaining work.

## Product decision

**Build the app a player can trust while they are also trying to play softball.** The signature experience is: open the game, recognize the situation, record what happened, put the phone down. Team management and a useful personal career grow around that experience.

Keep Flutter, Riverpod, Drift, Supabase, the personal-first entry point, and the drag-to-base diamond. Replace the scoring assumptions, sync protocol, identity boundaries, and inconsistent interaction details. A framework rewrite would consume time without addressing the hard problems.

The organizing promise: **Your game, saved before the next pitch.** This is a proposed product direction, not a claim about current durability.

## 1. Who this is for

- **Player-scorer:** tracks the lineup while playing. Needs speed, quick recovery, visible next batter, and a phone someone else can understand immediately.
- **Personal tracker:** records their own plate appearances on any team, including pickup games. Needs almost no setup and no invented team context.
- **Manager:** needs tonight's available players, a reusable batting order, league rules, results, and a roster that survives season changes.
- **Invited teammate:** wants their numbers and team results without waiting for an export. Joining and reading should be free when the team pays for sharing.
- **Multi-team player:** plays Tuesday league, Thursday league, and weekend tournaments. Their identity stays constant while team roles, rules, and competitions change.

Success means people finish recording real games. Number of settings, screens, and statistics is not a success measure.

## 2. Navigation and information hierarchy

Use three destinations: **You · Teams · Games**. Account, appearance, backup, and exports live behind the profile control. Field Mode takes over the screen during scoring.

**You:** live game first; next scheduled game second; one primary Start/Resume action; season batting line; recent games with the user's own performance. A compact scope filter selects All teams, a team, or Unaffiliated. Keep the selected date/season scope visible. Default to final games in career aggregates; show today's live performance separately.

**Teams:** a compact team switcher showing membership/role, then the selected team's next game, availability, lineup, record, and season. Roster, competitions, and settings are secondary destinations. Do not start users in an administrative dashboard.

**Games:** chronological schedule and history across contexts; filter team, season, tournament, and status. Doubleheaders remain distinct games with a convenient Start game two action.

Starting remains a bottom sheet with **My at-bats / Team lineup**. Personal mode optionally keeps team scores. Team mode remembers the team, competition, home/away setting, opponent, and last lineup. Require only what is needed to begin; names, park, and dates can be corrected later.

A named team in a personal log can stay a lightweight local context. When it becomes a managed club, explicitly link the context to the club. Never merge teams or people simply because names match.

## 3. Field Mode: preserve the diamond, remove the friction

### The layout

Top: named teams and score, inning/half, three readable out indicators. Middle: current batter and today's line, followed by on-deck and in-the-hole names. Bottom reachable area: large diamond, stable outcome strip, last-play sentence, visible Undo and Handoff.

The current golden render has a large gap between batter and diamond, tiny runner labels, and gesture-only actions that a new scorer must discover. Tighten the situation/batter grouping and use that space for legible base occupants and next hitters. Inspect actual devices before deciding final spacing; golden images are not performance or usability evidence.

### Interaction contract

1. Drag the batter toward a base. Snap zones highlight before release; a light haptic confirms the target. First base offers **Hit · Walk · Error · Choice**, using words before abbreviations.
2. Double, triple, and over-fence home run record the suggested hit immediately. A persistent last-play strip shows the recorded interpretation. It remains editable until and after the next play.
3. Drag down for an out. Default to a generic out when no runner decision is needed. Strikeout and fly/ground detail stay one tap away. When an out could change runs, expose the relevant runner decisions immediately. Do not require Fly/Ground/Line for every routine out.
4. Show suggested runner destinations together. Tap or drag a runner to change **Hold / Advance / Score / Out**. Preserve identities, not merely a run-count slider. Ask “Who was out?” for a choice or double play instead of automatically retiring the lead runner.
5. A small **More on this play** disclosure handles “single, then error to second,” runner thrown out stretching a hit, an award, or multiple outs. Ending base and hit credit are separate concepts.
6. Every drag has a tap alternative: tap batter, tap destination, choose any necessary detail. VoiceOver exposes the same actions. Gesture speed must not make the app inaccessible.

Allow a short-lived, visibly provisional runner suggestion so the scorer can move on quickly. Persist it with its assumptions; confirm it implicitly when starting the next play, or correct it first. Unresolved unknowns remain flagged. Never call an assumed runner outcome scorer-confirmed.

No modal after every at-bat. No celebration that blocks the next input. No movement of active touch targets while a finger is down. End game is a visible secondary action with a compact review; pulling the score can remain a shortcut, but cannot be the only discoverable control.

### Handoff is a first-class feature

**Same phone:** Handoff opens a simplified scoring surface with “Sam batting · Mike next,” the situation, diamond, and Undo. Optional first-use hint: “Drag the hitter where they reached.” Hide team administration and private personal notes. No login, role transfer, or network round trip. This is a focused UI, not a security boundary against someone holding an unlocked phone.

**Different phone:** premium team members can explicitly transfer scoring authority. The receiver sees the last accepted play before taking over. Offline takeover can create a separate recoverable branch, but cannot guarantee exclusive ownership across disconnected devices. Explain this only when it occurs.

### Real dugout recovery

- **Catch up:** enter several missed at-bats in lineup order, then reconcile outs, bases, and score. Allow “result unknown”; do not turn a skipped batter into an out.
- **Score only for a while:** record known half totals and mark individual coverage incomplete. Resume detailed scoring from a confirmed situation. Missing plate appearances are excluded from rate calculations with a coverage warning.
- **Wrong batter:** change the player on the play directly. Do not delete and recreate the inning.
- **Undo / redo:** visible controls; undo is an auditable correction. Preview any downstream conflict before applying an older correction.
- **Interrupted play:** store the draft locally. Relaunch returns to the same unfinished decision, without counting it twice.
- **Opponent half:** enter runs with plus/minus or direct total; End half. No opponent roster required.
- **Personal mode with team scores:** enter the absolute team half total independently of RBI. A player's RBI is not a safe substitute for the team's scoreboard.

## 4. Premium visual direction

Think precision sports instrument: ink and graphite surfaces, restrained emerald accents, crisp type, strong numeric hierarchy, and very little decoration. The hacker reference belongs in the name, diamond mark, and quiet accent treatment. Skip terminal copy, code rain, masks, fake diagnostics, and gratuitous neon.

Use platform-appropriate typography and navigation behavior; tabular figures for scores. Keep one shared token system for spacing, surfaces, typography, motion, and feedback. Use translucent material sparingly on navigation/sheets where it preserves readability; keep the actual scoring surface stable and high contrast. Flutter should express the product's visual identity without approximating every new native effect at high rendering cost.

Field Mode should offer an outdoor high-contrast option, including a light surface. Test under sun, sunglasses, one-handed use, sweaty fingers, and on smaller phones. Target 48–56 logical-pixel primary scoring controls; support text scaling, non-color status cues, screen readers, reduced motion, and reduced transparency. Apple explicitly treats accessibility and motion preferences as design inputs. [Apple accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility), [Apple motion](https://developer.apple.com/design/human-interface-guidelines/motion?changes=_3).

Motion proposal: immediate drag tracking, roughly 120–180 ms confirmations, 200–280 ms sheet/state transitions, and subtle score changes. These are starting values to test, not performance measurements. Animate only the elements that changed; disable ornamental motion during rapid entry.

“No loading signs” should mean no network loading state in scoring. Cached content appears immediately. Initial account restore still needs honest progress with a working local path; errors must remain visible. Never show “saved” before a durable local commit or “backed up” before server acknowledgement.

## 5. Slowpitch scoring and statistics

### Rules are explicit, versioned presets

Store a rule snapshot on each game: association/year, local overrides, innings, run/mercy limits, home-run allowance and excess penalty, coed walk award, courtesy-runner policy, batting-order rules, tie-breaker runner, and end conditions. Local leagues vary. Existing games must not change when next season's team settings change.

USA Softball recognizes sacrifice flies, including qualifying line drives and some dropped catches; walks and sacrifice flies do not count as at-bats. Hits require more than reaching safely: forced preceding-runner outs and ordinary-effort retirements affect hit credit. RBI can come from hits, sacrifices, infield outs, choices, and forced awards. Implement explicit runner outcomes and out timing rather than deriving these from a destination alone. [2026 USA Softball, Rules 1, 5, 11](https://www.usasoftball.com/wp-content/uploads/sites/120/2026/01/1-12-2026-Rule-Book.pdf).

USSSA defines a sacrifice fly around a caught fair fly that permits a run. Its rulebook distinguishes base awards and restricts advancement on unbatted pitches. This supports keeping association-specific rule profiles; “slowpitch” is not one universal ruleset. [2026 USSSA rulebook](https://cms.usssa.net/wp-content/uploads/sites/2/2025/12/usssa-slowpitch-2026-rulebook-final.pdf).

### What belongs on the stat screens

**Headline:** AVG, OBP, SLG, OPS, plus hits/at-bats so percentages have context. Default secondary line: games, PA, runs, RBI, home runs. Expand for singles, doubles, triples, walks, strikeouts, sacrifice flies, extra-base hits, total bases, ROE, and FC.

Use the existing standard hitting formulas as the base contract: AVG = H/AB; default slowpitch OBP = (H + BB)/(AB + BB + SF); TB = 1B + 2×2B + 3×3B + 4×HR; SLG = TB/AB; OPS = OBP + SLG. Awards outside that base model need explicit denominator rules. No-denominator rates display an em dash. OBP excludes errors and fielder's choices. [OBP definition](https://www.mlb.com/glossary/standard-stats/on-base-percentage). Extra advancement does not increase total bases; OPS combines OBP and SLG. [Total bases](https://www.mlb.com/glossary/standard-stats/total-bases), [OPS](https://www.mlb.com/glossary/standard-stats/on-base-plus-slugging).

Filter by team, season, tournament, date range, and personal/team source. Show minimum-PA qualification and sample size on leaderboards. Compute combined rates from combined numerators/denominators, never by averaging player or game percentages. Never label a partial personal log a complete team record.

**Optional, off by default:** spray direction (five broad zones), contact type (ground/line/fly), subjective hard/medium/soft contact, a short note, courtesy-runner appearances, and baserunning outs. Add these after the main result or between innings. Show the percentage of plays tagged; an untagged ball is unknown, not weak contact. Spray charts should distinguish all batted balls from hits.

**Later, only with trustworthy inputs:** situational splits and RISP performance for fully tracked games; streaks and rolling averages with sample sizes. Pitching/fielding statistics need substantially more observation than unilateral scoring supplies. Do not manufacture ERA, fielding percentage, exit velocity, WAR, or league-normalized ratings.

No pitch counts, ball/strike entry, or pitch location. No sacrifice-bunt button in the default slowpitch workflow. Keep strikeouts as outcomes, including the relevant foul-out subtype when a ruleset needs it. Steals/HBP belong only in a supported explicit variant, not the default interface.

### The engine contract

Model a play as batter credit + base movements + outs + run credits. A movement names the runner, starting position, destination, reason, and associated scoring identity. Courtesy-runner appearance, substitute identity, and credited run must be representable separately according to the selected rules.

Represent zero, one, two, or three outs; force versus tag; and whether a run preceded a timing out. Enforce third-out run rules before committing the score. Support a hit plus an error/advance without upgrading hit credit, and a sacrifice classification without assuming the batter must always be retired. MLB's common convention excludes error-caused runs and grounded-double-play runs from RBI; configure the adopted scoring policy explicitly rather than treating every run as RBI. [RBI convention](https://www.mlb.com/glossary/standard-stats/runs-batted-in).

Maintain lifecycle events for half ended, suspended, resumed, finalized, forfeit, and correction. Store actual played score separately from an administrative forfeit result. Distinguish a completed scoreless inning (0), an unplayed home half (X), and unknown data. Catch rule-limit endings and walk-offs as suggestions the scorer can confirm.

## 6. Teams, seasons, tournaments, and invitations

**Roster:** paste names, add substitutes quickly, archive departed players, jersey/nickname, optional batting hand, and rule-relevant eligibility fields. Do not require a biography. Attendance is In / Out / Maybe; anonymous local managers can mark attendance themselves, while shared teams collect member responses.

**Lineup:** reuse last game, drag order, mark unavailable, add late arrival, and substitute without rewriting earlier plate appearances. Support batting everybody, extra hitters, and local order constraints. Version lineup changes at the point they take effect. Keep defensive positions optional.

**Competitions:** seasons and tournaments group games and carry rules. A game can belong to both while counting once in all-time totals. Tournament mode emphasizes today's sequence, pool/bracket labels, field, and next game. Full bracket administration and league-wide standings require data beyond this team and are deferred.

**Invites:** manager shares an expiring link/QR through the native share sheet. Recipient signs in only when joining, then claims their roster entry with confirmation appropriate to the team. Membership acceptance and player identity claiming are separate operations. High-privilege invitations are owner-controlled. Existing local stats are preserved during linking.

Use an immutable person ID, optional authenticated account mapping, team-specific roster entries, and memberships. One person can be a player on one team, scorer on another, owner on a third. Name matching only suggests candidates. Revoke links and memberships explicitly; never expose private personal logs to a team.

**Double-count prevention:** if a player also logs an at-bat personally, link it to the corresponding official team appearance with user review. Career stats count one canonical appearance. Private notes remain private. Do not sum the two recordings or silently overwrite the personal observation.

**Role model:** owner handles billing/ownership; manager handles roster/schedule; delegated scorer can score assigned games; player views allowed stats and changes their own RSVP; fan access is optional and narrow. Team-scored stats remain team-authoritative. Players can request corrections without gaining roster or score editing privileges.

## 7. Local-first architecture and premium sync

### Keep the stack; make the write path small

The Flutter UI reads reactive local projections. A scoring command validates the expected game revision, writes an immutable event, updates its projection, and adds an outbox item **inside one SQLite transaction**. Feedback confirms the local commit. Network work occurs afterward. Persist draft decisions separately from committed plays.

Keep pure Dart scoring/replay logic. Use one versioned event stream for gameplay rather than two collections sharing an unenforced sequence. Add event ID, game ID, device ID, local ordinal, base revision, schema version, rules version, and correction reference. Treat player lines, game totals, and inning rows as rebuildable projections.

Full replay remains useful for small games and audit verification. First eliminate redundant full-history reads and writes, batch local updates, and select only the state each widget needs. Add incremental reduction/checkpoints when profiling justifies them. Unknown event versions must preserve the raw event and show an update-required state; never reinterpret unknown input as an out.

### Proposed sync protocol

1. **Push commands/events in bounded batches.** Idempotency keys prevent retry duplication. Server authorizes each command and verifies its expected game revision and scorer epoch.
2. **Acknowledge explicitly.** Remove only the exact acknowledged outbox operations. A later local edit remains pending even if an earlier upload finishes afterward.
3. **Pull deltas with a server cursor.** Use a commit-safe change feed, ordered pagination, bounded snapshot watermark, and atomic page-apply plus cursor persistence. Include tombstones. Never advance to the phone's current clock. A bare sequence allocated before commit is insufficient: serialize revision allocation/commit per scope or use a feed whose cursor cannot skip later-committing transactions.
4. **Bootstrap membership separately.** Joining a team grants a paginated snapshot, even if every record predates the user's previous cursor. Scope cursors/cache by authenticated account and team/private dataset.
5. **Retry deliberately.** Exponential backoff with jitter, foreground/resume/connectivity triggers, and batched pending changes. Connectivity is a hint, not evidence of a working internet connection. Background execution is opportunistic; resume must finish interrupted sync.
6. **Resolve conflicts by domain.** Independently changed metadata fields may merge. Concurrent scoring sequences do not. Hold the conflicting branch locally, show a meaningful comparison, and let an authorized scorer reconcile it. Preserve rejected edits so nobody loses a dugout record.

One phone is the active scorer by default. The server uses a game revision plus scorer epoch to fence stale writers. Transfer requires acknowledging the current revision; an older offline phone cannot later replace accepted game history. Same-phone handoff needs none of this overhead.

Ship pull-on-open/resume and refresh first. Live viewing can later use private, team-authorized Broadcast notifications to trigger delta pulls; notifications are not durable storage. Subscribe only while viewing the game. Supabase currently recommends Broadcast for scalability/security over Postgres Changes. [Supabase change subscriptions](https://supabase.com/docs/guides/realtime/subscribing-to-database-changes).

### Entitlements and data ownership

- **Free local:** personal/team scoring, roster, competitions, stats, local history, manual export/import. No account required; no artificial game limit.
- **Player Plus:** encrypted transport to private cloud backup and multi-device sync for personal datasets. Exact retail pricing requires validation.
- **Team Plus:** team-owned backup, shared roster/schedule/stats, invitations, and authorized scorer transfers. The team subscription covers invited players' access to that team's synced data. Nobody should pay merely to see stats their team already paid to share.
- **Expiry:** keep all local data usable and exportable. Stop new premium cloud writes after a disclosed grace policy; keep an account-accessible recovery/export path for retained server data. Publish retention/deletion terms before sale. Team ownership transfer preserves the dataset independently of the former payer.

Server-owned entitlement records gate premium writes; never trust a client flag or editable JWT metadata. Handle subscription restores, refunds, delayed webhook delivery, and offline entitlement caching. Do not offer a paywall in the middle of scoring.

### Security and resilience

Create team and initial owner atomically in a restricted server operation. Membership insertions require validated invitations or authorized owner/manager actions, with role ceilings. Use RLS on every exposed private/team table, check relationships against the same team, and test reads as well as writes. RLS is enforced per row, not inferred from being signed in. [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).

Tokenized invitations should expire, be revocable, rate-limited, and stored as hashes where practical. Claiming a player needs a deliberate authorization path. Partition caches on account changes; preserve signed-out local datasets without leaking the previous account's private data. Revocation stops future access; previously downloaded information cannot be remotely unlearned.

Use OS-protected credentials, minimized diagnostic payloads, verified backup restore, and export/import with schema version and integrity checks. Device-only data can still be lost with a lost phone or uninstall; describe that fact briefly in backup settings. On a database write failure, preserve the draft and show a retry action instead of displaying false success.

## 8. Concrete findings in the current code

These are working-tree findings, not a claim about the deployed database. No live server schema or policies were inspected or modified.

1. **Sharing blocker — membership self-enrollment.** `supabase/migrations/20260904120000_initial_schema.sql`, policy `team_members_insert_self_owner`, accepts `user_id = auth.uid()` without an invitation/team-ownership condition. A known team ID can be used to request membership with an arbitrary role. Fix membership bootstrap and role escalation before enabling team sharing.
2. **Sync is incomplete.** `core/services/sync/sync_engine.dart` loops over many tables, but dirty mapping and remote apply handle only `teams`. `people`, `personal_teams`, and `game_events` also lack equivalent definitions in the checked-in initial remote migration. Local schema version is 6. Inventory both schemas before promising backup.
3. **Cursor can skip data.** `_pull` selects after a timestamp then stores device time, without ordered pagination. It advances even for tables whose rows are ignored. Concurrent/clock-skewed arrivals can be missed. LWW appears in comments, but unconditional upsert does not enforce a newer-wins server condition.
4. **Runner run attribution is incomplete.** `ScoringEngine` returns `scoredPlayerIds`; `GameReplay._team` records only whether the current batter scored on that same play. A runner who singles and scores on a later teammate hit can be omitted from their individual R total. Preserve and aggregate runner events by identity.
5. **Scoring is too compressed.** `_fieldersChoice` retires the most advanced runner; `_hit` advances everyone equally; `_adjust` edits run counts without out timing. These are plausible suggestions, not enough information for complete slowpitch scorekeeping.
6. **Replay depends on mutable settings.** `ScoringRepository.replay` reads current team rules/current lineup. Historical outcomes can change after settings edits. Snapshot rules and event-version lineup changes.
7. **Scoring mutations are not atomic.** `recordPa` inserts, then calls `rebuild`; rebuild makes several independent writes. Crashes can leave projections inconsistent, and concurrent commands can compete for sequence numbers. Wrap command, event, projection, and outbox writes in a transaction and serialize per game.
8. **Finality is fragile.** `rebuild` writes `status: live` whenever plays exist. A stats correction can implicitly reopen a final game. Finalization and reopening need explicit lifecycle operations.
9. **Unknown values silently become outs.** `PaResult.fromWire` falls back to `out`. Preserve unsupported data and stop just the affected interpretation instead of corrupting a career average.
10. **Personal scoreboard conflates quantities.** `_personalRunsFor` derives team scoring from RBI plus own run, alongside teammate totals. Replace this with independent authoritative half totals to avoid omissions and double-counting.

Preserve existing uncommitted work. The proposal changes no application or database behavior.

## 9. Efficiency, operating cost, and scope discipline

Local computation should handle scoring, filtering, charts, and share-card rendering. Upload compact canonical events and necessary metadata, not every derived stat row after each replay. Use local aggregated queries, lazy game history, and indexes proven by query plans. Split `tracker_repository.dart` by domain as those workflows change, without building a generic repository framework.

Keep one managed Postgres backend and one sync coordinator. Avoid microservices, a CRDT for inning state, AI inference in the scoring path, continuous polling, and media/video storage for launch. A managed sync vendor is worth evaluating only if its offline conflicts and per-user cost beat this bounded append/event workload; do not switch before a two-device fault-injection prototype.

**Illustrative capacity model, not measured usage or a cloud bill:** 100 team games × 80 events × 1 KB/event ≈ 8 MB of raw event payload per team per year. At 1,000 such teams that is about 8 GB before indexes, replicas, backups, metadata, corrections, and retention. Syncing the entire payload to 15 members would mean roughly 120 MB/team before protocol overhead; actual scope and caching change this. Measure those multipliers.

The operating-cost dashboard should track storage growth, bytes pulled per active team, realtime fanout, authenticated users, email delivery, retries, and restore costs. Revenue modelling must also include payment fees, taxes, support, and refund/retention policy. Supabase has separate plan/usage cost dimensions; obtain a current estimate at launch rather than freezing today's quote into the architecture. [Supabase pricing](https://supabase.com/pricing).

Do not sell enhanced sync until a clean-device restore recovers a full season. A manual portable export is a launch requirement even for free users.

## 10. Delivery sequence and release gates

### Phase 0 — protect truth

Implement runner/out events, game rule snapshots, lifecycle events, atomic local writes, explicit unknowns, and complete run/stat projections. Reconcile local/server schemas and repair the membership model in a tested migration before cloud sharing. Capture current UI and behavior tests before changing them.

**Gate:** deterministic replay; correct individual/team totals on a reviewed scoring fixture set; crash recovery without lost acknowledged plays; cross-team and self-role-escalation tests reject access.

### Phase 1 — the dugout experience

Implement the refined diamond, plain-language outcome strip, visible Undo, same-phone Handoff, missed-play recovery, independent personal score totals, draft restore, and coherent You/Teams/Games navigation. Build the visual tokens and outdoor/accessibility modes alongside these flows.

**Gate:** people who have never seen the app can finish a simulated inning and handle a handed-over phone. Correctness and speed both improve relative to the current build.

### Phase 2 — connected team beta

Complete identity linking, invites/claims, team roles, portable backups, paginated sync, conflict handling, new-device restore, entitlement enforcement, and optional device transfer. RSVP and shared schedules land here after core sharing works.

**Gate:** two-device disconnect/reconnect, duplicate delivery, late commits, revoked membership, expired plan, clock skew, partial bootstrap, and account-switch tests pass. No silently discarded scoring branch.

### Phase 3 — career and competition depth

Polish season/tournament views, qualified leaderboards, carefully scoped trends, share cards, coverage labels, and optional spray/contact tagging. Add live viewers only after measuring demand and fanout costs.

**Gate:** a full season remains quick to browse; all aggregates reconcile; sparse data never presents as a complete sample.

Defer chat, team discovery, full opponent scoring, streaming video, watch scoring, automated lineup optimization, and speculative “AI coach” features. They do not solve the current hand-the-phone problem.

## 11. Validation plan

Baseline: **94 existing scoring/replay/repository/stat tests passed** on September 8, 2026. This verifies their current expectations; it does not cover all rule cases or invalidate the static findings above. No new product code was implemented for this proposal. Existing golden renders were inspected; the live app was not device-profiled.

Build a rules-reviewed fixture pack: loaded walk, choice with different runners retired, hit plus error, runner out stretching, two-out force, timing third out, double play, sacrifice eligibility, courtesy runner, substitute, HR excess, tie-break runner, walk-off, mercy end, scoreless inning, abandoned game, and historical edit. Include aggregate invariants: no duplicated runner, valid bases, deterministic replay, correct R credit, and team totals equal known credited runs plus explicitly unassigned runs.

Benchmark targets to validate, not current measurements: common at-bat median ≤2 seconds, p90 ≤4 seconds; handed-over phone first play ≤10 seconds without coaching; local durable save p95 <100 ms; cold start to usable local home p95 <1 second on the agreed baseline device. Profile both 60 Hz and 120 Hz devices at their frame budgets, in release/profile mode. Flutter recommends controlling rebuild work and expensive rendering operations. [Flutter performance guidance](https://docs.flutter.dev/perf/best-practices).

Recruit 6–8 rec players across personal trackers and managers for a formative study, including people unfamiliar with scorekeeping. Test with a scripted inning, a forced interruption, sunglasses/outdoor conditions, and airplane mode; follow with real games. Measure correction frequency, wrong-batter errors, incomplete games, restore success, and willingness to hand over the phone. Treat this as usability learning, not a statistically representative market study.

## Decision to carry forward

The overhaul should be driven by **fast, recoverable, accurate game recording**. Keep the distinctive diamond. Invest first in trustworthy scoring and local durability, then make team sharing the paid convenience that naturally grows from a game people already enjoy recording.
