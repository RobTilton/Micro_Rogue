# Combat Awareness
Updated: 2026-09-15
Checkpoint: [Combat Awareness]+[Validation]+[Logs and Families]

Combat log details are now player-observed information. Player-involved attacks/counters retain numbers. Enemy-versus-enemy details require both participants visible on the player's map. Otherwise, same-map combat is grouped into one “You hear fighting in the distance.” message. When all tracked hidden pairs end (death, separation without pursuit, departure or hostility change), emit “The distant fighting falls silent.” once. Becoming visible switches to detailed reporting without a false silence message. Map changes reset transient hearing state. No sound carries between maps; hearing is currently map-wide, without acoustic distance/occlusion modeling.

Hidden deaths, potion use, pickups and off-map outcomes no longer leak identities, HP or loot. Offscreen daily combat remains simulated; its omniscient summary is removed from the player log. Hearing state and event queues are transient, not save data. Combat damage, XP, loot and AI turn resolution remain unchanged.

New room-based interiors store constraints.population_families with primary and optional rival. Provisional seeded policy: pick one resident family; 50% permit one distinct rival; occupied non-boss rooms pick primary 75% of the time when rival exists. Boss belongs to primary. Family choices use independent streams and do not increase spawn counts. Applicable to generated caves, dungeons, towers and compact ruins using shared room population. Existing populated maps are not reshuffled.

Enemy faction identity is separate from family. faction_key uses explicit faction_id, falling back to family for old saves. New enemies initialize faction_id from family. Enemies sharing an identity do not attack each other even when their families differ. Existing player/town relationship is unchanged. Both live AI and offscreen conflict use shared hostile(). IDs persist and validate on load. This is groundwork for authored alliances; no faction diplomacy UI, squad tactics or extra group spawning is added.

Files: Production/Actors/actor_world.gd owns observed events, hearing and hostility; enemy_brain.gd routes pickup messages; UI/actor_game.gd finalizes sound summaries at event flush; Persistence/persistent_actor_world.gd owns room roster, explicit faction IDs and offscreen log filtering.

Validation: awareness_test.gd passed 61 checks including 100 hidden hits reduced to one sound, multiple concurrent fights, final silence, visible/player details, off-map suppression, map-change reset, shared-faction alliance and deterministic rosters. family_integration.gd passed 61 checks through actual dungeon spawning, resident/rival membership, boss identity, save validation, replacement-character persistence and exact reload. Adventure Loop 51 regression checks passed. Scoped whitespace passed. Human playtest pending.

Performance: log traffic reduced by tested aggregation; no timing gain measured. _note appends to a seven-entry buffer, so logs alone are unlikely to explain the full simulation hitch. Hearing only revisits known combat pairs at flush; AI/pathfinding/visibility still run. Profiling stutters is separate follow-up. Original sources and isolated test saves retained. No save reset or commit.
