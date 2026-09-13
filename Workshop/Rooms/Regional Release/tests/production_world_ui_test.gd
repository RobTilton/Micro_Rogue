extends SceneTree
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Regional Release/tests/world_ui_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90.0).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	game.autosave_directory = "res://Workshop/Rooms/Regional Release/tests/production_regression_saves/autosaves/"
	game.snapshot_directory = game.autosave_directory.path_join("snapshots/")
	game.preferences_path = game.autosave_directory.path_join("preferences.cfg")
	root.add_child(game)
	check(game.get_script().resource_path == "res://Production/UI/world_game.gd","Room script identity")
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	for frame: int in range(3): await process_frame
	check(game.simulation.maps.records.size() > 1,"scene uses hierarchical registry")
	var origin: String = game.player.map_id
	game._enter_map()
	check(game.travel_transition_active and game.player.map_id == origin,"fade starts before generation/travel")
	game._enter_map()
	check(game.player.map_id == origin,"duplicate travel blocked during fade")
	while game.player.map_id == origin: await process_frame
	check(game.travel_cover.color.a == 1.0,"map changes behind opaque cover")
	check(game.travel_cover.size == Vector2(root.size),"cover fills viewport")
	while game.travel_transition_active: await process_frame
	check(not game.travel_cover.visible,"cover released after fade")
	check(game.active_map.layer == "Local","Local travel UI")
	check(game.active_map.hex_radius == 20 and game.active_map.cells().size() == 1261,"hex Local presented")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Regional Release/tests/production_local_gameplay.png")
	var local_id: String = game.active_map.id
	game._discover_dungeon()
	check(game.active_map.links.size() == 5,"event control adds persistent entrance")
	for cell: Vector2i in game.active_map.links:
		if game.active_map.links[cell].kind == "Town": game.player.pos = cell; break
	await game._enter_map()
	check(game.active_map.title == "Town","Town UI")
	for kind: String in ["Well","Underground"]:
		for cell: Vector2i in game.active_map.links:
			if game.active_map.links[cell].kind == kind: game.player.pos = cell; break
		await game._enter_map()
		check(game.map_world.records[game.player.map_id].template == kind,"recursive UI "+kind)
	game.player.hp = 999
	game.player.max_hp = 999
	game._unload_inactive()
	check(not game.map_world.maps.has(local_id),"UI unload releases parent")
	check(game.board.actor_sprites.has(game.player.id),"actor sprite retained")
	var saved: Dictionary = game.simulation.save_game("res://Workshop/Rooms/Regional Release/tests/production_regression_saves/")
	check(saved.ok,"UI world saves")
	game._load_path(saved.path)
	check(game.map_world.records[game.player.map_id].template == "Underground","UI resumes nested map")
	check(game.cooldowns == game.player.clock,"restored UI uses actor clock")
	game._options_panel(game.root)
	for frame: int in range(3): await process_frame
	check(game.frame_ready,"loaded scene frame ready")
	game.queue_free()
	await process_frame
	print("World UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
