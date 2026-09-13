# Regional Foundation — DOTS
Updated: 2026-09-12
Checkpoint: [Regional Foundation]+[Persistence]+[Validation]

Adoption: Rob approved this generation and requested Production promotion with edge entry, a hex start menu and one-save regeneration. [Regional Release](../Regional%20Release/CURRENT_STATE.md) records the delivered successor. The behavior described below is the preserved source Room, not the current F5 release.


Approved: Rob accepted the proposed Regional Foundation boundary and asked “can we do it now?”. Implement in Workshop; preserve Production, root launcher and existing saves. No deletion or commit. Baseline: Production/BASELINE.json and SOURCE_BASELINE.json; no user Git checkpoint supplied.

Scope: fixed radius-20 hexagonal Locals (1261 cells), regional truth, hostility source changes with one point decay per Global hex, generation/re-entry revision synchronization, persistence and fresh-world validation. Record roads/fast-travel thought. Exclude actual neighbor travel, roads, economy/prosperity formulas, suppression stacking, monster families and quests. Existing physical map/actor facts must survive updates.

| Checkpoint | Depends on | Completion | Status |
|---|---|---|---|
| [Regional Foundation]+[Delivery]+[Contract] | approved scope | dependency baseline recorded, Room entry | complete |
| [Regional Foundation]+[World]+[Geometry] | Contract | 1261 playable cells, valid terrain/entrances/six boundaries | complete |
| [Regional Foundation]+[World]+[Regional] | Geometry | sources update Global truth and live/lazy Local caches | complete |
| [Regional Foundation]+[Persistence]+[Validation] | Regional | save/restart, event atomicity, rendering and regressions pass | complete |
| [Regional Foundation]+[Delivery]+[Playtest] | Validation | Rob validates F6 Room scene | awaiting_validation |

Starting state: copied runtime script closure, shared read-only Production art. Own user://regional_foundation/ saves. Production remains F5. Geometry: 96,399 checks across 11 biomes × 3 seeds, including inherited river/water boundaries and wrap. Regional: 12,112 checks including source decay, atomic rejection, live/lazy synchronization and journal restoration. Actor regression: 134 checks. Implementation validation complete; next is Rob’s F6 Playtest. All outputs retained.

## Closeout evidence

- Geometry: 96,399 checks, 11 biomes × 3 seeds; full six-sided outline inspected in tests/local_overview.png.
- Regional truth/persistence: 12,112 checks, including preservation of real actor equipment and health through late-source updates and reload.
- Shared actor regression: 134 checks.
- Automatic persistence: 17 checks; frontier-movement delta 827 bytes in measured run; interrupted tail recovery and exact state equality pass.
- Rendered UI: 19 checks; fade, Local travel, nested Town/Well/Underground, unload and reload pass; tests/local_gameplay.png inspected.
- Independent process: exact restored journal state passes in tests/restart_test.gd.
- Room boundary audit passes: imported Production scripts unchanged, only read-only Production art dependencies, F5 remains Production, separate save namespace.
- Production's strict historical hash audit reports only main.tscn. It already contained UID annotations and editor blank-line formatting when read for this Room; removing those annotations/blank lines in memory exactly matches its locked hash. All other 138 Production resource hashes match. No Production files were rewritten to normalize editor metadata.

Last completed: [Regional Foundation]+[Persistence]+[Validation]. No active implementation Box. Pending: [Regional Foundation]+[Delivery]+[Playtest]. All Room code, copied dependencies, tests, fixtures and captures retained; no deletion, save reset, Production promotion or Git commit. Roads thought recorded; current-state, README, design refinements and handoff synchronized.

Human feedback: Rob reports “the hex map shapes look solid.” Geometry appearance is accepted; this does not establish full gameplay/persistence acceptance or authorize Production promotion. Right-click contextual menu remains unimplemented and outside this Room’s delivered scope.
