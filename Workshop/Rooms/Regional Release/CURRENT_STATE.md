# Regional Release — Current State
Updated: 2026-09-12
Checkpoint: [Regional Release]+[Delivery]+[Promotion]

## Delivered

Production/main.tscn is the normal F5 entry and now composes Regional Foundation generation plus the approved entry/menu/save changes. Source Room scripts remain under this Room with res:// imports remapped into Production at adoption. Production has no Workshop runtime dependency. SOURCE_BASELINE.json records the original Regional Foundation script hashes; PROMOTION.json records the replaced code and adopted runtime. The old Production baseline/scene/README are preserved under Reference/; prior executable code is in Production/Previous/WorldFoundation with isolated user storage. No Git commit was made.

## Current behavior

- Locals are fixed radius-20 hexagons, diameter 41, 1261 playable cells. Global/regional persistence and source decay remain as validated in Regional Foundation.
- Actors record the exact final Global movement step (including multi-step paths, lunge and horizontal wrap). Local arrival selects the opposite side. With no approach, a deterministic dry side is selected. Candidates must be walkable, non-water and unoccupied. A blocked side refuses travel without spending activation. Player and enemy controllers share these rules. POI returns stay near the actual POI on dry terrain; they are not redirected to the region perimeter.
- A new Local's Return is on a dry perimeter where one exists. Fully wet edges are not carved into land; arrival is refused. Boats and direct Local-neighbor traversal remain deferred.
- The start menu follows Rob's sketch: staggered vertical outlined hexes, serif labels and underlines. Hover/focus rises 7 pixels over 0.14 seconds. Options, Continue, World Data, New World and Regenerate World are wired; Quit is separate. Layout scales to viewport size.
- Regenerate World rolls a different seed and starts fresh character setup, retaining difficulty. New World also replaces the active slot. Global is durably saved before character setup. The previous world is not retained as a backup.
- `world_slot.gd` removes obsolete journals/snapshots only after a complete replacement exists. Resume likewise leaves one journal. Journals compact at 32 MiB into a current-state checkpoint; the predecessor is then removed. Per-location archives are current-world cache data. Obsolete same-location archives and previous-world archives are removed; cleanup errors are reported. The extra-snapshot UI is removed.
- Movement confirmation preferences live independently in preferences.cfg. World Data describes current seed, explored locations and adventurer state. Unsupported generator-one/two worlds can be regenerated from menu metadata; Continue does not silently rebuild old geography. No Workshop world is automatically imported.

Production storage is user://worlds/. This Room's F6 candidate uses user://regional_release/. Automated menu/save tests explicitly use test-only directories. The accepted one-save deletion authority applies to obsolete game-save data in the runtime's dedicated storage, not source files or unrelated directories. Existing user progress is only replaced when the player selects New World/Regenerate, or a successfully resumed current world replaces its predecessor checkpoint.

## Validation

Production-targeted checks pass:

| Suite | Checks |
|---|---:|
| Geometry, 11 biomes × 3 seeds, river/surface boundaries | 96,399 |
| Regional pressure, atomic event rejection, actor preservation, persistence | 12,112 |
| Shared actor capabilities and pursuit | 134 |
| Dry directional edge entry and occupancy/water refusal | 30 |
| Rendered hex menu, hover, new-seed regeneration, one-save cleanup and compaction | 20 |
| Automatic saves, exact restoration, interrupted tail | 17 |
| Rendered gameplay, fades, nested locations and reload | 19 |

The Production menu was rendered with an actual OpenGL window; tests/production_start_menu.png records it. Workshop menu capture was visually inspected against Rob's reference. Normal project launch without a script override opened Production successfully. Save regression's measured movement delta was 876 bytes; timing is machine-dependent. The full regional generation was preserved without requiring the previous generation test code at runtime.

Automatic approval review briefly blocked the first Production validation attempts because of an account usage limit. Rob requested continuation; the same direct Godot checks then ran successfully. There is no remaining approval block.

## Limits and next step

Rob's F5 visual/playtest judgment remains pending for this release. Right-click contextual menu, boats, direct edge crossing, roads, economics, advanced population rules and other deferred systems are not included. The full-save transaction retains its 64 MiB limit; the current store is not an arbitrarily large indexed disk-streaming database. All code/test artifacts remain retained, except obsolete test save data intentionally removed while testing the authorized one-save behavior.
