extends RefCounted
const Biomes = preload("res://Production/World/biome_generator.gd")

static func generate(map, seed_value: int) -> Vector2i:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var width: float = map.dimensions.x
	var height: float = map.dimensions.y
	var plates: Array[Dictionary] = []
	for index: int in range(rng.randi_range(2,7)):
		plates.append({"center":Vector2(rng.randf()*width,rng.randf_range(6,height-7)),"angle":rng.randf()*TAU,"major":rng.randf_range(7,23),"minor":rng.randf_range(3.5,11),"strength":rng.randf_range(0.7,1.3)})
	var macro = Biomes.noise(seed_value+17,0.08)
	var coast = Biomes.noise(seed_value+29,0.21)
	var warp = Biomes.noise(seed_value+43,0.12)
	var elevation = Biomes.noise(seed_value+31,0.11)
	var moisture = Biomes.noise(seed_value+1009,0.13)
	var temperature = Biomes.noise(seed_value+2027,0.08)
	var scores: Dictionary = {}
	var ranked: Array[float] = []
	for cell: Vector2i in map.cells():
		if cell.y == 0 or cell.y == map.dimensions.y-1:
			map.walls.append(cell)
			map.biomes[cell] = "Ice Wall"
			continue
		map.biomes[cell] = "Sea"
		var longitude: float = fposmod(cell.x+cell.y*0.5,width)
		var angle: float = longitude/width*TAU
		var x: float = cos(angle)*width/TAU
		var z: float = sin(angle)*width/TAU
		var displacement: float = warp.get_noise_3d(x,z,cell.y)*7.0
		var score: float = 0.0
		for plate: Dictionary in plates:
			var delta := Vector2(fposmod(longitude-plate.center.x+width*0.5,width)-width*0.5,cell.y-plate.center.y)
			delta += Vector2(displacement,coast.get_noise_3d(x+13,z,cell.y)*3)
			delta = delta.rotated(plate.angle)
			var distance: float = pow(delta.x/plate.major,2)+pow(delta.y/plate.minor,2)
			score = maxf(score,plate.strength*exp(-distance))
		score += macro.get_noise_3d(x,z,cell.y)*0.45+coast.get_noise_3d(x,z,cell.y)*0.16
		score -= pow(absf((cell.y-height*0.5)/(height*0.5)),6)*0.35
		scores[cell] = score
		ranked.append(score)
	ranked.sort()
	var land_fraction: float = rng.randf_range(0.26,0.53)
	var threshold: float = ranked[int(ranked.size()*(1-land_fraction))]
	var land: Dictionary = {}
	for cell: Vector2i in scores:
		if scores[cell] >= threshold: land[cell] = true
	var largest: Array[Vector2i] = []
	var component: int = 0
	var visited: Dictionary = {}
	for start: Vector2i in land:
		if visited.has(start): continue
		var queue: Array[Vector2i] = [start]
		visited[start] = true
		var index: int = 0
		while index < queue.size():
			var cell: Vector2i = queue[index]
			index += 1
			map.continents[cell] = component
			var angle: float = fposmod(cell.x+cell.y*0.5,width)/width*TAU
			var x: float = cos(angle)*width/TAU
			var z: float = sin(angle)*width/TAU
			var e: float = elevation.get_noise_3d(x,z,cell.y)
			map.elevations[cell] = e
			map.biomes[cell] = Biomes.classify(maxf(e,-0.27),moisture.get_noise_3d(x,z,cell.y),temperature.get_noise_3d(x,z,cell.y))
			for neighbor: Vector2i in map.neighbors(cell):
				if land.has(neighbor) and not visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)
		if queue.size() > largest.size(): largest = queue
		component += 1
	# Start on the largest landmass, favoring dry interior cells over tiny islands.
	var spawn: Vector2i = largest[0]
	var best: float = -INF
	for cell: Vector2i in largest:
		var value: float = scores[cell]
		if value > best: best = value; spawn = cell
	Biomes.apply_wetlands(map)
	map.biomes[spawn] = "Plains"
	return spawn
