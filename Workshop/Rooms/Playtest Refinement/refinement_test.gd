extends SceneTree
const Sight = preload("res://Production/Actors/perception.gd")
const Knowledge = preload("res://Production/Actors/map_knowledge.gd")
const Map = preload("res://Production/World/hex_map.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Items = preload("res://Production/Actors/items.gd")
const Rules = preload("res://Production/Actors/equipment_rules.gd")
class Maps extends RefCounted:
	var maps: Dictionary = {}
class World extends "res://Production/Actors/actor_world.gd":
	func _make_maps(_seed: int) -> RefCounted:
		var data := Maps.new()
		data.maps.global = Map.new("global","Test","POI",Vector2i(40,20))
		return data
class QuestMaps extends RefCounted:
	var records: Dictionary = {}
class QuestUI extends "res://Production/UI/actor_game.gd":
	func _quest_direction(_parent: Node, _target_id: String) -> void: pass
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Playtest Refinement/refinement_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var world := World.new()
	var map = world.maps.maps.global
	var player: Dictionary = Actors.create([3,3,3,3,3,3])
	world.add_actor(player,"global",Vector2i(2,7),"player")
	var monster: Dictionary = Actors.create([3,3,3,3,3,3],true)
	world.add_actor(monster,"global",Vector2i(12,7),"enemy")
	for wisdom: int in range(0,11):
		player.stats.WIS = wisdom
		check(Sight.radius(player) == 7+floori(wisdom/2.0),"WIS increments sight every two points")
	world.set_sight_effect(player,"test",2)
	check(Sight.radius(player) == 14,"named sight modifier")
	world.set_sight_effect(player,"test",0)
	check(Sight.radius(player) == 12,"effect removal")
	player.stats.WIS = 20
	player.stats.DEX = 10
	monster.stats.WIS = 0
	monster.sight_base = 3
	check(world.can_see(player,monster.pos) and not world.engaged(player),"longer player sight permits avoiding unseen detection")
	var result: Dictionary = world.move(player,Vector2i(10,7))
	check(result.ok and player.pos == Vector2i(9,7),"movement truncates at detection boundary")
	check(world.engaged(player) and not player.actions.exploration and player.actions.move == 0,"detection charges combat move immediately")
	player.pos = Vector2i(2,7)
	player.skills.append("Lunge")
	world.refresh_action_mode(player)
	var lunged: Dictionary = world.lunge(player,Vector2i(10,7))
	check(lunged.ok and player.pos == Vector2i(9,7) and player.actions.attack == 0 and not player.actions.exploration,"Lunge cannot bypass detection or pay a free attack")
	world.cancel(player)
	map.walls = [Vector2i(10,7)]
	check(not world.can_see(monster,player.pos),"walls block detection")
	map.walls = []
	monster.pos = Vector2i(30,7)
	player.pos = Vector2i(2,7)
	player.stats.WIS = 0
	var chest := Vector2i(3,7)
	map.props[chest] = {"kind":"chest","name":"Chest","opened":false,"contents":[]}
	var first: Dictionary = Knowledge.observe(world,player)
	check(first.known.has(chest) and not first.known.has(Vector2i(39,19)),"only visible map cells discovered")
	check(not first.map.props[chest].has("contents"),"memory has no hidden chest inventory")
	player.pos = Vector2i(25,7)
	map.props[chest].opened = true
	var second: Dictionary = Knowledge.observe(world,player)
	check(not second.visible.has(chest) and not second.map.props[chest].opened,"offscreen chest remains remembered closed")
	var saved: Dictionary = bytes_to_var(var_to_bytes(world.discovered_maps))
	world.discovered_maps = saved
	var next: Dictionary = Actors.create([3,3,3,3,3,3])
	world.add_actor(next,"global",Vector2i(25,8),"player")
	check(Knowledge.observe(world,next).known.has(chest),"replacement character keeps discovery")
	next.pos = chest
	check(Knowledge.observe(world,next).map.props[chest].opened,"return updates remembered chest")
	var state: Dictionary = preload("res://Production/Persistence/map_state.gd").capture(map)
	check(Knowledge.valid(world.discovered_maps,{"global":state}),"discovery save validates")
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var sword: Dictionary = Items.generate({"base_id":"swords_1"},rng).item
	next.stats.STR = 3
	next.stats.DEX = 99
	check(Rules.stat_bonus(next,sword) == 3,"physical one hand uses only STR")
	sword.hands = "two"
	check(Rules.stat_bonus(next,sword) == 4,"two handed melee rounds 1.5 STR down")
	sword.category = "bows"
	check(Rules.stat_bonus(next,sword) == 3,"bows use STR without two hand multiplier")
	sword.category = "staffs"
	check(Rules.stat_bonus(next,sword) == next.stats.INT,"staffs use INT")
	var counts: Dictionary = {}
	for roll_value: int in range(1,1001):
		var id: String = Items.generator.quality_at(roll_value).id
		counts[id] = counts.get(id,0)+1
	check(counts.touched_by_the_gods == 1,"God-Touched is exactly 0.1 percent")
	var old: Dictionary = Items.generate({"base_id":"swords_1"},rng).item
	old.quality.weight = 40
	check(Items.valid_generated(old),"legacy quality weights do not invalidate owned gear")
	var potions: int = 0
	for index: int in range(100):
		if Items.loot({"max_material_tier":3},rng).item.kind == "potion": potions += 1
	check(potions > 5 and potions < 40,"random loot includes health potions")
	check(preload("res://Production/Actors/item_inspection.gd").tooltip(old).contains("Baseline cost:"),"shared tooltips include gold")
	# Isolated idle monster should advance toward a visible frontier after three world rounds.
	world.actors.erase(player.id)
	world.actors.erase(next.id)
	monster.pos = Vector2i(15,7)
	monster.bag = []
	monster.points = 0
	monster.sight_base = 3
	var start: Vector2i = monster.pos
	var brain = preload("res://Production/Actors/enemy_brain.gd").new()
	for tick_value: int in range(1,4):
		world.tick = tick_value
		world.begin_turn(monster)
		brain.take_turn(world,monster)
		if tick_value < 3: check(monster.pos == start,"idle exploration waits three rounds")
	check(monster.pos != start,"idle monster explores a frontier")
	var dungeon = preload("res://Production/World/dense_room_generator.gd").generate("dungeon","Dungeon",76)
	preload("res://Production/World/interior_props.gd").populate(dungeon,dungeon.room_layout,"Dungeon")
	check(preload("res://Production/Persistence/map_state.gd").valid(preload("res://Production/Persistence/map_state.gd").capture(dungeon)),"room roles and concentrated loot validate")
	check(dungeon.props.size() < dungeon.room_layout.rooms.size()*2,"room containers reduced from two or three per room")
	var boss_containers: int = 0
	for room: Dictionary in dungeon.room_layout.rooms:
		if room.get("loot_role","") != "boss": continue
		for prop: Dictionary in dungeon.props.values():
			if prop.room_id == room.id: boss_containers += 1
	check(boss_containers == 3,"boss room retains three loot opportunities")
	var ui := QuestUI.new()
	ui.simulation = world
	ui.map_world = QuestMaps.new()
	ui.map_world.records = {"town":{"label":"Town","constraints":{"quests":{
		"one":{"title":"Available bounty","status":"available","target":"target","reward":1},
		"two":{"title":"Accepted bounty","status":"accepted","target":"target","reward":1},
		"three":{"title":"Finished bounty","status":"rewarded","target":"target","reward":1}}}},"target":{"constraints":{}}}
	var panel := VBoxContainer.new()
	root.add_child(panel)
	ui._quests_panel(panel)
	check(has_text(panel,"Accepted bounty") and not has_text(panel,"Available bounty") and not has_text(panel,"Finished bounty"),"quest sidebar contains accepted quests only")
	panel.free()
	ui.free()
	print("Playtest Refinement: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)

func has_text(node: Node, wanted: String) -> bool:
	if node is Label and node.text == wanted: return true
	for child: Node in node.get_children():
		if has_text(child,wanted): return true
	return false
