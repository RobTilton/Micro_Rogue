extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Edges = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/river_edges.gd")
func _initialize() -> void:
	var map = Map.new("test","test","Global",Vector2i(80,42))
	map.wrap_horizontal = true
	var checks: int = 0
	for direction: int in range(6):
		map.rivers.clear()
		var a := Vector2i(0,20)
		var b: Vector2i = map.canonical(a+map.DIRECTIONS[direction])
		assert(Edges.add(map,a,direction),"river_edges_test.gd: valid edge")
		assert(Edges.has_edge(map,b,a),"river_edges_test.gd: symmetric lookup")
		Edges.add(map,b,(direction+3)%6)
		assert(map.rivers.size() == 1,"river_edges_test.gd: edge stored once")
		var one: PackedVector2Array = Edges.endpoints(direction,32)
		var other: PackedVector2Array = Edges.endpoints((direction+3)%6,32)
		var offset: Vector2 = Vector2(sqrt(3.0)*32*(map.DIRECTIONS[direction].x+map.DIRECTIONS[direction].y*0.5),48*map.DIRECTIONS[direction].y)
		assert(one[0].distance_to(other[1]+offset)<0.001 and one[1].distance_to(other[0]+offset)<0.001,"river_edges_test.gd: shared geometry")
		checks += 4
	map.rivers.clear()
	Edges.add_demo(map,Vector2i(77,20),7)
	assert(map.rivers.size() == 14,"river_edges_test.gd: connected seam demo")
	assert(not Edges.add(map,Vector2i(2,0),2),"river_edges_test.gd: rejects out of bounds")
	assert(not Edges.add(map,Vector2i(2,2),6),"river_edges_test.gd: rejects invalid direction")
	print("river_edges_test.gd: %d checks passed" % (checks+3))
	quit()
