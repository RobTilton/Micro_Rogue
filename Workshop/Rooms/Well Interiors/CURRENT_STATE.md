# Well Interiors
Updated: 2026-09-14
Checkpoint: [Well Interiors]+[Validation]+[Layouts]

Production Underground interiors below town wells now choose caves or compact dungeon ruins with an equal-probability seeded roll. The well chamber stays as the entrance layer. Choice uses a dedicated seed stream and does not reroll on visits. Existing generated maps remain unchanged. Newly generated well entrances name their Underground Cave outcome; existing saved link labels remain as saved.

Compact ruins reuse the partitioned dungeon generator with 6–9 rooms, width 28–36 and height 26–34 before boundary padding, two-cell walls and alternate room routes. A bounded-retry fallback is a connected six-room grid with loops. No extra dungeon floor is declared. A Ruin template is available to request_poi; this pass does not alter random Local entrance frequency or add ruins to that placement pool.

Cave outcomes use the established cave generator, including 8–14 main caverns and shallow branches. Population now dispatches by actual cave topology, giving Underground caves room-based monsters, bosses, loot and cave scenery. Ruins inherit dense-room population and scenery. Both return to the well through their spawn link and use existing persistence/state validation.

Files: Production/World/location_templates.gd, location_world.gd, dense_room_generator.gd and Production/Persistence/persistent_actor_world.gd. Originals retained under Reference/.

Validation: well_test.gd validated 32 deterministic wells (18 cave, 14 ruin), 32 compact ruins, graph validity, return links, scenery and repeatable geometry. well_integration.gd passed 54 checks, including actual town/well/underground initialization, snapshot validation, persistent character replacement and exact save/load. Adventure Loop regression passed 51 checks. Scoped whitespace passed. Human F5 acceptance pending. No save reset or commit; test artifacts retained.
