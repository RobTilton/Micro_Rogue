extends SceneTree
const World = preload("res://Workshop/Rooms/Regional Foundation/Persistence/persistent_actor_world.gd")
const Contracts = preload("res://Workshop/Rooms/Regional Foundation/World/geographic_contracts.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Regional Foundation/tests/geometry_test.gd: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90.0).timeout.connect(func(): quit(2))
	var biome_counts: Dictionary = {}
	for seed_value: int in [1729,781,92841]:
		var world = World.new(seed_value)
		var global_map = world.maps.maps.global
		var selected: Dictionary = {}
		for cell: Vector2i in global_map.links:
			var biome: String = global_map.biomes[cell]
			if not selected.has(biome): selected[biome] = cell
		for biome: String in selected:
			biome_counts[biome] = biome_counts.get(biome,0)+1
			var cell: Vector2i = selected[biome]
			var id: String = global_map.links[cell].id
			var local = world.maps.ensure_location(id)
			check(local.cells().size() == 1261 and local.hex_radius == 20,"uniform shape across seeds/biomes")
			for field: String in ["biomes","water_cells","elevations","links"]:
				for position: Vector2i in local.get(field): check(local.contains(position),"generated data inside hex "+biome)
			for entrance: Vector2i in local.links: check(not local.water_cells.has(entrance),"dry entrance "+biome)
			for contract: Dictionary in world.maps.records[id].constraints.boundaries:
				var boundary: Array[Vector2i] = Contracts.boundary_cells(local,contract.direction)
				for index: int in range(boundary.size()):
					check(local.water_cells.has(boundary[index]) == contract.water[roundi(float(index)*4.0/(boundary.size()-1))],"water profile meets side contract")
				if contract.river:
					var found: bool = false
					for route: Dictionary in local.river_routes:
						if route.get("parent_edge","") == contract.key: found = route.vertices.size() > 1 and route.boundary_cell in boundary
					check(found,"inherited river reaches correct side")
		check(World.validate_snapshot(world.snapshot()).is_empty(),"all biome maps save coherently")
	check(biome_counts.size() == 11,"all playable biomes represented")
	# A shared seam across horizontal wrap uses the same canonical side samples.
	var world = World.new(1729)
	var global_map = world.maps.maps.global
	var a_cell := Vector2i(79,20)
	var b_cell := Vector2i(0,20)
	var a = world.maps.ensure_location(global_map.links[a_cell].id)
	var b = world.maps.ensure_location(global_map.links[b_cell].id)
	var a_edge: Array[Vector2i] = Contracts.boundary_cells(a,0)
	var b_edge: Array[Vector2i] = Contracts.boundary_cells(b,3)
	for index: int in range(a_edge.size()):
		check(a.water_cells.has(a_edge[index]) == b.water_cells.has(b_edge[index]),"wrap boundary water agrees")
		check(a.biomes[a_edge[index]] == b.biomes[b_edge[index]],"wrap boundary terrain agrees")
	print("Geometry: %d checks, %d failures; biome coverage %s" % [checks,failures,str(biome_counts)])
	quit(1 if failures else 0)
