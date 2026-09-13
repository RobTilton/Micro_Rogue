# Production Runtime
Updated: 2026-09-10
Checkpoint: [UI Foundation]+[Delivery]+[ProductionPromotion]

Open the repository root `project.godot` and press **F5**. The active runtime is **Production/Current/ui/main.tscn**. One project contains both Production and Workshop.

Current includes the hex splash, character creation, floating panels, grid inventory and item cards, sword artwork, floor textures, black walls, shared Global/Local/POI maps, path-based Lunge, combat, cooldowns and per-run map persistence. All runtime resources live inside Production/Current; it has no Workshop dependency.

## Controls

- Move by clicking a hex and confirming; Shift-click bypasses. Options can disable confirmation.
- Clicking ground items opens **Move / Loot / Look**. Move follows normal confirmation; Loot is enabled within one hex; Look shows only visible properties at range. On an entrance tile, its travel button remains accessible while standing there, even under loot.
- Use the top-left **Map** control or **Activate** at a marker to enter/leave maps. Every global cell opens a local region. Dungeon is (4,2), Town (3,4), Tower (5,4); return is (1,3).
- Travelling during combat costs activation and preserves remaining actions. Enemy health, loot and position persist during the run. No disk save yet.
- Inventory is 8 columns × 5 rows, no stacking, rotation with R. Drag equipment and potions; dropping/equipping/belt transfers cost activation in combat. Floating panels drag by their title.

Validation: 2,190 checks pass against both Production and Workshop. Production launch/script ownership and tile-choice rendering checked. Imported textures replace direct Image loading. No executable export/package was built. Rob accepted persistence and requested this promotion; newest tile-menu visual acceptance remains for playtest.

`Current/PROMOTION.json` records source paths and promoted hashes. Previous `Gameplay/` and `Splash/` files are preserved earlier-baseline material, not the active game; see STARTING_SLICE_REFERENCE.md. Do not create another project to run either scene. No deletion or Git commit performed.
