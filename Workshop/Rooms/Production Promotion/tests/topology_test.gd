extends SceneTree
const Map = preload("res://Production/World/hex_map.gd")
const Topology = preload("res://Production/World/topology_generator.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Production Promotion/tests/topology_test.gd: "+message)
func create(seed_value: int):
	var map = Map.new("global","Test","Global",Vector2i(80,42))
	map.wrap_horizontal = true
	map.spawn_cell = Topology.generate(map,seed_value)
	return map
func _initialize() -> void:
	var old: Dictionary = {}
	var areas: Array[int] = []
	var counts: Array[int] = []
	var worst_overlap: float = 0.0
	for seed_value: int in range(32):
		var map = create(seed_value*7919+17)
		var repeat = create(seed_value*7919+17)
		check(map.biomes == repeat.biomes and map.spawn_cell == repeat.spawn_cell,"seed reproduces topology")
		check(map.walkable(map.spawn_cell) and map.biomes[map.spawn_cell] == "Plains" and map.continents.has(map.spawn_cell),"spawn is dry land")
		var sizes: Dictionary = {}
		for id: int in map.continents.values(): sizes[id] = sizes.get(id,0)+1
		check(sizes[map.continents[map.spawn_cell]] >= 80,"spawn has substantial connected land")
		check(map.continents.size() >= 800 and map.continents.size() <= 1750,"land budget leaves both exploration and ocean")
		areas.append(map.continents.size())
		counts.append(sizes.size())
		for x: int in range(80): check(not map.walkable(Vector2i(x,0)) and not map.walkable(Vector2i(x,41)),"polar boundary preserved")
		if not old.is_empty():
			var intersection: int = 0
			for cell in map.continents:
				if old.has(cell): intersection += 1
			var overlap: float = float(intersection)/(old.size()+map.continents.size()-intersection)
			worst_overlap = maxf(overlap,worst_overlap)
			check(overlap < 0.8,"different seeds substantially change land mask")
		old = map.continents
	check(areas.max()-areas.min() > 500,"land/ocean ratio varies")
	check(counts.max() != counts.min(),"landmass count varies")
	print("Topology: %d checks, %d failures; land %d–%d; components %d–%d; maximum adjacent-seed Jaccard %.3f" % [checks,failures,areas.min(),areas.max(),counts.min(),counts.max(),worst_overlap])
	quit(1 if failures else 0)
