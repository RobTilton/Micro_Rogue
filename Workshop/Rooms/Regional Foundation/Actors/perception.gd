extends RefCounted
const SIGHT_RADIUS: int = 8

static func visible(map, origin: Vector2i, destination: Vector2i) -> bool:
	if not map.contains(origin) or not map.contains(destination): return false
	var target: Vector2i = destination
	if map.wrap_horizontal:
		for shift: int in [-map.dimensions.x, map.dimensions.x]:
			var candidate: Vector2i = destination + Vector2i(shift,0)
			if _distance(origin,candidate) < _distance(origin,target): target = candidate
	var length: int = _distance(origin,target)
	if length > SIGHT_RADIUS: return false
	for step: int in range(1,length):
		var point: Vector2 = Vector2(origin).lerp(Vector2(target),float(step)/length)
		# Cube rounding keeps a straight ray on the axial hex grid.
		var cube := Vector3(point.x, -point.x-point.y, point.y)
		var rounded := Vector3(roundf(cube.x),roundf(cube.y),roundf(cube.z))
		var error: Vector3 = (rounded-cube).abs()
		if error.x > error.y and error.x > error.z: rounded.x = -rounded.y-rounded.z
		elif error.y > error.z: rounded.y = -rounded.x-rounded.z
		else: rounded.z = -rounded.x-rounded.y
		if not map.walkable(map.canonical(Vector2i(int(rounded.x),int(rounded.z)))): return false
	return true

static func _distance(a: Vector2i, b: Vector2i) -> int:
	var delta: Vector2i = a-b
	return maxi(absi(delta.x),maxi(absi(delta.y),absi(delta.x+delta.y)))
