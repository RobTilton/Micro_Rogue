# Adventure Loop
Updated: 2026-09-14
Checkpoint: [Adventure Loop]+[Validation]+[Playtest Priorities]

F5 Production includes the playtest recovery and generation pass. Starting evidence: pre-change sources and Item Presentation baseline retained in Reference/.

General Goods adds five health potions (2 gold each) and five rations (1 gold each) per weekly stock cycle. Existing initialized towns receive supplies once on load/re-entry. Opening shops does not refill stock. Potions work from backpack or belt and heal CON. Rations occupy one backpack cell.

Camp consumes one backpack ration, advances six hours and heals 2×CON capped at maximum HP. It requires a ready actor outside combat on a non-Global map. Activate, self context menu and selected ration expose it. Refusal without a ration spends nothing. Inn remains one gold for six hours and 2×CON recovery.

Chest gold is halved, rounded down. A persisted marker makes existing chest migration idempotent on load/re-entry. Other container and corpse gold formulas are unchanged.

Caves now have 8–14 main caverns and zero to three one-cavern branches, retaining a looped main route. Dungeon/tower generation partitions variable footprints into differently sized rooms separated by two-cell walls, with two-cell door passages. Connections must retain alternate routes. Exterior-room trimming must preserve graph validity. A bounded retry retains the legacy generator as fallback; 24 tested buildings needed none. Existing saved geometry stays intact; new generation applies to previously ungenerated POIs. Cellular automata and distinct ruin/fort/nest/den layouts remain deferred.

Death opens replacement-character creation in the same world. Identity, seed, time and saved world changes survive creation/reload. The new actor receives normal fresh-character setup and a safe arrival in the starting town. Explicit New World/Regenerate still replaces the world. This pass does not add retrieval of fallen-player gear from a corpse.

One minimap is the first sidebar child above the location control; none remains over the board. Clicking it still moves the camera. Rendered placement inspected at 1440×900 in tests/sidebar.png.

[Item icon checklist](../../Chad-Casso/Requests/ITEM_ICON_CHECKLIST.md): 161 gear base icons and two consumables. Enemy sprites, floor imports and separate POI templates remain tracked in Workshop/TODO.md.

Validation: tests/adventure_test.gd passed 51 checks in both headless and rendered Godot 4.4.1. Includes 12 cave seeds, 24 buildings, graph validity/diversity, supplies, backpack potion, Camp recovery/time/refusal, no shop refill, chest migration, replacement creation/reload, retained world changes, single sidebar minimap and exact save/load. Scoped whitespace passed; no Production GDScript references to res://Workshop. Human F5 acceptance pending. Sources and isolated test artifacts retained; no player save reset or commit.
