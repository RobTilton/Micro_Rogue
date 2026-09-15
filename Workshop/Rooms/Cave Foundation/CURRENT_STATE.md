# Cave Foundation — Current State
Updated: 2026-09-14
Checkpoint: [Cave Foundation]+[Validation]+[Delivery]

Production now generates Cave POIs using a room graph, then carves caverns and passageways. Rob’s navigation invariant: no dead-end branch beyond a single room off the main route. Dungeon and Tower generators remain unchanged.

## Finding a cave

New Local maps declare a Cave alongside Dungeon, Town and Tower, using the existing dry, spaced POI placement. On an existing Local, open Map and choose **Discover a cave** to create a persistent entrance without resetting the world. The current Cave marker is the generic C entrance marker. Activate at the entrance as with other POIs. Arrival is in the entry cavern; its Return link leads to the exact originating Local entrance. Existing saved locations are not regenerated.

## Generation contract

`Production/World/cave_generator.gd` builds six main caverns in a closed loop. Half of seeds also get a cross-connection; zero to two side caverns each attach directly to a main cavern. There are no side-room chains. The main cycle guarantees a route around rather than a long return through a linear chain. Passage intersections may create extra shortcuts; no intentional disconnected chambers or multi-room dead-end branches are generated.

First-pass tuning: 64×52 axial map bounds; main cavern radii 3–5 and side radii 2–3; rough outer rings; corridors nominally 1–2 hexes wide, with displaced midpoints and varied shortest steps producing bends. Cavern centers are jittered within a stable six-room scaffold. Thus seeds vary chamber outlines, widths, paths, side rooms and shortcut presence, but this is not yet arbitrary network topology or unlimited cave sizes. All rock remains the existing black blocked-wall representation; floor artwork remains the existing placeholder.

Each cavern retains id, seed, center, radius, main/side status and exact owned cells. Each passage retains endpoints, width, ordered centerline and carved cells. `main_route` and `entry_room` distinguish traversal structure from room content. `valid()` rejects broken main cycles, chained leaves and malformed/unwalkable paths. The seed sweep also checks physical flood-fill connectivity independently of recorded graph edges.

## Room content and persistence

`persistent_actor_world.gd` populates rooms once using a separate stream derived from each room seed. The entry room is left empty. Each other room has a provisional 60% chance of one existing enemy and 65% chance of one loose item, using current material tier 1–3 generation. Actors and loot carry their cavern id. These are test population defaults, not class, ecology or hostility scaling rules. No chest system or new enemies were invented. Room-owned cells/seeds are the entry point for later custom room layouts, chests and encounters.

Caves use the existing provisional hostility strength 1 and Global regional update path. New sources update regional truth normally. All room topology, walls, actors and items survive save/load and re-entry. Population does not run twice. Optional `cave_layout` in `hex_map.gd`/`map_state.gd` defaults empty for older ordinary maps; generated Cave records require nonempty valid topology. Generator/schema compatibility remains unchanged because existing geometry is preserved and the new template is additive.

## Evidence and remaining work

- Topology sweep: 40 seeds, 493 checks passed. Every carved cell reachable, room centers reachable, direct-leaf constraint holds, all 40 physical layouts distinct, same-seed output identical, broken cycles rejected and old map data loads without cave metadata.
- Rendered Production exercise passed: natural Cave discovery, entry-room arrival, room-owned monsters/loot, no re-population, exact journal roundtrip, Local return and re-entry. A follow-up headless run including explicit event discovery passed 13 checks. Counts vary with random world/population fixtures.
- [cave_gameplay.png](tests/cave_gameplay.png) shows actual gameplay and was inspected. [carved_overview.png](tests/carved_overview.png) is an axial-coordinate debugging overview: green main rooms, ochre side rooms, pale passages, dark rock. Its square pixels index axial cells; it is not a pixel-accurate hex-renderer screenshot or new art asset.

Source originals and prior manifest are retained in Reference. Production remains self-contained. Test saves are isolated in tests/saves. No player save reset, art replacement or Git commit. Human playtest acceptance pending. Next families are Dungeon and Tower; their room shapes/content can later reuse the graph-first concept, but no shared universal POI framework is claimed in this pass.

[Adventure Loop](<../Adventure Loop/CURRENT_STATE.md>) supersedes this document for new cave counts, dungeon/tower geometry and minimap placement. Existing saved geometry remains intact.
