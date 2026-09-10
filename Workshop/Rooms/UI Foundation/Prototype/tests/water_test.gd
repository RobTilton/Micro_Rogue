extends SceneTree
const World = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/map_world.gd")
const Water = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_water.gd")
func _initialize() -> void:
	var checks: int = 0
	for biome: String in ["Sea","Lakes"]:
		var world = World.new(1729)
		var link: Dictionary = world.maps.global.links[Vector2i(2,2)].duplicate(true)
		link.biome = biome
		var region = world.resolve(link)
		assert(not region.water_cells.is_empty(),"water_test.gd: water generated")
		checks += 1
		var repeat = World.new(1729).resolve(link)
		assert(region.water_cells == repeat.water_cells,"water_test.gd: deterministic")
		checks += 1
		for entrance: Vector2i in region.links:
			assert(not region.water_cells.has(entrance),"water_test.gd: dry entrance")
			checks += 1
		for cell: Vector2i in region.cells():
			for edge: int in Water.shore_edges(region,cell):
				assert(region.water_cells.has(cell) and not region.water_cells.has(cell+Water.DIRECTIONS[edge]),"water_test.gd: shore only meets land")
				checks += 1
	print("water_test.gd: %d checks passed" % checks)
	quit()
