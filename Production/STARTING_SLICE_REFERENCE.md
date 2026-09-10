# Earlier Starting Slice — retained reference

This describes the earlier baseline, not the active runtime. See README.md for current Production.

# Production Runtime
Updated: 2026-09-10
Checkpoint: [starting Slice]+[Delivery]+[ProductionPromotion]
Implementation baseline: accepted starting Slice, promoted with reference updates and passing headless checks; no Git commit created.

Production owns the adopted game. Open the **root** `project.godot`, open `Production/Gameplay/main.tscn`, and press **F6** to run this promoted slice. Root F5 currently runs the newer Workshop UI for playtesting. There is one Godot project for the repository; no separate project is required here.

- `Gameplay/main.tscn` and `Gameplay/main.gd`: runtime entry and orchestration.
- `Gameplay/`: character, item, inventory, combat, cooldown and presentation components.
- `Splash/splash_art.gd`: adopted splash art; no runtime dependency on Workshop.

Begin adventure, assign the six dice, and enter the arena. Use the action buttons and highlighted hexes. Unlock skills in the sidebar. Inventory controls equip, stock, remove and drop items. Defeated enemies leave their actual possessions. The next-encounter button preserves the adventurer, cooldowns and ground loot.

[System contract and full controls](../Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/MICRO_ROGUE_SLICE.md) owns detailed rules, paths, validation and limits. [Workshop tests](../Workshop/Tests/README.md) validate this runtime. Future experiments remain in Workshop until their Production adoption is authorized.
