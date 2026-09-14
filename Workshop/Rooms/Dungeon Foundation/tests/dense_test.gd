extends SceneTree
const Generator = preload("res://Production/World/dense_room_generator.gd")
const State = preload("res://Production/Persistence/map_state.gd")
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("Workshop/Rooms/Dungeon Foundation/tests/dense_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for seed_value: int in range(80):
		var map = Generator.generate("test","test",seed_value,seed_value%2 == 0)
		check(State.valid(State.capture(map)),"valid connected cyclic room layout")
		check(State.capture(map) == State.capture(Generator.generate("test","test",seed_value,seed_value%2 == 0)),"determinism")
		var blocked: Dictionary = {}
		for cell in map.walls: blocked[cell] = true
		var seen: Dictionary = {map.spawn_cell:true}
		var queue: Array = [map.spawn_cell]
		while not queue.is_empty():
			var cell: Vector2i = queue.pop_back()
			for next: Vector2i in map.neighbors(cell):
				if not blocked.has(next) and not seen.has(next):
					seen[next] = true
					queue.append(next)
		check(seen.size()+map.walls.size() == map.dimensions.x*map.dimensions.y,"physical floor connectivity")
		check(float(seen.size())/(map.dimensions.x*map.dimensions.y) > 0.65,"dense use of footprint")
	var game = load("res://Production/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/Dungeon Foundation/tests/saves/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	await game._enter_map()
	var local = game.active_map
	for kind: String in ["Dungeon","Tower"]:
		game.player.map_id = local.id
		for cell: Vector2i in local.links:
			if local.links[cell].kind == kind: game.player.pos = cell; break
		game.simulation.begin_turn(game.player)
		await game._enter_map()
		var first = game.active_map
		check(not first.room_layout.is_empty(),kind+" first floor")
		var bottom: Vector2i = first.spawn_cell+Vector2i(1,0)
		check(not first.links.has(bottom),"bottom shortcut hidden")
		for cell: Vector2i in first.links:
			if first.links[cell].kind in ["DungeonFloor","TowerFloor"]: game.player.pos = cell; break
		var stair: Vector2i = game.player.pos
		game.simulation.begin_turn(game.player)
		await game._enter_map()
		var top = game.active_map
		check(not top.room_layout.is_empty() and top.id != first.id,"upper floor generation")
		check(not first.links.has(bottom),"entering top normally does not reveal ladder")
		if kind == "Tower":
			game.player.pos = top.room_layout.rooms.back().center
			game.simulation.begin_turn(game.player)
			await game._enter_map()
			check(game.player.map_id == first.id and game.player.pos == bottom,"ladder descends directly")
			check(first.links.has(bottom),"successful player descent reveals bottom")
			game.simulation.begin_turn(game.player)
			await game._enter_map()
			check(game.player.map_id == top.id,"revealed ladder climbs back")
		else:
			game.simulation.begin_turn(game.player)
			await game._enter_map()
			check(game.player.map_id == first.id and game.player.pos == stair,"stairs return to correct room")
		game._automatic_checkpoint()
		var restored = Sim.new(1)
		var loaded: Dictionary = restored.load_game(game.journal.path)
		print(kind," load ",loaded," validation ",Sim.validate_snapshot(game.simulation.snapshot()))
		for key in game.simulation.snapshot():
			if loaded.ok and restored.snapshot().get(key) != game.simulation.snapshot()[key]: print("different ",key)
		check(loaded.ok and restored.snapshot() == game.simulation.snapshot(),"exact world save roundtrip")
	game.queue_free()
	await process_frame
	print("Dense rooms: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
