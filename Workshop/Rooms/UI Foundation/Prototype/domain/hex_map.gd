extends RefCounted
## Shared axial grid data for every map scale. No rendering or actor ownership.
var id: String
var title: String
var layer: String
var dimensions: Vector2i
var walls: Array = []
var view_offset: Vector2 = Vector2.ZERO
var view_initialized: bool = false
var water_cells: Dictionary = {}
var biomes: Dictionary = {}
var region_biome: String = ""
var links: Dictionary = {}
func _init(map_id: String = "arena", map_title: String = "Arena", map_layer: String = "POI", extent: Vector2i = Vector2i(7,7)) -> void:
	id = map_id
	title = map_title
	layer = map_layer
	dimensions = extent
func contains(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < dimensions.x and cell.y < dimensions.y
func walkable(cell: Vector2i) -> bool:
	return contains(cell) and cell not in walls
func cells() -> Array:
	var result: Array = []
	for q: int in range(dimensions.x):
		for r: int in range(dimensions.y): result.append(Vector2i(q,r))
	return result
