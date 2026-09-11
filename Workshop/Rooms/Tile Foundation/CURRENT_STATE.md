# Tile Foundation — Current State
Updated: 2026-09-11
Checkpoint: [Tile Foundation]+[Transfer]+[RoomSetup]
Implementation baseline/evidence: BASELINE.json records existing Workshop scripts and inspected assets; relevant code and art were read on 2026-09-11. Existing modified and untracked files were present before this work; no clean Git baseline claimed.

## Rapid Shape

This Room now owns tile art direction and future tile-work planning. [ART_STYLE.md](ART_STYLE.md) is a proposal awaiting Rob's judgment. No visible terrain edges and 2D top-down are confirmed; exact POI treatment and native pixel scale remain open. UI Foundation retains the working executable prototype. This is a documentation/work-ownership transfer, not a physical runtime migration.

## Locations And Component Contracts

All implementation links below remain in UI Foundation; no copies or changed resource paths were introduced.

| Owner | Current responsibility / relevant constraint |
|---|---|
| [world_view.gd](../UI%20Foundation/Prototype/ui/world_view.gd) | Samples terrain sheets through hex UV polygons; nearest texture filter; panning and picking. Local POI badge selection currently replaces terrain drawing for supported entrance cells. |
| [hex_board.gd](../UI%20Foundation/Prototype/gameplay/hex_board.gd) | Base hex geometry, ordinary gray cell outlines, actor/loot draw order. Radius 32. The permanent outline conflicts with the newly confirmed art target. |
| [poi_art.gd](../UI%20Foundation/Prototype/ui/poi_art.gd) | Crops Town/Dungeon/Tower from POI_Overlay_Tiles.png and adds an orange hex outline. Current art has side faces and a scenic base. |
| [terrain_variation.gd](../UI%20Foundation/Prototype/ui/terrain_variation.gd) | Deterministic variant selection for ordinary Local ground and wetland/wasteland helpers. |
| [river_art.gd](../UI%20Foundation/Prototype/ui/river_art.gd) | Samples River_Water_Texture.png for edge strips. Rivers are landscape features; distinguish their banks from unwanted tile borders. |
| [map_world.gd](../UI%20Foundation/Prototype/domain/map_world.gd) | Creates Global immediately, Local/POI lazily; Local generation runs water, terrain, then rivers. In-run map identity persists. |
| [hex_map.gd](../UI%20Foundation/Prototype/domain/hex_map.gd) | Coordinate, wrap, wall, terrain and link data shared by gameplay and rendering. |
| [local_water.gd](../UI%20Foundation/Prototype/domain/local_water.gd) | Lake basins/islands and other biome water shapes; entrance placement. |
| [local_terrain.gd](../UI%20Foundation/Prototype/domain/local_terrain.gd) | Seeded regional terrain and stored elevation. |
| [continent_generator.gd](../UI%20Foundation/Prototype/domain/continent_generator.gd), [biome_generator.gd](../UI%20Foundation/Prototype/domain/biome_generator.gd) | Global shape and biome classification. |
| [river_generator.gd](../UI%20Foundation/Prototype/domain/river_generator.gd), [river_edges.gd](../UI%20Foundation/Prototype/domain/river_edges.gd) | Generated drainage routes and canonical shared-edge geometry. |
| [travel_cost.gd](../UI%20Foundation/Prototype/domain/travel_cost.gd) | Terrain movement costs; no rule changes in this transfer. |

## Entry And Existing Behavior

Open UI Foundation's [main.tscn](../UI%20Foundation/Prototype/ui/main.tscn) in the root project and use F6 for the Workshop iteration. Prior documentation identifies F5 as the promoted Production entry; do not use it as proof of current tile changes.

Global is 80×42 including ice rows, horizontally wrapped. Local width×height ranges from 30×20 to 45×30 at exact 3:2 ratio; POIs are 18×14. Local maps are generated on first visit, so existing map instances do not regenerate when code changes. Current water is sampled from Ocean_And_Lake_Tiles.png, with a small interior patch and rotated UVs. Water_03 is review input only. Local Swamp falls back to Forest art; Salt Marsh dry cells use Plains while water uses sea samples. Dedicated swamp/salt-marsh files merely existing does not mean they are integrated.

## Dependencies And Preservation

Source art remains in Workshop/Chad-Casso. FutureWasteland is prohibited, including inspection. The first Wasteland sheet's roads are excluded; Wasteland_02 is usable including its stone roads. Source images, existing output, scripts and tests are retained. No Production promotion, deletion, Git commit, asset generation or runtime rewrite is included in current execution.

## Evidence And Remaining Work

Directly inspected Plains, Forest, Hills, Mountains, POI and both Water_03 files. Checked Water_03 PNG headers and matching hashes using the Python standard library. Read current draw owners and map construction. Verified documentation links, preserved document bytes and baseline hashes. Runtime regression suites were not rerun for this documentation-only change.

Prior synchronized notes report 33 terrain cases, 199 water checks, 78 river-generation checks and 27 map checks for the latest biome/stripe pass. These are inherited reports, not freshly executed evidence. Existing visual acceptance remains pending. Water travel, exact Local/Global river continuity and seamless biome transitions remain unresolved implementation limits.

Next: review the per-set requirements and copyable request below. Producing/integrating replacement art remains separate; final style adoption is not inferred from the hypothetical acceptance discussion.

## Tile Set Request Package

Checkpoint: [Tile Foundation]+[Delivery]+[TileRequirements] — complete. Rob requested requirements for each used set and a reusable Chad-Casso template. [Tile set requirements](TILE_SET_REQUIREMENTS.md) covers all 13 loaded source sheets, separates unused Swamp/Salt Marsh files from current fallbacks, and defines proposed ground/overlay/river delivery profiles. [Request template](CHAD_CASSO_REQUEST_TEMPLATE.md) includes a copyable Lake request. Checked source coverage and document links; no images generated, messages sent or runtime changes made. Final style approval remains pending; the guide is the working specification.
