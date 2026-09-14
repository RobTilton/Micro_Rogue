extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("Workshop/Rooms/Living Frontier/tests/living_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var world = Sim.new(5100)
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	var player: Dictionary = Actors.create([6,6,6,6,6,6],true,rng)
	world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
	world.start_in_town()
	var town = world.maps.maps[player.map_id]
	var local_id: String = world.maps.records[player.map_id].parent
	var inn_cell := Vector2i.ZERO
	for cell: Vector2i in town.shops:
		if town.shops[cell].id == "inn": inn_cell = cell
	for cell: Vector2i in town.neighbors(inn_cell):
		if town.walkable(cell) and world.actor_at(town.id,cell).is_empty(): player.pos = cell; break
	world.begin_turn(player)
	player.gold = 0
	player.hp = 1
	check(not world.rest_at_inn(player,inn_cell).ok and world.world_hours == 0 and player.hp == 1,"unpaid rest changes nothing")
	player.gold = 2
	check(world.rest_at_inn(player,inn_cell).ok,"paid rest")
	check(player.gold == 1 and player.hp == mini(player.max_hp,13) and world.world_hours == 6,"one gold, 2 CON healing, one six-hour block")
	world.begin_turn(player)
	player.hp = player.max_hp-1
	check(world.rest_at_inn(player,inn_cell).ok and player.hp == player.max_hp,"healing capped at max HP")
	var target_id: String = world.maps.records.global.constraints.route_poi
	var destination: Dictionary = world.quest_destination(player,target_id)
	check(destination.cell == world.maps.records[world.maps.records[target_id].parent].constraints.global_cell,"quest resolves global target")
	check(not destination.arrow.is_empty() and not destination.biome.is_empty(),"quest direction and terrain")
	var local = world.maps.maps[local_id]
	var props_before: Dictionary = local.props.duplicate(true)
	for enemy: Dictionary in world._local_survivors(local_id): enemy.hp = 0
	world.world_hours = 167
	world.advance_hours(1)
	check(world.world_hours == 168 and world._local_survivors(local_id).size() == 3,"weekly boundary repopulates cleared Local")
	check(local.props == props_before,"weekly spawn does not refill loot")
	var ids: Array = world._local_survivors(local_id).map(func(a: Dictionary): return a.id)
	world._repopulate_week(1)
	check(world._local_survivors(local_id).map(func(a: Dictionary): return a.id) == ids,"same week cannot duplicate population")
	# A living encounter actor keeps the region uncleared even with no Local residents.
	var encounter_id: String = local_id+"/encounter_test"
	world.maps.declare(encounter_id,local_id,"Encounter","Test encounter",{"return_cell":local.spawn_cell,"biome":"Plains"})
	var encounter = world.ensure_map({"id":encounter_id})
	for id: int in ids: world.actors[id].hp = 0
	var survivor: Dictionary = world.actors[ids[0]]
	survivor.hp = survivor.max_hp
	survivor.map_id = encounter_id
	survivor.pos = encounter.spawn_cell
	world._repopulate_week(2)
	check(world._local_survivors(local_id).size() == 1,"arena survivor blocks weekly refill")
	survivor.map_id = local_id
	survivor.pos = world.arrival_cell(local,local.spawn_cell)
	var poi_id: String = ""
	for child: String in world.maps.records[local_id].children:
		if world.maps.records[child].template == "Cave": poi_id = child; break
	var poi = world.ensure_map({"id":poi_id})
	for actor: Dictionary in world.on_map(poi_id): actor.hp = 0
	var old_props: Dictionary = poi.props.duplicate(true)
	var old_boss: int = world.maps.records[poi_id].constraints.boss_id
	var old_bag: Array = survivor.bag.duplicate(true)
	var count: int = world.actors.size()
	world._settle_month(1)
	check(survivor.map_id == poi_id and survivor.bag == old_bag and world.actors.size() == count,"monthly migration preserves actor identity and gear")
	check(poi.props == old_props and world.maps.records[poi_id].constraints.boss_id == old_boss,"occupation preserves loot and old quest boss")
	world._settle_month(1)
	check(world.actors.size() == count,"same month is idempotent")
	# Actual month boundary invokes migration; an occupied POI retains its current settler.
	var migrant: Dictionary = world.actors[ids[1]]
	migrant.hp = migrant.max_hp
	migrant.map_id = local_id
	migrant.pos = world.arrival_cell(local,local.spawn_cell)
	var second_id: String = ""
	for child: String in world.maps.records[local_id].children:
		if world.maps.records[child].template == "Dungeon": second_id = child; break
	world.ensure_map({"id":second_id})
	for actor: Dictionary in world.on_map(second_id): actor.hp = 0
	world.world_hours = 1439
	world.advance_hours(1)
	check(migrant.map_id == second_id and survivor.map_id == poi_id,"month boundary migrates into next cleared POI without replacing occupants")
	count = world.actors.size()
	var corrupted: Dictionary = world.snapshot()
	corrupted.records[local_id].constraints.population_week = "invalid"
	check(not Sim.validate_snapshot(corrupted).is_empty(),"invalid population marker refused")
	var saved: Dictionary = world.save_game("res://Workshop/Rooms/Living Frontier/tests/saves/")
	check(saved.ok,"save new population state")
	var restored = Sim.new(1)
	check(restored.load_game(world.last_save).ok and restored.snapshot() == world.snapshot(),"exact recovery of rest and population markers")
	restored._repopulate_week(2)
	restored._settle_month(1)
	check(restored.actors.size() == count,"reload cannot repeat timed population")
	# Draw the production quest card in a real renderer when available.
	if DisplayServer.get_name() != "headless":
		var panel := VBoxContainer.new()
		root.add_child(panel)
		var tile = preload("res://Production/UI/quest_hex.gd").new()
		tile.biome = destination.biome
		panel.add_child(tile)
		var label := Label.new()
		label.text = destination.arrow+" "+str(destination.cell)+" "+destination.biome
		panel.add_child(label)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Living Frontier/tests/quest_hex.png")
	print("Living Frontier: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
