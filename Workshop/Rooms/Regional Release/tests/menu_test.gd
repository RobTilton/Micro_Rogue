extends SceneTree
const Journal = preload("res://Workshop/Rooms/Regional Release/Persistence/autosave_journal.gd")
const Slot = preload("res://Workshop/Rooms/Regional Release/Persistence/world_slot.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; push_error("Workshop/Rooms/Regional Release/tests/menu_test.gd: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90).timeout.connect(func(): quit(2))
	var game = load("res://Workshop/Rooms/Regional Release/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/Regional Release/tests/menu_slot/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	check(game.start_menu.buttons.size() == 5,"five hex menu actions")
	await game._new_character()
	var original_path: String = game.journal.path
	var original_seed: int = game.map_world.world_seed
	var original_id: String = game.map_world.world_id
	check(FileAccess.file_exists(original_path),"current world persisted")
	game._show_splash()
	check(not game.start_menu.buttons.continue.disabled and not game.start_menu.buttons.regenerate.disabled,"saved world enables menu actions")
	var button = game.start_menu.buttons.continue
	button.mouse_entered.emit()
	await create_timer(0.2).timeout
	check(button.lift > 6.9,"hover rises")
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("res://Workshop/Rooms/Regional Release/tests/start_menu.png") == OK,"menu capture")
	button.mouse_exited.emit()
	await create_timer(0.2).timeout
	check(button.lift < 0.1,"hover settles")
	game._start_options()
	check(game.root.get_child(0).text == "OPTIONS","Options works without player")
	game._world_data()
	check(game.root.get_child(0).text == "WORLD DATA","World Data opens")
	await game._regenerate_world()
	check(game.map_world.world_seed != original_seed,"regeneration rolls new seed")
	check(game.map_world.world_id != original_id and game.simulation.player_id == 0,"regeneration creates fresh world and adventurer setup")
	check(not FileAccess.file_exists(original_path),"old save removed after replacement")
	check(game.simulation.regeneration.world_id == original_id,"regeneration provenance retained as small metadata")
	check(DirAccess.get_files_at(game.autosave_directory).size() == 1,"one active journal")
	var current_path: String = game.journal.path
	check(game._load_path(current_path),"Continue restores current world")
	check(game._automatic_checkpoint(),"resume checkpoint succeeds")
	check(not FileAccess.file_exists(current_path) and DirAccess.get_files_at(game.autosave_directory).size() == 1,"resume replaces predecessor instead of retaining history")
	var before_compaction: String = game.journal.path
	game.journal.compact_bytes = 1
	check(game._automatic_checkpoint(),"bounded journal compaction succeeds")
	check(not FileAccess.file_exists(before_compaction) and DirAccess.get_files_at(game.autosave_directory).size() == 1,"compaction leaves one current save")
	var keep: String = game.journal.path
	var refused: Dictionary = Slot.prune(directory+"missing.journal",game.map_world.world_id,[game.autosave_directory])
	check(not refused.ok and FileAccess.file_exists(keep),"incomplete replacement never removes valid save")
	check(Journal.read_snapshot(keep).ok,"compacted save is readable")
	game.queue_free()
	await process_frame
	print("Hex menu/single save: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
