extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const State = preload("res://Production/Persistence/map_state.gd")
const DIR = "res://Workshop/Rooms/Village Foundation/tests/saves/"
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Village Foundation/tests/shops_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	game.autosave_directory = DIR+"autosaves/"
	game.snapshot_directory = DIR+"snapshots/"
	game.preferences_path = DIR+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	await game._enter_map()
	for cell: Vector2i in game.active_map.links:
		if game.active_map.links[cell].kind == "Town": game.player.pos = cell; break
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	check(game.active_map.shops.size() == 6,"six shop hexes")
	var map = game.active_map
	for cell: Vector2i in map.shops:
		check(not map.walkable(cell),"shop blocks its hex")
		var adjacent: Vector2i = map.neighbors(cell).filter(func(candidate): return map.walkable(candidate))[0]
		game.player.pos = adjacent
		check(game.simulation.inspect_shop(game.player,cell).ok,"adjacent interaction "+map.shops[cell].id)
	game.player.pos = Vector2i(1,3)
	check(not game.simulation.inspect_shop(game.player,Vector2i(10,9)).ok,"distant interaction refused")
	var paths: Dictionary = game.simulation.paths(game.player,999)
	for cell: Vector2i in map.shops:
		var accessible: bool = false
		for adjacent: Vector2i in map.neighbors(cell):
			if paths.has(adjacent): accessible = true
		check(accessible,"shop reachable from entrance")
	var state: Dictionary = State.capture(map)
	check(State.valid(state) and State.restore(state).shops == map.shops,"shop map state roundtrip")
	var legacy: Dictionary = state.duplicate(true)
	legacy.erase("shops")
	check(State.valid(legacy) and State.restore(legacy).shops.is_empty(),"older maps retain geometry without shops")
	game.player.pos = Vector2i(4,4)
	game._refresh()
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	check(restored.load_game(game.journal.path).ok and restored.snapshot() == game.simulation.snapshot(),"shop world exact save/load")
	game._open_shop(Vector2i(4,5))
	await process_frame
	check(game.host.panel_name == "Shop","adjacent click opens menu")
	check(game.host.content.get_child_count() > 0,"shop menu has content")
	game.host.close()
	game.board.pan_offset = Vector2.ZERO
	game._refresh()
	await process_frame
	await process_frame
	check(game.board.shop_nodes.size() == 6,"six roof sprites render")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Village Foundation/tests/shops.png")
	game.queue_free()
	await process_frame
	print("Single-hex shops: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
