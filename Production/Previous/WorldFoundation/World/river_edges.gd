extends RefCounted
## One undirected record per shared edge, including across horizontal wrap.
static func key(map, a: Vector2i, b: Vector2i) -> String:
	a = map.canonical(a)
	b = map.canonical(b)
	if a.x > b.x or (a.x == b.x and a.y > b.y):
		var swap: Vector2i = a
		a = b
		b = swap
	return "%d,%d:%d,%d" % [a.x,a.y,b.x,b.y]
static func add(map, cell: Vector2i, direction: int) -> bool:
	if direction < 0 or direction >= 6: return false
	var a: Vector2i = map.canonical(cell)
	var b: Vector2i = map.canonical(cell+map.DIRECTIONS[direction])
	if not map.walkable(a) or not map.walkable(b): return false
	map.rivers[key(map,a,b)] = {"cell":a,"direction":direction}
	return true
static func has_edge(map, a: Vector2i, b: Vector2i) -> bool:
	return map.rivers.has(key(map,a,b))
static func endpoints(direction: int, radius: float) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for corner: int in [posmod(-direction,6),posmod(1-direction,6)]:
		points.append(Vector2.from_angle(deg_to_rad(60*corner-30))*radius)
	return points
static func add_demo(map, start: Vector2i, length: int = 7) -> void:
	for step: int in range(length):
		var cell: Vector2i = start+Vector2i(step,0)
		add(map,cell,2)
		add(map,cell,1)
