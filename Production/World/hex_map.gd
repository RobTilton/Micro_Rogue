extends RefCounted
## Shared axial grid data for every map scale. No rendering or actor ownership.
const DIRECTIONS: Array[Vector2i] = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
var hex_radius: int = 0
var regional_revision: int = -1
var regional_values: Dictionary = {}
var wrap_horizontal: bool = false
var continents: Dictionary = {}
var spawn_cell: Vector2i = Vector2i(2,2)
var id: String
var title: String
var layer: String
var dimensions: Vector2i
var walls: Array = []
var shops: Dictionary = {}
var props: Dictionary = {}
var cave_layout: Dictionary = {}
var room_layout: Dictionary = {}
var view_zoom: float = 1.0
var view_offset: Vector2 = Vector2.ZERO
var view_initialized: bool = false
var rivers: Dictionary = {}
var elevations: Dictionary = {}
var river_routes: Array = []
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
	if hex_radius > 0:
		var delta := cell-Vector2i(hex_radius,hex_radius)
		return maxi(absi(delta.x),maxi(absi(delta.y),absi(delta.x+delta.y))) <= hex_radius
	return cell.x >= 0 and cell.y >= 0 and cell.x < dimensions.x and cell.y < dimensions.y
func walkable(cell: Vector2i) -> bool:
	return contains(cell) and cell not in walls and not shops.has(cell)
func cells() -> Array:
	var result: Array = []
	for q: int in range(dimensions.x):
		for r: int in range(dimensions.y):
			if contains(Vector2i(q,r)): result.append(Vector2i(q,r))
	return result

func canonical(cell: Vector2i) -> Vector2i:
	return Vector2i(posmod(cell.x,dimensions.x),cell.y) if wrap_horizontal else cell
func neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for direction: Vector2i in DIRECTIONS:
		var next: Vector2i = canonical(cell+direction)
		if contains(next): result.append(next)
	return result
func distance(a: Vector2i, b: Vector2i) -> int:
	var best: int = 2147483647
	for shift: int in ([-dimensions.x,0,dimensions.x] if wrap_horizontal else [0]):
		var delta: Vector2i = a-b-Vector2i(shift,0)
		best = mini(best,maxi(absi(delta.x),maxi(absi(delta.y),absi(delta.x+delta.y))))
	return best
