# Living Adventurers — current state
Updated: 2026-09-18

Promoted to Production by explicit user instruction after their checkpoint. F5 now runs Living Adventurers. Human playtest of this promotion is pending. The isolated F6 prototype remains available. Authorization covers Workshop design and implementation while keeping F5 clean. Design source: [NPC Adventurers / Meta Progression](../../Micro_Rogue_NPC_Adventurers_Meta_Progression.md), refined by the user's simulation and retirement decisions.

## Playtest

Open `AdventurerPlaytest.tscn`, press F6 and create a new Workshop world. Walk six successful peaceful hex steps to advance nearby actors; failed movement does not count. Options exposes the roster, recent simulation history and a manual tick button. Character exposes retirement in a safe town. Retirement opens fresh character creation while retaining the world and old character as an NPC.

## Implemented behavior

- Adventurers use persistent actors, actual inventory, shared combat, equipment and progression. They visit shops, acquire supplies/upgrades, accept crier goals, travel, fight, loot, return, heal and claim rewards. Existing learned skills/builds are retained on retirement.
- Player-map encounters use live combat. Nearby off-map encounters resolve one real enemy per pass. At two or more global hexes away, expeditions use bounded probability resolution: up to 64 fights per pass, with at most three distant adventurers processed per tick in rotating order. Results change actual HP, supplies, enemies, XP and loot; entering or loading does not reroll them.
- Offscreen damage estimates use actual gear, stats, defenses, momentum and nearby enemy pressure. Zero-damage stalemates retreat. Death leaves ordinary persistent corpse/loot consequences. The loaded player map is excluded from abstract resolution.
- Every six successful peaceful player steps triggers a simulation turn, separately from the calendar. Combat interrupts exploration scheduling. NPC travel waits six existing world hours per global crossing; NPC inn stays cost one gold and wait six world hours, healing twice CON plus applicable healing bonuses. NPC actions do not advance the player's calendar themselves. Use normal travel, inn or camp to pass world time.
- Three adventurers maximum per global hex, including retirees; population and travel check both home residency and physical occupancy. Towns seed once, with no automatic replacement population yet.
- Retirement preserves actor identity, stats, equipment and skill board. Ordinary adventurers make room first; otherwise the earliest retiree is displaced. A connected town with capacity receives them. Without one, they die quietly: their full actor/gear record is removed, no corpse is created, and a bounded history entry remains.
- Transitions and border crossings use 0.25-second fades out and in. Adventurers use friendly humanoid presentation with name labels.

## Data and code

`adventurer_world.gd` extends the shared persistent world and owns the scheduler, controller, population and retirement. The ledger lives in global map constraints (`adventurers`): step count, turn, distant-processing cursor, retirement sequence, seeded towns and the last 100 history events. Each actor's `adventure` record persists home, goal, phase, rest/travel deadlines and progress.

`expedition_resolver.gd` resolves offscreen encounters against actual actors and items. `adventurer_game.gd` is a Workshop copy of the game shell with isolated save paths and retirement/diagnostic UI, inheriting shared actor UI. `adventurer_view.gd` and `adventurer_sprite.gd` adapt presentation without changing world factions. Shared Production modules remain read-only dependencies; future edits to the Production game shell do not automatically update this copied shell. Its starting version is preserved in `Reference/world_game.gd.txt`.

## Provisional boundaries

Any living character can retire in a safe town for testing; no level threshold is imposed. Connected-town overflow migration is an immediate abstract relocation. Ordinary seeded actors roll six d6 stats. Quest rewards go to the first successful claimant, while accepted-by labels show competing adventurers. Current placeholder skills are used; comprehensive AI skill selection and offscreen tactical skill effects remain future work.

Expedition probability and loot/equipment valuation need playtesting and tuning. This is bounded encounter simulation, not full tactical replay. NPC journeys waiting for calendar time will not complete just by repeatedly clicking the manual simulation tick. Broader world events and all future meta-progression ideas in the source document are not claimed implemented.

## Validation

Godot 4.4.1: `simulation_test.gd` passed 35 checks; `expedition_test.gd` passed 21; `playtest_test.gd` passed 11. Total: **67 checks, zero failures** across scheduler, real encounter outcomes, caps/migration/retirement, save round trips and the actual F6 retirement/new-character UI.

Inspected `retirement.png` and `roster.png`: town actors align with tiles, labels and Workshop controls are visible. Automated outputs remain in the Room. Human gameplay acceptance is pending.

The captured hashes of 105 Production/project files are unchanged. No Production promotion, project startup change, player-world reset or commit was performed.

## Production promotion — 2026-09-17

User created a checkpoint and requested promotion. `Production/UI/world_game.gd` now uses `Production/Persistence/adventurer_world.gd`, with resolver and presentation scripts owned by Production. No runtime dependency on this Room was added. Normal production save directories, preferences and existing one-world pruning behavior are preserved. Workshop labels and the manual simulation test button are absent from F5; retirement remains in Character. Existing saves accept the new ledger and seed loaded towns once, preserving world and character identity. No actual user save was touched during validation.

Production-targeted tests passed: 35 scheduling/retirement checks, 21 expedition checks, 11 actual-scene UI checks, and 6 old-save migration checks (73 total). Tests use isolated Room storage. Production baseline hashes refreshed. Earlier statements about F5 being unchanged describe the pre-promotion prototype only. Offscreen balance and the other provisional behavior above remain unchanged.

## Per-step movement pause fix — 2026-09-18

Peaceful steps no longer increment geography revision just to persist the six-step scheduler counter. The adventurer snapshot copies only the ledger's containing dictionary branch, retaining immutable prior journal snapshots and reusing unchanged map states. Per-step automatic saving remains enabled; combat interruptions and six-step NPC simulation remain intact.

An isolated starting-town profile measured repeated checkpoint work at about 179–185 ms before the fix, versus 16–18 ms in the final run. Initial full saves still cost more; these measurements do not claim all movement/frame costs or large-world simulation spikes are eliminated. Snapshot assertions confirmed previous step counters remain unchanged and geography states are reused. The 35-check Production scheduler/retirement regression passed. Original script preserved under `Reference/BeforeMovementFix/`. Human F5 movement playtest pending.
