# Living Adventurers
Updated: 2026-09-17

Approved outcome: Workshop-only playable NPC adventuring and retirement prototype. User authorized design/Room/execution while explicitly keeping F5 clean. Production and project configuration are read-only dependencies. No production-save access or promotion.
Starting state: current working runtime after Rings and Quality tuning; hashes captured in Reference/production_hashes.json. Design: Workshop/Micro_Rogue_NPC_Adventurers_Meta_Progression.md and current conversation.
Acceptance: six successful peaceful steps trigger one simulation turn; live/near/distant modes preserve actual actor/item state; NPCs trade, take goals, travel, fight, loot, return and die; retirement preserves build and continues the world; maximum three residents per global hex including retirees; ordinary NPCs displaced first, then earliest retiree, connected town migration or quiet terminal death. F6 scene, isolated saves, longer transition fades, validation and documentation.

- [LivingAdventurers]+[Foundation]+[Simulation] — active. Persistent scheduler, adventurer controller, encounter resolver and population/retirement rules.
- [LivingAdventurers]+[Playtest]+[Scene] — planned; depends on Simulation. Isolated F6 game, roster/retirement controls, quest visibility and fades.
- [LivingAdventurers]+[Validation]+[Delivery] — planned; depends on Scene. Automated behavior/save checks, visual check, prove Production unchanged, synchronize docs.

Last completed: none. Human acceptance pending. Retain Room files and test outputs. No deletes or commits.
