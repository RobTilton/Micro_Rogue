extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Caves = preload("res://Production/World/cave_generator.gd")
const Dense = preload("res://Production/World/dense_room_generator.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Adventure Loop/tests/adventure_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(180).timeout.connect(func(): quit(2))
	var shapes: Dictionary = {}
	var cave_counts: Dictionary = {}
	var fallbacks: int = 0
	for seed_value: int in range(12):
		var cave = Caves.generate("cave","Cave",seed_value)
		check(Caves.valid(cave.cave_layout,cave.dimensions,cave.walls),"variable cave validates")
		cave_counts[cave.cave_layout.rooms.size()] = true
		for tower: bool in [false,true]:
			var dungeon = Dense.generate("test","Test",seed_value,tower)
			check(Dense.valid(dungeon.room_layout,dungeon.dimensions,dungeon.walls),"partitioned rooms have connected loops")
			if dungeon.room_layout.version == 1: fallbacks += 1
			shapes[str(dungeon.dimensions)+str(dungeon.room_layout.rooms.size())] = true
	check(cave_counts.size() > 3 and shapes.size() > 10,"seed sweep varies cavern counts and building layouts")
	print("Layout fallbacks in 24 buildings: ",fallbacks)
	var game = load("res://Production/main.tscn").instantiate()
	var dir: String = "res://Workshop/Rooms/Well Interiors/tests/saves/"
	game.autosave_directory = dir+"autosaves/"
	game.snapshot_directory = dir+"snapshots/"
	game.preferences_path = dir+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	var world = game.simulation
	var player: Dictionary = game.player
	var town = game.active_map
	var well = world.ensure_map({"id":town.id+"/well"})
	var underground = world.ensure_map({"id":well.id+"/underground"})
	check(not underground.room_layout.is_empty() or not underground.cave_layout.is_empty(),"well resolves new topology")
	check(not underground.props.is_empty(),"well interior receives containers and scenery")
	check(Sim.validate_snapshot(world.snapshot()).is_empty(),"populated well interior saves validly")
	var merchant: Dictionary = {}
	var shop_cell := Vector2i.ZERO
	for cell: Vector2i in town.shops:
		if town.shops[cell].id == "general_goods": merchant = town.shops[cell]; shop_cell = cell
	var potion_id: int = 0
	var ration_id: int = 0
	var supply_count: int = 0
	for entry: Dictionary in merchant.stock:
		if entry.item.kind == "potion": potion_id = entry.item.item_id; supply_count += 1
		if entry.item.kind == "ration": ration_id = entry.item.item_id; supply_count += 1
	check(supply_count == 10,"general goods has five potions and five rations")
	for cell: Vector2i in town.neighbors(shop_cell):
		if town.walkable(cell) and world.actor_at(town.id,cell,player.id).is_empty(): player.pos = cell; break
	check(world.buy(player,shop_cell,potion_id).ok and world.buy(player,shop_cell,ration_id).ok,"supplies purchasable")
	player.hp = 1
	check(world.drink(player,potion_id).ok and player.hp == 7 and player.belt.is_empty(),"backpack potion works without a belt")
	check(world.camp(player).ok and player.hp == 18 and world.world_hours == 6,"camp consumes ration, heals 2 CON, advances six hours")
	check(not world.camp(player).ok and world.world_hours == 6,"camp without ration spends nothing")
	world.ensure_map({"id":town.id})
	check(merchant.stock.size() == maxi(5,merchant.prosperity*3)+8,"shop reopen does not refill supplies")
	var chest_cell: Vector2i = town.spawn_cell
	for cell: Vector2i in town.cells():
		if town.walkable(cell) and not town.links.has(cell) and not town.props.has(cell): chest_cell = cell; break
	town.props[chest_cell] = {"kind":"chest","name":"Test chest","opened":false,"contents":[],"gold":11,"room_id":-1}
	world._balance_chest_gold(town)
	world._balance_chest_gold(town)
	check(town.props[chest_cell].gold == 5,"old chest gold halved once, rounded down")
	var old_world: String = world.maps.world_id
	var old_seed: int = world.maps.world_seed
	var old_player: int = player.id
	var old_time: int = world.world_hours
	player.hp = 0
	await game._new_character()
	check(game.simulation.maps.world_id == old_world and game.simulation.creation.has("dice_slots"),"death opens creation inside existing world")
	print("CREATION VALIDATION ",Sim.validate_snapshot(game.simulation.snapshot()))
	var pending_path: String = game.journal.path
	check(game._load_path(pending_path) and game.simulation.maps.world_id == old_world,"replacement creation survives reload")
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	world = game.simulation
	player = game.player
	check(world.maps.world_id == old_world and world.maps.world_seed == old_seed and world.world_hours == old_time,"replacement retains world identity and calendar")
	check(player.id != old_player and world.actors.has(old_player) and world.actors[old_player].hp == 0 and player.gold == 50,"new actor with old fallen actor retained")
	check(world.maps.maps[town.id].props[chest_cell].gold == 5,"world changes survive character death")
	check(game.minimap.get_parent() == game.rail and game.rail.get_child(0) == game.minimap,"single minimap is above sidebar")
	var saved: Dictionary = world.save_game(dir+"roundtrip/")
	var restored = Sim.new(1)
	print("FINAL SAVE ",saved," VALID ",Sim.validate_snapshot(world.snapshot()))
	check(saved.ok and restored.load_game(world.last_save).ok and restored.snapshot() == world.snapshot(),"new consumables and persistent world save exactly")
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Well Interiors/tests/sidebar.png")
	game.queue_free()
	await process_frame
	print("Well integration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
