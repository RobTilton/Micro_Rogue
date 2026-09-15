# Dungeon and Tower Generation
Updated: 2026-09-14
Checkpoint: [Dungeon Foundation]+[Integration]+[Validation]

Production uses `Production/World/dense_room_generator.gd` for newly generated Dungeon, DungeonFloor, Tower and TowerFloor maps. Existing saved geometry remains unchanged. Cave and Underground geometry keep their own generators.

Rooms occupy packed axial bands: 3–4 columns, 3–5 rows (towers: 3 rows), each room 6–10 hexes wide and deep. Hex-cell walls separate rooms; adjacent rooms connect through single-hex doorways. Every doorway has an alternate room-graph route: no leaf rooms or long hallways. The axial bands look slanted on the hex board; this is an initial structured layout, not a copy of the reference or irregular architectural packing.

LocationWorld owns lazy floor declaration, normal stairs and the top-floor ladder. Towers currently have two floors. The bottom ladder is absent from links until a player successfully descends. Successful descent inserts the reciprocal link and increments geography revision so autosave retains it. Enemies can use available entrances under the shared actor travel system; their descent does not reveal the player shortcut.

MapState persists optional room_layout metadata, validates room membership and cyclic doorway connectivity, and accepts older maps without it. Per-room deterministic population uses existing goblin and loot generation, skipping entry/stair rooms. No new chest, room furnishing, or enemy class system is included.

Validation: 334 checks passed across 80 generation seeds and live Production scene integration: density, physical connectivity, deterministic layout, alternate doorway routes, stairs, hidden ladder reveal, climbing back, exact autosave/load. Isolated saves retained under tests/saves. Human visual playtest remains pending.

Runtime source references and prior baseline retained in Reference; no Git commit or player-save reset performed. New interiors can be reached through new POIs or fresh world generation; Map discovery can add a new dungeon to an existing Local.

[Adventure Loop](<../Adventure Loop/CURRENT_STATE.md>) supersedes this document for new cave counts, dungeon/tower geometry and minimap placement. Existing saved geometry remains intact.
