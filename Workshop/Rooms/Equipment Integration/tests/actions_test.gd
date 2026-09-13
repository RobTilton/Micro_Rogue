extends SceneTree
const Sim = preload("res://Production/Actors/actor_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Items = preload("res://Production/Actors/items.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Rules = preload("res://Production/Actors/equipment_rules.gd")
const Map = preload("res://Production/World/hex_map.gd")
var failures: int = 0
var checks: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Equipment Integration/tests/actions_test.gd: "+message)
func _initialize() -> void:
	var world = Sim.new(1)
	var map = Map.new("arena","Arena","POI",Vector2i(20,20))
	world.maps.maps.arena = map
	var actor: Dictionary = Actors.create([6,6,6,6,6,6])
	var enemy: Dictionary = Actors.create([6,6,6,6,6,6])
	world.add_actor(actor,"arena",Vector2i(4,4),"player")
	world.add_actor(enemy,"arena",Vector2i(8,4),"enemy")
	world.begin_turn(actor)
	var maul: Dictionary = Items.generate({"base_id":"maces_8"}).item
	Grid.place_auto(actor.bag,maul)
	var shield_id: int = actor.off.item_id
	check(world.transfer(actor,{"zone":"bag","id":maul.item_id},{"zone":"equipment","slot":"main"},true).ok and actor.off.item_id == shield_id,"two hand preview atomic")
	check(world.transfer(actor,{"zone":"bag","id":maul.item_id},{"zone":"equipment","slot":"main"}).ok and actor.off.is_empty(),"two hand equip stows shield")
	check(not world.transfer(actor,{"zone":"bag","id":shield_id},{"zone":"equipment","slot":"off"}).ok,"cannot equip shield alongside maul")
	world.begin_turn(actor)
	for slot: String in ["head","arms","legs"]:
		var armor: Dictionary = Items.generate({"category":"cloth_"+slot}).item
		Grid.place_auto(actor.bag,armor)
		world.begin_turn(actor)
		check(world.transfer(actor,{"zone":"bag","id":armor.item_id},{"zone":"equipment","slot":slot}).ok,"equip "+slot)
	actor.main = Items.generate({"base_id":"bows_1"}).item
	world.begin_turn(actor)
	check(world.attack(actor,enemy.id).ok,"bow attack at four hexes")
	actor.main = Items.generate({"base_id":"staffs_4"}).item
	world.begin_turn(actor)
	check(world.attack(actor,enemy.id).ok,"staff attack at four hexes")
	world.begin_turn(actor)
	map.walls.append(Vector2i(6,4))
	var blocked_actions: Dictionary = actor.actions.duplicate()
	check(not world.attack(actor,enemy.id).ok and actor.actions == blocked_actions,"terrain blocks ranged attack without cost")
	map.walls.clear()
	enemy.pos = Vector2i(10,4)
	world.begin_turn(actor)
	var before: Dictionary = actor.actions.duplicate()
	check(not world.attack(actor,enemy.id).ok and actor.actions == before,"range refusal spends nothing")
	actor.main = Items.generate({"base_id":"swords_3"}).item
	actor.grip = "one"
	check(world.change_grip(actor).ok and Rules.hands(actor,actor.main)==2,"grip change shared action")
	enemy.head = Items.generate({"category":"plate_head"}).item
	var id: int = enemy.head.item_id
	enemy.hp = 0
	world.resolve_death(enemy,actor)
	var found: bool = false
	for entry: Dictionary in world.ground.arena:
		if entry.item.item_id == id: found = true
	check(found and enemy.head.is_empty(),"enemy drops actual accessory")
	print("Equipment actions: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
