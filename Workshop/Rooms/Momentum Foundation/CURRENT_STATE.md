# Momentum Foundation
Updated: 2026-09-12
Checkpoint: [Momentum Foundation]+[Persistence]+[Integration]

Production now uses a world momentum threshold of **3** for testing. Every living actor gains effective speed (DEX plus source-keyed effects, clamped at zero) each world tick. Each full threshold is removed from its meter, preserving the remainder. The first grant gives its normal action allowance; each further grant gives one flexible action. DEX 6 earns the normal allowance plus one flexible action per tick. DEX 1 earns its allowance every third tick. DEX 4 earns one extra flexible action every third tick.

Flexible actions pay movement, attacks, activations, potions, paid inventory operations and travel. Normal category actions are spent first. Pickup retains activation/attack/move priority, then flexible actions. Weapon requirements, cooldowns and prerequisites still apply. Normal dual-wield sequencing remains intact; additional flexible attacks use the main weapon. Unspent action allowances expire next world tick; momentum persists. Cooldowns advance once per world tick, including ticks without an action grant.

Player and NPCs share the scheduler and action payment service. All living actors accrue momentum, but spatial AI remains limited to the player map and existing pursuit/observation activity. No full-world AI expansion. The brain can spend extra flexible actions rather than hitting the old three-attack cap. Player turns automatically skip empty momentum ticks, capped at 256 ticks per advance to avoid unbounded stalls for tiny fractional speeds. Zero speed returns control after one tick; Wait can advance the world.

Outside combat, movement advances the world when movement and flexible actions are exhausted. Travel does not refresh an existing allowance; exhausted budgets advance normally. The HUD shows Free actions, speed and the momentum balance/threshold. New actors start with no unearned actions; Production earns the initial player allowance through the shared scheduler.

## Item/effect integration

Use the simulation service shared by all actors:

```gdscript
simulation.set_speed_effect(actor_id, "item:<unique-id>", 2.0)
simulation.set_speed_effect(actor_id, "effect:slow", -1.5)
simulation.set_speed_effect(actor_id, "effect:slow", 0.0) # removes source
simulation.adjust_momentum(actor_id, 1.0)
```

Each speed source replaces its own previous modifier, so repeated application does not stack accidentally. Both methods return the normal result dictionary. Speed changes and momentum adjustments affect grants on the next tick; already granted actions remain available. Momentum adjustments clamp at zero. Effects must be removed by their owning lifecycle; no duration/gear-stat system was invented. Effective speed is `Momentum.speed(actor)`. The simulation's `turn_threshold` is persisted and must be a positive integer; the default lives in `Production/Actors/momentum.gd`.

## Persistence and evidence

Momentum, speed effects, free budget and world threshold persist in snapshots and automatic journals. Existing generator-three saves missing these fields load with zero momentum/effects/free and threshold 3. Malformed new fields refuse loading before mutating the live simulation. Geography and the one-save lifecycle are unchanged; item generation remains untouched.

`tests/momentum_test.gd`: 28 checks passed covering remainders, fractional modifiers, flexible costs, inventory previews, cooldowns, NPC action counts, offscreen accrual, slow and stopped actors.

`tests/integration_test.gd`: 13 checks passed headlessly covering Production startup, extra movement budget, free travel through fades, exact journal roundtrip, legacy migration and atomic malformed-save rejection. Test saves are isolated under this Room and retained. The same 13 checks also passed in the rendered OpenGL Production scene. Human playtest acceptance remains pending.

Changed-file originals are in Reference; the prior Production manifest is Reference/BASELINE.json. Production/BASELINE.json records the adopted runtime. Prior Regional Release evidence describes its historical baseline. No Git commit was made.

## Superseding momentum rule — 2026-09-18

User changed shared gain to `world turn threshold + floor(effective DEX / 2) + momentum effects`, clamped at zero after effects. Default threshold is 3. All actors have the threshold as innate gain, so unmodified DEX 0–1 earns a full normal turn each tick; DEX 2–3 gains 4, DEX 4–5 gains 5, and DEX 6–7 gains 6. Extra grants remain flexible actions and remainders persist. Rings and source-keyed effects still modify gain, including slowing effects. Movement distance is unchanged.

Grant calculation, player catch-up guard, HUD and Production offscreen expedition estimates use the world's actual threshold. Previous DEX-only examples/tests are historical and superseded by `tests/innate_momentum_test.gd` (12 checks passed). Production UI compilation passed. Existing momentum meters and saves are preserved. Changed source snapshots retained in Reference/InnateMomentum.
