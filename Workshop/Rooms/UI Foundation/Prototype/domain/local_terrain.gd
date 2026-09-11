extends RefCounted
## Region identity selects a related terrain palette; noise forms contiguous patches.
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
const PALETTES: Dictionary = {
	"Plains": ["Forest", "Hills"], "Forest": ["Plains", "Hills"],
	"Hills": ["Plains", "Mountains"], "Mountains": ["Hills", "Wasteland"],
	"Desert": ["Wasteland", "Hills"], "Wasteland": ["Desert", "Hills"],
	"Marsh": ["Plains", "Forest"], "Swamp": ["Marsh", "Forest"],
	"Salt Marsh": ["Plains", "Marsh"], "Sea": ["Plains", "Hills"],
	"Lakes": ["Plains", "Forest"]}
static func generate(map, seed_value: int) -> void:
	var elevation = Biomes.noise(seed_value+4093, 0.045)
	var moisture = Biomes.noise(seed_value+8191, 0.075)
	var warp = Biomes.noise(seed_value+12289, 0.045)
	var samples: Array[float] = []
	var moisture_values: Dictionary = {}
	for cell: Vector2i in map.cells():
		var position := Vector2(cell.x+cell.y*0.5, cell.y*0.8660254)
		position += Vector2(warp.get_noise_2dv(position),warp.get_noise_2dv(position+Vector2(83,157)))*5.0
		var height: float = elevation.get_noise_2dv(position)
		map.elevations[cell] = height
		var wetness: float = moisture.get_noise_2dv(position)
		# Dry uplands follow relief, woodland follows moisture; ridges use folded noise.
		var sample: float = wetness
		if map.region_biome in ["Hills", "Mountains"]: sample = absf(height)*2.0
		elif map.region_biome in ["Desert", "Wasteland"]: sample = height*0.8+wetness*0.2
		elif map.region_biome in ["Marsh", "Swamp", "Salt Marsh"]: sample = wetness-height*0.5
		moisture_values[cell] = sample
		samples.append(moisture_values[cell])
	samples.sort()
	var low: float = samples[int(samples.size()*0.20)]
	var high: float = samples[int(samples.size()*0.82)]
	var palette: Array = PALETTES.get(map.region_biome, ["Plains", "Hills"])
	for cell: Vector2i in map.cells():
		var terrain: String = map.region_biome
		if moisture_values[cell] < low: terrain = palette[0]
		elif moisture_values[cell] > high: terrain = palette[1]
		if terrain in ["Sea", "Lakes"]: terrain = "Plains"
		if map.water_cells.has(cell): terrain = "Sea" if map.region_biome in ["Sea", "Salt Marsh"] else "Lakes"
		map.biomes[cell] = terrain
