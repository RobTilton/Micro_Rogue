extends RefCounted
const Edges = preload("res://Production/World/river_edges.gd")
const Rivers = preload("res://Production/World/river_generator.gd")

static func seed_for(seed_value: int, text: String) -> int:
	var value: int = seed_value & 0x7fffffff
	for byte: int in text.to_utf8_buffer(): value = ((value ^ byte)*16777619) & 0x7fffffff
	return value

static func from_global(global_map, cell: Vector2i, seed_value: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for direction: int in range(6):
		var neighbor: Vector2i = global_map.canonical(cell+global_map.DIRECTIONS[direction])
		if not global_map.walkable(neighbor): continue
		var key: String = Edges.key(global_map,cell,neighbor)
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_for(seed_value,key+":boundary")
		var a: String = global_map.biomes[cell]
		var b: String = global_map.biomes[neighbor]
		var wet_a: bool = a in ["Sea","Lakes"]
		var wet_b: bool = b in ["Sea","Lakes"]
		var river: bool = global_map.rivers.has(key)
		var profile: Array[bool] = []
		for index: int in range(5): profile.append((wet_a and wet_b) or ((wet_a or wet_b) and rng.randf() < 0.5))
		var materials: Array[String] = [a,b]
		materials.sort()
		var dry: String = materials[seed_for(seed_value,key)%2]
		if dry in ["Sea","Lakes","Salt Marsh"]: dry = "Plains"
		result.append({"key":key,"direction":direction,"neighbor":neighbor,"water":profile,"dry":dry,"river":river})
	return result

static func boundary_cells(map, side: int, include_corners: bool = false) -> Array[Vector2i]:
	if map.hex_radius > 0:
		# Exclude shared corner cells so adjacent contracts cannot overwrite each other.
		# Opposite sides use matching canonical sample order.
		var edge: Array[Vector2i] = []
		var radius: int = map.hex_radius
		var center := Vector2i(radius,radius)
		for step: int in range(0 if include_corners else 1,radius+1 if include_corners else radius):
			var offsets: Array[Vector2i] = [Vector2i(radius,-radius+step),Vector2i(step,-radius),Vector2i(-radius+step,-step),Vector2i(-radius,step),Vector2i(-radius+step,radius),Vector2i(step,radius-step)]
			edge.append(center+offsets[side])
		return edge
	# Six disjoint boundary sections, covering the rectangular perimeter.
	# Samples run in shared canonical parameter order, independent of cell count.
	var result: Array[Vector2i] = []
	match side:
		0:
			for y: int in range(map.dimensions.y): result.append(Vector2i(map.dimensions.x-1,y))
		1:
			for x: int in range(int(map.dimensions.x/2.0),map.dimensions.x-1): result.append(Vector2i(x,0))
		2:
			for x: int in range(1,int(map.dimensions.x/2.0)): result.append(Vector2i(x,0))
		3:
			for y: int in range(map.dimensions.y): result.append(Vector2i(0,y))
		4:
			for x: int in range(1,int(map.dimensions.x/2.0)): result.append(Vector2i(x,map.dimensions.y-1))
		5:
			for x: int in range(int(map.dimensions.x/2.0),map.dimensions.x-1): result.append(Vector2i(x,map.dimensions.y-1))
	return result

static func apply_surface(map, contracts: Array) -> void:
	for contract: Dictionary in contracts:
		var cells: Array[Vector2i] = boundary_cells(map,contract.direction)
		for index: int in range(cells.size()):
			var cell: Vector2i = cells[index]
			if contract.water[roundi(float(index)*4.0/maxi(1,cells.size()-1))]:
				map.water_cells[cell] = true
				map.biomes[cell] = "Sea"
			else:
				map.water_cells.erase(cell)
				map.biomes[cell] = contract.dry

static func route_constraints(map, contracts: Array) -> void:
	# Refine each parent shared-edge river as a connected child edge route to its port.
	var graph: Dictionary = {}
	var anchors: Dictionary = {}
	for cell: Vector2i in map.cells():
		for direction: int in range(6):
			var next: Vector2i = cell+map.DIRECTIONS[direction]
			if not map.walkable(cell) or not map.walkable(next): continue
			var center := Vector2i(cell.x*2+cell.y,cell.y*3)
			var a: Vector2i = center+Rivers.CORNERS[posmod(-direction,6)]
			var b: Vector2i = center+Rivers.CORNERS[posmod(1-direction,6)]
			for pair: Array in [[a,b],[b,a]]:
				if not graph.has(pair[0]): graph[pair[0]] = []
				graph[pair[0]].append({"next":pair[1],"cell":cell,"direction":direction})
			if not anchors.has(cell): anchors[cell] = a
	var hub_cell := Vector2i(int(map.dimensions.x/2.0),int(map.dimensions.y/2.0))
	if not anchors.has(hub_cell): return
	var hub: Vector2i = anchors[hub_cell]
	var previous: Dictionary = {hub:{}}
	var queue: Array[Vector2i] = [hub]
	var index: int = 0
	while index < queue.size():
		var vertex: Vector2i = queue[index]
		index += 1
		for edge: Dictionary in graph[vertex]:
			if previous.has(edge.next): continue
			previous[edge.next] = {"vertex":vertex,"edge":edge}
			queue.append(edge.next)
	for contract: Dictionary in contracts:
		if not contract.river: continue
		var boundary: Array[Vector2i] = boundary_cells(map,contract.direction)
		var cell: Vector2i = boundary[int(boundary.size()/2.0)]
		var port: Vector2i = anchors[cell]
		var current: Vector2i = port
		var vertices: Array[Vector2i] = [port]
		while current != hub:
			var step: Dictionary = previous[current]
			Edges.add(map,step.edge.cell,step.edge.direction)
			current = step.vertex
			vertices.append(current)
		map.river_routes.append({"vertices":vertices,"outlet":port,"parent_edge":contract.key,"boundary_cell":cell,"constrained":true})
