# Living Adventurers
Updated: 2026-09-17

Approved outcome: Workshop-only playable NPC adventuring and retirement prototype. User authorized design/Room/execution while explicitly keeping F5 clean. Production and project configuration are read-only dependencies. No production-save access or promotion.
Starting state: current working runtime after Rings and Quality tuning; hashes captured in Reference/production_hashes.json. Design: Workshop/Micro_Rogue_NPC_Adventurers_Meta_Progression.md and current conversation.
Acceptance: six successful peaceful steps trigger one simulation turn; live/near/distant modes preserve actual actor/item state; NPCs trade, take goals, travel, fight, loot, return and die; retirement preserves build and continues the world; maximum three residents per global hex including retirees; ordinary NPCs displaced first, then earliest retiree, connected town migration or quiet terminal death. F6 scene, isolated saves, longer transition fades, validation and documentation.

- [LivingAdventurers]+[Foundation]+[Simulation] — complete. Persistent scheduler, controller, encounter resolver and population/retirement rules.
- [LivingAdventurers]+[Playtest]+[Scene] — complete. Isolated F6 game, retirement/roster controls, quest visibility and fades.
- [LivingAdventurers]+[Validation]+[Delivery] — complete. 67 automated checks passed, screenshots inspected, 105 protected file hashes unchanged, current-state and Room index synchronized.

Last completed: [LivingAdventurers]+[Validation]+[Delivery]. No active implementation Box. Next: human F6 playtest; Production promotion requires a separate decision. See [CURRENT_STATE.md](CURRENT_STATE.md) for evidence and limits. Retain Room files and test outputs. No deletes or commits.

- [LivingAdventurers]+[Production]+[Promotion] — complete. User checkpoint created and explicitly authorized Production promotion. Preserve existing save paths, remove testing controls from F5, validate actual Production scene and synchronize baseline.

Current last completed: [LivingAdventurers]+[Production]+[Promotion]. 73 Production-targeted checks passed. Next: human F5 playtest. Production promotion is authorized and delivered; prior no-promotion boundary is superseded.

- [LivingAdventurers]+[Movement]+[CheckpointCost] — complete (2026-09-18). Removed per-step geography invalidation, preserved per-step saves and immutable journal history. Snapshot assertions and 35 Production regression checks passed. Next: human F5 movement feel check.
