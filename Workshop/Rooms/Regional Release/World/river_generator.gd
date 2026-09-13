extends RefCounted
const Edges = preload("res://Workshop/Rooms/Regional Release/World/river_edges.gd")
const CORNERS: Array[Vector2i] = [Vector2i(1,-1),Vector2i(1,1),Vector2i(0,2),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(0,-2)]
static func vertex(map, point: Vector2i) -> Vector2i:
	return Vector2i(posmod(point.x,map.dimensions.x*2),point.y) if map.wrap_horizontal else point
static func water(map, cell: Vector2i) -> bool:
	return map.water_cells.has(cell) or map.biomes.get(cell,"") in ["Sea","Lakes"]
static func generate(map, seed_value: int) -> void:
	map.rivers.clear()
	map.river_routes.clear()
	var graph: Dictionary = {}
	var outlets: Dictionary = {}
	var heights: Dictionary = {}
	var edges_seen: Dictionary = {}
	for cell: Vector2i in map.cells():
		if not map.walkable(cell): continue
		for direction: int in range(6):
			var next: Vector2i = map.canonical(cell+map.DIRECTIONS[direction])
			if not map.walkable(next) or (water(map,cell) and water(map,next)): continue
			var key: String = Edges.key(map,cell,next)
			if edges_seen.has(key): continue
			edges_seen[key] = true
			var center := Vector2i(cell.x*2+cell.y,cell.y*3)
			var a: Vector2i = vertex(map,center+CORNERS[posmod(-direction,6)])
			var b: Vector2i = vertex(map,center+CORNERS[posmod(1-direction,6)])
			for pair: Array in [[a,b],[b,a]]:
				if not graph.has(pair[0]): graph[pair[0]] = []
				graph[pair[0]].append({"next":pair[1],"cell":cell,"direction":direction})
				heights[pair[0]] = maxf(heights.get(pair[0],-1.0),map.elevations.get(cell,0.0))
				if water(map,cell) or water(map,next): outlets[pair[0]] = true
	# Local rivers may drain out of the region; Global rivers must reach actual water.
	if map.layer == "Local":
		for point: Vector2i in graph:
			if graph[point].size() < 3: outlets[point] = true
	var distance: Dictionary = {}
	var frontier: Array = outlets.keys()
	for point: Vector2i in frontier: distance[point] = 0
	var head: int = 0
	while head < frontier.size():
		var point: Vector2i = frontier[head]
		head += 1
		for edge: Dictionary in graph[point]:
			if not distance.has(edge.next):
				distance[edge.next] = distance[point]+1
				frontier.append(edge.next)
	var candidates: Array = []
	for point: Vector2i in distance:
		if distance[point] >= 6: candidates.append(point)
	candidates.sort_custom(func(a: Vector2i,b: Vector2i):
		var score_a: float = heights[a]+distance[a]*0.04+posmod((str(a)+str(seed_value)).hash(),100)*0.001
		var score_b: float = heights[b]+distance[b]*0.04+posmod((str(b)+str(seed_value)).hash(),100)*0.001
		return score_a > score_b)
	var chosen: Array[Vector2i] = []
	for source: Vector2i in candidates:
		if chosen.size() >= (8 if map.layer == "Global" else 2): break
		var close: bool = false
		for previous: Vector2i in chosen:
			var dx: int = absi(source.x-previous.x)
			if map.wrap_horizontal: dx = mini(dx,map.dimensions.x*2-dx)
			if Vector2(dx,source.y-previous.y).length() < 14: close = true
		if close: continue
		chosen.append(source)
		var current: Vector2i = source
		var route: Array = [current]
		while distance[current] > 0:
			var selected: Dictionary = {}
			for edge: Dictionary in graph[current]:
				if distance.get(edge.next,2147483647) != distance[current]-1: continue
				if selected.is_empty() or heights[edge.next] < heights[selected.next]: selected = edge
			Edges.add(map,selected.cell,selected.direction)
			current = selected.next
			route.append(current)
		map.river_routes.append({"vertices":route,"outlet":current})
