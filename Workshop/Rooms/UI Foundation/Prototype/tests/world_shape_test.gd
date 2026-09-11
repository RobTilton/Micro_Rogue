extends SceneTree
const World = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/map_world.gd")
const Paths = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/movement_preview.gd")
var checks: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	assert(value,"world_shape_test.gd: "+message)
func _initialize() -> void:
	for seed_value: int in [1,1729,70001]:
		var world = World.new(seed_value)
		var map = world.maps.global
		check(map.dimensions == Vector2i(80,42),"80 wide, 42 high")
		check(world.maps.size() == 1 and world.states.is_empty(),"locals remain lazy")
		check(map.links.size() == 3200 and map.walls.size() == 160,"40 playable rows plus ice")
		check(map.walkable(map.spawn_cell) and map.biomes[map.spawn_cell] == "Plains","land spawn")
		for q: int in range(80):
			check(not map.walkable(Vector2i(q,0)) and not map.walkable(Vector2i(q,41)),"caps blocked")
		check(Vector2i(79,20) in map.neighbors(Vector2i(0,20)),"west wraps")
		check(Vector2i(0,20) in map.neighbors(Vector2i(79,20)),"east wraps")
		check(map.distance(Vector2i(0,20),Vector2i(79,20)) == 1,"wrapped proximity")
		check(Paths.paths(Vector2i(0,20),3,[],map).has(Vector2i(79,20)),"wrapped weighted path")
		for continent: int in range(2):
			var cells: Dictionary = {}
			for cell: Vector2i in map.continents:
				if map.continents[cell] == continent: cells[cell] = true
			check(cells.size() > 400,"large continent")
			var frontier: Array = [cells.keys()[0]]
			var visited: Dictionary = {frontier[0]:true}
			while not frontier.is_empty():
				var cell: Vector2i = frontier.pop_back()
				for neighbor: Vector2i in map.neighbors(cell):
					if cells.has(neighbor) and not visited.has(neighbor):
						visited[neighbor] = true
						frontier.append(neighbor)
					check(not map.continents.has(neighbor) or map.continents[neighbor] == continent,"ocean separates continents")
			check(visited.size() == cells.size(),"continent connected")
		var same = World.new(seed_value)
		check(same.maps.global.biomes == map.biomes,"seed repeatability")
		for index: int in range(12):
			var link: Dictionary = map.links[Vector2i(index,20)]
			var local = world.resolve(link)
			check(local.dimensions.y >= 20 and local.dimensions.y <= 30,"local height bounds")
			check(local.dimensions.x >= 30 and local.dimensions.x <= 45 and local.dimensions.x*2 == local.dimensions.y*3,"local width and ratio")
			check(local.dimensions == same.resolve(link).dimensions,"stable local size")
	print("world_shape_test.gd: %d checks passed" % checks)
	quit()
