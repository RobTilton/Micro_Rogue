extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Water = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_water.gd")
const Placement = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_poi_placement.gd")
const World = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/map_world.gd")
var checks: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	assert(value, "Workshop/Rooms/UI Foundation/Prototype/tests/local_poi_placement_test.gd: " + message)
func fixture(biome: String, seed_value: int):
	var half_height: int = 10 + seed_value % 6
	var map = Map.new("test", "test", "Local", Vector2i(half_height*3,half_height*2))
	map.region_biome = biome
	map.links[Vector2i(1,3)] = {"kind":"Return", "id":"parent", "arrival":Vector2i(8,8)}
	for entry: Array in [[Vector2i(4,2),"Dungeon"],[Vector2i(3,4),"Town"],[Vector2i(5,4),"Tower"]]:
		map.links[entry[0]] = {"kind":entry[1],"id":"test_"+entry[1],"return_cell":entry[0]}
	Water.generate(map,seed_value)
	return map
func _initialize() -> void:
	var island_count: int = 0
	var layouts: Dictionary = {}
	for biome: String in ["Plains","Forest","Hills","Mountains","Desert","Wasteland","Sea","Lakes","Marsh","Swamp","Salt Marsh"]:
		for seed_value: int in range(24):
			var map = fixture(biome,seed_value)
			var water_before: Dictionary = map.water_cells.duplicate()
			var pinned: Vector2i = Vector2i(-1,-1)
			for cell: Vector2i in map.links:
				if map.links[cell].get("island",false): pinned = cell
			Placement.generate(map,seed_value)
			check(map.links.size() == 4,"Return and exactly three destinations")
			check(map.links[Vector2i(1,3)].arrival == Vector2i(8,8),"Return unchanged")
			check(map.water_cells == water_before,"no water carved by placement")
			var kinds: Dictionary = {}
			for cell: Vector2i in map.links:
				var link: Dictionary = map.links[cell]
				kinds[link.kind] = true
				check(map.walkable(cell) and not map.water_cells.has(cell),"dry walkable entrance")
				if link.kind != "Return":
					check(link.return_cell == cell,"child returns to relocated entrance")
					for other: Vector2i in map.links:
						if other != cell: check(map.distance(cell,other) >= 6,"destinations meaningfully separated")
			check(kinds.size() == 4,"distinct kinds retained")
			if pinned != Vector2i(-1,-1):
				island_count += 1
				check(map.links.has(pinned) and map.links[pinned].kind == "Tower","island Tower retained")
			var repeat = fixture(biome,seed_value)
			Placement.generate(repeat,seed_value)
			check(map.links == repeat.links,"repeatable seed")
			if biome == "Plains": layouts[str(map.links.keys())] = true
	check(island_count > 0 and island_count < 24,"both island and ordinary lakes covered")
	check(layouts.size() > 12,"different seeds vary placement")
	var world = World.new(1729)
	var descriptor: Dictionary = world.maps.global.links.values()[0]
	var local = world.resolve(descriptor)
	var original: Dictionary = local.links.duplicate(true)
	check(world.resolve(descriptor) == local and local.links == original,"revisit retains map and destinations")
	var second = World.new(1729)
	second.resolve(second.maps.global.links.values()[1])
	check(second.resolve(descriptor).links == original,"visit order does not affect placement")
	print("Workshop/Rooms/UI Foundation/Prototype/tests/local_poi_placement_test.gd: %d checks passed across 264 biome/seed cases" % checks)
	quit()
