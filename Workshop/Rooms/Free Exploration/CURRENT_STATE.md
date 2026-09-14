# Free Exploration
Updated: 2026-09-14
Checkpoint: [Free Exploration]+[Validation]+[Combat-only Actions]

F5 Production: activation and movement budgets apply during combat. Safe shopping, equipping, unequipping, inventory transfers, pickup, search, movement and services can be repeated without ending a turn. Gold, item consumption, capacity, reach, handedness and travel/rest time still apply. Inn stays remain one six-hour block. Existing saves work without reset.

The shared actor readiness boundary refreshes exploration mode using the existing engagement/pursuit check. Combat.available/spend/loot_cost honor that mode; inventory transfers use the noncombat path. When danger resumes, the actor receives a finite normal allowance with no accumulated free exploration grants. Subsequent refreshes do not refill combat actions. Momentum scheduling remains active in combat. Pending skills and retreat still require completion/cancellation. Explicit Wait remains available; safe actions do not automatically advance the turn scheduler. Existing pursuit counts as engagement.

The HUD shows Exploration instead of action counters outside combat. Every shop stock button has a native hover tooltip using the shared item inspection description: name, material/quality, damage and scaling or defense/capacity, and price. No separate item-stat calculation is introduced.

Files: Production/Actors/actor_world.gd, Production/Actors/combat.gd, Production/UI/actor_game.gd. Prior source versions and baseline retained under Reference/.

Validation: Free Exploration integration 13 checks passed, covering zero-activation repeated purchases/equipment changes, repeated movement without ticks, retained gold costs, finite combat re-entry, no combat refill, free equip after combat, save/load and tooltip content on every shop item. Living Frontier regression 18 checks passed. Frontier regression 75 checks passed with valid exact save restoration. Human hover/interaction playtest pending. Isolated test saves retained; no player-save reset or commit.
