extends SceneTree
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Production Promotion/tests/isolation_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(not DirAccess.dir_exists_absolute("res://Workshop"),"Workshop absent from packaged filesystem")
	check(not FileAccess.file_exists("res://Production/Current/ui/main.tscn"),"earlier Production baseline absent")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://Production/main.tscn","canonical entry is promoted game")
	var game = load("res://Production/main.tscn").instantiate()
	root.add_child(game)
	await game._new_character()
	var world_id: String = game.map_world.world_id
	check(game.journal.path.begins_with("user://worlds/autosaves/") and FileAccess.file_exists(game.journal.path),"startup saves independently to user data")
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	await game._enter_map()
	check(game.active_map.layer == "Local","Local generation works with no Workshop")
	check(game.board.local_textures.size() == 5 and game.board.water_texture != null and game.board.poi_texture != null and game.board.river_texture != null,"dynamic and fixed terrain resources load")
	check(game.board.actor_sprites.has(game.player.id),"player sprite loads from Production atlas")
	game._toggle_panel("Inventory",180)
	for frame: int in range(4): await process_frame
	var art = load("res://Production/UI/item_art.gd")
	check(art.texture_named("bronze_sword") != null,"dynamic item texture resolves within Production")
	game.host.close()
	game._unload_inactive()
	check(not game.map_world.maps.has("global"),"archive writes without project-source access")
	await game._enter_map()
	check(game.active_map.id == "global" and game.map_world.world_id == world_id,"Return restores same world from independent storage")
	game._save_world()
	check(game.simulation.last_save.begins_with("user://worlds/snapshots/") and FileAccess.file_exists(game.simulation.last_save),"extra snapshot creates its own writable directory")
	var path: String = game.journal.path
	check(game._load_path(path) and game.map_world.world_id == world_id,"automatic checkpoint resumes in isolated runtime")
	for frame: int in range(5): await process_frame
	game.board.focus_player()
	await RenderingServer.frame_post_draw
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0: check(root.get_texture().get_image().save_png(args[0]) == OK,"render evidence written")
	print("Production isolation: %d checks, %d failures; user data: %s" % [checks,failures,OS.get_user_data_dir()])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
