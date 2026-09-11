extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Water = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_water.gd")
func _initialize() -> void:
	for seed_value: int in range(40):
		var map = Map.new("lake","Lake","Local",Vector2i(36,24))
		map.region_biome = "Lakes"
		map.links[Vector2i(1,3)] = {"kind":"Return"}
		map.links[Vector2i(5,4)] = {"kind":"Tower","return_cell":Vector2i(5,4)}
		Water.generate(map,seed_value)
		assert(map.water_cells.size() > 864*0.4)
		assert(map.water_cells.has(Vector2i(17,11)))
		var visited: Dictionary = {Vector2i(17,11):true}
		var queue: Array = [Vector2i(17,11)]
		while not queue.is_empty():
			var cell: Vector2i = queue.pop_back()
			for direction: Vector2i in Water.DIRECTIONS:
				var neighbor: Vector2i = cell+direction
				if map.water_cells.has(neighbor) and not visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)
		assert(visited.size() == map.water_cells.size())
		for entrance: Vector2i in map.links:
			assert(not map.water_cells.has(entrance))
			if map.links[entrance].kind == "Tower": assert(map.links[entrance].return_cell == entrance)
	print("Lake basins: 40 seeds passed connected central water, coverage, dry POIs and return coordinates.")
	quit()
