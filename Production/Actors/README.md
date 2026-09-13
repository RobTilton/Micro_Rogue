# Actors
Updated: 2026-09-13
Checkpoint: [Production Promotion]+[Runtime]+[Modules]

Shared capabilities for player and enemies live here. `actor_world.gd` owns actor identity, legal actions, turns, perception-driven travel and ground ownership. `enemy_brain.gd` chooses actions through that same service. `actors.gd`, `items.gd`, `combat.gd`, `cooldowns.gd` and inventory helpers implement the common rules.

Player and enemies retain the same action capabilities; AI policy is separate from capability. The player controller belongs to UI. Durable world composition is `Persistence/persistent_actor_world.gd`, which extends the shared actor service without duplicating gameplay rules.

This promotion preserves the accepted behavior. Static sprites, basic AI and item generation remain the current placeholders; no new classes, identification system or abilities were added.

`momentum.gd` owns speed and threshold grants (default 3). ActorWorld schedules all living actors and exposes source-keyed speed effects and momentum adjustments. Combat centralizes normal/flexible action payment. See [rules and hooks](<../../Workshop/Rooms/Momentum Foundation/CURRENT_STATE.md>).

Current equipment/combat rules supersede the original placeholder item/defense rules: `loot_catalog.json`, `loot_generator.gd` and `equipment_rules.gd` feed the shared item, combat and inventory services. Chest/head/arms/legs and offhand contributions are fixed, with innate CON/WIL defense. See [Equipment Integration](<../../Workshop/Rooms/Equipment Integration/CURRENT_STATE.md>) for source defaults, formulas and remaining modules.
