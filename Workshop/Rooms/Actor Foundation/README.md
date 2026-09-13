# Actor Foundation
Updated: 2026-09-11


**World Foundation handoff (2026-09-11):** Hierarchical generation, recursive templates, saves and event POIs now run in [World Foundation](../World%20Foundation/README.md), composed with this accepted actor system. This scene retains its original generator. Map/simulation factory hooks and optional seeded actor/item generation support the new composition; actor 134/UI 17 and shared regression checks pass after those changes.

Open [main.tscn](main.tscn) in the existing root Godot project and press **F6**. This is the new actor-enabled Workshop scene. Root F5 and the separate UI Foundation scene retain their prior entry points.

Create a character and explore a region, then a Dungeon or Tower. The player uses a static adventurer sprite; enemies use a static goblin sprite. Click an enemy to select it; Attack then click the intended enemy to attack. Gold ring marks selection. Cyan/red rings distinguish player/enemies; bars show health.

- In combat, use movement/attack/activation allowances, then End Turn.
- Outside combat, a committed movement or paid inventory/potion action advances one world turn. Wait also advances a turn.
- Entrance travel costs activation and always advances a turn. An enemy must see the departure, reach the same entrance and pay its own travel cost to follow.
- Drop equipment to give enemies something to investigate. They inspect within one hex, pick up upgrades if they have capacity/actions, and equip using a later available activation. No random ground-loot population was added.
- Lunge, Riposte and Show-Off use shared actor rules. Static sprite appearance does not change with equipment.

[Current state](CURRENT_STATE.md) · [DOTS](DOTS.md) · [handoff](HANDOFF.md) · [gameplay capture](tests/actor_gameplay.png) · [sprite source and prompts](art/README.md)

Implementation and automated validation delivered; Rob accepted the delivered actor gameplay on 2026-09-11; water-art dissatisfaction remains separate. See current state for limits and test evidence.

Hierarchy alignment review: [World Generation Alignment](../UI%20Foundation/WORLD_GENERATION_ALIGNMENT.md). This is a design/code assessment, not an implemented generator migration. Equipment-dependent sprites are an explicit stretch goal; static actor sprites satisfy the current pass.
