extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const DIR = "res://Workshop/Rooms/Cave Foundation/tests/saves/"
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Cave Foundation/tests/integration_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(120).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	game.autosave_directory = DIR+"autosaves/"
	game.snapshot_directory = DIR+"snapshots/"
	game.preferences_path = DIR+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	await game._enter_map()
	var local_id: String = game.player.map_id
	var previous_count: int = game.active_map.links.size()
	game._discover_cave()
	check(game.active_map.links.size()==previous_count+1,"event discovery adds Cave to existing Local")
	var cave_cell := Vector2i(-1,-1)
	for cell: Vector2i in game.active_map.links:
		if game.active_map.links[cell].kind == "Cave": cave_cell = cell; break
	check(cave_cell != Vector2i(-1,-1),"Cave is naturally discoverable on Local")
	if cave_cell == Vector2i(-1,-1): quit(1); return
	game.player.pos = cave_cell
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	check(game.map_world.records[game.player.map_id].template == "Cave","Cave travel")
	var map = game.active_map
	check(game.player.pos == map.spawn_cell and map.cave_layout.rooms[0].cells.has(game.player.pos),"entry cavern arrival")
	var actors_before: int = game.simulation.actors.size()
	var ground_before: Array = game.simulation.ground[map.id].duplicate(true)
	game.simulation.ensure_map({"id":map.id})
	check(game.simulation.actors.size() == actors_before and game.simulation.ground[map.id] == ground_before,"no population reroll")
	for actor: Dictionary in game.simulation.on_map(map.id):
		if actor.id != game.player.id: check(map.cave_layout.rooms[actor.cave_room_id].cells.has(actor.pos),"monster belongs to its cavern")
	for entry: Dictionary in ground_before: check(map.cave_layout.rooms[entry.cave_room_id].cells.has(entry.pos),"loot belongs to its cavern")
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	check(restored.load_game(game.journal.path).ok and restored.snapshot() == game.simulation.snapshot(),"cave rooms actors loot exact journal roundtrip")
	var invalid: Dictionary = restored.snapshot()
	invalid.states[map.id].erase("cave_layout")
	check(not Sim.validate_snapshot(invalid).is_empty(),"Cave cannot load without its room topology")
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	check(game.player.map_id == local_id and game.player.pos == cave_cell,"return to original Local entrance")
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	check(game.player.map_id == map.id and game.simulation.actors.size() == actors_before and game.simulation.ground[map.id] == ground_before,"re-entry preserves contents")
	# Retained geometry overview: actual carved pixels, not an AI concept proof.
	var overview := Image.create(384,312,false,Image.FORMAT_RGBA8)
	overview.fill(Color("121820"))
	var rock: Dictionary = {}
	for cell: Vector2i in map.walls: rock[cell]=true
	for cell: Vector2i in map.cells():
		if not rock.has(cell): overview.fill_rect(Rect2i(cell*6,Vector2i(6,6)),Color("b7b0a0"))
	for room: Dictionary in map.cave_layout.rooms:
		for cell: Vector2i in room.cells: overview.fill_rect(Rect2i(cell*6,Vector2i(6,6)),Color("97b59d") if room.main else Color("c6ab7e"))
	overview.save_png("res://Workshop/Rooms/Cave Foundation/tests/carved_overview.png")
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Cave Foundation/tests/cave_gameplay.png")
	game.queue_free()
	await process_frame
	print("Cave Production integration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
