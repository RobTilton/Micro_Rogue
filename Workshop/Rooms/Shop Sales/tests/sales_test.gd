extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Shop Sales/tests/sales_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var world = Sim.new(5100)
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	var player: Dictionary = Actors.create([6,6,6,6,6,6],true,rng)
	for slot: String in world.Grid.EQUIPMENT: player[slot] = {}
	player.bag = []
	player.gold = 10000
	world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
	world.start_in_town()
	var town = world.maps.maps[player.map_id]
	var shop_cell := Vector2i.ZERO
	for cell: Vector2i in town.shops:
		if town.shops[cell].id == "blacksmith": shop_cell = cell
	for cell: Vector2i in town.neighbors(shop_cell):
		if town.walkable(cell) and world.actor_at(town.id,cell).is_empty(): player.pos = cell; break

	var prices = preload("res://Production/World/village_shops.gd")
	check(prices.sale_price({"base_rank":1,"material_tier":1,"quality":{"modifier":0}}) == 2,"odd price rounds down")
	var shop: Dictionary = town.shops[shop_cell]
	var entry: Dictionary = shop.stock[0].duplicate(true)
	check(world.buy(player,shop_cell,entry.item.item_id).ok,"buy test gear")
	var before: int = player.gold
	check(world.sell(player,shop_cell,entry.item.item_id).ok,"sell gear")
	check(player.gold == before+entry.price/2,"half-price payout")
	check(shop.stock.back().item.item_id == entry.item.item_id and shop.stock.back().item.name == entry.item.name and shop.stock.back().price == entry.price,"same item enters same shop at retail")
	check(not world.sell(player,shop_cell,entry.item.item_id).ok,"cannot sell same gear twice")
	check(world.buy(player,shop_cell,entry.item.item_id).ok,"sold gear can be bought back")
	var ui = preload("res://Workshop/Rooms/Shop Sales/tests/trade_ui.gd").new()
	ui.simulation = world
	ui.player = player
	ui.map_world = world.maps
	ui.selected_shop_cell = shop_cell
	root.add_child(ui)
	before = player.gold
	ui._sell_item(entry.item.item_id)
	check(ui.trade_confirmation.visible and player.gold == before,"sale waits for confirmation")
	ui.trade_confirmation.canceled.emit()
	ui.trade_confirmation.hide()
	ui._confirm_trade()
	check(player.gold == before,"cancel does not sell")
	ui._sell_item(entry.item.item_id)
	ui.trade_confirmation.confirmed.emit()
	ui.trade_confirmation.hide()
	check(ui.outcome.ok and player.gold == before+entry.price/2,"confirm sells once")
	before = player.gold
	ui._buy_item(entry.item.item_id)
	check(ui.trade_confirmation.visible and player.gold == before,"buy waits for confirmation")
	ui.trade_confirmation.confirmed.emit()
	ui.trade_confirmation.hide()
	check(ui.outcome.ok and player.gold == before-entry.price,"confirm buys once")
	var key := InputEventKey.new()
	key.keycode = KEY_CTRL
	key.pressed = true
	key.ctrl_pressed = true
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	before = player.gold
	ui._sell_item(entry.item.item_id)
	check(ui.outcome.ok and player.gold == before+entry.price/2 and not ui.trade_confirmation.visible,"Ctrl sale bypasses dialog")
	ui._buy_item(entry.item.item_id)
	check(ui.outcome.ok and player.gold == before+entry.price/2-entry.price and not ui.trade_confirmation.visible,"Ctrl purchase bypasses dialog")
	key = InputEventKey.new()
	key.keycode = KEY_CTRL
	key.pressed = false
	Input.parse_input_event(key)
	await process_frame
	var saved: Dictionary = world.save_game("res://Workshop/Rooms/Shop Sales/tests/saves/")
	var restored = Sim.new(1)
	check(saved.ok and restored.load_game(world.last_save).ok and restored.snapshot() == world.snapshot(),"stock and ownership survive save/load")
	ui.queue_free()
	await process_frame
	print("Shop Sales: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
