extends RefCounted
## Deterministic terrain classification in world-space axial coordinates.
const NAMES: Array[String] = ["Forest","Plains","Hills","Mountains","Sea","Lakes","Desert","Wasteland","Marsh","Swamp","Salt Marsh","Ice Wall"]
static func noise(seed_value: int, frequency: float) -> FastNoiseLite:
	var field: FastNoiseLite = FastNoiseLite.new()
	field.seed = seed_value
	field.frequency = frequency
	field.fractal_octaves = 3
	return field
static func classify(elevation: float, moisture: float, warmth: float) -> String:
	if elevation < -0.28: return "Sea"
	if elevation > 0.38: return "Mountains"
	if elevation > 0.18: return "Hills"
	if moisture > 0.32 and elevation < -0.06: return "Lakes"
	if moisture < -0.18: return "Desert" if warmth > 0.0 else "Wasteland"
	if moisture > 0.06: return "Forest"
	return "Plains"
static func generate(map, world_seed: int) -> void:
	var elevation = noise(world_seed,0.12)
	var moisture = noise(world_seed+1009,0.17)
	var temperature = noise(world_seed+2027,0.08)
	for cell: Vector2i in map.cells():
		var x: float = cell.x + cell.y * 0.5
		var y: float = cell.y * sqrt(3.0) * 0.5
		map.biomes[cell] = classify(elevation.get_noise_2d(x,y),moisture.get_noise_2d(x,y),temperature.get_noise_2d(x,y))

	apply_wetlands(map)

static func apply_wetlands(map) -> void:
	# User-defined adjacency rules evaluated simultaneously from the base biomes.
	var original: Dictionary = map.biomes.duplicate()
	var directions: Array[Vector2i] = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
	for cell: Vector2i in original:
		var water_neighbors: int = 0
		var ocean_neighbors: int = 0
		for direction: Vector2i in directions:
			var neighbor: String = original.get(map.canonical(cell+direction),"")
			if neighbor in ["Sea","Lakes"]: water_neighbors += 1
			if neighbor == "Sea": ocean_neighbors += 1
		if original[cell] == "Plains" and ocean_neighbors >= 4:
			map.biomes[cell] = "Salt Marsh"
		elif original[cell] == "Plains" and water_neighbors > 0:
			map.biomes[cell] = "Marsh"
		elif original[cell] == "Forest" and water_neighbors > 0:
			map.biomes[cell] = "Swamp"
