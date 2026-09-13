# Regional Foundation
Updated: 2026-09-12
Checkpoint: [Regional Foundation]+[Persistence]+[Validation]

Adoption: Rob approved this generation and requested Production promotion with edge entry, a hex start menu and one-save regeneration. [Regional Release](../Regional%20Release/CURRENT_STATE.md) records the delivered successor. The behavior described below is the preserved source Room, not the current F5 release.


Open [main.tscn](main.tscn) in Godot and press **F6**. Choose **Generate new world**. This Workshop build has its own save folder (`user://regional_foundation/`); Production's F5 game and saves remain preserved.

Locals now have a fixed hexagonal footprint: radius 20, 41 cells across opposite corners, 1261 playable cells. Pan with left drag or middle drag to see the perimeter. Activate the center Return to reach Global; direct edge crossing is future work. Current character setup and Global starting position are retained.

Regional hostility is persisted Global state. New or changed POI sources update loaded maps immediately; unloaded maps synchronize on re-entry. Existing physical contents remain intact. Hostility math remains internal; future economy/spawn systems will consume it.

- [Current state and API](CURRENT_STATE.md)
- [Approved design refinements](DESIGN_CONTRACT.md)
- [DOTS](DOTS.md)
- [Full Local overview](tests/local_overview.png)
- [Gameplay capture](tests/local_gameplay.png)

Art remains the accepted placeholder art. This is a Workshop candidate, not a Production promotion.
