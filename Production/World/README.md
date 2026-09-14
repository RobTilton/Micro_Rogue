# World
Updated: 2026-09-14
Checkpoint: [Regional Release]+[Delivery]+[Promotion]

`location_world.gd` owns stable identities, lazy map resolution and generation. Global topology is seeded once; Local maps use radius-20 axial hexagons (1261 cells). Interiors keep template geometry. The preserved base `map_world.gd` and `continent_generator.gd` are overridden by this composition, not alternative active entry points.

`regional_state.gd` maintains Global-owned regional facts and source contributions. A radius-two data bubble resolves ahead of exploration without materializing Local maps. Source strength decays by one per wrapped Global hex; multiple sources add. Local generation publishes its finite POI pass, then regional revisions reconcile loaded maps immediately and unloaded maps when restored. `set_poi_hostility` changes pressure without rerolling populations or physical locations.

`local_entry.gd` supplies ordered dry candidates for each of six sides. Global arrival uses the opposite of the final Global movement direction, recorded by the shared actor service, including wrapping and multi-step paths. No approach uses a deterministic dry side. Occupancy never causes water arrival or transfer to another side. POI returns retain their actual location and require a free dry local cell. Boat exceptions and automatic neighbor traversal are deferred.

`geographic_contracts.gd` owns canonical neighbor boundary profiles and river ports. Surface profiles exclude shared corners; full edge candidates include corners. If no edge is dry, entry is refused rather than reshaping water. These are traversal-ready logical sides; neighboring maps are not stitched automatically.

Geometry revisions and regional revisions are separate so pressure changes do not force geography rewrites. Placeholders: generic Dungeon/Tower pressure 1; civilization suppression, prosperity/spawn formulas, monster families, roads and geological events are absent.

Cave generation is owned by `cave_generator.gd`: deterministic room graph, organic carved cells, main loop and optional single-room branches. Room/passage metadata is separate from actor content. Existing Dungeon/Tower layouts remain unchanged. See [Cave Foundation](<../../Workshop/Rooms/Cave Foundation/CURRENT_STATE.md>).

Dense Dungeon/Tower generation (2026-09-13): packed hex-cell rooms, cyclic single-door connections, persisted per-room content and a player-revealed tower return ladder. Existing saved layouts retained. See `Workshop/Rooms/Dungeon Foundation/CURRENT_STATE.md` for scope and validation.

Interior scenery (2026-09-13): new caves/dungeons/towers get persistent walkable props and fixed container loot. Shared search exposes contents for pickup; enemy corpses retain possessions. Temporary symbols pending transparent art. Details: `Workshop/Rooms/Interior Scenery/CURRENT_STATE.md`.

Town Market (2026-09-13): new radius-three towns with perimeter shops, persistent seeded stock and containers; shared purchases, new characters empty-equipped with 100 gold. Provisional prosperity and no restocking yet. See `Workshop/Rooms/Town Market/CURRENT_STATE.md`.

Town Life (2026-09-13): named-town starts, three allied NPCs, crier boss bounties, persistent hostility-based gold and player-relative monster levels. Rules and provisional formulas: `Workshop/Rooms/Town Life/CURRENT_STATE.md`.

Mouse Play (2026-09-13): contextual mouse actions, self double-click travel, wheel zoom with saved camera state, actor slides, Quests rail and minimap. Controls and evidence: `Workshop/Rooms/Mouse Play/CURRENT_STATE.md`.

World Time and Frontier (2026-09-13): adopted calendar, six-hour border travel, Local-edge exploration, starter trade route with two towns and a one-skill-point crier tutorial, sparse towns, outdoor encounters, independent monster aging, faction combat, stat spending and weekly stock. Authoritative scope and limits: `Workshop/Rooms/World Time and Frontier/CURRENT_STATE.md`. This supersedes earlier statements deferring these features or retaining player-relative monster scaling.

Living Frontier (2026-09-14): 1-gold inn recovery (2 × CON, one six-hour block), quest bearing/terrain hex, seven-day cleared-Local replenishment and monthly survivor occupation of visited cleared POIs. Supersedes prior inn-service deferral. Rules and validation: `Workshop/Rooms/Living Frontier/CURRENT_STATE.md`.
