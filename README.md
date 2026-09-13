# Micro Rogue
Updated: 2026-09-12

Open the root **project.godot** and press **F5**. The accepted game now runs from **Production/main.tscn**.

Production owns the working Actors, World, Persistence, UI and Assets modules. Its runtime has no Workshop dependency, including placeholder artwork. The staggered hex start menu offers New World, Continue, World Data and new-seed regeneration. Locals are fixed radius-20 hexagons with dry edge entry; regional hostility persists. There is one active world save, replaced on regeneration. Automatic saves live in Godot's writable user-data folder, not the repository.

| Location | Purpose |
|---|---|
| Production/main.tscn | Canonical F5 game |
| Production/Actors | Shared player/enemy capabilities, rules, inventory and AI policy |
| Production/World | Topology, location identity, templates, navigation and generation |
| Production/Persistence | Save validation, checkpoints, map state and writable storage |
| Production/UI | Controllers, creation flow, board, sprites, panels and input |
| Production/Assets | Independent runtime artwork, including current placeholders |
| Workshop/ | Experiments, design, original source material, tests and promotion evidence |
| Production/Current, Gameplay, Splash | Preserved earlier builds; none is the F5 entry |

This remains one Godot project. F6 can run a specific Workshop experiment, but F5 is the accepted Production game. Test tooling may inspect Production; Production never imports Workshop tooling or resources.

- [Production controls, saves and module ownership](Production/README.md)
- [Promotion baseline and evidence](<Workshop/Rooms/Regional Release/CURRENT_STATE.md>)
- [Workshop Rooms](Workshop/Rooms/README.md)
- [Design](Workshop/Design/Hierarchical_World_Gen.md)
- [User thoughts — unimplemented ideas](Workshop/Design/USER_HAD_A_THOUGHT.md)
- [Agent startup](AGENTS.md)

The source gameplay was accepted by Rob and promoted under explicit authorization. New gameplay, final art, item identification/classes and further AI/dungeon design remain separate work. Runtime removes obsolete world saves as explicitly requested; source/history material is retained and no Git commit was created.
