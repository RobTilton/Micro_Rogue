extends SceneTree
const World = preload("res://Workshop/Rooms/Living Adventurers/adventurer_world.gd")
const Resolve = preload("res://Workshop/Rooms/Living Adventurers/expedition_resolver.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Living Adventurers/expedition_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(120).timeout.connect(func(): quit(2))
	var world := World.new(152)
	var player: Dictionary = world.Actors.create([3,3,3,3,3,3])
	player.gold = 50
	world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
	world.start_in_town()
	var home: String = player.map_id
	var local: String = world.region_of(player)
	var id: String = local+"/adventure_test_cave"
	world.maps.declare(id,local,"Cave","Test cave",{"return_cell":Vector2i(5,5)})
	var map = world.ensure_map({"id":id})
	var adventurer: Dictionary = world.residents(local)[0]
	adventurer.map_id = id
	adventurer.pos = world.arrival_cell(map,map.spawn_cell)
	adventurer.adventure.goal = id
	adventurer.adventure.phase = "explore"
	for stat: String in world.Actors.STATS: adventurer.stats[stat] = 100
	adventurer.max_hp = 300
	adventurer.hp = 300
	var initial: int = world.foes_in(id).size()
	check(initial > 2,"real POI population exists")
	var next_item: int = world.Items.next_item_id
	Resolve.resolve(world,adventurer,false)
	check(world.foes_in(id).size() == initial-1,"near simulation resolves only one fight")
	check(adventurer.hp == 300,"zero incoming damage cannot invent wounds")
	world.ledger().turn += 1
	Resolve.resolve(world,adventurer,true)
	check(world.foes_in(id).is_empty(),"distant expedition removes actual defeated enemies")
	check(adventurer.adventure.phase == "return","completed expedition returns home")
	check(world.Items.next_item_id == next_item,"expedition does not fabricate loot identities")
	check(not adventurer.bag.is_empty(),"victor collects actual equipment and supplies")
	check(World.validate_workshop(world.snapshot()).is_empty(),"expedition keeps valid world and unique item ownership")
	# Player arriving at the POI disables probability resolution immediately.
	var foe: Dictionary = world.Actors.create([1,1000,1,1,1,1],true)
	for slot: String in world.Grid.EQUIPMENT: foe[slot] = {}
	foe.gold = 1
	foe.max_hp = 1000
	foe.hp = 1000
	world.add_actor(foe,id,world.arrival_cell(map,Vector2i(10,10)),"enemy","goblin") if map.walkable(Vector2i(10,10)) and world.arrival_cell(map,Vector2i(10,10)) != Vector2i(-1,-1) else world.add_actor(foe,id,world.resident_cell(map),"enemy","goblin")
	player.map_id = id
	player.pos = world.arrival_cell(map,map.spawn_cell)
	var before: int = foe.hp
	Resolve.resolve(world,adventurer,true)
	check(foe.hp == before and adventurer.hp == 300,"loaded-map guard refuses abstract combat")
	player.map_id = home
	player.pos = world.arrival_cell(world.maps.maps[home],world.maps.maps[home].spawn_cell)
	# Stalemate neither kills nor advances a counterfeit victory.
	adventurer.stats.STR = 1
	for slot: String in world.Grid.EQUIPMENT: adventurer[slot] = {}
	foe.stats.CON = 1000
	adventurer.adventure.phase = "explore"
	Resolve.resolve(world,adventurer,false)
	check(adventurer.hp > 0 and foe.hp == before and adventurer.adventure.phase == "return","flat-defense stalemate retreats")
	# Dangerous fight can kill an adventurer, preserving their real possessions.
	foe.stats.CON = 1
	adventurer.stats.STR = 5
	adventurer.stats.CON = 1
	adventurer.hp = 1
	adventurer.max_hp = 3
	adventurer.bag = []
	var treasure: Dictionary = world.Items.ration()
	world.Grid.place_auto(adventurer.bag,treasure)
	adventurer.adventure.phase = "explore"
	for attempt: int in range(10):
		if adventurer.hp <= 0: break
		world.ledger().turn += 1
		Resolve.resolve(world,adventurer,false)
	check(adventurer.hp == 0 and adventurer.dropped,"adventurer death persists")
	var found: bool = false
	for prop: Dictionary in map.props.values():
		for item: Dictionary in prop.contents:
			if item.item_id == treasure.item_id: found = true
	for entry: Dictionary in world.ground[id]:
		if entry.item.item_id == treasure.item_id: found = true
	check(found,"dead adventurer's actual possession remains recoverable")
	var saved: Dictionary = world.save_game("res://Workshop/Rooms/Living Adventurers/Tests/expeditions/")
	check(saved.ok,"death and expedition results save")
	var restored := World.new(154)
	check(restored.load_game(world.last_save).ok,"death and expedition results reload")
	check(restored.actors[adventurer.id].hp == 0 and restored.actors[foe.id].hp == foe.hp,"loading preserves outcome instead of rerolling")
	# A connected town with a vacancy receives a displaced resident.
	var towns: Array = world.connected_towns(home)
	check(not towns.is_empty(),"starter trade route supplies a connected town")
	var target: String = towns[0]
	var target_region: String = world.maps.regional_local(target)
	var outgoing: Dictionary = world.residents(target_region)[0]
	outgoing.hp = 0
	var migrant: Dictionary = world.residents(local)[0]
	var identity: int = migrant.id
	world.displace(migrant)
	check(migrant.hp > 0 and migrant.id == identity and migrant.adventure.home == target,"migration preserves identity and uses connected vacancy")
	check(world.residents(target_region).size() == 3,"migration cannot exceed destination cap")
	var hour: int = world.world_hours
	check(not world.journey_ready(migrant,"test-edge") and world.world_hours == hour,"NPC travel schedules without moving player time")
	world.world_hours += 5
	check(not world.journey_ready(migrant,"test-edge"),"NPC crossing waits full six hours")
	world.world_hours += 1
	check(world.journey_ready(migrant,"test-edge"),"NPC crossing ready after six hours")
	print("Adventurer expeditions: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
