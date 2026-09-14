extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const DIR = "res://Workshop/Rooms/Town Market/tests/saves/"
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Town Market/tests/town_test.gd: "+message)
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
	check(game.player.gold == 100,"new character gold")
	check(game.simulation.Inventory.possessions(game.player).is_empty(),"new character has no gear")
	var local = game.active_map
	var town_cell := Vector2i(-1,-1)
	for cell: Vector2i in local.links:
		if local.links[cell].kind == "Town": town_cell = cell; break
	check(town_cell != Vector2i(-1,-1),"Town entrance")
	game.player.pos = town_cell
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	var map = game.active_map
	check(map.hex_radius == 3 and map.cells().size() == 37,"radius three town")
	check(map.walkable(game.player.pos) and game.player.pos == map.spawn_cell,"dry walkable arrival")
	check(map.shops.size() == 6 and map.props.size() == 3,"six shops and three containers")
	var reached: Dictionary = {map.spawn_cell:true}
	var queue: Array = [map.spawn_cell]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		for next: Vector2i in map.neighbors(cell):
			if map.walkable(next) and not reached.has(next): reached[next] = true; queue.append(next)
	var selected := Vector2i(-1,-1)
	for cell: Vector2i in map.shops:
		var shop: Dictionary = map.shops[cell]
		check(map.distance(cell,Vector2i(3,3)) == 3,"perimeter placement")
		var access: bool = false
		for next: Vector2i in map.neighbors(cell):
			if reached.has(next): access = true
		check(access,"reachable shop")
		if shop.id in ["inn","jeweler"]: continue
		check(shop.stock.size() == maxi(5,shop.prosperity*3),"prosperity stock count")
		selected = cell
	check(selected != Vector2i(-1,-1),"trading fixture")
	for cell: Vector2i in map.neighbors(selected):
		if map.walkable(cell): game.player.pos = cell; break
	game.simulation.begin_turn(game.player)
	var entry: Dictionary = map.shops[selected].stock[0].duplicate(true)
	var stock_before: int = map.shops[selected].stock.size()
	check(game.simulation.buy(game.player,selected,entry.item.item_id).ok,"purchase")
	check(game.player.gold == 100-entry.price and map.shops[selected].stock.size() == stock_before-1,"exact gold and stock deduction")
	check(game.player.bag.size() == 1 and game.player.bag[0].item_id == entry.item.item_id,"item in backpack")
	game.simulation.begin_turn(game.player)
	check(not game.simulation.buy(game.player,selected,entry.item.item_id).ok,"cannot buy sold item twice")
	game.player.gold = 0
	var before: Dictionary = game.simulation.snapshot()
	check(not game.simulation.buy(game.player,selected,map.shops[selected].stock[0].item.item_id).ok,"insufficient gold refused")
	check(before == game.simulation.snapshot(),"refusal leaves world unchanged")
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	var loaded: Dictionary = restored.load_game(game.journal.path)
	print("Town load: ",loaded," validation: ",Sim.validate_snapshot(game.simulation.snapshot()))
	check(loaded.ok and restored.snapshot() == game.simulation.snapshot(),"Town stock gold and containers exact save roundtrip")
	game.player.pos = map.spawn_cell
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	check(game.player.map_id == local.id and game.player.pos == town_cell,"return to Local")
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	check(game.active_map.shops[selected].stock.size() == stock_before-1,"revisit does not restock")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Town Market/tests/town_gameplay.png")
	game.queue_free()
	await process_frame
	print("Town market integration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
