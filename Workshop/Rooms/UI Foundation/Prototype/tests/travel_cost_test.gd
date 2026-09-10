extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Travel = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/travel_cost.gd")
const Paths = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/movement_preview.gd")
func _initialize() -> void:
	var map = Map.new("test","test","Global",Vector2i(5,4))
	for cell: Vector2i in map.cells(): map.biomes[cell] = "Plains"
	map.biomes[Vector2i(1,1)] = "Mountains"
	var path: Array = Paths.paths(Vector2i(0,1),3,[],map)[Vector2i(2,1)]
	assert(path.size() == 3 and Vector2i(1,1) not in path,"travel_cost_test.gd: cheaper detour")
	map.biomes[Vector2i(1,1)] = "Forest"
	assert(Travel.path_cost(map,[Vector2i(1,1),Vector2i(1,1)]) == 3.0,"travel_cost_test.gd: fractions retained")
	assert(not Paths.paths(Vector2i(0,1),1,[],map).has(Vector2i(1,1)),"travel_cost_test.gd: budget excludes forest")
	for pair: Array in [["Mountains",6],["Hills",4],["Forest",3],["Swamp",4],["Marsh",4],["Salt Marsh",4],["Wasteland",2],["Plains",2]]:
		map.biomes[Vector2i(1,1)] = pair[0]
		assert(Travel.units(map,Vector2i(1,1)) == pair[1],"travel_cost_test.gd: multiplier")
	map.layer = "Local"
	map.biomes[Vector2i(1,1)] = "Mountains"
	assert(Travel.units(map,Vector2i(1,1)) == 2,"travel_cost_test.gd: local movement unchanged")
	print("travel_cost_test.gd: 12 checks passed")
	quit()
