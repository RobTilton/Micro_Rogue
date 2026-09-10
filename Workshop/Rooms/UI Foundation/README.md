# UI Foundation Workshop

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
