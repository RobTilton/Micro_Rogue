# UI Foundation Workshop

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


## Play the connected maps

F5 → create character → Global map. Open the **top-left Map button** and choose **Explore region** at your current hex. In the Local map, move to **D at (4, 2)**, then Map → Dungeon. Town is (3, 4), Tower is (5, 4). Inside a POI, **R at (1, 3)** returns to the local map; its R returns to Global. Activate offers the same transition button.

Black hexes block movement. Map state persists for this run, including enemy health and dropped items. Travelling in combat costs activation and preserves spent actions. No disk saves yet. New map validation: 27 checks plus 2,152 existing regressions. [Dungeon capture](Prototype/tests/map_world.png).

Updated: 2026-09-10

Use the repository's only [project.godot](../../../project.godot). Press **F5** to run this latest UI. Create a character to enter the wireframe. This is a Workshop scene in the same Godot project as Production, not a separate project.

Scene: `Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn`.

Use the rail for Character, Inventory, Skills, Logs and Options. Drag a panel by its title bar to move it; release near a viewport edge to dock. Positions are remembered during the session. Click a hex to preview movement, then Confirm; Shift-click bypasses. Click a tile with ground items to inspect it. Within one hex, see stats and use Take to loot individual items; farther away, see appearance only. Activate still provides belt use and nearby loot. Shift-click keeps immediate movement onto a loot tile. Inventory is 8 columns × 5 rows; R rotates a dragged item. Drag potions to reveal belt pouches. Select a backpack belt to inspect/load it.

The promoted slice remains at `Production/Gameplay/main.tscn`; open that scene and press F6 to run it. Production promotion of this UI is pending playtest.

[Current state and tests](CURRENT_STATE.md) · [DOTS](DOTS.md)


Floor prototype: root F5 now displays the supplied stone/moss/rubble floor sheet on the existing hex arena. Preview: [joined floor capture](Prototype/tests/floor_patch.png). Walls remain deferred.


## Ground Prototype 02 — 2026-09-10
Current floor source is `Workshop/Chad-Casso/ground_prototype_02.png`. Only the seven individual FLOOR TILES examples are sampled, with inset UVs excluding labels/background. Wall artwork is unused: approved wall appearance remains flat black hexes in pure overhead 2D. Arena remains open; terrain wall placement/collision is not implemented. Rendered in Godot and inspected in `Prototype/tests/floor_patch_02.png`; prior capture/source retained. Texture transitions remain visible; this is a visual sample, not a seamless-texture claim. Production unchanged.


## Hex Splash — 2026-09-10
Workshop splash now uses a subdued joined pointy-top hex backdrop, hexagonal large O frame around the existing torchbearer, and a gold hex divider ornament. Pixel lettering and original Micro/Rogue arrangement retained. Pure code-native drawing; no generated imagery. Root startup passed Godot 4.4.1 headless; rendered capture inspected at `Prototype/tests/hex_splash.png`. Production unchanged; human visual acceptance pending.
