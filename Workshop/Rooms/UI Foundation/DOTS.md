# UI Foundation — DOTS

## Global Terrain Travel Cost — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[TravelCosts]
Rob specified global crossing multipliers: Mountains 3, Hills 2, Forest 1.5, Swamp/Marsh/Salt Marsh 2, Plains/Wasteland 1. Saltwater interpreted as Salt Marsh given oceans were explicitly deferred to later boat travel. Desert defaults to normal 1. Sea/Lakes retain prior provisional traversal (1) until water travel rules are defined; boats not implemented.

`domain/travel_cost.gd` stores half-step integer units, avoiding per-hex rounding of forest costs. Dijkstra in movement_preview chooses minimum-cost routes within existing 3+DEX movement budget. Cost is paid for the entered tile, not the origin. Global preview displays terrain cost/budget. Local/POI movement remains cost 1; combat action allowance unchanged. This limits distance per movement command; it does not create a world-time simulation or additional out-of-combat action costs.

Validation: 12 targeted checks (multipliers, cheaper detour, forest fractions, range limit, local unaffected), plus map/UI/tile-choice regressions. Workshop only, F6. Island overlay and river work mentioned by Rob remain separate future inputs; no river generation or crossing mechanic claimed. Latest checkpoint complete; human travel playtest pending. No Production changes/deletion/commit.


## Marsh Artwork and Explicit Wetland Rules — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[Wetlands]
Rob corrected the upload name to MARSH; Local_Map_Marsh.png integrated using seven explicit mud/reed/shallow-pool samples. Props/bridges/buildings unassigned. Marsh uses this artwork on Global and Local. Swamp temporarily uses Forest art and Salt Marsh uses Sea art/local water geometry until their own assets arrive; biome identities and labels are distinct.

Rob's latest rules supersede previous proposed elevation/moisture restrictions for wetlands: base Plains adjacent to Sea or Lakes becomes Marsh; base Forest adjacent to Sea or Lakes becomes Swamp; base Plains with at least four Sea neighbors becomes Salt Marsh (takes priority over ordinary Marsh). Applied simultaneously against a snapshot after the noise classification, not cascading. Out-of-bounds cells do not count. Rob corrected Salt Marsh to Plains, not water: Sea and Lakes remain water. Child maps inherit resulting biome metadata. Local Salt Marsh uses sea water generation/dry entrance paths. Movement remains unchanged.

Validation: 35 targeted wetland-rule checks, 867 deterministic biome checks, 270 water checks, 27 map checks pass (1,199). Godot Marsh capture inspected in tests/terrain_marsh.png. Workshop only, F6; Production unchanged. No image generation/deletion/commit. Latest checkpoint complete; human review and future Swamp/Salt Marsh art pending.

Wasteland restriction clarification retained: FutureWasteland entirely barred; first Wasteland sheet usable except its roads; _02 fully usable including stone roads. Current selected ground samples comply.


## Wasteland Sheets — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[WastelandArt]
Rob provided two usable Wasteland sheets and explicitly excluded the modern third. Runtime `ui/wasteland_art.gd` names only Local_Map_Wasteland_DO_NOT_USE_THE_ROADS.png and Local_Map_Wasteland_02.png. Six explicit ground samples include both sources, omit every road tile and avoid implied functional ruins/portals. Stable per-cell selection feeds world_view's local Wasteland rendering. POI badge priority is unchanged.

DO_NOT_USE_FutureWasteland.png is preserved and has no runtime reference; it was not opened for visual inspection. Original sheets preserved. Godot editor import may maintain asset metadata for repository images; that is not runtime selection. No wildcard asset loading is used.

Validation: actual Godot capture `Prototype/tests/terrain_wasteland.png` inspected: cracked ground and fantasy rock details, no modern roads. Presentation-only change; no gameplay mutations. Workshop F6, no Production promotion. Awaiting next swamp/marsh sheets. Latest checkpoint complete; human visual review pending.


## Terrain Batch: Hills, Mountains, Water, Desert — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[TerrainBatch]
Rob requested continued integration of new uploads, noted ocean/lake special handling, and supplied Desert. Workshop now samples Local_Map_Hills (two flatter first-row variants), Local_Map_Mountains (two flatter first-row variants), Local_Map_Desert (eight first-row variants), and Ocean_And_Lake_Tiles (three open-water variants each for sea/inland water). Existing Plains/Forest and POI artwork remain. Source PNGs preserved; no image generation.

`domain/local_water.gd` deterministically generates water patches in Sea/Lakes local regions using noise seeded by world seed + region ID. Entrances and connecting dry paths are kept on land. Shoreline edges are computed from six neighboring hexes and drawn as narrow sandy/foam bands for sea and green banks for lakes. No edge is drawn between two water cells. Authored shoreline/feature tiles are reserved because this sheet does not provide a complete matching connection set. Water is still traversable; boat/swimming rules remain undefined. Not a claim of seamless art or hydrological simulation.

Validation: 270 water checks (determinism, dry entrances, shoreline neighbor conditions), 27 map, 27 pan, 11 tile-choice checks pass. All five terrain preview captures generated in tests/terrain_*.png; sea/desert/mountains visually inspected. Wetlands discussed only: possible future moisture/elevation + neighboring-water pass, with swamp vs marsh vegetation; not implemented and no sheet loaded yet. Rotation/mirroring approved where appropriate; this batch keeps original orientation, shore geometry already follows all six edges.

Workshop only: open Prototype/ui/main.tscn and F6. Root F5/Production unchanged. Latest checkpoint complete; next: human terrain review and integrate further supplied sheets. No deletion/commit/promotion.


## Expanded Maps / Local Terrain / Panning — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[ExpandedMaps]
Rob requested Local_Map_* integration, four-times maps, and mouse dragging; clarified ALL layers and unchanged tile size. Scope implemented in Workshop; F5 remains previous Production. Open Prototype/ui/main.tscn with F6.

Dimensions doubled on each axis, yielding four times the prior cell count: Global 24×18 (432), Local 14×12 (168), POI 18×14 (252). Tile radius stays 32 logical pixels; auto-fit shrinking removed. No zoom was added because unchanged tile size satisfies the clarified choice. Existing entrance locations/encounter setup remain, so new area is exploration space, not additional generated POIs/enemies.

World view handles left/middle drag panning on all layers. Seven-pixel threshold separates left-click release from dragging, avoiding movement or menu actions during a pan. Shift-click still bypasses confirmation. Per-map view offsets persist in memory through travel; first visit centers player. Map panel provides Center on player. Focus loss clears drag state. Panels and inventory retain their own input handling. Floor drawing filters offscreen cells, but enumeration still traverses the finite map; this is not chunk streaming. Map borders can be panned past; Center on player recovers the view.

Local_Map_Plains.png and Local_Map_Forest.png provide eight first-row ground variants for matching region biomes, stable by region ID/cell. Other local biomes retain the prior ground fallback. Road and object rows are reserved; no new collision/road rules inferred from art. POI badges and black POI wall tiles remain. The source sheets are preserved and sampled via UVs.

Validation: 27 pan/size checks (left and middle drags, no click on drag, correct hit after pan, per-map restoration, recenter and offscreen filtering across all layers), 867 biome checks and 163 map/UI/input regressions pass (1,057 checks this iteration). Forest rendering inspected in expanded_forest_region.png; that initial capture forced the forest variant and retains a mismatched random region title. Capture helper now selects an actual Forest region for future captures. Production untouched; human playtest pending; no deletion/commit.


## Local POI Artwork — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[PoiBadges]
User supplied `Workshop/Chad-Casso/POI_Overlay_Tiles.png` for local POI markers. `Prototype/ui/poi_art.gd` samples hex badges from the sheet: village for Town, stone doorway for Dungeon, ascending stairs for Tower. These are map symbols, not changes to interior wall rendering. The source has a painted background, so badge UVs crop the art within a hex rather than assuming transparent overlays. Unused cave/fort/castle/boat/descending-stairs artwork remains available without inventing new POI types.

World view draws badges during the floor pass, beneath actors and loot; orange hex outline identifies entrances and hover tooltips name destinations. Return retains R; Global retains biome artwork. Transitions, Move/Loot/Look behavior and map identities are unchanged. Workshop only, F6 on Prototype/ui/main.tscn; F5 remains Production.

Validation: 27 map and 11 tile-choice checks pass. Rendered local map inspected in `Prototype/tests/local_poi_badges.png`. Human visual acceptance pending. No image generation, asset rewriting, promotion or deletion.


## Overworld Biomes — current Workshop iteration
Updated: 2026-09-10
Checkpoint: [UI Foundation]+[World]+[OverworldBiomes]
Rob supplied `Workshop/Chad-Casso/OVERWORLD_TILES_BIOME.png` and requested noise-based global terrain. Implemented in Workshop only; Production/Current and root F5 remain the prior promoted baseline. Open `Prototype/ui/main.tscn` and press F6 for this iteration.

Global maps now have 12×9 hexes. `domain/biome_generator.gd` combines three seeded FastNoiseLite fields: elevation, moisture and temperature. Sampling uses axial coordinates transformed into evenly spaced world coordinates. Elevation selects sea/mountains/hills; wet lowlands become lakes; moisture and warmth select forest/plains/desert/wasteland. Each new run picks a seed, shown in the Map panel. Passing the same seed to MapWorld reproduces the biome assignment. No disk save or seed-entry UI is included.

The supplied sheet is sampled through inset hex UV coordinates for its eight named biomes. Only Global uses this artwork; local maps retain their existing visual template and inherit parent biome metadata for later local generation. Every global cell still opens its own local map. Water/mountains do not yet impose traversal rules; all biomes remain traversable. Global entry markers are suppressed to show terrain clearly; use Map/Activate at any global hex. The current global biome appears in Map. Board geometry and hit testing fit the map to available space; this is not streaming or large-world camera support.

Validation: 219 biome checks pass (repeatable seed, different seeds, all cells assigned valid biomes, local metadata). Existing movement/maps/UI/input checks total 163 and pass. Godot render inspected at `Prototype/tests/overworld_biomes.png`; seed 1729 contains all eight biomes (18 plains, 6 wasteland, 25 hills, 11 mountains, 21 forest, 15 sea, 6 lakes, 6 desert). Not every random seed is guaranteed all biomes. No generation calls, new image edits, promotion, deletion or Git commit performed. Human playtest pending.


## Promoted Current State — 2026-09-10
Checkpoint: [UI Foundation]+[Delivery]+[ProductionPromotion]
Rob confirmed map persistence works and requested promotion of all completed work, plus a Move/Loot/Look choice for dropped items on entrances. Implemented and promoted to `Production/Current`; root F5 launches that scene. Workshop remains available via its main.tscn and F6. This section supersedes earlier no-promotion, F5-Workshop, unfinished-ItemCards and image-export-loading notes below.

Tile click choices preserve movement confirmation, range-limited loot and appearance-only distant Look; entrance travel remains exposed on the player's tile. Item cards retain sword-only art and text placeholders for other gear. No new artwork was generated. Both builds use imported texture resources. Previous Production Gameplay/Splash retained as earlier baseline.

Validation: seven suites pass on each build (2,190 checks each: 2027 rules, 79 UI, 8 drag, 24 inspection, 14 floating, 27 maps, 11 tile choices). Production scene UID references were isolated from Workshop. Promoted launch script ownership and rendered menu verified in `Workshop/Tests/PromotedCurrent/production_tile_choices.png`. `Production/Current/PROMOTION.json` records promoted content hashes and origins. Persistence is in-memory only; no export artifact built. Human tile-menu playtest pending; prior persistence accepted. No Git commit/deletion.


## Current Checkpoint: Shared Map System
Updated: 2026-09-10
Checkpoint: [UI Foundation]+[World]+[SharedMaps]
Authorization: Rob approved global/local/POI shared grids, persistent round trips, black blocked hexes and existing combat integration: “I like it. Execute bro”. Workshop only; Production unchanged. Human playtest pending.

- New characters start on a 5×5 Global grid. Every global cell links to its own lazily created 7×6 Local grid. Each local grid contains Dungeon, Town and Tower entries and a return link. POIs use 9×7 grids with solid black boundary/interior walls. Town is an empty exploration template; Dungeon/Tower have one existing slice enemy. This is a fixed content skeleton, not full world generation.
- Move normally, then open the top-left Map control or Activate while standing on an orange entry marker. Press its entry/return button. Transitions are explicit; clicking a marker still uses movement confirmation. Return restores the prior map position. Labels identify destinations; markers use initial letters.
- `Prototype/domain/hex_map.gd` owns common dimensions, axial cells, wall/walkability data and links. `map_world.gd` owns lazy map identities/templates and per-map runtime snapshots. `movement_preview.gd` uses optional map data for bounds and walls; default open-arena behavior remains for baseline fixtures. `world_view.gd` sizes/centers/input-tests the active grid; `hex_board.gd` draws its cells, black walls and actors. Rendering remains limited to these small maps and currently draws the full active map; no world streaming/culling claim.
- `workshop_game.gd` owns map transitions and snapshots. Player stats/equipment/HP/XP/cooldowns travel with the player. Each map retains position, enemy, ground loot, battle flag, remaining actions and Riposte state in memory. Return does not respawn enemies, duplicate drops or reset actions. Travelling in combat costs activation; pending Lunge/Riposte movement must be finished/cancelled. Saved attack allowance is clamped against current equipment. Inactive maps pause. New run resets all maps; no disk save/load yet.
- Normal movement, Riposte retreat, Lunge and enemy pathfinding respect the active map's walls. Lunge now uses a turning path up to its existing DEX range, optional attack with unchanged +1.5 STR, one Attack action and cooldown; normal Move is retained. This supersedes prior straight-line Lunge notes for Workshop only.
- Validation: new map suite 27 checks; existing baseline 2027, UI 79, tile inspection 24, drag input 8, floating panels 14 all pass (2,179 total). Existing UI regression setup explicitly retains the original open-arena fixture; the map suite covers the new startup and integrations. Godot OpenGL capture inspected: `Prototype/tests/map_world.png`. New tests cover round trip, distinct local identities, town/tower, walls, curved Lunge, enemy movement, state/loot/action persistence, no free repeat escape and new-run reset.
- Known inherited presentation limitation: floor/item PNGs currently load as Images directly; Godot warns export packaging needs imported resources. Editor/runtime tests pass. Item-card presentation remains its own unfinished checkpoint. No Git checkpoint or promotion performed.

| Checkpoint | Responsibility | Dependency | Completion | Status | Evidence |
|---|---|---|---|---|---|
| [UI Foundation]+[World]+[SharedMaps] | Common grid, lazy map links, persistent state and blocked terrain | Existing hex/UI slice | Round trip and regression checks pass | complete | 2,179 checks; map_world.png |

Last completed: [UI Foundation]+[World]+[SharedMaps]. Next: Rob's map traversal playtest. ItemCards remains independently unfinished; all outputs retained.

Updated: 2026-09-10

## Room Contract

- Outcome: Plain modular rail/viewport/HUD UI, independently sized overlays, 8-column × 5-row inventory, transactional drag/drop, contextual belt targets and movement confirmation.
- Scope: Room UI plus explicitly requested single-project integration: root launcher/settings, nested configuration retirement, shared resource paths, relevant docs and obsolete Godot registrations. No Production gameplay changes, deletion or Git commits.
- Acceptance: Inventory bounds/non-overlap/no stacking/rotation/atomic refusal hold, existing combat works, layout follows sketches, automated checks and Rob's playtest.
- Authority: Rob answered “execute” to the UI Foundation alignment after confirming inventory dimensions, footprints, rotation and refusal of invalid swaps. “continue?” reaffirmed ongoing work.
- Baseline: Accepted Production slice; source hashes in BASELINE.json verified unchanged. No user Git checkpoint supplied or created.

## Current Traversal

- Last completed checkpoint: [UI Foundation]+[Interface]+[FloatingPanels]
- Active checkpoint: [UI Foundation]+[Validation]+[Playtest]
- Next eligible action: Rob opens root project.godot and presses F5 and playtests the interface; fix concrete feedback within this Room.
- Human acceptance / Git checkpoint: Pending / none created.

## Mandatory Box List

| Checkpoint | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| [UI Foundation]+[Systems]+[Inventory] | Grid, footprints, rotation, ownership and atomic transfers | none | Capacity/ownership/action checks pass | complete | Prototype/domain/grid_inventory.gd; regression checks pass |
| [UI Foundation]+[Interface]+[Wireframe] | Rail overlays, HUD, activation and movement preview | Systems Inventory | Integrated scene, input and rendered-layout checks pass | complete | Prototype/ui/; 2,114 checks across three suites; rendered captures inspected |
| [UI Foundation]+[Integration]+[SingleProject] | One root project and valid shared resource paths | Interface Wireframe | One project.godot, both scenes load and regression tests pass | complete | Root config, paths, docs and obsolete registration consolidated |
| [UI Foundation]+[Interaction]+[TileInspection] | Range-aware tile look/loot | Integration SingleProject | Range disclosure, pickup costs and movement/targeting checks pass | complete | 24 new checks and 2,114 existing checks pass; docs synchronized |
| [UI Foundation]+[Interface]+[FloatingPanels] | Draggable edge-docked overlays, no connector lines | Interaction TileInspection | Input/docking/regression checks and docs pass | complete | 14 targeted + 111 existing UI checks pass |
| [UI Foundation]+[Validation]+[Playtest] | Human layout and usability acceptance | Interface Wireframe | Rob verifies interface and interactions | awaiting_validation | Root F5 launches Workshop UI; awaiting Rob |

## Current References And Disposition

- [Current state](CURRENT_STATE.md): exact components, controls, contracts, validation and limits.
- [Launch guide](README.md): entry point within the shared project.
- [Baseline system contract](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/MICRO_ROGUE_SLICE.md): accepted Production behavior; not superseded.
- Retain all Room output. Production scripts match baseline hashes; root F5 now selects the Workshop UI. No promotion or deletion authorized/performed; no Git commit created.
- Mana, Gold, map layers, future item types and enemy scavenging remain deferred. Prototype has placeholders only where the wireframe reserves space.

## Single-Project Consolidation

Rob explicitly requested one Godot project at the repository root, with Workshop for development and Production for promoted work. Root configuration and scoped resource-path updates are now authorized. Preserve nested configuration contents as reference .cfg files. Set root F5 to current Workshop UI; Production remains independently runnable as a scene.


## Tile Look / Loot Follow-up

Rob requests clicking nearby item tiles to loot, and distant item tiles to inspect only visible characteristics. Item statistics require distance ≤ 1 hex. Scoped to Workshop UI and tests; existing loot costs/capacity rules remain.


## Floating Panels Follow-up

Rob requested removing rail-to-panel lines and movable floating/docking windows. Implement title-bar dragging, viewport-edge snapping, per-panel in-session placement memory and resize containment in the Workshop panel host. Keep current single-open-panel behavior and gameplay unchanged.


## Item Cards / Pixel Art Follow-up

Rob accepted floating panels as working perfectly and requested item cards with 8-bit graphics. Scope: current slice item artwork, reusable display cards, grid/equipment/belt presentation and focused tests in this Room. Preserve footprint/ownership rules and distant-inspection disclosure. No Production promotion.

| [UI Foundation]+[Presentation]+[ItemCards] | Pixel artwork and reusable item cards | Interface FloatingPanels | Current item graphics integrated, disclosure and UI checks pass, docs synchronized | complete | Promoted sword-only cards; UI/inspection checks pass |


## Hex Floor Prototype — 2026-09-10
Rob supplied `Workshop/Chad-Casso/first_two_rows_floor_prototype.png` for the agreed joined-floor test. Workshop world_view samples the first two rows through exact pointy-top hex polygons; source PNG is preserved, background and painted rims excluded by inset UV coordinates. Deterministic variations cover the current arena. Gameplay, actors and Production are unchanged. No image generation used. Squares migration remains on hold; path-based Lunge is agreed but not implemented by this presentation checkpoint.

Validation: 79 UI checks pass; actual Godot OpenGL capture inspected at `Prototype/tests/floor_patch.png`. Joined geometry has no background gaps; texture-pattern discontinuities remain visible. Walls are not integrated. Source is loaded directly with Image for this Workshop prototype; export packaging needs imported texture resources before promotion. Item-card work remains a separate unfinished checkpoint.


## Wall Art Decision — 2026-09-10
Rob selected plain BLACK hexes for solid walls. Keep pure 2D overhead presentation and existing hex geometry: textured walkable floors, flat black wall cells, no raised brick faces or perspective. Additional wall sprite generation is unnecessary. This records the visual contract; the current open 7×7 arena has no terrain wall placement/collision system yet. Future wall cells must block player/enemy movement and skill travel through the same terrain rule; painting a floor black alone is not a functioning wall.


## Ground Prototype 02 — 2026-09-10
Current floor source is `Workshop/Chad-Casso/ground_prototype_02.png`. Only the seven individual FLOOR TILES examples are sampled, with inset UVs excluding labels/background. Wall artwork is unused: approved wall appearance remains flat black hexes in pure overhead 2D. Arena remains open; terrain wall placement/collision is not implemented. Rendered in Godot and inspected in `Prototype/tests/floor_patch_02.png`; prior capture/source retained. Texture transitions remain visible; this is a visual sample, not a seamless-texture claim. Production unchanged.


## Hex Splash — 2026-09-10
Workshop splash now uses a subdued joined pointy-top hex backdrop, hexagonal large O frame around the existing torchbearer, and a gold hex divider ornament. Pixel lettering and original Micro/Rogue arrangement retained. Pure code-native drawing; no generated imagery. Root startup passed Godot 4.4.1 headless; rendered capture inspected at `Prototype/tests/hex_splash.png`. Production unchanged; human visual acceptance pending.

| Checkpoint | Responsibility | Dependency | Completion | Status | Evidence |
|---|---|---|---|---|---|
| [UI Foundation]+[Interaction]+[TileChoices] | Move/Loot/Look and entrance coexistence | SharedMaps | Input flow and range checks pass | complete | 11 targeted checks |
| [UI Foundation]+[Delivery]+[ProductionPromotion] | Self-contained adopted runtime and launch/docs | TileChoices and completed UI work | Production regression/launch checks pass | complete | 2,190 checks; PROMOTION.json |

Last completed: [UI Foundation]+[Delivery]+[ProductionPromotion]. No active implementation Box. Next: human tile-menu playtest; future iterations stay in Workshop. Retain all output.

| Checkpoint | Responsibility | Dependency | Completion | Status | Evidence |
|---|---|---|---|---|---|
| [UI Foundation]+[World]+[OverworldBiomes] | Seeded biome data, atlas rendering and parent metadata | SharedMaps | Determinism, integration and render checks pass | complete | 219 biome + 163 regression checks; overworld_biomes.png |

Latest completed: [UI Foundation]+[World]+[OverworldBiomes]. No active implementation Box. Next: human biome-map playtest; this iteration is not yet promoted.

[UI Foundation]+[World]+[PoiBadges]: complete; depends on OverworldBiomes and SharedMaps. Latest completed checkpoint. Next: human local-map visual review.

[UI Foundation]+[World]+[ExpandedMaps]: complete; dependencies PoiBadges and OverworldBiomes. Latest completed checkpoint. Next: human pan/local terrain playtest. No active implementation Box.
