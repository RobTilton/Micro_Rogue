extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const DIR = "res://Workshop/Rooms/Interior Scenery/tests/saves/"
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Interior Scenery/tests/props_test.gd: "+message)
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
	check(not map.props.is_empty(),"room props generated")
	var selected := Vector2i(-1,-1)
	for cell: Vector2i in map.props:
		for link: Vector2i in map.links: check(map.distance(cell,link)>2,"entrance clearance")
		if map.props[cell].kind not in ["rug","rubble"]: selected = cell
	check(selected != Vector2i(-1,-1),"searchable scenery")
	if selected == Vector2i(-1,-1): quit(1); return
	game.player.pos = selected
	game.simulation.begin_turn(game.player)
	var expected: Array = map.props[selected].contents.duplicate(true)
	var before: int = game.simulation.ground[map.id].size()
	check(game.simulation.interact(game.player,{"kind":"search","cell":selected}).ok,"shared search")
	check(map.props[selected].opened and map.props[selected].contents.is_empty(),"searched state")
	check(game.simulation.ground[map.id].size() == before+expected.size(),"exact contents released")
	game.simulation.begin_turn(game.player)
	check(not game.simulation.interact(game.player,{"kind":"search","cell":selected}).ok,"no duplicate search")
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	check(restored.load_game(game.journal.path).ok and restored.snapshot() == game.simulation.snapshot(),"opened and unopened containers persist")
	var victim: Dictionary = {}
	for actor: Dictionary in game.simulation.on_map(map.id):
		if actor.id != game.player.id: victim = actor; break
	check(not victim.is_empty(),"corpse fixture")
	if not victim.is_empty():
		var possessions: Array = game.simulation.Inventory.possessions(victim).duplicate(true)
		victim.hp = 0
		game.simulation.resolve_death(victim,game.player)
		check(map.props.has(victim.pos) and map.props[victim.pos].kind == "corpse","death creates corpse")
		check(map.props[victim.pos].contents == possessions,"corpse retains actual possessions")
		var content_count: int = map.props[victim.pos].contents.size()
		game.simulation.resolve_death(victim,game.player)
		check(map.props[victim.pos].contents.size() == content_count,"death is idempotent")
		game.player.pos = victim.pos
		game.simulation.begin_turn(game.player)
		check(game.simulation.interact(game.player,{"kind":"search","cell":victim.pos}).ok,"corpse loot accessible")
	game._automatic_checkpoint()
	var final_save = Sim.new(1)
	check(final_save.load_game(game.journal.path).ok and final_save.snapshot() == game.simulation.snapshot(),"corpse save roundtrip")
	# AI invokes the same capability, with no access to sealed item properties.
	for actor: Dictionary in game.simulation.on_map(map.id):
		if actor.id == game.player.id or actor.hp <= 0: continue
		for cell: Vector2i in map.props:
			if map.props[cell].opened or map.props[cell].kind in ["rug","rubble"] or not game.simulation.actor_at(map.id,cell).is_empty(): continue
			actor.pos = cell
			actor.momentum = game.simulation.turn_threshold
			game.simulation.begin_turn(actor)
			check(game.simulation.interact(actor,{"kind":"search","cell":cell}).ok,"enemy can search")
			break
		break
	game.queue_free()
	await process_frame
	print("Interior props integration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
