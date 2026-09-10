# Micro Rogue
Updated: 2026-09-10

A Godot 4.4.1 roguelike proof: one-roll character creation, hex combat, Sword Mastery, random equipment, inventory, cooldowns and progression. The connected-map slice, floating UI, inventory cards and hex artwork are now promoted into Production.

This repository is **one Godot project**. Open root `project.godot` and press **F5** for the promoted game: `Production/Current/ui/main.tscn`.

Production holds promoted work. To iterate in the same editor, open `Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn` and press **F6**. `Production/Gameplay` and `Production/Splash` preserve the earlier baseline; `Production/Current` is the active runtime.

| Location | Ownership |
|---|---|
| `Production/` | Accepted runtime scenes, scripts and assets; source of current game behavior |
| `Workshop/` | Bounded development Rooms, tests, design, documentation and reusable tools |
| Root `project.godot` | Godot launcher and project-wide engine settings |
| Root `AGENTS.md`, `README.md`, `.gitignore`, `.git/` | Repository operating instructions and version-control infrastructure |
| Root `.godot/` | Generated, ignored editor cache |

Promoted runtime resources reference only Production. Workshop scenes use their own repository-root resource paths; no nested Godot projects are needed. Workshop tests import Production to validate the adopted game. Experiments belong in a scoped Workshop Room; adopting their result into Production requires the corresponding authorized promotion. Do not treat the retained splash prototype as another live game implementation.

- [Current Workshop UI](<Workshop/Rooms/UI Foundation/README.md>)
- [Production entry and controls](Production/README.md)
- [Runtime system contract](Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/MICRO_ROGUE_SLICE.md)
- [Tests](Workshop/Tests/README.md)
- [Project design](Workshop/Design/Micro_Adventure_Roguelike_Design_Doc_v0.1.md)
- [Completed starting Slice](<Workshop/Rooms/starting Slice/DOTS.md>)
- [Agent startup](AGENTS.md)

This is an accepted playable slice, not the full game. Combat balance, procedural worlds, full inventory presentation and additional trees remain future work. No automated Git checkpoint was created during promotion.
