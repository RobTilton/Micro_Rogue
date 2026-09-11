# UI Foundation — Current State
Updated: 2026-09-11
Checkpoint: [UI Foundation]+[World]+[LocalPoiSpacing]
Implementation baseline/evidence: existing uncommitted Prototype; tile-transfer hashes in ../Tile Foundation/BASELINE.json. Local POI implementation and focused Godot validation completed; see Local POI Spacing below.

## Rapid Shape

UI Foundation retains the working interface/game prototype. Tile art direction and future tile planning now belong to [Tile Foundation](../Tile%20Foundation/CURRENT_STATE.md). The executable has not moved. Original notes are preserved under Reference/Before_Tile_Foundation_2026-09-11; they contain superseded state and are not normal recovery input.

## Current Locations And Entry

Open [Prototype/ui/main.tscn](Prototype/ui/main.tscn) in the repository root project and press F6 for this Workshop iteration. Prior promotion notes identify root F5 as Production/Current; earlier claims that F5 runs Workshop are superseded.

- ui/workshop_game.gd wires game state, panels, movement confirmation and map transitions.
- ui/panel_host.gd owns movable/docked overlays; inventory_grid.gd and item_target.gd emit transfer intents.
- domain/grid_inventory.gd owns atomic placement/ownership/action mutation; item_inspection.gd owns distance-limited disclosure.
- domain/map_world.gd and hex_map.gd own persistent map identities and geometry; world_view.gd presents the active map.
- gameplay/ and splash/ retain existing mechanics/creation; tests/ retains validation and captures.

Paths in this list are relative to Prototype/. [Tile component references](../Tile%20Foundation/CURRENT_STATE.md) own detailed rendering/generation recovery.

## Local POI Spacing

Checkpoint: [UI Foundation]+[World]+[LocalPoiSpacing] — implementation complete; Rob's exploration review pending. `Prototype/domain/local_poi_placement.gd` distributes one Dungeon, Town and Tower across existing dry walkable Local cells after water generation and before terrain/rivers. It reserves Return at (1,3) and any lake-island Tower, then samples seeded positions within 80% of the best minimum distance to reserved entrances. No land is carved. Each moved link retains its identity and updates its return coordinate. Maps persist in-run; start a new run or visit an ungenerated Local region for new placements. Number/types of POIs and enemy/loot rules are unchanged.

Godot 4.4.1 validation: 5,560 placement checks across 264 biome/seed cases passed (dry distinct destinations, six-hex separation in sampled cases, determinism, unchanged water/island Towers, stable revisit and visit-order behavior). Map travel/persistence 27, tile choices 11 and panning 27 passed; lake basin checks passed across 40 seeds. Existing fixed-coordinate test fixtures now discover entrances by kind. The six-hex observed minimum is not a hard guarantee on future constrained maps. No rendered spacing capture or human visual acceptance claimed.

## Current Map And Presentation Contracts

Global is 80×42 with horizontal wrap and blocked ice caps. Local dimensions range width×height 30×20 through 45×30; POIs are 18×14. Radius remains 32 with mouse panning. Map generation is lazy and state persists in the current run only. Player stats/equipment/HP/XP/cooldowns travel; inactive maps pause and retain enemies, loot and actions. Return coordinates are map-owned; water generation can relocate Local POIs, so old fixed-coordinate play instructions are not reliable for every generated map.

Travel is explicit through Map/Activate at an entrance. Walls block movement and skill paths; normal movement, enemy routing, Lunge and Riposte use the common terrain rules. Inventory and distant inspection remain unchanged. Town is an exploration template; Dungeon/Tower use the existing encounter skeleton. Water traversal is provisional; boats/swimming and disk persistence are not implemented.

Sword-only item art/cards and other-item placeholders are delivered. Floating panels were accepted as working by Rob; prior notes record acceptance of map persistence. Tile-menu and newer terrain visual acceptance are still pending. Ordinary hex outlines and perspective POI badges remain in runtime and conflict with the newly requested art target; recording the new style has not changed their rendering.

Current tile-choice follow-up: dropped-item tiles offer Move/Loot/Look while entrance travel remains available on the player’s tile. This delivered menu behavior supersedes earlier inspection-only wording below.

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

## Evidence And Limits

Prior promotion records report 2,190 checks per build for baseline/UI/input/inspection/panels/maps/tile choices. Latest biome/stripe notes report 33 terrain cases, 199 water checks, 78 river checks and 27 map checks. These are preserved reported results, not fresh runs. No gameplay code, assets or launch configuration changed in this reorganization.

[DOTS](DOTS.md) records current traversal. [Tile handoff](../Tile%20Foundation/HANDOFF.md) carries the new work boundary. All old documents and outputs remain retained; no Git checkpoint or Production adoption occurred in this pass.

Current generation reference: [How the Game Is Generated Now](GAME_GENERATION.md) explains the active Workshop world/Local/POI pipeline, encounter and item randomness, persistence and unimplemented systems. Checkpoint [UI Foundation]+[Documentation]+[GenerationReference] complete; documentation-only inspection, no fresh runtime tests.

## Actor Foundation Consumer

[Actor Foundation](../Actor%20Foundation/CURRENT_STATE.md) is the new actor-enabled Workshop scene. It reuses this Room’s interface and map generation, with a `_make_board()` factory hook added to ui/workshop_game.gd. Its registry/action service replaces single-enemy snapshots for that scene only. Current actors/pursuit/turn timing are documented there; the earlier single-enemy descriptions above still describe this Room’s own scene. Existing baseline/UI/drag/panel checks passed after the hook. No Production promotion.
