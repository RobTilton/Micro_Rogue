extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Terrain = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_terrain.gd")
func _initialize() -> void:
	for biome: String in Terrain.PALETTES:
		for seed_value: int in [1,1729,70001]:
			var map = Map.new("test","Test","Local",Vector2i(36,24))
			map.region_biome = biome
			map.water_cells[Vector2i(0,0)] = true
			Terrain.generate(map,seed_value)
			var first: Dictionary = map.biomes.duplicate()
			Terrain.generate(map,seed_value)
			assert(first == map.biomes)
			var types: Dictionary = {}
			var same: int = 0
			var edges: int = 0
			for cell: Vector2i in map.cells():
				types[map.biomes[cell]] = true
				for neighbor: Vector2i in map.neighbors(cell):
					edges += 1
					if map.biomes[cell] == map.biomes[neighbor]: same += 1
			assert(types.size() >= 2)
			assert(float(same)/edges > 0.65)
			assert(map.biomes[Vector2i(0,0)] in ["Sea","Lakes"])
			assert(map.elevations.size() == 864)
	print("Local terrain: 33 biome/seed cases passed: deterministic patches, adjacency coherence, water and elevation.")
	quit()
