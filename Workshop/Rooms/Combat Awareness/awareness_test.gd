extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
class TestWorld extends "res://Production/Actors/actor_world.gd":
	var visible: Array[Vector2i] = []
	func _make_maps(_seed: int) -> RefCounted: return RefCounted.new()
	func can_see(actor: Dictionary, cell: Vector2i) -> bool:
		return actor.id != player_id or cell in visible
var checks: int = 0
func check(value: bool) -> void:
	checks += 1
	assert(value,"Workshop/Rooms/Combat Awareness/awareness_test.gd: check failed")
func _initialize() -> void:
	var world := TestWorld.new()
	var player: Dictionary = {"id":1,"map_id":"poi","faction":"player","pos":Vector2i.ZERO,"hp":10}
	var a: Dictionary = {"id":2,"name":"Raider","family":"raiders","faction":"enemy","map_id":"poi","pos":Vector2i(10,10),"hp":10,"trail":[]}
	var b: Dictionary = {"id":3,"name":"Goblin","family":"goblins","faction":"enemy","map_id":"poi","pos":Vector2i(11,10),"hp":10,"trail":[]}
	var c: Dictionary = a.duplicate(true)
	c.id = 4
	world.actors = {1:player,2:a,3:b,4:c}
	world.player_id = 1
	for i: int in range(100): world.report_combat(a,b,"Raider hits Goblin for 99.")
	world.finish_hearing()
	check(world.events == ["You hear fighting in the distance."])
	world.report_combat(c,b,"Secret damage 70")
	a.hp = 0
	world.finish_hearing()
	check(world.events.size() == 1)
	world.report_observed(a,"Raider dies with secret loot")
	check(world.events.size() == 1)
	b.hp = 0
	world.finish_hearing()
	world.finish_hearing()
	check(world.events == ["You hear fighting in the distance.","The distant fighting falls silent."])
	world.events.clear()
	a.hp = 10
	b.hp = 10
	world.visible = [a.pos,b.pos]
	world.report_combat(a,b,"Visible damage 7")
	check(world.events == ["Visible damage 7"])
	world.visible.clear()
	world.report_combat(a,player,"Player takes 4")
	check(world.events.back() == "Player takes 4")
	world.events.clear()
	a.map_id = "elsewhere"
	world.report_combat(a,b,"Other map damage")
	world.report_observed(a,"Other map potion")
	check(world.events.is_empty())
	a.map_id = "poi"
	world.report_combat(a,b,"hidden")
	player.map_id = "town"
	world.finish_hearing()
	check(not world.hearing_fighting and world.distant_pairs.is_empty())
	check(world.hostile(a,b))
	a.faction_id = "alliance"
	b.faction_id = "alliance"
	check(not world.hostile(a,b))
	check(world.hostile(a,player))
	for seed_value: int in range(50):
		var families: Dictionary = Sim.room_families(seed_value)
		check(families == Sim.room_families(seed_value) and families.primary != families.rival)
	print("Combat Awareness: %d checks passed; 100 hidden hits become one sound, final silence waits for all tracked fights." % checks)
	quit()
