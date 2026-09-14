extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Free Exploration/tests/free_test.gd: "+message)
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
	var original_tick: int = world.tick
	var original_momentum: float = player.momentum
	for key: String in ["move","attack","activation","free"]: player.actions[key] = 0
	var shop: Dictionary = town.shops[shop_cell]
	var bought: Dictionary = shop.stock[0].item.duplicate(true)
	var price: int = shop.stock[0].price
	check(world.buy(player,shop_cell,bought.item_id).ok,"purchase without activation")
	check(player.gold == 10000-price,"gold still charged")
	var slot: String = "off" if bought.kind == "shield" else bought.get("slot","armor") if bought.kind == "armor" else "main"
	check(world.transfer(player,{"zone":"bag","id":bought.item_id},{"zone":"equipment","slot":slot}).ok,"equip without waiting")
	check(world.transfer(player,{"zone":"equipment","slot":slot,"id":bought.item_id},{"zone":"bag"}).ok,"unequip without waiting")
	check(world.buy(player,shop_cell,shop.stock[0].item.item_id).ok,"second purchase without waiting")
	check(world.tick == original_tick and player.momentum == original_momentum and world.world_hours == 0,"safe shopping advances no turns or time")
	var moved: int = 0
	for attempt: int in range(2):
		for cell: Vector2i in town.neighbors(player.pos):
			if town.walkable(cell) and world.actor_at(town.id,cell).is_empty():
				if world.move(player,cell).ok: moved += 1
				break
	check(moved == 2 and world.tick == original_tick,"repeated safe movement without turns")
	var enemy: Dictionary = Actors.create([6,6,6,6,6,6],true,rng)
	var enemy_cell: Vector2i = world.arrival_cell(town,player.pos)
	world.add_actor(enemy,town.id,enemy_cell,"enemy")
	world.refresh_action_mode(player)
	check(not player.actions.exploration and player.actions.activation == 1,"combat restores finite allowance")
	world.Combat.spend(player.actions,"activation")
	check(not world.transfer(player,{"zone":"bag","id":bought.item_id},{"zone":"equipment","slot":slot}).ok,"combat equip requires activation")
	world.refresh_action_mode(player)
	check(player.actions.activation == 0,"refresh cannot refill combat actions")
	enemy.hp = 0
	check(world.transfer(player,{"zone":"bag","id":bought.item_id},{"zone":"equipment","slot":slot}).ok,"combat ending restores free equip")
	var save: Dictionary = world.save_game("res://Workshop/Rooms/Free Exploration/tests/saves/")
	var restored = Sim.new(1)
	check(save.ok and restored.load_game(world.last_save).ok,"exploration state saves and loads")
	var game = load("res://Production/main.tscn").instantiate()
	game.simulation = world
	game.map_world = world.maps
	game.player = player
	game.selected_shop_cell = shop_cell
	for cell: Vector2i in town.neighbors(shop_cell):
		if town.walkable(cell) and world.actor_at(town.id,cell,player.id).is_empty(): player.pos = cell; break
	var panel := VBoxContainer.new()
	root.add_child(panel)
	game._shop_panel(panel)
	var tooltips: int = 0
	for child in panel.get_children():
		if child is Button and child.tooltip_text.contains("Material tier") and child.tooltip_text.contains("Price:"): tooltips += 1
	check(tooltips == shop.stock.size() and tooltips > 0,"every shop item has full inspection and price tooltip")
	game.free()
	panel.queue_free()
	print("Free Exploration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
