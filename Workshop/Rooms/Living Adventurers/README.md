# Living Adventurers
Updated: 2026-09-17

Promoted to Production: **F5 now runs Living Adventurers** with normal production saves. The F6 prototype below remains isolated for testing.

1. Open `AdventurerPlaytest.tscn` in Godot and press **F6**.
2. Create a Workshop world and character. Six successful peaceful steps advance the NPC simulation.
3. Open **Options** for the adventurer roster, recent history and a manual simulation-turn test button.
4. In a safe town, open **Character → Retire in this town…**. Confirming permanently hands this actor to NPC control and starts character creation in the same world.

Workshop saves live under this Room's `Saves/`; automated saves use `Tests/`. Production saves are not loaded or pruned.

See [current state](CURRENT_STATE.md) for behavior, evidence and provisional rules, and [DOTS](DOTS.md) for completion status.
