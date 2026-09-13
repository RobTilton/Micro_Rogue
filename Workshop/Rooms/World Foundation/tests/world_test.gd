extends SceneTree
const Sim = preload("res://Workshop/Rooms/World Foundation/domain/persistent_actor_world.gd")
const Locations = preload("res://Workshop/Rooms/World Foundation/domain/location_world.gd")
const Actors = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/actors.gd")
const State = preload("res://Workshop/Rooms/World Foundation/domain/map_state.gd")
const Contracts = preload("res://Workshop/Rooms/World Foundation/domain/geographic_contracts.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/World Foundation/tests/world_test.gd: "+message)
func _initialize() -> void:
	var sim = Sim.new(1729)
	check(sim.maps is Locations,"factory selects hierarchical registry")
	var p: Dictionary = Actors.create([4,4,4,4,4,4])
	sim.add_actor(p,"global",sim.maps.maps.global.spawn_cell,"player","player")
	check(sim.maps.maps.size() == 1,"only global generated initially")
	check(sim.travel(p).ok,"travel into lazy Local")
	var local_id: String = p.map_id
	var local = sim.maps.maps[local_id]
	var dungeon_id: String = ""
	for cell: Vector2i in local.links:
		if local.links[cell].kind == "Dungeon": dungeon_id = local.links[cell].id; p.pos = cell
	check(not sim.maps.records[dungeon_id].generated,"POI remains deferred")
	sim.begin_turn(p)
	check(sim.travel(p).ok,"travel into dungeon")
	var dungeon = sim.maps.maps[dungeon_id]
	var floor_id: String = dungeon_id+"/floor_2"
	check(sim.maps.records.has(floor_id) and not sim.maps.records[floor_id].generated,"floor is declared lazily")
	var count: int = sim.actors.size()
	check(sim.unload_location(local_id).ok and not sim.maps.maps.has(local_id),"inactive Local unloads")
	sim.begin_turn(p)
	check(sim.travel(p).ok and p.map_id == local_id,"Return restores archived parent")
	check(State.capture(local) == State.capture(sim.maps.maps[local_id]),"restored map equals saved state")
	sim.begin_turn(p)
	check(sim.travel(p).ok and sim.actors.size() == count,"reentry does not repopulate")
	var first: Dictionary = sim.maps.request_poi(dungeon_id,"Dungeon")
	var second: Dictionary = sim.maps.request_poi(dungeon_id,"Dungeon")
	check(first.ok and second.ok and first.id != second.id,"same-type event instances unique")
	var before: Dictionary = sim.maps.records.duplicate(true)
	check(not sim.maps.request_poi(dungeon_id,"Dungeon",Vector2i(0,0)).ok and before == sim.maps.records,"failed request is atomic")
	nested_tests(sim)
	geography_tests()
	population_tests()
	p.clock.start("Lunge",4)
	p.pending = p.main.duplicate(true)
	p.actions.attack = 0
	corruption_tests(sim)
	var saved: Dictionary = sim.save_game("res://Workshop/Rooms/World Foundation/tests/saves/")
	check(saved.ok,"snapshot validates and writes: "+saved.reason)
	if saved.ok:
		var restored = Sim.new(1)
		check(restored.load_game(saved.path).ok,"snapshot loads")
		check(restored.maps.maps.size() == 1,"load materializes only player map")
		check(restored.snapshot() == sim.snapshot(),"complete state roundtrip")
		FileAccess.open("res://Workshop/Rooms/World Foundation/tests/restart_path.txt",FileAccess.WRITE).store_string(saved.path)
	print("World Foundation: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func nested_tests(sim) -> void:
	var local_id: String = ""
	for id: String in sim.maps.records:
		if sim.maps.records[id].template == "Local" and not sim.maps.records[id].generated:
			local_id = id
			break
	var before: Dictionary = sim.maps.records.duplicate(true)
	var loaded: Array = sim.maps.maps.keys()
	var counter: int = sim.maps.next_instance
	check(not sim.maps.request_poi(local_id,"Dungeon",Vector2i(-2,-2)).ok,"unseen invalid request rejected")
	check(before == sim.maps.records and loaded == sim.maps.maps.keys() and counter == sim.maps.next_instance,"rejected unseen request leaves registry unchanged")
	var event: Dictionary = sim.maps.request_poi(local_id,"Town")
	check(event.ok and not sim.maps.records[event.id].generated,"unseen event resolves parent only")
	var town = sim.ensure_map({"id":event.id})
	var well_id: String = town.id+"/well"
	check(not sim.maps.records[well_id].generated,"Town declares unresolved Well")
	sim.ensure_map({"id":well_id})
	var underground_id: String = well_id+"/underground"
	check(not sim.maps.records[underground_id].generated,"Well declares unresolved underground")
	sim.ensure_map({"id":underground_id})
	var parent: String = underground_id
	for depth: int in range(7):
		var request: Dictionary = sim.maps.request_poi(parent,"Well")
		check(request.ok,"recursive event depth %d" % depth)
		sim.ensure_map({"id":request.id})
		parent = request.id
	check(sim.maps.records[parent].address.begins_with(sim.maps.world_id+"/"),"deep hierarchy has world address")

func geography_tests() -> void:
	for seed_value: int in [1729,44,995]:
		var world = Locations.new(seed_value)
		var global_map = world.maps.global
		var inspected: int = 0
		for cell: Vector2i in global_map.links:
			var id: String = global_map.links[cell].id
			var contracts: Array = world.records[id].constraints.boundaries
			for contract: Dictionary in contracts:
				var other_id: String = global_map.links[contract.neighbor].id
				var paired: bool = false
				for other: Dictionary in world.records[other_id].constraints.boundaries:
					if other.key == contract.key:
						paired = other.water == contract.water and other.dry == contract.dry and other.river == contract.river and other.direction == (contract.direction+3)%6
				check(paired,"neighbor shares parent contract including wrap")
			if inspected >= 5: continue
			if not contracts.any(func(c): return c.river): continue
			inspected += 1
			var map = world.ensure_location(id)
			for contract: Dictionary in contracts:
				var cells: Array = Contracts.boundary_cells(map,contract.direction)
				for index: int in range(cells.size()):
					var wet: bool = contract.water[roundi(float(index)*4/maxi(1,cells.size()-1))]
					check(map.water_cells.has(cells[index]) == wet,"resolved boundary obeys water contract")
				if contract.river:
					check(map.river_routes.any(func(route): return route.get("parent_edge","") == contract.key and route.vertices.size() > 1),"parent river receives connected child route")
		check(inspected == 5,"river fixtures exercised")
	var a = Locations.new(719)
	var b = Locations.new(719)
	var ids: Array = a.records.keys().slice(1,4)
	for id: String in ids: a.ensure_location(id)
	ids.reverse()
	for id: String in ids: b.ensure_location(id)
	for id: String in ids: check(State.capture(a.maps[id]) == State.capture(b.maps[id]),"map generation independent of visit order")

func corruption_tests(sim) -> void:
	var baseline: Dictionary = sim.snapshot()
	var invalids: Array = []
	var altered: Dictionary = baseline.duplicate(true)
	altered.schema = 999
	invalids.append(altered)
	altered = baseline.duplicate(true)
	altered.records.global.parent = "global"
	invalids.append(altered)
	altered = baseline.duplicate(true)
	altered.actors[sim.player_id].clock_state = {"remaining":[]}
	invalids.append(altered)
	altered = baseline.duplicate(true)
	altered.actors[sim.player_id].bag = ["broken"]
	invalids.append(altered)
	altered = baseline.duplicate(true)
	altered.states.global.walls = "broken"
	invalids.append(altered)
	altered = baseline.duplicate(true)
	altered.actors[sim.player_id].off = altered.actors[sim.player_id].main.duplicate(true)
	invalids.append(altered)
	for index: int in range(invalids.size()):
		var path: String = "res://Workshop/Rooms/World Foundation/tests/saves/invalid_%d_%d.bin" % [Time.get_ticks_usec(),index]
		var file := FileAccess.open(path,FileAccess.WRITE)
		file.store_buffer(var_to_bytes(invalids[index]))
		file.close()
		check(not sim.load_game(path).ok,"malformed save refused %d" % index)
		check(sim.snapshot() == baseline,"refused load changes nothing %d" % index)

func population_tests() -> void:
	var a = Sim.new(2026)
	var b = Sim.new(2026)
	var ids: Array = a.maps.records.keys().slice(1,3)
	var targets: Array[String] = []
	for id: String in ids:
		a.ensure_map({"id":id})
		b.ensure_map({"id":id})
		targets.append(id+"/poi_dungeon_1")
	for id: String in targets: a.ensure_map({"id":id})
	targets.reverse()
	for id: String in targets: b.ensure_map({"id":id})
	for id: String in targets:
		var first: Dictionary = a.on_map(id)[0]
		var second: Dictionary = b.on_map(id)[0]
		check(first.stats == second.stats,"population stats independent of visit order")
		for slot: String in ["main","off","armor","belt"]:
			check(signature(first[slot]) == signature(second[slot]),"population equipment independent of visit order")

func signature(item: Dictionary) -> Dictionary:
	var result: Dictionary = item.duplicate(true)
	result.erase("item_id")
	if result.has("contents"):
		for index: int in range(result.contents.size()): result.contents[index] = signature(result.contents[index])
	return result
