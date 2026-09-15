extends RefCounted
## Packed axial rooms, separated by one hex of wall, connected through doors.
const Map = preload("res://Production/World/hex_map.gd")
const Contracts = preload("res://Production/World/geographic_contracts.gd")
static func _legacy_generate(id: String, title: String, seed_value: int, tower: bool = false):
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var columns: int = rng.randi_range(3,4)
	var rows: int = 3 if tower else rng.randi_range(3,5)
	var xs: Array = [1]
	var ys: Array = [1]
	for index: int in range(columns): xs.append(xs.back()+rng.randi_range(6,10)+1)
	for index: int in range(rows): ys.append(ys.back()+rng.randi_range(6,10)+1)
	var map = Map.new(id,title,"POI",Vector2i(xs.back()+1,ys.back()+1))
	var rooms: Array = []
	var doors: Array = []
	var floor_cells: Dictionary = {}
	for row: int in range(rows):
		for column: int in range(columns):
			var cells: Array = []
			for q: int in range(xs[column],xs[column+1]-1):
				for r: int in range(ys[row],ys[row+1]-1):
					var cell := Vector2i(q,r)
					cells.append(cell)
					floor_cells[cell] = true
			var room_id: int = rooms.size()
			rooms.append({"id":room_id,"center":Vector2i(int((xs[column]+xs[column+1]-2)/2.0),int((ys[row]+ys[row+1]-2)/2.0)),"cells":cells,"seed":Contracts.seed_for(seed_value,"room:"+str(room_id))})
			if column > 0:
				var cell := Vector2i(xs[column]-1,rng.randi_range(ys[row]+1,ys[row+1]-3))
				doors.append({"from":room_id-1,"to":room_id,"cell":cell})
				floor_cells[cell] = true
			if row > 0:
				var cell := Vector2i(rng.randi_range(xs[column]+1,xs[column+1]-3),ys[row]-1)
				doors.append({"from":room_id-columns,"to":room_id,"cell":cell})
				floor_cells[cell] = true
	map.spawn_cell = rooms[0].center
	map.room_layout = {"version":1,"rooms":rooms,"doors":doors,"entry_room":0}
	for cell: Vector2i in map.cells():
		if not floor_cells.has(cell): map.walls.append(cell)
	return map

static func valid(data, dimensions: Vector2i, walls: Array) -> bool:
	if not data is Dictionary: return false
	if data.is_empty(): return true
	if data.get("version") not in [1,2] or data.get("entry_room") != 0 or not data.get("rooms") is Array or not data.get("doors") is Array: return false
	if data.rooms.size() < (6 if data.version == 2 else 9) or data.rooms.size() > 24: return false
	var blocked: Dictionary = {}
	for cell in walls: blocked[cell] = true
	var owners: Dictionary = {}
	var adjacent: Array = []
	for index: int in range(data.rooms.size()):
		var room = data.rooms[index]
		if not room is Dictionary or room.get("id") != index or not room.get("seed") is int or not room.get("cells") is Array or not room.get("center") is Vector2i: return false
		if room.center not in room.cells or room.cells.size() < 36: return false
		adjacent.append([])
		for cell in room.cells:
			if not _floor(cell,dimensions,blocked) or owners.has(cell): return false
			owners[cell] = index
	for door in data.doors:
		if not door is Dictionary or not door.get("from") is int or not door.get("to") is int or not _floor(door.get("cell"),dimensions,blocked): return false
		var a: int = door.from
		var b: int = door.to
		if a < 0 or b < 0 or a >= adjacent.size() or b >= adjacent.size() or a == b or b in adjacent[a] or owners.has(door.cell): return false
		var cells: Array = door.get("cells",[door.cell])
		if cells.is_empty() or cells[0] != door.cell or (data.version == 2 and cells.size() != 2): return false
		for index: int in range(cells.size()):
			if not _floor(cells[index],dimensions,blocked) or owners.has(cells[index]): return false
			if index > 0 and cells[index]-cells[index-1] not in Map.DIRECTIONS: return false
		var touches_a: bool = false
		var touches_b: bool = false
		for direction: Vector2i in Map.DIRECTIONS:
			if owners.get(cells.front()+direction,-1) == a: touches_a = true
			if owners.get(cells.back()+direction,-1) == b: touches_b = true
		if not touches_a or not touches_b: return false
		adjacent[a].append(b)
		adjacent[b].append(a)
	# Every room retains a route through the complex if any one doorway is blocked.
	for edge in data.doors:
		var seen: Dictionary = {0:true}
		var queue: Array = [0]
		while not queue.is_empty():
			var current: int = queue.pop_back()
			for next: int in adjacent[current]:
				if (current == edge.from and next == edge.to) or (current == edge.to and next == edge.from): continue
				if not seen.has(next):
					seen[next] = true
					queue.append(next)
		if seen.size() != adjacent.size(): return false
	return not data.doors.is_empty()
static func _floor(cell, dimensions: Vector2i, blocked: Dictionary) -> bool:
	return cell is Vector2i and cell.x > 0 and cell.y > 0 and cell.x < dimensions.x-1 and cell.y < dimensions.y-1 and not blocked.has(cell)

static func generate(id: String, title: String, seed_value: int, tower: bool = false):
	for attempt: int in range(48):
		var rng := RandomNumberGenerator.new()
		rng.seed = Contracts.seed_for(seed_value,"partition-"+str(attempt))
		var width: int = rng.randi_range(35,47) if tower else rng.randi_range(44,66)
		var height: int = rng.randi_range(35,47) if tower else rng.randi_range(40,60)
		var leaves: Array[Rect2i] = [Rect2i(1,1,width,height)]
		var target: int = rng.randi_range(9,13) if tower else rng.randi_range(12,20)
		for division: int in range(target-1):
			var choices: Array[int] = []
			for index: int in range(leaves.size()):
				if leaves[index].size.x >= 16 or leaves[index].size.y >= 16: choices.append(index)
			if choices.is_empty(): break
			choices.sort_custom(func(a: int,b: int): return leaves[a].get_area() > leaves[b].get_area())
			var chosen: int = choices[rng.randi_range(0,mini(2,choices.size()-1))]
			var rect: Rect2i = leaves[chosen]
			var vertical: bool = rect.size.x >= 16 and (rect.size.y < 16 or rng.randf() < float(rect.size.x)/(rect.size.x+rect.size.y))
			var length: int = rect.size.x if vertical else rect.size.y
			var cut: int = rng.randi_range(7,length-9)
			var first: Rect2i = rect
			var second: Rect2i = rect
			if vertical:
				first.size.x = cut
				second.position.x += cut+2
				second.size.x -= cut+2
			else:
				first.size.y = cut
				second.position.y += cut+2
				second.size.y -= cut+2
			leaves[chosen] = first
			leaves.append(second)
		var map = _assemble(id,title,seed_value,leaves,Vector2i(width+2,height+2),rng)
		if not valid(map.room_layout,map.dimensions,map.walls): continue
		# Cut rooms from exterior edges when the remaining complex still has loops.
		for trim: int in range(rng.randi_range(1,4)):
			if leaves.size() <= 8: break
			var candidates: Array[int] = []
			for index: int in range(leaves.size()):
				var rect: Rect2i = leaves[index]
				if rect.position.x == 1 or rect.position.y == 1 or rect.end.x == width+1 or rect.end.y == height+1: candidates.append(index)
			if candidates.is_empty(): break
			var trial: Array[Rect2i] = leaves.duplicate()
			trial.remove_at(candidates[rng.randi_range(0,candidates.size()-1)])
			var candidate = _assemble(id,title,seed_value,trial,map.dimensions,rng)
			if valid(candidate.room_layout,candidate.dimensions,candidate.walls): leaves = trial; map = candidate
		return map
	return _legacy_generate(id,title,seed_value,tower)

static func _assemble(id: String, title: String, seed_value: int, leaves: Array[Rect2i], extent: Vector2i, rng: RandomNumberGenerator):
	var map = Map.new(id,title,"POI",extent)
	var rooms: Array = []
	var doors: Array = []
	var floor_cells: Dictionary = {}
	for rect: Rect2i in leaves:
		var cells: Array = []
		for q: int in range(rect.position.x,rect.end.x):
			for r: int in range(rect.position.y,rect.end.y):
				var cell := Vector2i(q,r)
				cells.append(cell)
				floor_cells[cell] = true
		var room_id: int = rooms.size()
		rooms.append({"id":room_id,"center":rect.position+rect.size/2,"cells":cells,"seed":Contracts.seed_for(seed_value,"room:"+str(room_id))})
	for a: int in range(leaves.size()):
		for b: int in range(a+1,leaves.size()):
			var first: Rect2i = leaves[a]
			var second: Rect2i = leaves[b]
			var cells: Array = []
			var low_y: int = maxi(first.position.y,second.position.y)
			var high_y: int = mini(first.end.y,second.end.y)-1
			var low_x: int = maxi(first.position.x,second.position.x)
			var high_x: int = mini(first.end.x,second.end.x)-1
			if high_y-low_y >= 2 and (second.position.x-first.end.x == 2 or first.position.x-second.end.x == 2):
				var y: int = rng.randi_range(low_y+1,high_y-1)
				cells = [Vector2i(first.end.x,y),Vector2i(first.end.x+1,y)] if first.end.x < second.position.x else [Vector2i(first.position.x-1,y),Vector2i(first.position.x-2,y)]
			elif high_x-low_x >= 2 and (second.position.y-first.end.y == 2 or first.position.y-second.end.y == 2):
				var x: int = rng.randi_range(low_x+1,high_x-1)
				cells = [Vector2i(x,first.end.y),Vector2i(x,first.end.y+1)] if first.end.y < second.position.y else [Vector2i(x,first.position.y-1),Vector2i(x,first.position.y-2)]
			if cells.is_empty(): continue
			doors.append({"from":a,"to":b,"cell":cells[0],"cells":cells})
			for cell: Vector2i in cells: floor_cells[cell] = true
	map.spawn_cell = rooms[0].center
	map.room_layout = {"version":2,"rooms":rooms,"doors":doors,"entry_room":0}
	for cell: Vector2i in map.cells():
		if not floor_cells.has(cell): map.walls.append(cell)
	return map
