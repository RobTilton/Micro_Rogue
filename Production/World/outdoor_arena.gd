extends RefCounted
const Map = preload("res://Production/World/hex_map.gd")
static func generate(id: String, title: String, biome: String):
	var map = Map.new(id,title,"Encounter",Vector2i(13,13))
	map.hex_radius = 6
	map.spawn_cell = Vector2i(1,6)
	map.region_biome = biome
	# Lake/sea encounters take place on dry shoreline, pending boats.
	var floor_biome: String = "Plains" if biome in ["Sea","Lakes","Salt Marsh","Ice Wall"] else biome
	for cell: Vector2i in map.cells(): map.biomes[cell] = floor_biome
	return map
