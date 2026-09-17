# Inventory Shortcuts and Wells
Updated: 2026-09-15
Checkpoint: [Inventory Shortcuts and Wells]+[Validation]+[Controls and Chambers]

Shift-left-click backpack equipment equips its natural slot through the shared transfer path; Shift-left-click worn gear returns it to the backpack. Existing swaps, offhand displacement, room checks and combat activation costs remain in force. Potions/rations are excluded from quick equip. Ordinary click selection and drag/drop remain available.

Right-click a carried belt in the backpack or equipment panel opens Empty belt. All contained potions move to backpack slots atomically. Full backpack or insufficient combat activation refuses without changing inventory. Empty belts have a disabled command. The belt remains where it was. One activation during combat, free outside combat. Identity and contents are preserved; no dropping on the ground or partial emptying.

Newly generated well chambers use a compact irregular floor carved from overlapping rounded areas within 17×15 bounds, with a guaranteed return link. Dedicated seeded roll gives 40% a deeper entrance and 60% no deeper entrance. An existing deeper entrance still chooses 50/50 Underground cave/compact ruin using its separate seed stream. No automatic monsters/loot are added to the well chamber itself. Existing generated wells preserve geometry and links; no save reset or migration.

Files: Production/UI/inventory_grid.gd and item_target.gd emit shortcuts; game_ui.gd routes equip/context actions; Actors/grid_inventory.gd owns atomic emptying; World/location_world.gd owns well chamber/depth generation; location_templates.gd no longer declares an unconditional well child.

Validation: integration_test.gd passed 61 checks, including equip/unequip, populated-belt emptying, full-backpack atomic refusal, missing combat action refusal, exactly one combat activation, optional well snapshot and save/reload. input_test.gd verified actual control signals for backpack/equipment Shift-click and right-click. well_sweep.gd checked all walkable cells and exits across 100 wells: all connected, 36 deeper entrances. preview.gd rendered wells.png; inspected cave-like outlines. Scoped whitespace passed. Human F5 acceptance pending.

Original sources, test saves and preview retained. Production baseline updated. No player-save reset or commit.
