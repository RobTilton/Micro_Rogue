extends RefCounted
## Main-room loop plus optional shortcut; side rooms are direct leaves only.
const Map = preload("res://Production/World/hex_map.gd")
const Contracts = preload("res://Production/World/geographic_contracts.gd")
const CENTERS = [Vector2i(14,24),Vector2i(22,10),Vector2i(40,10),Vector2i(48,24),Vector2i(40,38),Vector2i(22,38)]
static func generate(id: String, title: String, seed_value: int):
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var count: int = rng.randi_range(8,14)
	var extent := Vector2i(rng.randi_range(78,100),rng.randi_range(66,84))
	var map = Map.new(id,title,"POI",extent)
	var rooms: Array = []
	var edges: Array = []
	var floor_cells: Dictionary = {}
	var origin := Vector2(extent)*0.5
	var rotation: float = rng.randf_range(0,TAU)
	for index: int in range(count):
		var angle: float = rotation+TAU*index/count
		var radial: float = rng.randf_range(0.88,1.08)
		var center := Vector2i(origin+Vector2(cos(angle)*extent.x*0.29,sin(angle)*extent.y*0.29)*radial)
		rooms.append(_room(index,center,rng.randi_range(3,6),true,seed_value,floor_cells))
	for index: int in range(count): edges.append(_passage(rooms[index],rooms[(index+1)%count],rng,floor_cells))
	if rng.randf() < 0.65: edges.append(_passage(rooms[0],rooms[count/2],rng,floor_cells))
	for branch: int in range(rng.randi_range(0,3)):
		var parent: int = branch*count/3
		var outward: Vector2 = (Vector2(rooms[parent].center)-origin).normalized()
		var center := Vector2i(Vector2(rooms[parent].center)+outward*10)
		center.x = clampi(center.x,5,extent.x-6)
		center.y = clampi(center.y,5,extent.y-6)
		var leaf: Dictionary = _room(rooms.size(),center,rng.randi_range(2,3),false,seed_value,floor_cells)
		rooms.append(leaf)
		edges.append(_passage(rooms[parent],leaf,rng,floor_cells))
	map.spawn_cell = rooms[0].center
	map.cave_layout = {"version":2,"rooms":rooms,"passages":edges,"main_route":range(count),"entry_room":0}
	for cell: Vector2i in map.cells():
		if not floor_cells.has(cell): map.walls.append(cell)
	return map
static func _room(id: int, center: Vector2i, radius: int, main: bool, seed_value: int, floor_cells: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	var room_seed: int = Contracts.seed_for(seed_value,"cavern:"+str(id))
	rng.seed = room_seed
	var cells: Array = []
	for q: int in range(-radius,radius+1):
		for r: int in range(-radius,radius+1):
			var distance: int = maxi(absi(q),maxi(absi(r),absi(q+r)))
			if distance > radius: continue
			if distance == radius and rng.randf() < 0.32: continue
			var cell: Vector2i = center+Vector2i(q,r)
			cells.append(cell)
			floor_cells[cell] = true
	return {"id":id,"center":center,"radius":radius,"main":main,"seed":room_seed,"cells":cells}
static func _passage(a: Dictionary, b: Dictionary, rng: RandomNumberGenerator, floor_cells: Dictionary) -> Dictionary:
	var midpoint := Vector2i(roundi((a.center.x+b.center.x)*0.5),roundi((a.center.y+b.center.y)*0.5))
	midpoint += Vector2i(rng.randi_range(-2,2),rng.randi_range(-2,2))
	var route: Array = [a.center]
	var current: Vector2i = a.center
	for goal: Vector2i in [midpoint,b.center]:
		while current != goal:
			var options: Array = []
			var distance: int = _distance(current,goal)
			for direction: Vector2i in Map.DIRECTIONS:
				if _distance(current+direction,goal) < distance: options.append(current+direction)
			current = options[rng.randi_range(0,options.size()-1)]
			route.append(current)
	var width: int = rng.randi_range(1,2)
	var cells: Dictionary = {}
	for cell: Vector2i in route:
		cells[cell] = true
		if width == 2: cells[cell+Vector2i(0,1)] = true
	for cell: Vector2i in cells: floor_cells[cell] = true
	return {"from":a.id,"to":b.id,"width":width,"route":route,"cells":cells.keys()}
static func _distance(a: Vector2i, b: Vector2i) -> int:
	var delta: Vector2i = a-b
	return maxi(absi(delta.x),maxi(absi(delta.y),absi(delta.x+delta.y)))
static func valid(data, dimensions: Vector2i, walls: Array) -> bool:
	if not data is Dictionary: return false
	if data.is_empty(): return true
	if data.get("version") not in [1,2] or not data.get("rooms") is Array or not data.get("passages") is Array or not data.get("main_route") is Array or data.get("entry_room") != 0: return false
	var count: int = data.main_route.size()
	if count < 6 or count > 14 or data.main_route != range(count) or data.rooms.size() < count or data.rooms.size() > count+3: return false
	var blocked: Dictionary = {}
	for cell in walls: blocked[cell] = true
	var rooms: Dictionary = {}
	var adjacency: Dictionary = {}
	for room in data.rooms:
		if not room is Dictionary or not room.get("id") is int or rooms.has(room.id) or not room.get("center") is Vector2i or not room.get("seed") is int or not room.get("radius") is int or room.radius not in range(2,7) or not room.get("main") is bool or not room.get("cells") is Array: return false
		if room.id < 0 or room.id >= data.rooms.size() or room.main != (room.id < count) or room.center not in room.cells: return false
		for cell in room.cells:
			if not _floor(cell,dimensions,blocked): return false
		rooms[room.id] = room
		adjacency[room.id] = []
	for passage in data.passages:
		if not passage is Dictionary or not passage.get("from") is int or not passage.get("to") is int or not rooms.has(passage.from) or not rooms.has(passage.to) or passage.from == passage.to or passage.to in adjacency[passage.from]: return false
		if not passage.get("width") is int or passage.width not in [1,2] or not passage.get("route") is Array or passage.route.size() < 2 or not passage.get("cells") is Array: return false
		if passage.route.front() != rooms[passage.from].center or passage.route.back() != rooms[passage.to].center: return false
		for index: int in range(passage.route.size()):
			var cell = passage.route[index]
			if not _floor(cell,dimensions,blocked) or cell not in passage.cells: return false
			if index > 0 and _distance(cell,passage.route[index-1]) != 1: return false
		for cell in passage.cells:
			if not _floor(cell,dimensions,blocked): return false
		adjacency[passage.from].append(passage.to)
		adjacency[passage.to].append(passage.from)
	for id: int in rooms:
		if id < count:
			if (id+1)%count not in adjacency[id]: return false
		elif adjacency[id].size() != 1 or adjacency[id][0] >= count: return false
	return true
static func _floor(cell, dimensions: Vector2i, blocked: Dictionary) -> bool:
	return cell is Vector2i and cell.x > 0 and cell.y > 0 and cell.x < dimensions.x-1 and cell.y < dimensions.y-1 and not blocked.has(cell)
