extends RefCounted
const Contracts = preload("res://Production/World/geographic_contracts.gd")

static func dry(map, cell: Vector2i) -> bool:
	return map.walkable(cell) and not map.water_cells.has(cell) and map.biomes.get(cell,"") not in ["Sea","Lakes"]

static func candidates(map, side: int) -> Array[Vector2i]:
	var edge: Array[Vector2i] = Contracts.boundary_cells(map,side,true)
	var center: Vector2i = edge[edge.size()/2]
	edge.sort_custom(func(a: Vector2i,b: Vector2i):
		var distance_a: int = map.distance(a,center)
		var distance_b: int = map.distance(b,center)
		if distance_a != distance_b: return distance_a < distance_b
		return a.x < b.x or (a.x == b.x and a.y < b.y))
	var result: Array[Vector2i] = []
	for cell: Vector2i in edge:
		if dry(map,cell): result.append(cell)
	return result

static func arrival(simulation, map, side: int) -> Vector2i:
	# No boats exist yet. Never fall back into water or into a different side.
	for cell: Vector2i in candidates(map,side):
		if simulation.actor_at(map.id,cell).is_empty(): return cell
	return Vector2i(-1,-1)

static func default_side(map) -> int:
	for side: int in [3,4,2,5,1,0]:
		if not candidates(map,side).is_empty(): return side
	return -1
