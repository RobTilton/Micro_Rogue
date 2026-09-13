# Production Promotion — Handoff
Updated: 2026-09-12
Checkpoint: [Production Promotion]+[Validation]+[Adoption]
DOTS: [DOTS.md](DOTS.md)

Rob accepted the working game and explicitly authorized Production promotion, root F5 adoption, runtime independence and safe save continuity. Active runtime: **Production/main.tscn**. Read Production/README.md and module READMEs for ownership; CURRENT_STATE.md and PROMOTION.json record transfer evidence.

No source gameplay was changed. Required code/art was copied and references relocated; save storage now uses user://worlds/ with folder creation. Workshop and earlier Production files remain intact. The previous root configuration and README contents are retained in Reference/. No Git commit or deletion was authorized or performed.

## Save migration

Actual source folders contained no complete user saves at inspection. Run `tools/migrate_saves.gd` with the root project if a subsequent explicit transfer is needed. It imports only actual World Foundation saves, excludes tests, validates them, preserves exact copies and will not supersede existing Production progress. The tool deliberately lives outside Production; no runtime folder probing or cross-dependency is introduced.

## Human verification

Press F5 from the root project. Generate a world, create the adventurer, enter a Local/POI, make an inventory or combat action, stop and use Continue world. This is the promoted copy of the accepted experience. New work should name its Production module or use a bounded Workshop experiment; do not resume editing an old Room and assume F5 uses those files.

Generated validation packages, screenshots, snapshots and fixtures remain retained under this Room. The isolated validation run uses a different user-data app identity, so it does not create a playable test world in the normal game's Continue list.
