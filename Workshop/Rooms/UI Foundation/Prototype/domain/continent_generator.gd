extends RefCounted
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
static func generate(map, seed_value: int) -> Vector2i:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var phase: float = rng.randf_range(0,80)
	var coast = Biomes.noise(seed_value,0.16)
	var elevation = Biomes.noise(seed_value+31,0.11)
	var moisture = Biomes.noise(seed_value+1009,0.13)
	var temperature = Biomes.noise(seed_value+2027,0.08)
	var centers: Array[Vector2] = [Vector2(phase,20+rng.randf_range(-2,2)),Vector2(fposmod(phase+40,80),20+rng.randf_range(-2,2))]
	var lobes: Array = []
	for index: int in range(2):
		var parts: Array[Vector3] = [Vector3(0,0,8)]
		for offset: Vector2 in [Vector2(-9,-10),Vector2(9,-9),Vector2(-9,10),Vector2(9,10)]:
			parts.append(Vector3(offset.x+rng.randf_range(-1,1),offset.y+rng.randf_range(-2,2),rng.randf_range(6,7.5)))
		lobes.append(parts)
	var candidates: Array[Dictionary] = [{},{}]
	for cell: Vector2i in map.cells():
		if cell.y == 0 or cell.y == 41:
			map.walls.append(cell)
			map.biomes[cell] = "Ice Wall"
			continue
		map.biomes[cell] = "Sea"
		var longitude: float = fposmod(cell.x+cell.y*0.5,80)
		var angle: float = longitude/80*TAU
		var roughness: float = coast.get_noise_3d(cos(angle)*13,sin(angle)*13,cell.y)
		for index: int in range(2):
			var dx: float = fposmod(longitude-centers[index].x+40,80)-40
			var point := Vector2(dx,cell.y-centers[index].y)
			var land: bool = false
			for part: Vector3 in lobes[index]:
				var target := Vector2(part.x,part.y)
				var radius: float = part.z+roughness*2.5
				if point.distance_to(target) < radius: land = true
				if target != Vector2.ZERO:
					var nearest: Vector2 = Geometry2D.get_closest_point_to_segment(point,Vector2.ZERO,target)
					if point.distance_to(nearest) < 1.4: land = true
			if land and absf(dx)<18 and cell.y>1 and cell.y<40: candidates[index][cell] = true
	var spawn := Vector2i(2,2)
	# Retain only each core's connected component: no accidental offshore islands.
	for index: int in range(2):
		var core: Vector2i = map.canonical(Vector2i(roundi(centers[index].x-centers[index].y*0.5),roundi(centers[index].y)))
		var frontier: Array = [core]
		var visited: Dictionary = {core:true}
		while not frontier.is_empty():
			var cell: Vector2i = frontier.pop_back()
			map.continents[cell] = index
			var longitude: float = fposmod(cell.x+cell.y*0.5,80)
			var angle: float = longitude/80*TAU
			var e: float = elevation.get_noise_3d(cos(angle)*13,sin(angle)*13,cell.y)
			var m: float = moisture.get_noise_3d(cos(angle)*13,sin(angle)*13,cell.y)
			var t: float = temperature.get_noise_3d(cos(angle)*13,sin(angle)*13,cell.y)
			map.elevations[cell] = e
			map.biomes[cell] = Biomes.classify(maxf(e,-0.27),m,t)
			for neighbor: Vector2i in map.neighbors(cell):
				if candidates[index].has(neighbor) and not visited.has(neighbor):
					visited[neighbor] = true
					frontier.append(neighbor)
		if index == 0: spawn = core
	Biomes.apply_wetlands(map)
	map.biomes[spawn] = "Plains"
	return spawn
