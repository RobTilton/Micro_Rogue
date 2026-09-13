# World
Updated: 2026-09-12
Checkpoint: [Regional Release]+[Delivery]+[Promotion]

`location_world.gd` owns stable identities, lazy map resolution and generation. Global topology is seeded once; Local maps use radius-20 axial hexagons (1261 cells). Interiors keep template geometry. The preserved base `map_world.gd` and `continent_generator.gd` are overridden by this composition, not alternative active entry points.

`regional_state.gd` maintains Global-owned regional facts and source contributions. A radius-two data bubble resolves ahead of exploration without materializing Local maps. Source strength decays by one per wrapped Global hex; multiple sources add. Local generation publishes its finite POI pass, then regional revisions reconcile loaded maps immediately and unloaded maps when restored. `set_poi_hostility` changes pressure without rerolling populations or physical locations.

`local_entry.gd` supplies ordered dry candidates for each of six sides. Global arrival uses the opposite of the final Global movement direction, recorded by the shared actor service, including wrapping and multi-step paths. No approach uses a deterministic dry side. Occupancy never causes water arrival or transfer to another side. POI returns retain their actual location and require a free dry local cell. Boat exceptions and automatic neighbor traversal are deferred.

`geographic_contracts.gd` owns canonical neighbor boundary profiles and river ports. Surface profiles exclude shared corners; full edge candidates include corners. If no edge is dry, entry is refused rather than reshaping water. These are traversal-ready logical sides; neighboring maps are not stitched automatically.

Geometry revisions and regional revisions are separate so pressure changes do not force geography rewrites. Placeholders: generic Dungeon/Tower pressure 1; civilization suppression, prosperity/spawn formulas, monster families, roads and geological events are absent.
