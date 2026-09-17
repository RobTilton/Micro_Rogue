extends RefCounted
const Rings = preload("res://Production/Actors/rings.gd")
const SIGHT_RADIUS: int = 8 # Default for callers without an actor.
const BASE_RADIUS: int = 7

static func radius(actor: Dictionary) -> int:
	var value: int = int(actor.get("sight_base",BASE_RADIUS)) + floori(float(Rings.stat(actor,"WIS"))/2.0)
	for modifier: int in actor.get("sight_effects",{}).values(): value += modifier
	return maxi(0,value+Rings.bonus(actor,"sight"))

static func valid(actor: Dictionary) -> bool:
	if not actor.get("sight_base",BASE_RADIUS) is int or actor.get("sight_base",BASE_RADIUS) < 0: return false
	if not actor.get("sight_effects",{}) is Dictionary: return false
	for source in actor.get("sight_effects",{}):
		if not source is String or source.is_empty() or not actor.sight_effects[source] is int: return false
	return true

static func cells(map, actor: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var reach: int = mini(radius(actor),map.dimensions.x+map.dimensions.y)
	for q: int in range(-reach,reach+1):
		for r: int in range(maxi(-reach,-q-reach),mini(reach,-q+reach)+1):
			var cell: Vector2i = map.canonical(actor.pos+Vector2i(q,r))
			if visible(map,actor.pos,cell,reach): result[cell] = true
	return result


static func visible(map, origin: Vector2i, destination: Vector2i, sight_radius: int = SIGHT_RADIUS) -> bool:
	if not map.contains(origin) or not map.contains(destination): return false
	var target: Vector2i = destination
	if map.wrap_horizontal:
		for shift: int in [-map.dimensions.x, map.dimensions.x]:
			var candidate: Vector2i = destination + Vector2i(shift,0)
			if _distance(origin,candidate) < _distance(origin,target): target = candidate
	var length: int = _distance(origin,target)
	if length > sight_radius: return false
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
