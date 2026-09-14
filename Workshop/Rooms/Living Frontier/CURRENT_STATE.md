# Living Frontier
Updated: 2026-09-14
Checkpoint: [Living Frontier]+[Validation]+[Recovery and Repopulation]

F5 Production now includes inn recovery, quest directions and timed repopulation. Existing saves remain compatible; no new world required for these additions. Human playtest acceptance is pending.

## Entry points and behavior
Approach the Inn and choose Rest: one gold (an activation only during combat), one six-hour block, healing capped at max HP by 2 × CON, no ration. The user-specified stay is exactly six hours. Full-health actors may pay to pass time. Refused interactions spend nothing. Rest advances the same clock that drives aging, factions, stock and population events. Calendar presentation is Month.day.block: 1 Morning, 2 Noon, 3 Evening, 4 Midnight. Each block is six hours; after Midnight comes the next day’s Morning. Existing elapsed-hour save storage is retained for compatibility; no hourly clock is displayed.

Crier and Quests entries show the target terrain hex, Global coordinates, biome and direction arrow, plus the Local POI entrance coordinates. The arrow gives a straight bearing, not a pathfinding instruction. When in the target Global region it instead indicates the Local entrance direction; its scope is labeled. Horizontal world wrapping is respected. The preview reuses Production terrain artwork.

At each seven-day calendar boundary, initialized Locals with no surviving enemy on the Local or in its encounter arenas receive up to three seeded scouts, depending on free dry cells. Spawns avoid entrances, props, the map spawn vicinity and the nearby player. Existing POI residents do not block outdoor replenishment. Containers and loot remain unchanged. This is a calendar boundary, not seven days counted from the last kill.

At each 30-day month boundary, living enemies physically in the Local can occupy previously initialized, cleared Cave/Dungeon/Tower POIs in that region. One actor moves into each eligible POI while survivors remain. Living occupants anywhere in that POI's descendant maps, including a player, prevent occupation. Active encounter actors stay in their arena. Unvisited POIs are not generated for this purpose. Migrants retain identity, stats, age, equipment and health. Trails are cleared at migration. The POI's normal hostility source returns and is removed when its last tracked settler dies. The original dead boss reference, completed quest rewards, scenery and loot are preserved; no duplicate tutorial reward or chest refill.

Daily aging/faction resolution precedes weekly/monthly processing at shared boundaries; weekly spawning precedes monthly occupation when both coincide. Saved per-Local period markers prevent repeating an event. Old saves adopt this at the next boundary, with no retrospective population catch-up.

## Files and validation
Runtime: Production/Persistence/persistent_actor_world.gd. UI: Production/UI/actor_game.gd and Production/UI/quest_hex.gd. Prior modified sources and baseline retained under Reference/.

Living Frontier integration: 18 checks, zero failures, including real week/month boundaries, no-money refusal, healing cap, encounter survivors, unchanged loot/boss references, actor identity, idempotence, corrupted-marker refusal and exact save/load. Rendered quest hex/arrow inspected in tests/quest_hex.png. Frontier regression: 106 checks, zero failures, valid save restoration. Scoped whitespace check passed. Modified runtime files contain no Workshop resource references. Isolated test saves retained; no player-save reset or Git commit.

Road/rivers artwork remains separate. There is no new boss promotion, renewed bounty chain, loot respawn or full population ecology in this pass.

Six Hour Blocks correction validated: Living Frontier 18 checks and Frontier 123 checks passed, including Morning/Noon/Evening/Midnight ordering and rollover.

Safe actions and shop hover details are superseded by [Free Exploration](<../Free Exploration/CURRENT_STATE.md>).
