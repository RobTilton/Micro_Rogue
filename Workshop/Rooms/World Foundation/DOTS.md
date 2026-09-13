# World Foundation — DOTS
Updated: 2026-09-12
Checkpoint: [World Foundation]+[Validation]+[Integration]
Implementation baseline: accepted Actor Foundation, UI Foundation generation and Workshop/Design/Hierarchical_World_Gen.md; no user Git checkpoint supplied.

## Contract

Rob requested implementation of the entire hierarchy alignment now. Scope: dedicated Workshop scene, common location registry/resolver, recursive template instances, inherited geographic boundary contracts, durable save/load and map unload/reload, event-created POIs, and composed actor/pursuit validation. Preserve existing scenes/assets and actor rules. No Production changes, deletion or commit. Examples such as roads/factions are future content, not an obligation to invent every system named in the architecture.

## Traversal

Implementation complete. Next: Rob’s World Foundation playtest. Rob accepted the working World Foundation game and authorized Production promotion. Canonical runtime is now Production/main.tscn; this Room remains the preserved development source.

| Checkpoint | Responsibility | Depends on | Completion | Status | Evidence |
|---|---|---|---|---|---|
| [World Foundation]+[Locations]+[Registry] | Stable catalogue and ensure-location | existing maps | identity/load/generate tests | complete | world_test.gd; stable catalogue, lazy resolution and Return restoration |
| [World Foundation]+[Locations]+[Templates] | Template instances and arbitrary-depth children | Registry | lazy Dungeon and Town/Well recursion proofs | complete | world_test.gd; Town/Well/Underground, lazy floor and seven further depths |
| [World Foundation]+[Geography]+[Boundaries] | Canonical parent boundary contracts | Registry | neighbor profiles and constrained rivers verified | complete | world_test.gd; three-seed contracts and resolved routes; boundary/coast proof captures |
| [World Foundation]+[Persistence]+[Snapshots] | Versioned saves and unload/reload | Registry, Templates | restart/actors/loot/Return persistence | complete | world_test.gd; full roundtrip, corrupt-save refusal; restart_test.gd 14 checks |
| [World Foundation]+[Locations]+[Events] | Atomic POI requests | Templates | accepted/rejected and same-type instances | complete | world_test.gd; same-type IDs and atomic rejected unseen-parent requests |
| [World Foundation]+[Validation]+[Integration] | New scene and existing actor behavior | all implementation Boxes | tests, render and current docs | complete | 58,503 world + 12 World UI + 14 restart; 134/17 Actor and 2,128 shared regressions; rendered captures inspected |
| [World Foundation]+[Validation]+[Playtest] | Rob's review | Integration | human acceptance | complete | Rob: everything in the game is working; explicit Production promotion authorized |

All outputs retained. Saves use unique snapshot filenames; saving never overwrites or deletes an earlier snapshot.

## Closeout

All six implementation checkpoints delivered under Rob’s authorization to implement all hierarchy stages. No Production changes, launcher adoption, deletion or commit. Detailed behavior, limitations and retained output disposition are synchronized in CURRENT_STATE.md, GENERATION.md, HANDOFF.md and prior Room references. Saves and test fixtures remain on disk; automatic checkpoints now supersede the original manual-save requirement (see the 2026-09-12 checkpoint below).

## Playtest correction — 2026-09-12

[World Foundation]+[Presentation]+[TravelFade] — complete; human feel check pending. Rob noticed a brief Local-generation hitch and requested fade-out/in. Add a short travel-only transition, generate after the opaque frame is presented, and block duplicate input during the transition. Movement remains immediate. Validate transition timing and existing World UI travel.

Travel fade validation: World UI 17 checks, zero failures on the actual OpenGL backend. The map changes behind a full-viewport opaque cover; duplicate entry is blocked; overlay survives scene rebuild and is hidden afterward. Fade timings: 0.12 seconds out and 0.12 seconds in. Initial overlay lifetime failure corrected before delivery.

## Automatic persistence and startup topology — 2026-09-12

[World Foundation]+[Persistence]+[Automatic] and [World Foundation]+[Generation]+[Topology] — complete; human playtest ongoing. Rob wants saving removed from player responsibility, explicit world-first startup, and substantially different Global layouts rather than repeated X/hex silhouettes. Implement durable automatic checkpoints including the generated world before character creation; preserve existing snapshots. Replace new-world topology within World Foundation only, validate seed reproducibility, varied silhouettes, viable spawn and restoration. Volcano/earthquake ideas are documentation only, explicitly not authorized for implementation.

Automatic/topology evidence: 16 automatic persistence checks, 8 separate-process compatibility checks, 2,721 topology checks across 32 seeds, 58,454 hierarchy checks, 14 restart/pursuit checks and 17 rendered World UI checks — all pass. Six generated topology variants inspected. Startup checkpoints the world before character creation and retains the creation roll. Incremental journal snapshots match complete state; interrupted tails and incomplete first records recover via Continue. Existing generator-one worlds retain their Global layout. User thought file created without implementing geological events. CURRENT_STATE, README, GENERATION, HANDOFF and save-storage guidance synchronized.

## Accepted and promoted — 2026-09-12

Rob accepted current gameplay and issued Execute for the aligned promotion. [Production Promotion](../Production%20Promotion/CURRENT_STATE.md) owns the transfer evidence. F5 now uses Production/main.tscn with independent resources and user-data saves. This Room stays preserved; later edits here do not automatically change Production. Source acceptance does not imply final water/art quality or implementation of deferred ideas.
