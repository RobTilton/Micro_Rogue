extends SceneTree
const Items = preload("res://Production/Actors/items.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Movement Flow/integration_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func pump(game, count: int = 100) -> void:
	for index: int in range(count):
		game.set_process(false)
		game.board.set_process(false)
		game._process(0.26)
		game.board._process(0.26)
		await process_frame
		if game.travel_goal == null and game.travel_task.is_empty() and not game.travel_inflight and not game._movement_busy(): return
	check(false,"movement settles within bounded steps")
func run() -> void:
	create_timer(90).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/Movement Flow/tests/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,3,3,3,3,3,3]
	game._start_run()
	game.set_process(false)
	game.board.set_process(false)
	game.confirm_movement = false
	var world = game.simulation
	var player: Dictionary = game.player
	var town = game.active_map
	var crier: Dictionary = {}
	for npc: Dictionary in world.on_map(player.map_id):
		if npc.get("role","") == "crier": crier = npc
	check(not crier.is_empty(),"town crier exists")
	game._approach_task({"kind":"crier","actor_id":crier.id})
	await pump(game)
	check(town.distance(player.pos,crier.pos) <= 1 and game.host.panel_name == "Activate","talk walks to crier and opens bounty panel")
	check(game.travel_task.is_empty(),"completed talk clears task safely")
	game._approach_task({"kind":"crier","actor_id":crier.id})
	await pump(game)
	check(game.host.panel_name == "Activate","talk again keeps the bounty panel open")
	game._execute_travel_task({})
	game._talk_to_crier(-1)
	check(game.host.panel_name == "Activate","cancelled dispatch and stale crier do not crash")
	game.host.close()
	# Retarget while traversing a single hex: old route must never append.
	var destination: Vector2i = player.pos
	for cell: Vector2i in town.cells():
		if town.walkable(cell) and world.actor_at(town.id,cell).is_empty() and town.distance(player.pos,cell) >= 3: destination = cell; break
	var starting: Vector2i = player.pos
	game._request_movement(destination,true)
	game._process(0.01)
	check(town.distance(starting,player.pos) == 1 and game.board.motions.has(player.id),"request commits only first animated hex")
	var first: Vector2i = player.pos
	game._request_movement(starting,true)
	check(player.pos == first and game.travel_goal == starting,"retarget changes destination without another instant move")
	check(game.board.motions[player.id].route.size() == 1,"retarget does not append visual route")
	await pump(game)
	check(player.pos == starting,"replacement path finishes at replacement destination")
	# Approach a real shop.
	var shop_cell: Vector2i = town.shops.keys()[0]
	game._approach_task({"kind":"shop","cell":shop_cell})
	await pump(game)
	check(town.distance(player.pos,shop_cell) <= 1 and game.host.panel_name == "Shop","approach opens shop after arriving")
	game.host.close()
	# Search and take use current target state, then inventory's own range validation.
	var prop_cell: Vector2i = player.pos
	for cell: Vector2i in town.cells():
		if town.walkable(cell) and not town.links.has(cell) and world.actor_at(town.id,cell).is_empty() and town.distance(player.pos,cell) >= 2: prop_cell = cell; break
	var potion: Dictionary = Items.potion()
	town.props[prop_cell] = {"kind":"chest","name":"Movement test chest","opened":false,"contents":[potion],"gold":0,"room_id":-1}
	game._approach_task({"kind":"search","cell":prop_cell})
	await pump(game)
	check(town.props[prop_cell].opened and town.distance(player.pos,prop_cell) <= 1,"search walks adjacent and opens once")
	game._approach_task({"kind":"take","item_id":potion.item_id})
	await pump(game)
	var owned: bool = false
	for item: Dictionary in player.bag:
		if item.item_id == potion.item_id: owned = true
	check(owned,"queued pickup reaches inventory")
	game._approach_task({"kind":"take","item_id":potion.item_id})
	check(game.travel_task.is_empty(),"removed ground target cancels safely")
	# Detection interrupts all intent before the sprite advances.
	game._queue_travel(destination)
	game._process(0.01)
	game._announce_combat()
	check(game.travel_goal == null and game.travel_task.is_empty() and game.board.motion_paused and game.combat_banner.visible,"combat cancels intent and displays pause banner")
	var frozen: Vector2 = game.board.actor_sprites[player.id].position
	game.board._process(0.3)
	check(game.board.actor_sprites[player.id].position == frozen,"announcement visibly freezes player")
	await pump(game)
	check(not game.board.motion_paused,"movement resumes after announcement")
	# An attack request approaches within reach and spends exactly one attack.
	var foe: Dictionary = world.Actors.create([3,3,3,3,1,3],true)
	var foe_cell: Vector2i = player.pos
	for cell: Vector2i in town.cells():
		if town.walkable(cell) and world.actor_at(town.id,cell).is_empty() and town.distance(player.pos,cell) in [2,3] and world.can_see(player,cell): foe_cell = cell; break
	foe.hp = 999
	foe.max_hp = 999
	foe.sight_base = 20
	world.add_actor(foe,town.id,foe_cell,"enemy")
	player.main = Items.make("sword")
	world.begin_turn(player)
	game._refresh()
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Movement Flow/combat_pause.png")
	await pump(game)
	game._approach_task({"kind":"attack","actor_id":foe.id})
	await pump(game)
	check(town.distance(player.pos,foe.pos) <= 1 and player.actions.used_attacks == 1,"approach attack stays within movement and attack budgets")
	foe.hp = 0
	game._refresh()
	# Context entrance waits for approach and its existing fade transition.
	game.host.close()
	var entrance: Vector2i = town.links.keys()[0]
	var expected_map: String = town.links[entrance].id
	game._approach_task({"kind":"entrance","cell":entrance})
	await pump(game)
	while game.travel_transition_active: await process_frame
	check(player.map_id == expected_map,"approach enters the chosen location after arriving")
	if world.maps.records[player.map_id].template == "Local":
		var local = world.maps.maps[player.map_id]
		for npc: Dictionary in world.on_map(player.map_id):
			if npc.id != player.id: npc.hp = 0
		var hidden: Dictionary = world.Actors.create([3,3,3,3,1,3],true)
		hidden.sight_base = 0
		var hidden_cell: Vector2i = player.pos
		for cell: Vector2i in local.cells():
			if local.walkable(cell) and local.distance(player.pos,cell) == 3 and world.can_see(player,cell): hidden_cell = cell; break
		world.add_actor(hidden,local.id,hidden_cell,"enemy")
		var local_id: String = player.map_id
		world.complete_walk_step(player)
		check(player.map_id == local_id,"seeing an unaware monster does not force an arena")
		hidden.sight_base = 20
		world.complete_walk_step(player)
		check(player.map_id != local_id and world.maps.records[player.map_id].template == "Encounter","monster detection enters arena after visible step completion")
	check(game._automatic_checkpoint(),"completed movement saves committed position")
	var committed: Vector2i = player.pos
	game.travel_goal = Vector2i(99,99)
	game.travel_task = {"kind":"crier","actor_id":crier.id}
	game.travel_inflight = true
	check(game._load_path(game.journal.path) and game.travel_goal == null and game.travel_task.is_empty() and not game.travel_inflight and game.player.pos == committed,"load restores position and discards unexecuted travel intent")
	print("Movement Flow integration: %d checks, %d failures" % [checks,failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
