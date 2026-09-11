# Actor Foundation — Current State
Updated: 2026-09-11
Checkpoint: [Actor Foundation]+[Validation]+[Integration]
Implementation baseline/evidence: inherited UI Foundation Prototype with LocalPoiSpacing; BASELINE.json records pre-change input hashes. New Actor Foundation files are uncommitted; UI Foundation gains only a board-construction factory hook. No Production changes.

## Rapid Shape

A new runnable Workshop scene uses a persistent actor registry and a shared action boundary. Player input and enemy decisions call the same legal operations. Multiple enemies can coexist, pick up/equip loot, use potion/skill rules and pursue an observed map exit. Geography, POI spacing and initial enemy generation are reused. Runtime is at main.tscn; open it and use F6. Agent validation is delivered; Rob's acceptance remains pending.

## Locations And Ownership

| Owner | Responsibility |
|---|---|
| [domain/actor_world.gd](domain/actor_world.gd) | Actor registry, map ground, initialization, action costs, movement, skills, attacks, inventory, interaction/travel, death and turn scheduling |
| [domain/enemy_brain.gd](domain/enemy_brain.gd) | Replaceable decision policy; requests legal actions, does not implement alternate combat or inventory mutation |
| [domain/perception.gd](domain/perception.gd) | Eight-hex sight and wall-blocking hex ray, including horizontal wrap |
| [ui/actor_game.gd](ui/actor_game.gd) | Existing interface adapter: player commands, multi-target selection, wait/travel timing and visible actor/loot presentation |
| [ui/actor_view.gd](ui/actor_view.gd), [ui/actor_sprite.gd](ui/actor_sprite.gd) | Reuse terrain/panning; replace block actors with individually keyed sprites, selection rings and HP bars |
| [main.tscn](main.tscn) | New explicit launch scene |
| [art/README.md](art/README.md) | Source-derived static atlas, shader key and exact generation/edit prompts |
| [tests/](tests/) | Simulation and UI checks plus actual rendered capture |

Dependencies remain under UI Foundation/Prototype: map_world and its terrain generators, combat, actors/items, cooldowns, grid_inventory, movement_preview and UI components. The sole inherited implementation edit introduces `_make_board()` returning the original World view by default; this scene overrides it. No copied whole-game runtime or altered launcher.

## Actor And Action Contracts

Actor IDs are stable for a run. Each actor owns map_id, position, faction, sprite identity, existing stat/equipment fields, an action allowance, cooldown clock, pending skill/retreat state, sight memory and remembered item judgments. Registry actor dictionaries are authoritative; map-local ground arrays are authoritative. The old per-map single-enemy snapshot system is not used in this scene. Do not mix its save/restore methods with the new registry.

Both controllers use the following action boundary:

- Move: shared weighted pathfinding and occupancy; 3+DEX travel budget, one movement action. Optional exact preview path is revalidated.
- Attack: same faction/range/sight/life checks and existing damage/difficulty rules; main weapon then Show-Off offhand sword; action spending is shared. Existing difficulty rounding intentionally distinguishes player/enemy as before.
- Lunge: learned skill, ready clock and sword; DEX-length legal movement path; one attack, no normal movement spent; optional +1.5 STR attack; four-turn cooldown. Cancel does not refund costs.
- Riposte: learned skill and sword attack, two-turn cooldown, defense/counter on the next incoming attack; successful counter permits retreat up to ceil(DEX/2). The stance is consumed once. Pending Lunge/retreat blocks conflicting inventory/travel until resolved/cancelled.
- Inventory: existing transactional 8×5 grid, equipment compatibility, unique item ownership, belt slots, capacity and atomic refusal. Pickup spends activation then attacks then movement. Equipping/drop/belt transfers spend activation. Bag-to-bag rearrangement is free. A picked-up item must be owned before equipping.
- Potion: from equipped belt only, one activation, existing CON healing.
- Skill learning: same point cost and Lunge→Riposte→Show-Off prerequisite chain. Brain can spend available points; existing enemy creation still starts with no skills/points, so default enemies do not magically gain skills.
- World interaction: `interact()` supports existing entrance and pickup objects. Unknown kinds refuse. Future doors/chests need actual object/rule implementations; they have not been added here.

Deaths transfer enemy possessions to ground exactly once, clear the dead actor's ownership and award XP once. Dead IDs remain in the registry, excluded from live occupancy/scheduling/rendering. Player death still ends the adventure; it does not create an enemy-controlled player replacement.

## Perception And Decisions

Sight is eight hexes, blocked by solid map walls. Terrain remains visible; this is actor/loot perception, not terrain fog-of-war. Forest artwork and water do not block sight. Hidden actors/loot are not drawn. Ordinary pathfinding still respects occupied cells, including unseen occupants.

The simple policy learns available skills, resolves retreat, heals at half HP if able, and equips better owned items. Adjacent combat is urgent; otherwise it investigates visible equipment. Remotely it considers only visible item type; stats are evaluated after reaching one-hex inspection range. Rejected inferior items are remembered by ID. Upgrade score is expected item die value plus bonus, or belt capacity; this is deliberately a basic score, not build optimization. Full inventories and unavailable actions refuse without stealing/deleting the item.

The brain pursues visible hostiles, can Lunge if learned, uses available weapon attacks, and may prepare Riposte if learned and it has a remaining attack. Same-faction enemies do not attack one another. It does not invent skills from sprite weapons or species artwork.

When an opposing actor observes a departure, it remembers that exit and the destination entry location. It walks to the exit and uses ordinary travel. No teleporting to the player; no duplicate source/destination actor. Occupied arrivals use a free immediate neighboring cell; if all are occupied, travel waits without spending an activation. Unobserved departures reveal no exit. On losing sight, the enemy searches its remembered position and stops when reached/unreachable; it does not acquire the player's new map coordinates remotely.

## Turn Timing And Persistence

A world turn runs one phase for living NPCs on the player's map, plus actors with an active remembered pursuit/search elsewhere. Actor IDs are snapshotted before processing, so crossing maps cannot grant a second phase that turn. Other unaware offscreen maps remain paused.

In combat, the player uses allowances then End Turn. Outside combat, a successful move, paid inventory action or potion advances a turn; free bag rearrangement and inspection do not. Wait is available outside combat. Travel always costs activation and immediately grants an NPC phase, then the player's next allowance; repeated transitions therefore advance enemies rather than resetting them for free. An actor can arrive in another map while retaining HP, gear and cooldowns.

This scene uses turn-based cooldown ticks throughout; it does not use the old real-time three-second out-of-combat cooldown clock. New runs replace the registry and maps. No disk save, full-world simulation or random population spawning has been added.

## Validation And Limits

Godot 4.4.1, Windows engine through WSL:

- `actor_simulation_test.gd`: 134 checks, zero failures. Shared costs, wall sight, learned abilities, equipment/potion behavior, distant inspection, full-capacity atomic refusal, actor identity through pursuit, occupied arrival, lost sight, persistent deaths/loot and unknown-object refusal.
- `actor_ui_test.gd`: 17 checks, zero failures. Sprite wiring, waiting, map entry, multiple enemy selection, UI attacks/Riposte, observed pursuit, no duplicate drops, movement confirmation/world ticking, inventory access and new-run reset.
- Existing UI Foundation regression: baseline 2,027, UI 79, drag input 8, floating panels 14 — all pass after the board factory hook.
- Actual OpenGL 1440×900 capture inspected: `tests/actor_gameplay.png`. Player and two goblins appear over Local terrain with transparent runtime surroundings, rings and bars. It is a staged capture fixture, not random Local spawning. Sprite shader color multiplication was corrected after the first render.

An initial typed-array error in enemy pursuit was found and corrected; the final simulation checks pass. Runtime sprites use a magenta-key shader because the image tool supplied opaque output, not a true alpha cutout. The atlas was edited/generated from the supplied reference; it is not a pixel-exact extraction. Static south-facing player/goblin only: no animation, species variety, paper-doll gear rendering or sprite-dependent mechanics yet. Human visual acceptance remains pending.

No random Local enemies, random ground treasure, chests, doors, boats or broader object catalogue were added. These remain separate future work. Existing map generation and tile art, including permanent tile outlines, remain as before.
