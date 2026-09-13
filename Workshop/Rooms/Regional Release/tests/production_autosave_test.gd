extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Journal = preload("res://Production/Persistence/autosave_journal.gd")
const Actors = preload("res://Production/Actors/actors.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Regional Release/tests/autosave_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90.0).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	game.autosave_directory = "res://Workshop/Rooms/Regional Release/tests/production_regression_saves/autosave_validation/"
	game.snapshot_directory = game.autosave_directory.path_join("snapshots/")
	game.preferences_path = game.autosave_directory.path_join("preferences.cfg")
	root.add_child(game)
	check(game.get_script().resource_path == "res://Production/UI/world_game.gd","Room script identity")
	await game._new_character()
	var world_id: String = game.map_world.world_id
	var layout: Dictionary = game.map_world.maps.global.biomes.duplicate()
	var path: String = game.journal.path
	check(not path.is_empty() and FileAccess.file_exists(path),"world is saved before character creation")
	var restored = Sim.new(1)
	check(restored.load_game(path).ok and restored.player_id == 0,"generated world resumes without an adventurer")
	var dice: Array = game.dice_slots.duplicate()
	game._load_path(path)
	check(game.dice_slots == dice,"Continue preserves creation roll")
	check(game.prepared_world.maps.world_id == world_id,"Continue draft keeps world identity")
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	check(game.map_world.world_id == world_id and game.map_world.maps.global.biomes == layout,"character joins the pre-generated world")
	path = game.journal.path
	check(restored.load_game(path).ok and restored.player_id > 0,"new character automatically durable")
	var count: int = game.journal.writes
	game._automatic_checkpoint()
	check(game.journal.writes == count,"unchanged state adds no record")
	var destination: Vector2i = game.simulation.paths(game.player).keys()[0]
	var before_bytes: int = FileAccess.get_file_as_bytes(path).size()
	var start: int = Time.get_ticks_usec()
	game._finish(game.simulation.move(game.player,destination))
	var elapsed: int = Time.get_ticks_usec()-start
	check(restored.load_game(path).ok and restored.actors[restored.player_id].pos == destination,"movement saved without manual command")
	var added: int = FileAccess.get_file_as_bytes(path).size()-before_bytes
	check(added < 20000,"ordinary movement appends a small delta")
	game._end_turn()
	check(restored.load_game(path).ok and restored.tick == game.simulation.tick,"wait/turn is saved")
	await game._enter_map()
	check(restored.load_game(path).ok and restored.actors[restored.player_id].map_id == game.player.map_id,"travel is saved")
	var old_maps: int = game.map_world.records.size()
	game._discover_dungeon()
	check(game.map_world.records.size() == old_maps+1 and restored.load_game(path).ok and restored.maps.records.size() == old_maps+1,"event POI is saved")
	check(restored.snapshot() == game.simulation.snapshot(),"incremental journal equals complete world state")
	var baseline: Dictionary = restored.snapshot()
	var damaged: String = path+".interrupted.journal"
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	bytes.append_array(PackedByteArray([10,0,0,0,99]))
	var file := FileAccess.open(damaged,FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	var recovery: Dictionary = Journal.read_snapshot(damaged)
	check(recovery.ok and recovery.recovered,"interrupted tail recovers completed records")
	check(restored.load_game(damaged).ok and restored.snapshot() == baseline,"tail recovery restores exact prior state")
	# Keep a path for a completely separate process; no in-memory state is required.
	FileAccess.open("res://Workshop/Rooms/Regional Release/tests/autosave_restart_path.txt",FileAccess.WRITE).store_string(path)
	var invalid_path: String = game.autosave_directory+"99999999999999999999_invalid_"+str(Time.get_ticks_usec())+".journal"
	file = FileAccess.open(invalid_path,FileAccess.WRITE)
	file.store_32(Journal.MAGIC)
	file.close()
	game._load_latest()
	check(game.map_world.world_id == world_id and game.simulation.player_id > 0,"Continue skips an incomplete first checkpoint")
	print("Autosave movement including UI: %d microseconds; delta %d bytes" % [elapsed,added])
	game.queue_free()
	await process_frame
	print("Automatic persistence: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
