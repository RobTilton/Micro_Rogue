# Production Runtime
Updated: 2026-09-13
Checkpoint: [Regional Release]+[Delivery]+[Promotion]

Press **F5** in the root project. `Production/main.tscn` is the active game. Regional Foundation generation, dry edge entry and the hex start menu are now adopted. Runtime scripts and artwork resolve entirely within Production.

## Start menu

A staggered vertical chain of hexes presents Options, Continue, World Data, New World and Regenerate World. Hovering or keyboard focus lifts an option slightly. Options controls movement confirmation; the preference persists independently of the current world.

- **New World** generates Global geography before character creation, replacing the previous active save after the new world is durably written.
- **Continue** resumes the current compatible world or unfinished character creation.
- **World Data** shows the seed, explored-location count and adventurer status.
- **Regenerate World** rolls a different seed, keeps the difficulty setting, and starts fresh character setup. It replaces the old world and adventurer; no old-world recovery copy is retained.

Older generator-one/two saves are not silently rerolled by Continue. If one remains, World Data explains that it needs regeneration; Regenerate can use its metadata and replace it with the current generation. No Workshop save is automatically imported by the runtime.

## World and controls

Locals are fixed hexagons: radius 20, 41 cells across opposite corners, 1261 playable cells. Global entry uses a dry cell on the edge opposite the actor's final Global movement step. Without a prior approach, a deterministic dry side is chosen. A wet or fully occupied approached edge refuses travel without spending an activation. Boats and direct edge crossing are not implemented. Return to Global is placed on a dry perimeter where available; fully wet regions remain inaccessible without future boat support.

Regional hostility is Global-owned and persisted. Each source contributes max(0, strength − Global hex distance). New sources update loaded regions immediately and unloaded regions on re-entry. Existing terrain, actors and equipment persist. Generic Dungeon/Tower pressure is currently 1; economy, suppression and monster-family formulas remain deferred.

Click to move; Shift-click bypasses confirmation. Left/middle drag pans. Activate on a location entrance to travel, with fade transitions. Player and enemies share movement, combat, inventory, progression and observed-exit pursuit capabilities. Inventory rotation uses R; Wait/End Turn advances actors.

## Persistence and ownership

There is **one active world save** under `user://worlds/` (`%APPDATA%/Godot/app_userdata/Micro Rogue/worlds/` on Windows). Actions, travel, turns, setup and normal close checkpoint automatically. Resume/regeneration retain only the current durable journal; old journals/snapshots and previous-world archives are removed. The extra-snapshot UI is removed. Journals compact to a full current-state checkpoint at 32 MiB rather than growing action history indefinitely. Map archives are streaming/cache data for the current world, not additional saved worlds.

| Module | Owns |
|---|---|
| [Actors](Actors/README.md) | Shared actions, identity, combat, equipment and AI policy |
| [World](World/README.md) | Topology, hex geometry, regional truth, locations and entry rules |
| [Persistence](Persistence/README.md) | Validation, incremental journals, one-save lifecycle and restoration |
| [UI](UI/README.md) | Hex startup menu, creation, rendering, input and travel fades |
| [Assets](Assets/README.md) | Owned placeholder/runtime artwork |

Earlier executable code is retained under `Production/Previous/WorldFoundation` with isolated user storage. `Current`, `Gameplay` and `Splash` are older historical builds. None is the active F5 entry or an old-world save backup.

[Release evidence and limits](<../Workshop/Rooms/Regional Release/CURRENT_STATE.md>). Contextual menus, boats, roads, direct edge crossing, economy and new item/class systems remain separate work. No Git commit was made.

Momentum scheduling is adopted with threshold **3**, effective speed **DEX + effects**, persistent remainders and one flexible action per extra grant. See [Momentum rules and item/effect hooks](<../Workshop/Rooms/Momentum Foundation/CURRENT_STATE.md>).

Equipment Integration is now adopted: generated material/quality gear, Physical/Magical damage with zero minimum, fixed armor contributions, seven equipment slots, handedness and initial ranged attacks. See [current rules and test evidence](<../Workshop/Rooms/Equipment Integration/CURRENT_STATE.md>). Existing compatible saves gain empty accessory slots; no world reset is required.

New Town locations now contain six single-hex roof shop placeholders. Approach and click to open the service menu. Trading/rest are not implemented yet; existing saved Town layouts remain unchanged. [Village state and screenshot](<../Workshop/Rooms/Village Foundation/CURRENT_STATE.md>).
