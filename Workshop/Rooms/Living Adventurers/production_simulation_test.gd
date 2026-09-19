extends SceneTree
const World = preload("res://Production/Persistence/adventurer_world.gd")
const Resolver = preload("res://Production/Actors/expedition_resolver.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Living Adventurers/simulation_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(120).timeout.connect(func(): quit(2))
	var world := World.new(152)
	var player: Dictionary = world.Actors.create([3,3,3,3,3,3])
	for slot: String in world.Grid.EQUIPMENT: player[slot] = {}
	player.gold = 50
	world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
	world.start_in_town()
	var home: String = player.map_id
	var region: String = world.region_of(player)
	check(world.residents(region).size() == 3,"three ordinary adventurers at home")
	check(world.physically_present(region) == 3,"physical population cap")
	world.seed_town(home)
	check(world.residents(region).size() == 3,"town revisits cannot duplicate population")
	check(not world.hostile(player,world.residents(region)[0]),"adventurers are friendly to player")
	var before: int = world.ledger().turn
	for step: int in range(6):
		var map = world.maps.maps[player.map_id]
		var destination: Vector2i = player.pos
		for candidate: Vector2i in map.neighbors(player.pos):
			if map.walkable(candidate) and world.actor_at(map.id,candidate,player.id).is_empty(): destination = candidate; break
		check(destination != player.pos and world.walk_step(player,destination).ok,"peaceful movement step")
		if step < 5: check(world.ledger().turn == before,"no tick before sixth step")
	check(world.ledger().turn == before+1 and world.ledger().steps == 0,"sixth step advances exactly once")
	check(world.world_hours == 0,"exploration turns do not advance calendar")
	before = world.ledger().turn
	check(not world.walk_step(player,player.pos).ok and world.ledger().turn == before,"failed movement adds no tick")
	# The same real identities progress through errands and a crier, without End Turn input.
	for index: int in range(25): world.advance(world.ai)
	var accepted: bool = false
	for quest: Dictionary in world.maps.records[home].constraints.quests.values():
		if not quest.get("accepted_by",[]).is_empty(): accepted = true
	check(accepted,"adventurer physically reaches crier and accepts a goal")
	check(World.validate_adventurers(world.snapshot()).is_empty(),"scheduled state validates")
	var saved: Dictionary = world.save_game("res://Workshop/Rooms/Living Adventurers/Tests/production_saves/")
	check(saved.ok,"save scheduler and adventurer state")
	var loaded := World.new(153)
	check(loaded.load_game(world.last_save).ok,"load scheduler and actors")
	check(loaded.ledger() == world.ledger(),"scheduler and history survive reload")
	check(loaded.actors.size() == world.actors.size(),"load does not duplicate actors")
	check(not loaded.load_game("res://Workshop/Rooms/Living Adventurers/Tests/missing.world").ok,"missing save is refused")
	# Isolate cap policy from casualties in the preceding expedition progression test.
	world = World.new(152)
	player = world.Actors.create([3,3,3,3,3,3])
	player.gold = 50
	world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
	world.start_in_town()
	home = player.map_id
	region = world.region_of(player)
	# Retirements retain actor identity, build and possessions; ordinary residents leave first.
	var original_id: int = player.id
	var original_stats: Dictionary = player.stats.duplicate()
	var retired: Dictionary = world.retire_player()
	check(retired.ok and player.id == original_id and player.stats == original_stats and player.retired,"retirement retains identity and stats")
	check(world.residents(region).size() == 3,"retirement displaces ordinary resident")
	check(player.hp > 0 and player.adventure.home == home,"new retiree keeps home slot")
	# Explicitly fill connected homes; expeditions may have opened vacancies during the earlier test.
	for town_id: String in world.connected_towns(home):
		var target_region: String = world.maps.regional_local(town_id)
		while world.residents(target_region).size() < 3:
			var npc: Dictionary = world.Actors.create([3,3,3,3,3,3],true)
			npc.gold = 50
			world.add_actor(npc,town_id,world.resident_cell(world.maps.maps[town_id]),"adventurer","player")
			npc.adventure = {"home":town_id,"goal":"","phase":"quest","born":npc.id,"retired_at":0,"visits":0,"rest_until":-1}
	# Fill all three slots with retirees, then retire a fourth; no connected vacancy -> obscurity.
	for resident: Dictionary in world.residents(region):
		resident.retired = true
		resident.adventure.retired_at = resident.id
	player.adventure.retired_at = 1
	world.ledger().retirement_order = 100
	var replacement: Dictionary = world.Actors.create([4,4,4,4,4,4])
	replacement.gold = 50
	world.add_actor(replacement,home,world.arrival_cell(world.maps.maps[home],world.maps.maps[home].spawn_cell),"player","player")
	check(world.retire_player().ok,"fourth retirement accepted")
	check(player.hp == 0 and player.adventure.phase == "obscurity","oldest retiree quietly dies when connected towns full")
	check(world.residents(region).size() == 3,"overflow preserves hard cap")
	check(not world.actors.has(player.id),"obscurity removes full actor from active registry")
	check(world.Inventory.possessions(player).is_empty(),"quiet death does not leave recoverable equipment")
	# Repeated retirement cannot increment rank or displace another resident.
	before = world.ledger().retirement_order
	check(not world.retire_player().ok and world.ledger().retirement_order == before,"retirement is one-way and idempotent")
	check(World.validate_adventurers(world.snapshot()).is_empty(),"retirement snapshot remains valid")
	print("Living Adventurers: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
