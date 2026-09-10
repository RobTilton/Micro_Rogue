extends RefCounted
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
static func generate(map, seed_value: int) -> void:
	if map.region_biome not in ["Sea","Lakes","Salt Marsh"]: return
	var field = Biomes.noise(seed_value,0.22)
	for cell: Vector2i in map.cells():
		var sample: float = field.get_noise_2d(cell.x+cell.y*0.5,cell.y*0.8660254)
		if sample < (0.15 if map.region_biome in ["Sea","Salt Marsh"] else -0.1): map.water_cells[cell] = true
	# Keep entrances connected by dry paths; no swimming/boat mechanics inferred.
	for destination: Vector2i in map.links:
		var cell: Vector2i = Vector2i(1,3)
		map.water_cells.erase(cell)
		while cell != destination:
			if cell.x != destination.x: cell.x += signi(destination.x-cell.x)
			else: cell.y += signi(destination.y-cell.y)
			map.water_cells.erase(cell)
static func shore_edges(map, cell: Vector2i) -> Array[int]:
	var result: Array[int] = []
	if not map.water_cells.has(cell): return result
	for index: int in range(6):
		var neighbor: Vector2i = cell+DIRECTIONS[index]
		if map.contains(neighbor) and not map.water_cells.has(neighbor): result.append(index)
	return result
