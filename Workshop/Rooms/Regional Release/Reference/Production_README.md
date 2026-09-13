# Production Runtime
Updated: 2026-09-12
Checkpoint: [Production Promotion]+[Validation]+[Adoption]
Baseline: Rob accepted the working World Foundation game and authorized this self-contained promotion. Source/destination hashes and evidence are retained with the Production Promotion Room.

## Entry and ownership

Open the root project and press **F5**: **Production/main.tscn**. Its controller is UI/world_game.gd.

| Module | Owns |
|---|---|
| [Actors](Actors/README.md) | Actor identity, shared player/enemy actions, combat, inventory, progression and AI policy |
| [World](World/README.md) | Global topology, stable location records, constraints, lazy templates and map geometry |
| [Persistence](Persistence/README.md) | Automatic journals, snapshots, validation, map restoration and storage paths |
| [UI](UI/README.md) | Creation/startup, player intents, rendering, panels, sprites and travel fade |
| [Assets](Assets/README.md) | All required runtime artwork, copied independently from its original sources |

Production has no runtime reference to Workshop or to the preserved earlier builds. Placeholder status does not change asset ownership. An isolated package with Workshop and older builds absent passed rendering, startup, travel and persistence checks.

## Playing and persistence

- **Generate new world** establishes the Global layout and saves it before character creation. Dice/assignments survive restarting setup.
- **Continue world** restores the latest valid automatic checkpoint. Successful actions, turns, travel and event creation save automatically; normal window close also checkpoints.
- Move by clicking a hex. Options can disable confirmation; Shift-click bypasses it. Left/middle drag pans.
- Use Map or Activate while standing on an entrance. Local regions lead to Dungeon/Floor 2, Town/Well/Underground and Tower/Upper Tower. Travel fades around generation. Enemies can follow observed exits through the shared action system.
- Inventory retains grid placement, rotation with R, equipment/potions and shared action costs. End Turn/Wait advances actor turns.
- **Options → Save an extra snapshot** is an optional backup. **Unload inactive maps** releases map objects while retaining world state.

Saves are under `user://worlds/`. On Windows: `%APPDATA%/Godot/app_userdata/Micro Rogue/worlds/`. Journals, snapshots, archives and preserved imports have separate subfolders. The runtime does not inspect Workshop save folders.

A separate one-time save migration tool is provided with the promotion evidence. It validates complete Workshop saves, retains exact copies, activates the latest valid world only when Production has no active saves, and never removes originals. The actual source inventory at promotion contained no complete user saves; fixture worlds were not imported into the player's Continue menu.

## Preserved builds and current limits

`Production/Current` is a historical folder name for the 2026-09-10 UI slice. `Production/Gameplay` and `Production/Splash` are earlier baselines. They are preserved unchanged and are not current F5 ownership targets.

This promotion preserves accepted gameplay and placeholder art. It does not implement new item identification, classes, advanced AI/dungeon generation, equipment-changing sprites, contextual menus or geological events. The UI's established inheritance layers remain inside UI; journals still replay sequentially without pruning/compaction.

Validation and exact copy inventory: [Production Promotion](<../Workshop/Rooms/Production Promotion/CURRENT_STATE.md>). No deletion or Git commit occurred. Rob's source-gameplay acceptance is recorded; a quick human F5 verification remains welcome.
