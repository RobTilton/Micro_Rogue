extends SceneTree
const Sim = preload("res://Production/Actors/actor_world.gd")
const Brain = preload("res://Production/Actors/enemy_brain.gd")
const Actor = preload("res://Production/Actors/actors.gd")
const Items = preload("res://Production/Actors/items.gd")
const Map = preload("res://Production/World/hex_map.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
var checks: int = 0
var failures: int = 0
var world: RefCounted
var brain := Brain.new()
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		push_error("Workshop/Rooms/Production Promotion/tests/actor_simulation_test.gd: " + description)
		failures += 1
func fixture() -> void:
	world.actors.clear()
	world.ground = {"arena":[],"local":[]}
	world.initialized = {"arena":true,"local":true}
	var arena = Map.new("arena","Dungeon","POI",Vector2i(18,14))
	var local = Map.new("local","Local","Local",Vector2i(30,20))
	arena.links[Vector2i(1,3)] = {"id":"local","kind":"Return","arrival":Vector2i(10,10)}
	local.links[Vector2i(10,10)] = {"id":"arena","kind":"Dungeon","parent":"local","return_cell":Vector2i(10,10)}
	world.maps.maps.arena = arena
	world.maps.maps.local = local
	world.events.clear()
func actor(cell: Vector2i, faction: String, map_id: String = "arena") -> Dictionary:
	var result: Dictionary = Actor.create([4,4,4,4,4,4],faction != "player")
	result.hp = 100
	result.max_hp = 100
	result.points = 0
	result.belt.contents = []
	world.add_actor(result,map_id,cell,faction,"player" if faction == "player" else "goblin")
	return result
func _initialize() -> void:
	world = Sim.new(1729)
	fixture()
	var p: Dictionary = actor(Vector2i(1,3),"player")
	var e: Dictionary = actor(Vector2i(4,3),"enemy")
	check(world.move(p,Vector2i(2,3)).ok,"player legal move")
	check(not world.move(p,Vector2i(3,3)).ok,"second move refused")
	check(not world.move(e,p.pos).ok,"enemy cannot overlap player")
	world.maps.maps.arena.walls.append(Vector2i(3,3))
	check(not world.can_see(p,e.pos) and not world.can_see(e,p.pos),"wall blocks both observers")
	check(world.move(e,Vector2i(4,4)).ok,"enemy legal move uses same service")
	check(not world.move(e,Vector2i(5,4)).ok,"enemy second move refused")
	check(p.actions.move == e.actions.move,"equal movement costs")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(3,3),"enemy")
	p.skills = ["Lunge","Riposte","Show-Off"]
	p.off = Items.make("sword")
	world.begin_turn(p)
	check(world.lunge(p,Vector2i(2,3)).ok,"shared Lunge moves")
	check(p.actions.move == 1 and p.actions.attack == 1,"Lunge preserves move and spends one attack")
	check(not world.travel(p).ok and not world.drink(p,123).ok,"pending Lunge blocks mutation")
	check(world.attack(p,e.id).ok and p.pending.is_empty(),"optional attack consumes pending weapon")
	check(world.attack(p,e.id).ok and p.actions.attack == 0,"Show-Off offhand attack")
	check(not world.attack(p,e.id).ok,"no third attack")
	world.begin_turn(p)
	check(not world.skill_available(p,"Lunge"),"cooldown not reset by fresh allowance")
	check(world.riposte(p).ok,"shared Riposte")
	check(p.riposte and p.clock.ticks("Riposte") == 2,"Riposte state and clock")
	check(world.attack(e,p.id).ok and not p.riposte,"one incoming attack consumes stance")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(3,3),"enemy")
	e.skills = ["Lunge","Riposte","Show-Off"]
	e.off = Items.make("sword",true)
	world.begin_turn(e)
	check(world.lunge(e,Vector2i(2,3)).ok and world.attack(e,p.id).ok,"enemy uses same Lunge")
	check(world.attack(e,p.id).ok and not world.attack(e,p.id).ok,"enemy dual wield costs")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(6,3),"enemy")
	var upgrade: Dictionary = Items.make("armor")
	upgrade.die = 100
	upgrade.bonus = 20
	world.ground.arena.append({"item":upgrade,"pos":Vector2i(7,3)})
	brain.take_turn(world,e)
	check(world.ground.arena.is_empty() and not e.bag.is_empty(),"enemy collects inspected better armor")
	check(e.armor.item_id != upgrade.item_id,"pickup does not grant free equip")
	world.begin_turn(e)
	brain.take_turn(world,e)
	check(e.armor.item_id == upgrade.item_id,"enemy equips upgrade next activation")
	check(Grid.valid(e,world.ground.arena),"equipment swap retains valid ownership")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(10,8),"enemy")
	var poor: Dictionary = Items.make("armor")
	poor.die = 0
	poor.bonus = -50
	world.ground.arena.append({"item":poor,"pos":Vector2i(15,8)})
	brain.take_turn(world,e)
	check(e.pos != Vector2i(10,8),"distant unknown item investigated without secret stats")
	check(not world.ground.arena.is_empty(),"inferior item rejected after approaching")
	check(e.known_items.get(poor.item_id,true) == false,"inspection remembers rejection")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(6,3),"enemy")
	world.maps.maps.arena.walls.append(Vector2i(7,3))
	upgrade = Items.make("armor")
	upgrade.die = 100
	world.ground.arena.append({"item":upgrade,"pos":Vector2i(8,3)})
	brain.take_turn(world,e)
	check(not e.known_items.has(upgrade.item_id),"cannot inspect through wall")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(6,3),"enemy")
	var potion: Dictionary = Items.potion()
	potion.pouch = 0
	e.belt.contents.append(potion)
	e.hp = 20
	check(world.drink(e,potion.item_id).ok and e.hp == 24 and e.actions.activation == 0,"enemy potion costs activation and heals by CON")
	check(not world.drink(e,potion.item_id).ok,"potion cannot duplicate")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(3,3),"enemy")
	var id: int = e.id
	var equipment_id: int = e.main.item_id
	var resident: Dictionary = actor(Vector2i(12,10),"enemy","local")
	check(world.travel(p).ok,"player leaves Dungeon")
	check(e.trail.size() == 1,"visible departure remembered")
	world.advance(brain)
	check(e.map_id == "local" and e.id == id and e.main.item_id == equipment_id,"same equipped actor follows exit")
	check(e.pos != p.pos and e.pos != resident.pos,"arrival avoids occupied cells")
	check(world.on_map("local").size() == 3 and world.on_map("arena").is_empty(),"pursuer coexists with resident without duplicate")
	check(e.actions.move == 0 and e.actions.activation == 0,"pursuit spends movement and travel once")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(14,10),"enemy")
	check(world.travel(p).ok and e.trail.is_empty(),"unseen exit gives no omniscient pursuit")
	world.advance(brain)
	check(e.map_id == "arena" and e.pos == Vector2i(14,10),"unaware offscreen enemy pauses")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(3,3),"enemy")
	e.hp = 0
	var possessions: int = 4
	world.resolve_death(e,p)
	world.resolve_death(e,p)
	check(world.ground.arena.size() == possessions and e.main.is_empty(),"death drops ownership exactly once")
	check(p.xp == 1,"XP awarded once")
	check(world.travel(p).ok,"leave after death")
	world.begin_turn(p)
	check(world.travel(p).ok and world.ground.arena.size() == possessions,"return does not regenerate enemy or loot")
	fixture()
	p = actor(Vector2i(1,3),"player")
	for cell: Vector2i in [Vector2i(10,10),Vector2i(11,10),Vector2i(11,9),Vector2i(10,9),Vector2i(9,10),Vector2i(9,11),Vector2i(10,11)]: actor(cell,"enemy","local")
	check(not world.travel(p).ok and p.map_id == "arena" and p.actions.activation == 1,"occupied arrival refuses without spending or overlap")
	check(not world.interact(p,{"kind":"chest"}).ok,"unimplemented objects refuse explicitly")

	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(6,3),"enemy")
	for subject: Dictionary in [p,e]:
		var item: Dictionary = Items.make("armor")
		item.die = 100
		world.ground.arena.append({"item":item,"pos":subject.pos})
		for index: int in range(40):
			var filler: Dictionary = Items.potion()
			check(Grid.place_auto(subject.bag,filler),"fill capacity fixture")
		var before_ground: Array = world.ground.arena.duplicate(true)
		var before_actions: Dictionary = subject.actions.duplicate(true)
		check(not world.interact(subject,{"kind":"pickup","item_id":item.item_id}).ok,"full inventory refuses pickup for either controller")
		check(world.ground.arena == before_ground and subject.actions == before_actions,"capacity refusal preserves ground and actions")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(5,3),"enemy")
	p.skills = ["Lunge"]
	check(not world.attack(p,e.id).ok and p.actions.attack == 1,"out of range refuses before spending")
	check(not world.lunge(p,Vector2i(-1,-1)).ok and p.clock.ready("Lunge"),"invalid skill target has no cooldown cost")
	check(world.lunge(p,Vector2i(3,3)).ok,"valid pending Lunge")
	world.cancel(p)
	check(p.pending.is_empty() and p.clock.ticks("Lunge") == 4 and p.actions.attack == 0,"cancel does not refund skill cost")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(4,3),"enemy")
	world.maps.maps.arena.walls.append(Vector2i(2,3))
	check(not world.can_see(e,p.pos),"departure occluded by wall")
	check(world.travel(p).ok and e.trail.is_empty(),"occluded exit does not reveal destination")
	fixture()
	p = actor(Vector2i(1,3),"player")
	e = actor(Vector2i(3,3),"enemy")
	e.last_seen = {"map_id":"arena","pos":Vector2i(5,3)}
	p.map_id = "local"
	p.pos = Vector2i(20,15)
	world.advance(brain)
	world.advance(brain)
	check(e.map_id == "arena" and e.last_seen.is_empty(),"lost sight searches remembered location then stops")
	print("Workshop/Rooms/Production Promotion/tests/actor_simulation_test.gd: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
