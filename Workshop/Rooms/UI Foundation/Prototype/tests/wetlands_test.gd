extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
func _initialize() -> void:
	var directions: Array[Vector2i] = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
	var checks: int = 0
	for base: String in ["Plains","Forest","Sea","Lakes","Desert"]:
		for ocean_count: int in range(7):
			var map = Map.new()
			var center := Vector2i(3,3)
			map.biomes[center] = base
			for index: int in range(6): map.biomes[center+directions[index]] = "Sea" if index<ocean_count else "Plains"
			Biomes.apply_wetlands(map)
			var expected: String = base
			if base == "Plains" and ocean_count >= 4: expected = "Salt Marsh"
			elif base == "Plains" and ocean_count>0: expected = "Marsh"
			elif base == "Forest" and ocean_count>0: expected = "Swamp"
			assert(map.biomes[center] == expected,"wetlands_test.gd: adjacency rule")
			checks += 1
	print("wetlands_test.gd: %d checks passed" % checks)
	quit()
