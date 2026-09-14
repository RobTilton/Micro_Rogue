extends SceneTree
const Cave = preload("res://Production/World/cave_generator.gd")
const State = preload("res://Production/Persistence/map_state.gd")
var failures: int = 0
var checks: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Cave Foundation/tests/caves_test.gd: "+message)
func _initialize() -> void:
	var signatures: Dictionary = {}
	for seed_value: int in range(40):
		var map = Cave.generate("cave","Cave",seed_value)
		check(Cave.valid(map.cave_layout,map.dimensions,map.walls),"valid cave "+str(seed_value))
		check(State.capture(map)==State.capture(Cave.generate("cave","Cave",seed_value)),"repeatable seed")
		var blocked: Dictionary = {}
		for cell: Vector2i in map.walls: blocked[cell] = true
		var visited: Dictionary = {map.spawn_cell:true}
		var queue: Array = [map.spawn_cell]
		var head: int = 0
		while head < queue.size():
			var cell: Vector2i = queue[head]
			head += 1
			for neighbor: Vector2i in map.neighbors(cell):
				if not blocked.has(neighbor) and not visited.has(neighbor): visited[neighbor]=true;queue.append(neighbor)
		check(visited.size()+blocked.size()==map.dimensions.x*map.dimensions.y,"all carved cells connected")
		var degree: Dictionary = {}
		for room: Dictionary in map.cave_layout.rooms: degree[room.id] = []
		for passage: Dictionary in map.cave_layout.passages:
			degree[passage.from].append(passage.to)
			degree[passage.to].append(passage.from)
		for room: Dictionary in map.cave_layout.rooms:
			check(visited.has(room.center),"cavern reachable")
			if not room.main: check(degree[room.id].size()==1 and degree[room.id][0] in map.cave_layout.main_route,"no chained dead-end rooms")
		check(State.valid(State.capture(map)),"saveable cave metadata")
		signatures[hash(map.walls)] = true
	check(signatures.size()==40,"different seeds vary physical layout")
	var map = Cave.generate("cave","Cave",1)
	var broken: Dictionary = map.cave_layout.duplicate(true)
	broken.passages.remove_at(0)
	check(not Cave.valid(broken,map.dimensions,map.walls),"broken main circuit rejected")
	var legacy: Dictionary = State.capture(map)
	legacy.erase("cave_layout")
	check(State.valid(legacy) and State.restore(legacy).cave_layout.is_empty(),"old maps load without cave data")
	print("Cave topology: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
