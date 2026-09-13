extends SceneTree
const World = preload("res://Production/Persistence/persistent_actor_world.gd")
const State = preload("res://Production/Persistence/map_state.gd")
const Contracts = preload("res://Production/World/geographic_contracts.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Journal = preload("res://Production/Persistence/autosave_journal.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Regional Release/tests/regional_test.gd: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90.0).timeout.connect(func(): quit(2))
	var world = World.new(1729)
	var registry = world.maps
	var global_map = registry.maps.global
	var data: Dictionary = registry.records.global.regional
	var resolved: int = 0
	for value: Dictionary in data.hexes.values():
		if value.resolved: resolved += 1
	check(resolved == 19,"initial radius-two regional bubble")
	check(registry.maps.size() == 1,"bubble does not instantiate Local terrain")
	check(World.validate_snapshot(world.snapshot()).is_empty(),"new world snapshot validates")
	var center: Vector2i = global_map.spawn_cell
	var local_id: String = global_map.links[center].id
	var local = registry.ensure_location(local_id)
	check(local.hex_radius == 20 and local.cells().size() == 1261,"fixed radius and cell count")
	check(local.dimensions == Vector2i(41,41),"fixed diameter")
	check(not local.contains(Vector2i.ZERO),"bounding box corner excluded")
	check(local.contains(Vector2i(40,20)),"hex corner included")
	check(local.links.has(local.spawn_cell) and local.distance(Vector2i(20,20),local.spawn_cell) == 20,"Return starts at edge")
	var outline: Dictionary = {}
	for side: int in range(6):
		var boundary: Array[Vector2i] = Contracts.boundary_cells(local,side,true)
		check(boundary.size() == 21,"full edge length")
		for cell: Vector2i in boundary:
			check(local.contains(cell) and local.distance(Vector2i(20,20),cell) == 20,"edge cell on radius")
			outline[cell] = true
	check(outline.size() == 120,"six complete edges share six corners")
	for cell: Vector2i in local.cells():
		check(local.biomes.has(cell),"terrain covers playable cells")
		for neighbor: Vector2i in local.neighbors(cell): check(local.contains(neighbor),"navigation stays inside")
	for cell: Vector2i in local.links: check(local.contains(cell) and not local.water_cells.has(cell),"valid dry entrance")
	check(data.hexes[center].pois.size() == 3,"generated POIs published once")
	check(local.regional_revision == data.hexes[center].revision,"generation synchronizes values")
	world.add_actor(Actors.create([4,4,4,4,4,4]),"global",center,"player")
	world.initialized[local_id] = true
	world.ground[local_id] = []
	world.add_actor(Actors.create([4,4,4,4,4,4],true),local_id,Vector2i(20,21),"enemy")
	var actor_baseline: Dictionary = world.snapshot().actors
	var original: Dictionary = State.capture(local)
	var neighbor: Vector2i = global_map.canonical(center+Vector2i(3,0))
	var dragon_local: String = global_map.links[neighbor].id
	var event: Dictionary = registry.request_poi(dragon_local,"Dungeon",Vector2i(-1,-1),"Dragon influence fixture",5)
	check(event.ok,"late event stages unresolved Local and creates source")
	check(registry.maps[local_id] == local,"staged event preserves existing live map identity")
	var source_id: String = event.id
	check(data != registry.records.global.regional,"staged event commits separate regional dictionary")
	data = registry.records.global.regional
	for target: Vector2i in data.hexes:
		check(data.hexes[target].contributions.get(source_id,0) == maxi(0,5-global_map.distance(neighbor,target)),"one point decay including wrap")
	check(local.regional_values.contributions.get(source_id,0) == 2,"loaded map immediately sees dragon three away")
	check(local.biomes == original.biomes and local.links == original.links,"pressure does not regenerate physical map")
	var revision: int = registry.regional_revision
	check(registry.set_poi_hostility(source_id,5).ok and registry.regional_revision == revision,"same strength is idempotent")
	var before_bad: Dictionary = world.snapshot()
	var refused: Dictionary = registry.request_poi(global_map.links[global_map.canonical(center+Vector2i(5,0))].id,"Dungeon",Vector2i.ZERO,"Invalid",5)
	check(not refused.ok and world.snapshot() == before_bad,"invalid staged event changes nothing")
	check(registry.unload(local_id),"unload persists Local")
	check(registry.set_poi_hostility(source_id,7).ok,"source strength changes while Local absent")
	check(not registry.maps.has(local_id),"source updates do not materialize unloaded Local")
	local = registry.ensure_location(local_id)
	check(local.regional_values.contributions[source_id] == 4,"re-entry reconciles stale cache")
	check(local.links == original.links and local.biomes == original.biomes,"re-entry keeps original terrain and POIs")
	check(world.snapshot().actors == actor_baseline,"regional changes preserve actor identity, health and equipment")
	var journal = Journal.new()
	var first: Dictionary = journal.checkpoint(world.snapshot(),"res://Workshop/Rooms/Regional Release/tests/production_regression_saves/")
	check(first.ok,"initial regional journal writes")
	check(registry.set_poi_hostility(source_id,0).ok,"remove source pressure without deleting POI")
	check(not local.regional_values.contributions.has(source_id),"live cache removes pressure")
	check(journal.checkpoint(world.snapshot(journal.previous),"res://Workshop/Rooms/Regional Release/tests/production_regression_saves/").ok,"regional change delta saves")
	var restarted = World.new(42)
	var loaded: Dictionary = restarted.load_game(journal.path)
	check(loaded.ok,"restart accepts regional journal")
	check(restarted.snapshot().records == world.snapshot().records,"location records survive restart exactly")
	check(restarted.snapshot().regional_hexes == world.snapshot().regional_hexes,"Global regional truth survives restart exactly")
	check(restarted.snapshot().actors == actor_baseline,"restart retains original actor equipment and state")
	check(restarted.maps.ensure_location(local_id).regional_values == local.regional_values,"Local cache survives restart")
	var corrupted: Dictionary = world.snapshot()
	corrupted.regional_hexes[center].hostility += 100
	check(not World.validate_snapshot(corrupted).is_empty(),"inconsistent hostility save rejected")
	var bad_geometry: Dictionary = world.snapshot()
	bad_geometry.states[local_id].hex_radius = 19
	check(not World.validate_snapshot(bad_geometry).is_empty(),"inconsistent shape save rejected")
	print("Regional Foundation: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
