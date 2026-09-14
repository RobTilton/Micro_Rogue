extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("Workshop/Rooms/Mouse Play/tests/mouse_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/Mouse Play/tests/saves/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	await process_frame
	await process_frame
	var board = game.board
	var world = game.simulation
	var town = game.active_map
	var player: Dictionary = game.player
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	var sample := Vector2i(2,2)
	wheel.position = board.center(sample)
	var anchor: Vector2 = wheel.position
	board._gui_input(wheel)
	check(is_equal_approx(board.zoom,1.15),"wheel zoom")
	check(board.center(sample).distance_to(anchor) < 0.01 and board._cell_at(anchor) == sample,"zoom anchor and picking agree")
	board.set_zoom(100,anchor)
	check(board.zoom == 2.5,"zoom upper limit")
	board.set_zoom(0.001,anchor)
	check(board.zoom == 0.5,"zoom lower limit")
	board.set_zoom(1,anchor)
	board.focus_player()
	check(board.center(player.pos).distance_to(board.size*0.5) < 0.01,"focus player")
	board._process(0)
	var right := InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	right.pressed = true
	right.position = board.center(player.pos)
	board._gui_input(right)
	var labels: Array = []
	for index: int in range(game.context_popup.item_count): labels.append(game.context_popup.get_item_text(index))
	for label: String in ["Focus on player","Character","Inventory","Skills","Quests"]: check(label in labels,"self context "+label)
	check(game._selected_source().is_empty(),"no equipment selection for empty starting gear")
	var inventory_index: int = labels.find("Inventory")
	game.context_popup.hide()
	game.context_actions[inventory_index].call()
	check(game.host.panel_name == "Inventory","context inventory action")
	game.rail.entries.Quests.pressed.emit()
	check(game.host.panel_name == "Quests" and game.host.content.get_child_count() >= 6,"quest sidebar content")
	game.minimap.cell_selected.emit(Vector2i(3,3))
	check(board.center(Vector2i(3,3)).distance_to(board.size*0.5) < 0.01,"minimap focuses camera")
	world.begin_turn(player)
	var destination := Vector2i(-1,-1)
	for cell: Vector2i in town.neighbors(player.pos):
		if town.walkable(cell) and world.actor_at(town.id,cell).is_empty(): destination = cell; break
	var origin: Vector2i = player.pos
	check(world.move(player,destination).ok,"player movement fixture")
	game._refresh()
	check(board.motions.has(player.id),"player animation queued")
	board._process(0.125)
	check(board.actor_sprites[player.id].position.distance_to(board.center(origin).lerp(board.center(destination),0.5)) < 0.01,"halfway through quarter-second slide")
	check(board._interaction_cell_at(board.actor_sprites[player.id].position) == destination,"moving actor click resolves logical cell")
	board._process(0.125)
	check(not board.motions.has(player.id) and board.actor_sprites[player.id].position.distance_to(board.center(destination)) < 0.01,"slide completes exactly")
	var rng := RandomNumberGenerator.new()
	rng.seed = 71
	var foe: Dictionary = world.Actors.create([6,6,6,6,6,6],true,rng)
	var from := Vector2i(-1,-1)
	var to := Vector2i(-1,-1)
	for cell: Vector2i in town.cells():
		if not town.walkable(cell) or not world.actor_at(town.id,cell).is_empty() or not world.can_see(player,cell): continue
		for neighbor: Vector2i in town.neighbors(cell):
			if town.walkable(neighbor) and world.actor_at(town.id,neighbor).is_empty() and world.can_see(player,neighbor): from = cell; to = neighbor; break
		if from != Vector2i(-1,-1): break
	world.add_actor(foe,town.id,from,"enemy")
	world.begin_turn(foe)
	check(world.move(foe,to).ok,"enemy movement fixture")
	game._refresh()
	check(board.motions.has(foe.id),"enemy animation queued")
	board._process(0.25)
	check(not board.motions.has(foe.id),"enemy slide finishes")
	# Old saves without zoom remain loadable.
	var legacy: Dictionary = world.MapState.capture(town)
	legacy.erase("view_zoom")
	check(world.MapState.valid(legacy) and world.MapState.restore(legacy).view_zoom == 1.0,"legacy camera migration")
	board.set_zoom(1.3,board.size*0.5)
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	check(restored.load_game(game.journal.path).ok and restored.snapshot() == world.snapshot(),"camera and world exact save roundtrip")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		check(game.minimap.projected.size() == 37,"minimap renders town footprint")
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Mouse Play/tests/mouse_gameplay.png")
	player.pos = town.spawn_cell
	world.begin_turn(player)
	game._refresh()
	board._process(0)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = board.center(player.pos)
	click.pressed = true
	board._gui_input(click)
	click.pressed = false
	board._gui_input(click)
	check(player.map_id == town.id,"single self click does not travel")
	click.pressed = true
	click.double_click = true
	board._gui_input(click)
	click.pressed = false
	board._gui_input(click)
	await create_timer(1).timeout
	check(player.map_id == world.maps.records[town.id].parent,"double self click travels once")
	game.queue_free()
	await process_frame
	print("Mouse Play: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
