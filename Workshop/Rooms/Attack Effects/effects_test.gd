extends "res://Workshop/Rooms/Playtest Refinement/refinement_test.gd"
const Effects = preload("res://Production/UI/attack_effects.gd")
func run() -> void:
	var world := World.new()
	var player: Dictionary = Actors.create([3,3,3,3,3,3])
	world.add_actor(player,"global",Vector2i(3,7),"player")
	var target: Dictionary = Actors.create([3,3,3,3,3,3],true)
	world.add_actor(target,"global",Vector2i(4,7),"enemy")
	world.begin_turn(player)
	target.hp = 1000
	target.max_hp = 1000
	check(world.attack(player,target.id).ok and world.attack_events.size() == 1,"legal attack emits visual event")
	if world.attack_events.is_empty(): quit(1); return
	var event: Dictionary = world.attack_events[0]
	check(event.from == player.pos and event.to == target.pos and event.category == "swords","event retains attack positions/category")
	var amount: int = world.attack_events.size()
	world.attack(player,-1)
	check(world.attack_events.size() == amount,"invalid attack has no visual")
	var hidden: Dictionary = Actors.create([3,3,3,3,3,3],true)
	world.add_actor(hidden,"global",Vector2i(30,7),"enemy")
	world.record_attack_effect(hidden,target,hidden.main,1,false)
	check(world.attack_events.size() == amount,"offscreen attacks do not produce visual information")
	var effects := Effects.new()
	var before_hp: int = target.hp
	var before_actions: Dictionary = player.actions.duplicate(true)
	effects.play(event)
	check(effects.active.size() == 1,"effect starts")
	effects._process(1.0)
	check(effects.active.is_empty() and target.hp == before_hp and player.actions == before_actions,"effect expiry cannot change damage or turns")
	for pair: Array in [["swords","slash"],["spears","stab"],["daggers","dagger"],["axes","axe"],["maces","bonk"],["bows","arrow"],["staffs","bolt"]]:
		check(Effects.style({"category":pair[0]}) == pair[1],"weapon effect mapping")
	check(Effects.style({"category":"swords","two_handed":true}) == "heavy","two handed cleave")
	check(Effects.style({"category":"swords","lunge":true}) == "stab","Lunge thrust")
	for frames: Array in Effects.FRAMES.values():
		for rect: Rect2 in frames: check(Rect2(Vector2.ZERO,Effects.SHEET.get_size()).encloses(rect),"crop inside atlas")
	effects.free()
	print("Attack Effects: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
