# Production Runtime
Updated: 2026-09-16
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

Cave POIs now generate compact caverns connected by narrow passages, a looped main route and side branches no deeper than one cavern. New Locals include Cave entrances; Map → Discover a cave adds one to an existing Local. Room contents persist. [Cave implementation and evidence](<../Workshop/Rooms/Cave Foundation/CURRENT_STATE.md>).

Dense Dungeon/Tower generation (2026-09-13): packed hex-cell rooms, cyclic single-door connections, persisted per-room content and a player-revealed tower return ladder. Existing saved layouts retained. See `Workshop/Rooms/Dungeon Foundation/CURRENT_STATE.md` for scope and validation.

Interior scenery (2026-09-13): new caves/dungeons/towers get persistent walkable props and fixed container loot. Shared search exposes contents for pickup; enemy corpses retain possessions. Temporary symbols pending transparent art. Details: `Workshop/Rooms/Interior Scenery/CURRENT_STATE.md`.

Town Market (2026-09-13): new radius-three towns with perimeter shops, persistent seeded stock and containers; shared purchases, new characters empty-equipped with 100 gold. Provisional prosperity and no restocking yet. See `Workshop/Rooms/Town Market/CURRENT_STATE.md`.

Town Life (2026-09-13): named-town starts, three allied NPCs, crier boss bounties, persistent hostility-based gold and player-relative monster levels. Rules and provisional formulas: `Workshop/Rooms/Town Life/CURRENT_STATE.md`.

Mouse Play (2026-09-13): contextual mouse actions, self double-click travel, wheel zoom with saved camera state, actor slides, Quests rail and minimap. Controls and evidence: `Workshop/Rooms/Mouse Play/CURRENT_STATE.md`.

World Time and Frontier (2026-09-13): adopted calendar, six-hour border travel, Local-edge exploration, starter trade route with two towns and a one-skill-point crier tutorial, sparse towns, outdoor encounters, independent monster aging, faction combat, stat spending and weekly stock. Authoritative scope and limits: `Workshop/Rooms/World Time and Frontier/CURRENT_STATE.md`. This supersedes earlier statements deferring these features or retaining player-relative monster scaling.

Living Frontier (2026-09-14): 1-gold inn recovery (2 × CON, one six-hour block), quest bearing/terrain hex, seven-day cleared-Local replenishment and monthly survivor occupation of visited cleared POIs. Supersedes prior inn-service deferral. Rules and validation: `Workshop/Rooms/Living Frontier/CURRENT_STATE.md`.

Free Exploration (2026-09-14): action budgets now apply during combat; safe shopping, inventory and exploration need no end-turn prompts. Shop stock has inspection tooltips. Gold and six-hour time costs remain. See `Workshop/Rooms/Free Exploration/CURRENT_STATE.md`.

Shop Sales (2026-09-14): backpack gear sells for half retail rounded down into the receiving merchant stock. Buy/sell confirmations support Ctrl bypass. New characters start with 50 gold; existing balances preserved. See `Workshop/Rooms/Shop Sales/CURRENT_STATE.md`.

Weapon Bonus Balance (2026-09-14): weapon material/quality damage modifiers doubled, including existing generated gear through compatible runtime resolution. Armor/HP/base dice/stat scaling unchanged. See `Workshop/Rooms/Weapon Bonus Balance/CURRENT_STATE.md`.

Item Presentation (2026-09-14): paper-doll inventory, equipped pouches and stat column; opaque item tooltips across inventory/loot/ground with inspection-distance rules preserved. Jewelry remains placeholders. See `Workshop/Rooms/Item Presentation/CURRENT_STATE.md`.

Adventure Loop (2026-09-14): shop potions/rations, six-hour ration Camp, half chest gold, varied caves and partitioned dungeon/tower rooms, replacement characters in the same world after death, and one minimap above the sidebar. Existing generated geometry is retained. [Current scope and evidence](<../Workshop/Rooms/Adventure Loop/CURRENT_STATE.md>).

Warning cleanup (2026-09-14): explicit integer truncation preserves runtime values while removing integer-division diagnostics. Strict compilation and 51 gameplay checks passed. [Evidence](<../Workshop/Rooms/Warning Cleanup/CURRENT_STATE.md>).

Belt progression (2026-09-14): tier and quality determine 1–14 potion pouches; existing generated belts upgrade on load with contents preserved. [Contract and evidence](<../Workshop/Rooms/Belt Progression/CURRENT_STATE.md>).

Well interiors (2026-09-14): newly generated underground areas have a seeded 50/50 cave/compact-ruin choice. Compact ruins reuse the looped dungeon layout with 6–9 rooms. Saved layouts stay intact. [Evidence](<../Workshop/Rooms/Well Interiors/CURRENT_STATE.md>).

Sprite integration (2026-09-15): existing props, wells/stairs/ladders, goblins, raiders and town residents use matching prepared Chad-Casso artwork. Saved worlds receive presentation changes without regeneration. [Mappings and validation](<../Workshop/Rooms/Sprite Integration/CURRENT_STATE.md>).

Interior presentation (2026-09-15): existing art now distinguishes cave, dungeon, ruin, well and tower floors. Decorative rugs/rubble no longer advertise search. Saved geometry is unchanged. [Evidence](<../Workshop/Rooms/Interior Presentation/CURRENT_STATE.md>).

Inventory/wells (2026-09-15): Shift-click equips/unequips gear; right-click carried belts offers atomic Empty belt. New wells are small irregular chambers, with a 40% deeper entrance chance. Existing wells persist. [Controls and evidence](<../Workshop/Rooms/Inventory Shortcuts and Wells/CURRENT_STATE.md>).

Combat awareness (2026-09-15): unseen same-map fighting uses grouped sound/silence messages; observed/player fights retain details. New room populations use resident/rival families with persistent faction identities. Existing enemies retain their families. [Contract and evidence](<../Workshop/Rooms/Combat Awareness/CURRENT_STATE.md>).

Controls help (2026-09-15): choose Options → Controls from either the start menu or the game. Global-map access is explained first. [Evidence](<../Workshop/Rooms/Controls Help/CURRENT_STATE.md>).

Playtest refinement (2026-09-15): shared WIS/effect sight, persistent fog memory, detection-triggered combat, STR physical scaling, reduced/concentrated loot, potion drops, baseline tooltip prices and accepted-only quests. [Contract and checks](<../Workshop/Rooms/Playtest Refinement/CURRENT_STATE.md>).

Attack effects (2026-09-15): visible attacks/counters now use weapon-specific slashes, projectiles and impact flashes from the imported placeholder sheet, with a drawn arrow fallback. [Mapping and evidence](<../Workshop/Rooms/Attack Effects/CURRENT_STATE.md>).

Enemy roster (2026-09-16): 12 families/42 sprite variants, hostility/player-level spawn weights, humanoid equipment/skill guards and creature natural attacks. Legacy creatures retain former possessions as ground loot. [Contract and validation](<../Workshop/Rooms/Enemy Roster/CURRENT_STATE.md>).
