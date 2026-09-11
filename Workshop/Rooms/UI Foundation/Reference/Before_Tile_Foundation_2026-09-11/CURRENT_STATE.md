# UI Foundation — Current State

## Biome Shape / Stripe Pass — 2026-09-11
Rob requested the natural-shape pass for other Local biomes and removal of repeating sprite stripes. Local terrain now uses domain-warped low-frequency fields: relief/folded elevation for Hills/Mountains, elevation-dominant dry terrain, moisture-led forest/plains and moisture-minus-height wetlands. Related palettes and dominant region identity remain. Sea uses a seeded broad coast; Salt Marsh a more broken coast; Marsh/Swamp gain clustered water. Lakes retain their basin/islands. Other water regions no longer carve axial dry causeways: non-return POIs move to closest available dry tile with updated return coordinates. Fixed arrival/Return (1,3) retains a small dry patch; water traversal is still provisional.

Added ui/terrain_variation.gd: seeded RNG mixes coordinate strings before selecting sprite indices, replacing direct modulo hash patterns for ordinary ground, Wasteland and Marsh. Water samples a smaller interior patch with randomized orientation; full-tile rotation was visually rejected for a block-like appearance. No source assets changed or generated. Ordinary board hex outlines remain, and texture seams are not guaranteed seamless.

Validation: 33 biome/seed coherence/determinism cases pass after lowering elevation frequency (initial folded relief was too fragmented); water 199, river generation 78 and map world 27 checks pass. Godot renders inspected: land variant bands removed, centered lake shows open water and island Tower with no painted full-tile water rim. Latest capture /tmp/local_lake_stripe_fix.png; original rotated-full-tile experiment replaced in code. Workshop F6; new run/new maps for generation. Production unchanged, no commit/deletion. Individual biome visual acceptance remains Rob's review.


## Lake Basins — 2026-09-11
Rob requested mostly central water, natural breakup, possible island POIs, and removal of the little water borders. Lakes now use a broad elliptical basin in projected hex coordinates with low-frequency shoreline perturbation, retaining the center-connected water component. A seeded 65% chance adds a small off-center island and moves the Tower POI there, updating its return coordinate. Lake generation does not carve straight dry paths. Sea/Salt Marsh generation remains unchanged. Existing provisional water traversal remains; boats and swimming are not implemented.

Water rendering now samples a single consistent water variant instead of the repeating three-color coordinate cycle; explicit shoreline strips/lines removed for all Local water. Artwork itself can still contain visible tile edges/details; this is not a seamless-texture guarantee. Existing terrain sizes, river overlays, and other POIs remain.

Validation: lake basin test covers 40 seeds for central connected water, coverage, dry POIs and Tower return coordinates. Water 657, river generation 78 and map world 27 checks pass. Actual screenshot verification remains pending: automatic approval review rejected the graphical capture due to a usage limit. No visual acceptance claimed. Workshop F6, new run/newly generated regions; Production unchanged. No deletion or commit.


## Local Terrain Patches — 2026-09-10
Rob requested world-like variation within Local regions. `domain/local_terrain.gd` now generates deterministic moisture patches with related biome palettes, retaining roughly 62% parent terrain on dry regions; lower/upper moisture quantiles select companion terrain. Stored seeded elevation supplies local river routing. Existing Sea/Lakes/Salt Marsh water masks and dry entrance paths remain authoritative. This is regional variation, not exact continuity across adjacent Local map boundaries. Swamp and Salt Marsh still use existing art fallbacks.

Local generation runs lazily after water and before rivers. Rendering selects per-cell Local terrain with local-resolution assets, and hashed texture variants replace repeating diagonal bands. POI badges, local movement costs, map dimensions, black dungeon walls and Global generation remain unchanged. New runs/newly generated regions receive the change; existing instantiated regions are not regenerated.

Validation: 33 biome/seed cases verify determinism, mixed terrain, neighbor coherence, water preservation and elevation coverage; map pan 27 and river generation 78 checks pass. Initial empty-biome test fixture rendering error corrected with Plains fallback; rerun clean. Actual Godot forest capture inspected at `/tmp/local_terrain_patches.png`: visible clearings and rocky patches among forest. Workshop F6 only; no Production promotion or commit.


## Generated Rivers / Indented Continents — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[DrainageAndCoasts]
Rob accepted edge rendering and requested river generation plus less oval, more European-style land shapes with land bridges. Replaced ellipse masks with connected noise-perturbed lobes and narrow connecting corridors, bounded to maintain two ocean-separated continents and ice caps. Connected-core filtering still excludes offshore islands. Shape remains a simple procedural approximation, not realistic continental geology. Existing sizes/wrap remain.

`domain/river_generator.gd` builds a canonical hex-vertex graph from valid shared cell edges. Global outlet vertices touch Sea/Lakes; Local outlets may also touch region boundaries. Breadth-first drainage distances guarantee termination; sources favor high stored elevation and distance from outlets, spaced apart. Each step reduces outlet distance and prefers lower terrain among candidates. Up to eight Global and two Local sources, merges share canonical edge records; no loops. This is a simple drainage heuristic, not erosion or strict physical downhill flow. Local routes are independently seeded and do not yet inherit exact global entry/exit edges. It is possible for very watery small regions to have no suitable source. Demo zigzags are no longer inserted.

Movement/crossing restrictions, boats and bridge rules unchanged; river drawing remains underneath actors and loot. River records/routes stored on maps; deterministic generation runs only when a map is created. No new art generated.

Validation: 78 river generation checks across three seeds (sources, repeatability, nontrivial acyclic routes ending at water vertices), 26,697 world-shape assertions (connected large separated continents/caps/local sizes), plus map 27, wrap 6, edge geometry 27 and tile-choice 11 pass. Overview `Prototype/tests/generated_geography.png` inspected: schematic continent colors and river routes, not gameplay artwork; opposite image edges join. Workshop F6, Production unchanged. Latest checkpoint complete; human shape/drainage playtest pending. No deletion/promotion/commit.


## River Edge Overlay Prototype — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[RiverEdges]
Rob approved code-built rivers using River_Water_Texture.png; no image generator and no coastal-art work. File is the full reference sheet, so ui/river_art.gd samples a clean water rectangle (720,820,80,20), preserving the PNG. Domain river_edges.gd stores one undirected edge per adjacent canonical cell pair, validates endpoints, and computes shared-edge geometry for all six directions and horizontal wrap.

River rendering uses textured strips and joined caps, outlines drawn before water to avoid internal bank seams. Hex board overlay hook draws rivers after terrain and before actors/loot. Each map owns its river records for in-run persistence. Added explicit demonstration traces: seven-cell trace near Global spawn and ten-cell trace along Local row 6. These prove alignment; they are not hydrological generation, do not connect to water destinations and do not impose crossing costs/restrictions. Bridges/fords/crossing logic remain future work. POI maps have no default rivers.

Validation: 27 edge tests cover symmetric lookup, deduplication, six shared geometries, seam trace and invalid edges; map 27, pan 27 and seam flow 6 pass (87). Actual Godot render inspected in tests/river_edge_overlay.png: connected zigzag exactly on shared edges. Workshop F6; Production unchanged. Latest checkpoint complete; next human overlay review and later natural routing. No image generation, asset editing, deletion, promotion or commit.


## World Contract — 2026-09-10
Checkpoint: [UI Foundation]+[World]+[WorldContract]
Rob specifies horizontal wrap, minimum two large continents, 40×80 playable height×width plus top/bottom ice rows (42×80 total), random seed, lazy local generation, local heights 20–30 and widths 30–45 at exact 2:3 ratio. Dungeon sizing stays separate. No islands generated yet; Island marker kind renders IS if introduced later.

Implemented Global dimensions Vector2i(80,42), 3,200 playable cells and 160 impassable Ice Wall cells at y=0/41. Global east/west wraps; north/south does not. `continent_generator.gd` builds two noise-perturbed continental masks with separated ocean channels, retaining connected core components (no accidental offshore islands), then climate biomes and snapshot wetlands. Climate/coast noise samples a longitude cylinder for wrap continuity. Player starts on Plains on the first continent. Current template makes exactly two large continents; rivers/islands/world-time/boat rules remain future work.

`hex_map.gd` owns canonical horizontal coordinates, neighbors and wrapped distance. Weighted paths canonicalize neighbors. Proximity/ground transfers use wrapped distance on Global. World-view rendering selects the nearest horizontal copy of each canonical cell for continuous panning and seam hit tests. Ice caps draw pale blue; POI walls remain black. Tile size remains 32, no auto-shrink. Maps are finite data, not streamed chunks.

Only Global is constructed initially; links are lightweight descriptors. Local creation samples half-height 10–15 using world seed + region ID, giving exact height×width choices 20×30,22×33,24×36,26×39,28×42,30×45 independently of visit order. POIs remain 18×14. Existing fixed POI coordinates retained. Region state persists only in the current run. Production unchanged; Workshop main.tscn F6.

Validation: world_shape_test 24,321 assertions across seeds 1/1729/70001 cover dimensions, blocked caps, wrap, connected/separated continents (>400 cells each), deterministic terrain, lazy creation and local sizes. wrap_flow_test 6 checks cover visual seam coordinates, picking, movement, pickup, local entry/return. Map 27, pan 27, UI 79, inspection 24, choices 11, wetlands 35 checks pass; deterministic biome coverage/sampled metadata suite passes. No island generation, new assets, promotion, deletion or commit. Latest checkpoint complete; human world traversal playtest pending.


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

Updated: 2026-09-10
Checkpoint: [UI Foundation]+[World]+[SharedMaps]
Implementation baseline: isolated necessary copies of accepted Production scripts; 9 original script hashes in BASELINE.json remain unchanged. No Git checkpoint created.


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

## Earlier Interface Reference (map notes above supersede arena-only descriptions)

Plain wireframe ready for Rob's playtest inside the single repository Godot project. Production retains promoted work; Workshop scenes are development work in the same project. Root F5 now launches this UI without promoting it.

Open [root project.godot](../../../project.godot) in Godot 4.4.1, then press F5. The first screen is splash/creation; the new UI starts in the arena. To run the promoted slice, open Production/Gameplay/main.tscn in the same editor and press F6. The nested project settings are retained as Prototype/project_settings.reference.cfg, not an active project.

## Locations And Responsibilities

All following paths are relative to Prototype/.

| Location | Responsibility |
|---|---|
| `ui/workshop_game.gd` | Wires gameplay state to UI, handles intent, builds panel contents, routes transfers and movement confirmation |
| `ui/navigation_rail.gd` | Nine rail positions; emits panel requests; map-layer placeholder |
| `ui/panel_host.gd` | One overlay at a time, default/per-panel sizes, title dragging, edge docking and placement memory |
| `ui/bottom_hud.gd` | Persistent HP/Mana, centered abilities/action counts, Activate/End Turn, Gold and contextual belt targets |
| `ui/inventory_grid.gd` | 8×5 grid drawing, selection, drag source and placement preview; emits intent without mutating items |
| `ui/item_target.gd`, `ui/drag_context.gd` | Equipment/pouch/drop targets and shared drag payload/rotation |
| `ui/world_view.gd` | Centered hex board and path drawing; emits hex intent including Shift bypass |
| `domain/item_inspection.gd` | Returns range-appropriate display data; distant snapshots omit item statistics and hidden details |
| `domain/grid_inventory.gd` | Footprints, placement, validation and transactional ownership/action changes |
| `domain/movement_preview.gd` | Reachable paths shared by preview and movement confirmation |
| `gameplay/` | Room-local imported slice mechanics and creation flow; item generation adds stable instance IDs and pouch indices |
| `splash/` | Necessary Room-local copy of splash art |
| `tests/` | Rule/flow/input checks, capture helper and rendered wireframe images |

The existing Production contract remains at [Micro Rogue slice](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/MICRO_ROGUE_SLICE.md). This Room does not replace that adopted contract.

## UI Flow And Controls

- Rail 1 Character, 2 Inventory, 3 Skills, 4–7 reserved, 8 Logs, 9 Options. Click an entry to overlay its panel; click it again or Escape to close. Selecting another switches the panel. The underlying viewport retains its size and bottom HUD remains accessible.
- Default panel size 550×460. Character 390×430, Inventory 670×570, Skills 540×410, Logs 620×460, Options 430×350, Activate 430×480. Host clamps these sizes to viewport space. Panels float without rail connector lines and do not resize the world. Drag their title bars to move. Releasing within 20 logical pixels of an edge snaps to an 8-pixel margin; corners can dock on both axes. Drag away to undock. Each panel keeps its own position/docked edges across reopening and encounters for this application session. Docked panels follow viewport resizing, and free panels are clamped so they remain reachable. The bottom HUD/rail remain outside the docking area. Position storage is in memory, not saved across application restarts.
- Normal clicking a tile containing ground items opens Look/Loot before ordinary movement. At distance 0 or 1, full item identity/stats and individual Take buttons are available. Farther away, only explicit appearance/material/type and visible traits are shown; no rarity, dice, bonuses, healing effect, belt capacity or contents. Looking spends no actions. Take rechecks range and uses existing atomic pickup/loot costs. Empty piles are reported. Shift-click retains movement bypass; selected attacks/skills keep targeting priority. The panel offers Move to this tile through the existing movement gate.
- Ordinary movement is default on empty tiles: click a valid hex to preview path, destination and cost; Confirm commits. Shift-click bypasses. Options can disable confirmation. Cancel/Escape clears the preview. Confirmation revalidates the exact path before spending movement. Attack and abilities temporarily override movement mode; Cancel returns to movement.
- HP/action counts/cooldowns stay in the bottom HUD. Mana and Gold are visibly reserved without invented values. Activate opens current belt potions, nearby ground items and Backpack access. No nonexistent ring, spell or world interaction entries are shown.
- Inventory shows equipment and a real backpack grid. Drag equipment/backpack items onto compatible equipment slots, free grid cells or Drop at feet. Select an item for details, Rotate and Drop controls. R rotates while dragging. Invalid placements show a red preview and a refusal message on drop.
- Dragging a potion automatically reveals the bottom belt tray without closing Inventory. Drag onto an empty pouch to load it; drag a pouch's potion into the backpack to remove it. Selecting a backpack belt and Inspect/load shows that belt's own pouches, distinct from the equipped belt. A stocked belt retains contents when equipped/dropped.
- Activate's potion buttons consume the selected equipped-belt potion. Backpack potions cannot be used directly. Nearby pickup uses the established loot action priority.
- Character contains level/XP/stats, next-test-encounter after victory, and fresh character creation after death. Skills exposes the existing linear Sword Mastery tree. Logs retains the existing last-seven-message behavior. Options is rail position 9.

## Inventory Contract

8 columns × 5 rows. No stacking. Base footprints: potion 1×1, belt 2×1 horizontal, sword 1×2 vertical, armor/shield 2×2. Rotation swaps footprint axes. Each item has a unique instance ID; backpack items carry top-left grid position and orientation. Belts own individually indexed potion pouches.

Transfers validate current state, plan changes on deep copies, check resulting non-overlap/bounds/unique ownership/pouch capacity, and only then commit inventory, ground items and action costs. A failed operation changes nothing. Equipment swaps remove the incoming item in the plan before finding space for displaced equipment; the whole swap is refused if that equipment cannot fit. First-fit auto-placement tries the current and alternate orientations without moving unrelated backpack items.

Combat equipment/drop/belt transfers each cost one activation. Rearranging/rotating within the backpack is free. Ground pickup spends activation, then individual attacks, then movement; rejected pickup spends nothing. Picking up a potion prefers a free equipped-belt pouch, then backpack space. Ground equipment must be picked up before equipping. Outside combat transfers are free. Pending optional Lunge attacks must be resolved/skipped before inventory mutation.

Prototype equipment supports sword main hand, shield offhand, offhand sword with Show-Off and an equipped main sword, armor and belt. Empty slots remain safe. Displaced items and belt contents are preserved. No enemy scavenging, stacking, auto-sorting or new equipment types were added.

## Validation And Readiness

Godot 4.4.1: 2,027 imported baseline-rule checks, 79 UI/inventory/movement/flow checks and 8 native mouse/key input checks passed (2,114 total). Input checks drive actual drag gestures, automatic belt reveal, pouch drop/action cost, R rotation and grid placement. Full-window scene loading and rendered inventory/movement layouts were inspected. The headless input harness required an explicit 1440×900 window and normal input parsing; without those it supplied off-screen/incorrect mouse coordinates. Final input tests pass; these were validation-harness corrections.

Run from the repository root, replacing `godot` with the local executable:

```sh
godot --headless --path . --script "Workshop/Rooms/UI Foundation/Prototype/tests/baseline_rules_test.gd"
godot --headless --path . --script "Workshop/Rooms/UI Foundation/Prototype/tests/ui_foundation_test.gd"
godot --headless --path . --script "Workshop/Rooms/UI Foundation/Prototype/tests/drag_input_test.gd"
```

Rendered captures are in `tests/wireframe_inventory.png` and `tests/wireframe_movement.png`; they show the layout before the final horizontal centering adjustment to the HUD controls. An optional refresh of those captures was not executed because automatic permission review timed out; final centering is covered by the passing scene/input checks, and earlier rendered captures are retained. Capture helper uses sample items only inside the test; it does not grant items in normal play. Linux validation engine/data remain under /tmp; no cleanup/deletion performed.

Rob's visual/usability acceptance remains pending. This is a plain first wireframe, using abbreviations/tooltips instead of item art. Root canvas is 1440×900, shared by both Workshop and Production scenes. Rings, scrolls, throwables, Mana, Gold, map layers and Wisdom cooldown scaling remain deferred. Combat balance remains as accepted. Production promotion requires a subsequent approved scope after playtest.

## Single-Project Integration

Rob explicitly requested consolidation into the repository's single Godot project. All Room resources now use repository-root res://Workshop/Rooms/UI Foundation/Prototype/... paths. Both old nested project.godot files were renamed to project_settings.reference.cfg; content retained, not discarded. The original splash scene also resolves from the shared root. The root launcher selects this Workshop UI while Production remains the promoted baseline.

After integration, all 2,114 UI/baseline/input checks passed from root, and both root F5 and the explicit Production scene passed headless startup. Exactly one project.godot remains. The Windows Godot project list was backed up and its obsolete nested Micro Rogue entry removed; unrelated registrations and the root registration were preserved. Backup/helper retained at /tmp/micro_rogue_projects_before.cfg and /tmp/consolidate_micro_rogue_registry.py. No Git commit or gameplay promotion occurred.

## Tile Inspection Validation

24 additional checks passed for distance-zero/one disclosure, distant-stat hiding, explicit visible traits, action-free inspection, per-item loot costs, remote/full-action refusal, empty piles, Shift movement, targeting precedence and stale-range refresh. Existing 2,114 checks also passed after this change (2,138 total). Current generated gear stores its unqualified visible appearance separately from the rarity-bearing name. Potion appearance is a glass bottle at range. Glow is displayed only from explicit visible_traits data; this does not introduce enchantment generation or a new LOS system. All current arena tiles are already visible in this slice.

Run: `godot --headless --path . --script "Workshop/Rooms/UI Foundation/Prototype/tests/tile_inspection_test.gd"`.

## Floating Panel Validation

14 targeted checks passed for native title-bar dragging, release, unchanged actor/actions, per-panel memory, corner docking, resize anchoring, containment, undocking, closing and next-encounter persistence. The 8 item-drag, 79 UI/flow and 24 inspection checks also passed after the change (125 checks run for this follow-up). Production unchanged. Current behavior remains one open rail/context panel at a time; dock positions do not introduce new gameplay actions. Earlier screenshots retain the old connector appearance; current panel host no longer draws connectors.


## Hex Floor Prototype — 2026-09-10
Rob supplied `Workshop/Chad-Casso/first_two_rows_floor_prototype.png` for the agreed joined-floor test. Workshop world_view samples the first two rows through exact pointy-top hex polygons; source PNG is preserved, background and painted rims excluded by inset UV coordinates. Deterministic variations cover the current arena. Gameplay, actors and Production are unchanged. No image generation used. Squares migration remains on hold; path-based Lunge is agreed but not implemented by this presentation checkpoint.

Validation: 79 UI checks pass; actual Godot OpenGL capture inspected at `Prototype/tests/floor_patch.png`. Joined geometry has no background gaps; texture-pattern discontinuities remain visible. Walls are not integrated. Source is loaded directly with Image for this Workshop prototype; export packaging needs imported texture resources before promotion. Item-card work remains a separate unfinished checkpoint.


## Wall Art Decision — 2026-09-10
Rob selected plain BLACK hexes for solid walls. Keep pure 2D overhead presentation and existing hex geometry: textured walkable floors, flat black wall cells, no raised brick faces or perspective. Additional wall sprite generation is unnecessary. This records the visual contract; the current open 7×7 arena has no terrain wall placement/collision system yet. Future wall cells must block player/enemy movement and skill travel through the same terrain rule; painting a floor black alone is not a functioning wall.


## Ground Prototype 02 — 2026-09-10
Current floor source is `Workshop/Chad-Casso/ground_prototype_02.png`. Only the seven individual FLOOR TILES examples are sampled, with inset UVs excluding labels/background. Wall artwork is unused: approved wall appearance remains flat black hexes in pure overhead 2D. Arena remains open; terrain wall placement/collision is not implemented. Rendered in Godot and inspected in `Prototype/tests/floor_patch_02.png`; prior capture/source retained. Texture transitions remain visible; this is a visual sample, not a seamless-texture claim. Production unchanged.


## Hex Splash — 2026-09-10
Workshop splash now uses a subdued joined pointy-top hex backdrop, hexagonal large O frame around the existing torchbearer, and a gold hex divider ornament. Pixel lettering and original Micro/Rogue arrangement retained. Pure code-native drawing; no generated imagery. Root startup passed Godot 4.4.1 headless; rendered capture inspected at `Prototype/tests/hex_splash.png`. Production unchanged; human visual acceptance pending.
