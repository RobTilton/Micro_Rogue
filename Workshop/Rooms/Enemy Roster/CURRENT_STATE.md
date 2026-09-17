# Enemy Roster
Updated: 2026-09-16
Checkpoint: [Enemy Roster]+[Validation]+[Integration]

Live entry: Production/main.tscn (F5). 12 families / 42 variants use the imported art. Player authorization includes hostility/player-level spawn weighting and humanoid equipment/skill restrictions; werebeasts explicitly humanoid, flesh golems explicitly non-humanoid.

## Spawn policy

Production/Actors/enemy_catalog.json owns families, variants, sprite paths/crops, humanoid flags, natural attacks and tuning parameters. enemy_roster.gd owns seeded selection. Provisional pressure = max(0, hostility) + max(0, player_level - 1) / 3. Family eligibility requires pressure >= minimum. Eligible weight = base_weight / (1 + abs(pressure - preferred_pressure)/5)^2; normalized when drawing. This changes the family mixture, not overall population counts.

| Family | Minimum pressure | Preferred pressure | Base weight | Variants |
|---|---:|---:|---:|---:|
| Bear | 2 | 6 | 14 | 4 |
| Boar | 0 | 3 | 18 | 4 |
| Dragon | 14 | 22 | 8 | 6 |
| Drake | 8 | 14 | 12 | 4 |
| Goblin | 0 | 2 | 30 | 4 |
| Mound | 4 | 9 | 12 | 3 |
| Orc | 3 | 8 | 20 | 1 |
| Raider | 0 | 3 | 25 | 1 |
| Slime | 0 | 2 | 20 | 4 |
| Undead | 0 | 6 | 22 | 4 |
| Werebeast | 6 | 11 | 15 | 3 |
| Wolf | 0 | 1 | 25 | 4 |

Variant ceiling = min(available variants, 1 + floor(pressure/5)); bosses add 2 pressure for this selection only. Eligible tiers have weights 1, 2, 3, etc., so stronger variants become more common while weaker variants remain possible. Room primary/rival families use this same weighting, with existing 50% rival chance and 75% primary room selection. Boss belongs to primary family. Local generation and later respawns use the same _monster path. Existing actors remain near their original spawn level and continue aging independently; current player level does not rescale existing actors. Boss stats retain the existing +25% rule.

## Anatomy and combat

The persisted boolean is humanoid. True: humans/raiders, goblins, orcs, zombies, skeletons, liches, werewolves, wereboars and werebears. False: wolves, bears, boars, slimes/cube, all mounds, drakes/dragons and flesh golems. can_use_skills follows this flag for new variants.

Non-humanoids spawn without equipment or inventory. Their natural_attack is separate from inventory and uses the shared hit/defense/action system. Provisional attacks are physical, range 1, STR scaling; base die is 4 for slimes, 6 for wolves/boars, 8 for bears/mounds, 10 for flesh golems/drakes, 12 for dragons. Die gains tier-1 and flat bonus gains 2*(tier-1). Offscreen strength includes this natural attack. No elemental resistances, breath weapons or species-specific spells added.

Shared Rules.compatible, GridInventory transfer, legacy Inventory.equip, learning/skill availability, drinking, shops and container search enforce anatomy. Natural attacks cannot be equipped or dropped as items. Non-humanoids spend advancement points on stats and explore/fight through the existing brain; they do not investigate equipment or containers. Humanoids retain shared equipment/skill mechanics.

## Persistence and rendering

On loading a legacy save, known enemies receive a matching variant without rerolling identity or stats. Existing names/faction IDs are preserved. Old non-humanoid equipment and carried items become ground loot at their current position, preserving item IDs and belt contents. Previously learned skills remain recorded but cannot be used; pending weapon skills/counters are cleared. Migration is idempotent once enemy_variant exists. Player possessions are untouched. New family distribution applies to new generation/respawns, not a replacement of current populations.

40 distinct PNG source sheets are copied unchanged under Production/Assets/Enemies. The combined mound sheet supplies three variants; the redundant single-view human reference is not a separate enemy. Sprite crops are metadata measured from the largest opaque component of the first facing; existing alpha is used with a shader threshold to remove faint fringe. No raster files were repainted. Each sprite is capped at 48 pixels tall and 56 wide before camera zoom. All creatures retain the existing single-cell footprint.

Current actor view uses one facing per variant. Six-direction mapping, body-specific equipment overlays, humanoid class loadouts, biome-specific family rules and natural special abilities remain future work. The current humanoid body image does not visualize equipped gear; lich and other humanoid starting loadouts still use the existing general equipment generator. Species/tier combat balance is provisional.

## Validation and handoff

596 focused checks passed: every variant reachable, art resource availability, variant/inventory validity, legal natural/equipment attacks, humanoid restrictions through modern and legacy APIs, named variants retained, seeded selection and pressure-dependent weights. 72 integration checks passed: existing layout/creation/recovery/UI/save behavior plus legacy wolf migration, item preservation and repeat save roundtrip. Scope-specific whitespace check passed. roster.png renders all 42 variants and was visually inspected after width capping.

Godot import still reports the pre-existing duplicate UID for Workshop/Rooms/Regional Release/Reference/Production_main.tscn; this unrelated warning was not changed. No player save reset or commit. Reference originals, metadata probe, tests, isolated test saves and gallery retained in this Room. Human balance and visual acceptance pending.
