extends SceneTree
const World = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/map_world.gd")
const Generator = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/river_generator.gd")
func _initialize() -> void:
	var checks: int = 0
	for seed_value: int in [1,1729,70001]:
		var world = World.new(seed_value)
		var map = world.maps.global
		assert(map.river_routes.size() >= 2,"river_generation_test.gd: generated sources")
		checks += 1
		var repeat = World.new(seed_value)
		assert(map.rivers == repeat.maps.global.rivers,"river_generation_test.gd: repeatability")
		checks += 1
		for route: Dictionary in map.river_routes:
			var unique: Dictionary = {}
			for vertex: Vector2i in route.vertices: unique[vertex] = true
			assert(unique.size() == route.vertices.size(),"river_generation_test.gd: no loops")
			assert(route.vertices.size() >= 7,"river_generation_test.gd: nontrivial river")
			var mouth_found: bool = false
			for cell: Vector2i in map.biomes:
				if not Generator.water(map,cell): continue
				var center := Vector2i(cell.x*2+cell.y,cell.y*3)
				for corner: Vector2i in Generator.CORNERS:
					if Generator.vertex(map,center+corner) == route.outlet: mouth_found = true
			assert(mouth_found,"river_generation_test.gd: reaches water")
			checks += 3
	print("river_generation_test.gd: %d checks passed" % checks)
	quit()
