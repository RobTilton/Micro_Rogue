# Production Promotion — Current State
Updated: 2026-09-12
Checkpoint: [Production Promotion]+[Validation]+[Adoption]
Baseline: Rob accepted the current working World Foundation game and authorized promotion. PROMOTION.json records exact source hashes and the preserved earlier Production/Current baseline. No user Git checkpoint supplied.

## Delivered components

69 required source files were copied/remapped into Production/main.tscn and distinct Actors, World, Persistence, UI and Assets folders. One new storage-path module centralizes user://worlds/. Save/unload operations create their own writable folders; test storage can be isolated. No gameplay feature changes or edits to the accepted source scripts/assets were made.

Every active runtime resource resolves inside Production. Placeholder art is copied, not linked. The earlier Production/Current, Gameplay and Splash builds remain preserved and separate. UI inheritance is retained inside its owning module; a full controller rewrite is not part of this promotion.

## Validation evidence

Source hashes and earlier Production/Current hashes match the starting manifest. All texture import parameters match their originals. Resource-boundary audit passes.

Production-targeted checks: hierarchy 58,454; topology 2,721; actor simulation 134; actor UI 17; baseline rules 2,027; UI 79; drag 8; floating panels 14; autosave 16; restart/pursuit 14; autosave restart/legacy 8; migration 12 — all pass. Rendered World UI: 17 checks pass on OpenGL. Its viewport-size assertion is not meaningful under the headless viewport and was verified with an actual window.

An isolated PCK contains the promoted modules/assets and validation harness, without Workshop or earlier Production files. Its 13 checks pass: startup, dynamic artwork, Local generation, map unload/Return, extra snapshot and automatic resume. OpenGL capture inspected: tests/production_isolation.png. The isolated run uses a separate app-data identity and cannot populate the player's Continue list.

## Persistence continuity

SAVE_INVENTORY.json found no complete user .world/.journal saves in the actual World Foundation save folders. Test fixtures are deliberately excluded from migration into the player's storage. Migration tests exercise a preserved generator-one snapshot and current journal, preserve source/copy hashes and exact restored state, and verify repeated migration cannot roll back Production progress. tools/migrate_saves.gd provides the one-time transfer path without introducing runtime coupling.

F5 adoption is complete: root project.godot launches Production/main.tscn, and an actual root-project OpenGL startup exited without errors. SAVE_MIGRATION.json confirms no complete user saves were available; no fixture world was imported into normal user storage. Root, Production/module and source-Room documentation is synchronized.

Production/BASELINE.json records 139 owned source/import resource hashes. tools/audit_release.py verifies those hashes, all 69 accepted source hashes, the earlier Production/Current baseline, resource boundaries and F5 entry. Final audit passes. The test suite totals 63,534 checks across the listed suites and isolated runtime. Validation outputs, fixtures and the PCK remain retained in this Room; no deletion or Git commit occurred.

Human validation of the promoted F5 entry remains pending. Source gameplay acceptance is already recorded.
