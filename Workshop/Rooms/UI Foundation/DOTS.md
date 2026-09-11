# UI Foundation — DOTS
Updated: 2026-09-11
Checkpoint: [UI Foundation]+[Organization]+[TileRoomHandoff]
Implementation baseline/evidence: existing uncommitted Prototype; preserved source documents under Reference/Before_Tile_Foundation_2026-09-11; current transfer hashes in ../Tile Foundation/BASELINE.json.

## Room Contract

The existing UI/inventory/map prototype is retained. Rob authorized cleaning the Room and moving tile work into a dedicated Room after an alignment limited to art review, documentation and preserved resource paths; “Execute Bro” on 2026-09-11. No runtime migration, deletion, Production changes or Git commit in this pass.

## Current Traversal

- Last completed checkpoint: [UI Foundation]+[Documentation]+[GenerationReference].
- Active implementation checkpoint: none; LocalPoiSpacing delivered, human exploration review pending.
- Pending human checks: prior UI/tile-menu acceptance and newer terrain visual review; no blanket Room acceptance claimed.
- Next eligible action: Rob explores a new Workshop Local map to judge POI spacing. Tile style review remains in [Tile Foundation DOTS](../Tile%20Foundation/DOTS.md).

## Box Disposition

| Checkpoint | Responsibility | Depends on | Completion condition | Status | Evidence |
|---|---|---|---|---|---|
| [UI Foundation]+[Organization]+[TileRoomHandoff] | Preserve old notes, reconcile current entry and transfer tile work | Existing Room state | Preserved bytes, linked current docs and valid transfer | complete | Reference/Before_Tile_Foundation_2026-09-11; Tile Foundation/HANDOFF.md |
| [UI Foundation]+[Validation]+[Playtest] | Remaining human interface/tile-menu acceptance | Delivered interface work | Rob confirms remaining behavior | awaiting_validation | Prior reports; no new human acceptance |

Previously delivered implementation checkpoints retain their identities in the preserved DOTS: Inventory, Wireframe, SingleProject, TileInspection, FloatingPanels, ItemCards, SharedMaps, TileChoices, ProductionPromotion, OverworldBiomes, PoiBadges, ExpandedMaps, Wetlands, WastelandArt, TravelCosts, WorldContract, RiverEdges and DrainageAndCoasts. The later Local terrain/lake/stripe notes did not consistently assign Box identities; do not invent a historical identity or infer acceptance from their completion prose. Detailed old evidence remains retained, while current tile behavior/limits are consolidated in Tile Foundation/CURRENT_STATE.md.

## Current References And Disposition

[Current state](CURRENT_STATE.md), [launch guide](README.md), [tile handoff](../Tile%20Foundation/HANDOFF.md). All output retained in place. This transfers the active tile-work context; it does not declare all UI Foundation human validation complete.

## Local POI Spacing

Rob issued “execute” after the alignment to spread the existing Dungeon/Town/Tower across Local maps using seeded random dry-cell placement, preserve Return/island Tower and persistent round trips, validate biomes/seeds and update Workshop docs. Scope is this prototype and relevant tests/docs; random enemies/loot, art changes and Production remain outside this pass.

| Checkpoint | Responsibility | Depends on | Completion condition | Status | Evidence |
|---|---|---|---|---|---|
| [UI Foundation]+[World]+[LocalPoiSpacing] | Seeded separated Local destinations | Existing map/water generation | Dry distinct seeded placements; retained island/return links; focused checks pass | complete | Godot 4.4.1: 5,560 placement checks across 264 biome/seed cases; map 27, tile choices 11, pan 27; lake basins 40 seeds |

LocalPoiSpacing preserves one each Dungeon/Town/Tower plus fixed Return. Placement runs after water generation, reserves island Towers, chooses seeded random candidates within 80% of the best minimum hex distance from already reserved entrances, then updates child return coordinates. Dry candidates are never carved out of water; insufficient dry cells refuse without changing links. Six-hex minimum observed in the 264 tested cases is validation evidence, not a universal hard constraint on arbitrary future maps. Existing instantiated maps retain their placement. No random encounter/loot implementation, art changes, Production promotion or commit.

## Current Generation Reference

Rob requested a document explaining how the game is generated now. Scope: inspect current Workshop generation/encounter/item owners, write GAME_GENERATION.md and synchronize references; no runtime changes.

| Checkpoint | Responsibility | Depends on | Completion condition | Status | Evidence |
|---|---|---|---|---|---|
| [UI Foundation]+[Documentation]+[GenerationReference] | Explain current generation and limits | LocalPoiSpacing and current generation owners | Reference checked against implementation; links resolve | complete | GAME_GENERATION.md checked against current owners; relative links verified |

Actor Foundation is now a separate delivered consumer of this prototype: [Actor DOTS](../Actor%20Foundation/DOTS.md). Its execution authorized the `_make_board()` extension point in ui/workshop_game.gd. Baseline 2,027, UI 79, drag 8 and floating-panel 14 regressions pass. This does not mark pending UI human acceptance complete.
