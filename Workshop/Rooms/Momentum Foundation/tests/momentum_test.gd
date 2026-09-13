extends SceneTree
const Sim = preload("res://Production/Actors/actor_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Combat = preload("res://Production/Actors/combat.gd")
const Momentum = preload("res://Production/Actors/momentum.gd")
const Map = preload("res://Production/World/hex_map.gd")
const Brain = preload("res://Production/Actors/enemy_brain.gd")
const Items = preload("res://Production/Actors/items.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; push_error("Workshop/Rooms/Momentum Foundation/tests/momentum_test.gd: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var sim = Sim.new(1729)
	var map = Map.new("arena","Arena","POI",Vector2i(20,20))
	sim.maps.maps.arena = map
	var player: Dictionary = Actors.create([4,4,6,4,4,4])
	sim.add_actor(player,"arena",Vector2i(4,4),"player")
	check(sim.turn_threshold == 3 and Combat.remaining(player.actions) == 0,"threshold 3; no unearned spawn actions")
	sim.begin_turn(player)
	check(player.actions.attack == 1 and player.actions.move == 1 and player.actions.activation == 1 and player.actions.free == 1,"speed 6 = base + one free")
	player.stats.DEX = 1; player.momentum = 0.0
	for index: int in range(3):
		sim.begin_turn(player)
		check((Combat.remaining(player.actions) > 0) == (index == 2),"slow actor carries remainder")
	check(player.momentum == 0.0,"exact threshold consumed")
	player.stats.DEX = 4; player.momentum = 0.0
	for index: int in range(3):
		sim.begin_turn(player)
		check(player.actions.free == (1 if index == 2 else 0),"speed 4 periodic extra grant")
	check(sim.set_speed_effect(player.id,"test_boots",2.5).ok and Momentum.speed(player) == 6.5,"DEX plus source-keyed effects")
	player.momentum = 0.0; sim.begin_turn(player)
	check(player.actions.free == 1 and player.momentum == 0.5,"fractional carry")
	check(sim.set_speed_effect(player.id,"test_boots",0).ok and Momentum.speed(player) == 4.0,"remove effect by source")
	sim.adjust_momentum(player.id,2.5)
	check(player.momentum == 3.0,"external momentum adjustment retained until tick")
	player.stats.DEX = 3; player.momentum = 0.0; sim.begin_turn(player)
	player.actions.free = 3
	var first: Dictionary = sim.move(player,Vector2i(5,4))
	check(first.ok and player.actions.move == 0 and player.actions.free == 3,"normal movement spent first")
	check(sim.move(player,Vector2i(6,4)).ok and player.actions.free == 2,"free movement")
	var enemy: Dictionary = Actors.create([1,1,3,1,1,1],true)
	enemy.hp = 1000; enemy.max_hp = 1000
	sim.add_actor(enemy,"arena",Vector2i(7,4),"enemy")
	check(sim.attack(player,enemy.id).ok and player.actions.free == 2,"normal attack spent first")
	check(sim.attack(player,enemy.id).ok and player.actions.free == 1,"free attack uses main weapon after normal attack")
	var potion: Dictionary = Items.potion(); potion.pouch = 0; player.belt.contents = [potion]
	player.actions.activation = 0
	check(sim.drink(player,potion.item_id).ok and player.actions.free == 0,"free activation")
	var before: Dictionary = player.actions.duplicate()
	check(not sim.move(player,Vector2i(8,8)).ok and player.actions == before,"no budget refuses atomically")
	player.skills = ["Lunge"]; player.actions.free = 2
	check(sim.lunge(player,Vector2i(6,5)).ok,"free action can pay skill attack")
	sim.cancel(player)
	check(not sim.lunge(player,Vector2i(6,6)).ok and player.actions.free == 1,"free action cannot bypass cooldown")
	# Inventory preview and invalid transfer never spend the flexible budget.
	var sword: Dictionary = Items.make("sword")
	sim.ground.arena.append({"item":sword,"pos":player.pos})
	player.actions = {"move":0,"attack":0,"activation":0,"free":2,"used_attacks":1}
	var source: Dictionary = {"zone":"ground","id":sword.item_id}
	check(sim.transfer(player,source,{"zone":"pickup"},true).ok and player.actions.free == 2,"pickup preview preserves free actions")
	check(sim.transfer(player,source,{"zone":"pickup"}).ok and player.actions.free == 1,"free pickup")
	check(sim.transfer(player,{"zone":"bag","id":sword.item_id},{"zone":"equipment","slot":"main"}).ok and player.actions.free == 0,"free equipment activation")
	# NPC policy must use more than the old hardcoded three attacks.
	enemy.stats.DEX = 18; enemy.momentum = 0; enemy.main.die = 1; enemy.main.bonus = 0
	player.hp = 10000; player.max_hp = 10000; player.pos = Vector2i(6,4)
	sim.begin_turn(enemy)
	var initial_free: int = enemy.actions.free
	Brain.new().take_turn(sim,enemy)
	check(initial_free == 5 and enemy.actions.free == 0 and enemy.actions.attack == 0,"NPC uses all flexible attack grants")
	# Waiting advances slow player's meter, and credits inactive living actors too.
	player.stats.DEX = 1; player.momentum = 0; player.speed_effects = {}; player.clock.remaining.clear()
	enemy.hp = 0
	var remote: Dictionary = Actors.create([4,4,2,4,4,4],true)
	sim.add_actor(remote,"global",sim.maps.maps.global.spawn_cell,"enemy")
	var old_tick: int = sim.tick
	sim.advance_to_player(Brain.new())
	check(sim.tick-old_tick == 3 and Combat.remaining(player.actions) == 3,"slow player gets a usable turn after three world ticks")
	check(remote.momentum == 0.0 and remote.actions.move == 1,"offscreen living actor receives momentum without banking turns")
	sim.set_speed_effect(player.id,"immobilize",-100)
	old_tick = sim.tick; sim.advance_to_player(Brain.new())
	check(sim.tick == old_tick+1 and Combat.remaining(player.actions) == 0,"zero speed returns control without infinite loop")
	print("Momentum/actions: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
