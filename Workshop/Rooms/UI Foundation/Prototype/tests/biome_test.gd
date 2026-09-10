extends SceneTree
const World = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/map_world.gd")
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
func _initialize() -> void:
	var first = World.new(1729)
	var same = World.new(1729)
	var other = World.new(789)
	assert(first.maps.global.biomes == same.maps.global.biomes,"biome_test.gd: reproducibility")
	assert(first.maps.global.biomes != other.maps.global.biomes,"biome_test.gd: distinct seeds")
	assert(first.maps.global.biomes.size() == 432,"biome_test.gd: coverage")
	var counts: Dictionary = {}
	for cell: Vector2i in first.maps.global.biomes:
		var biome: String = first.maps.global.biomes[cell]
		assert(biome in Biomes.NAMES,"biome_test.gd: supported biome")
		counts[biome] = counts.get(biome,0)+1
		assert(first.resolve(first.maps.global.links[cell]).region_biome == biome,"biome_test.gd: local metadata")
	print("biome_test.gd: 867 checks passed; seed 1729 distribution: ",counts)
	quit()
