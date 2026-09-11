extends RefCounted
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
static func generate(map, seed_value: int) -> void:
	if map.region_biome not in ["Sea","Lakes","Salt Marsh","Marsh","Swamp"]: return
	map.water_cells.clear()
	if map.region_biome == "Lakes":
		_generate_lake(map,seed_value)
		return
	var field = Biomes.noise(seed_value,0.07)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var angle: float = rng.randf()*TAU
	var direction := Vector2.from_angle(angle)
	var middle := Vector2(map.dimensions-Vector2i.ONE)*0.5
	for cell: Vector2i in map.cells():
		var delta: Vector2 = Vector2(cell)-middle
		var position := Vector2(delta.x+delta.y*0.5,delta.y*0.8660254)
		var sample: float = field.get_noise_2dv(position)
		var coast: float = position.dot(direction)/float(mini(map.dimensions.x,map.dimensions.y))
		var water: bool = false
		match map.region_biome:
			"Sea": water = coast+sample*0.28 > -0.18
			"Salt Marsh": water = coast+sample*0.45 > 0.05
			"Marsh": water = sample < -0.19
			"Swamp": water = sample < -0.24
		if water: map.water_cells[cell] = true
	# Place POIs on nearby existing land rather than cutting straight paths through water.
	for entrance: Vector2i in map.links.keys():
		if map.links[entrance].kind == "Return":
			map.water_cells.erase(entrance)
			for offset: Vector2i in DIRECTIONS: map.water_cells.erase(entrance+offset)
			continue
		if not map.water_cells.has(entrance): continue
		var destination: Vector2i = entrance
		var distance: int = 2147483647
		for candidate: Vector2i in map.cells():
			if map.water_cells.has(candidate) or map.links.has(candidate): continue
			var candidate_distance: int = map.distance(entrance,candidate)
			if candidate_distance < distance:
				distance = candidate_distance
				destination = candidate
		if destination == entrance:
			map.water_cells.erase(entrance)
			continue
		var link: Dictionary = map.links[entrance]
		map.links.erase(entrance)
		if link.kind != "Return": link.return_cell = destination
		map.links[destination] = link
static func _generate_lake(map, seed_value: int) -> void:
	var field = Biomes.noise(seed_value,0.075)
	var middle: Vector2 = Vector2(map.dimensions-Vector2i.ONE)*0.5
	for cell: Vector2i in map.cells():
		var delta: Vector2 = Vector2(cell)-middle
		var position := Vector2(delta.x+delta.y*0.5,delta.y*0.8660254)
		var radius := Vector2(position.x/(map.dimensions.x*0.43),position.y/(map.dimensions.y*0.36)).length()
		if radius < 1.0+field.get_noise_2dv(position)*0.30:
			map.water_cells[cell] = true
	# Optional small island, offset from the lake center. No straight land causeways.
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	if rng.randf() < 0.65:
		var island := Vector2i(middle)+Vector2i(rng.randi_range(2,4),rng.randi_range(-2,2))
		map.water_cells.erase(island)
		for direction: Vector2i in DIRECTIONS:
			if rng.randf() < 0.75: map.water_cells.erase(island+direction)
		for entrance: Vector2i in map.links.keys():
			if map.links[entrance].kind == "Tower":
				var link: Dictionary = map.links[entrance]
				map.links.erase(entrance)
				link.return_cell = island
				map.links[island] = link
				break
	# Retain only the central connected body; discard detached shore puddles.
	var start := Vector2i(middle)
	var connected: Dictionary = {start:true}
	var queue: Array[Vector2i] = [start]
	var index: int = 0
	while index < queue.size():
		var cell: Vector2i = queue[index]
		index += 1
		for direction: Vector2i in DIRECTIONS:
			var neighbor: Vector2i = cell+direction
			if map.water_cells.has(neighbor) and not connected.has(neighbor):
				connected[neighbor] = true
				queue.append(neighbor)
	map.water_cells = connected
	for entrance: Vector2i in map.links: map.water_cells.erase(entrance)

static func shore_edges(map, cell: Vector2i) -> Array[int]:
	var result: Array[int] = []
	if not map.water_cells.has(cell): return result
	for index: int in range(6):
		var neighbor: Vector2i = cell+DIRECTIONS[index]
		if map.contains(neighbor) and not map.water_cells.has(neighbor): result.append(index)
	return result
