extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Clock = preload("res://Production/World/world_clock.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("Workshop/Rooms/World Time and Frontier/tests/frontier_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(150).timeout.connect(func(): quit(2))
	check(Clock.label(0) == "Month_01.day_01.1 · Morning","calendar start")
	check(Clock.parts(24*30).month == 2 and Clock.parts(24*30).day == 1,"30-day month")
	check(Clock.parts(24*360).year == 2 and Clock.parts(23).block == 4,"360-day year and four-block clock")
	for block: int in range(4):
		check(Clock.parts(block*6).block == block+1 and Clock.parts(block*6).period == ["Morning","Noon","Evening","Midnight"][block],"block order")
	check(Clock.parts(24).day == 2 and Clock.parts(24).block == 1,"Midnight rolls to next Morning")
	var game = load("res://Production/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/World Time and Frontier/tests/saves/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	var world = game.simulation
	var player: Dictionary = game.player
	check(player.gold == 50,"new character starts with 50 gold")
	var town_id: String = player.map_id
	var rules: Dictionary = world.maps.records.global.constraints
	var route: Array = rules.starter_route
	check(route.size() >= 3 and rules.route_towns.size() == 2,"two towns and starter route")
	for id: String in rules.route_towns: check(world.initialized.has(id) and world.maps.records[id].label != "Town","town exists and is named")
	var tutorial: Dictionary = world.maps.records[town_id].constraints.quests[rules.route_poi]
	check(tutorial.skill_reward == 1 and tutorial.tutorial,"route tutorial reward")
	var stat_before: int = player.stats.CON
	check(world.spend_stat(player,"CON").ok and player.stats.CON == stat_before+1 and player.points == 0,"player buys +1 stat")
	check(not world.spend_stat(player,"CON").ok,"stat purchase needs point")
	player.map_id = "global"
	player.pos = route[0]
	world.begin_turn(player)
	check(not world.move(player,route.back()).ok and world.world_hours == 0,"no multi-hex global travel")
	check(not world.lunge(player,route[1]).ok and not world.retreat(player,route[1]).ok and world.world_hours == 0,"combat moves cannot bypass travel rules")
	for path: Array in world.paths(player).values(): check(path.size() == 1,"global paths have one crossing")
	for index: int in range(4):
		world.begin_turn(player)
		check(world.move(player,route[1] if index%2 == 0 else route[0]).ok,"trade route step")
	check(world.world_hours == 24,"four crossings equal one day")
	var rng := RandomNumberGenerator.new()
	rng.seed = 883
	var global_map = world.maps.maps.global
	var aging: Dictionary = world._monster([3,3,3,3,3,3],rng,global_map,false)
	aging.can_use_skills = true
	world.add_actor(aging,"global",route.back(),"enemy")
	var initial_level: int = aging.level
	world.advance_hours(24)
	check(aging.level == initial_level and aging.age_fifths == 1,"daily 0.2 level stored exactly")
	world.advance_hours(96)
	check(aging.level == initial_level+1 and aging.age_fifths == 0,"five days grants one level")
	player.level += 10
	world._scale_monsters()
	check(aging.level == initial_level+1,"no player-level reclamp")
	var town = world.maps.maps[town_id]
	var old_stock: Array = []
	for shop: Dictionary in town.shops.values():
		for entry: Dictionary in shop.stock: old_stock.append(entry.item.item_id)
	world.advance_hours(24)
	check(world.world_hours == 168,"one week")
	for shop: Dictionary in town.shops.values():
		for entry: Dictionary in shop.stock: check(entry.item.item_id not in old_stock,"weekly stock refresh")
	var local_id: String = world.maps.records[town_id].parent
	var arena_id: String = local_id+"/conflict_fixture"
	world.maps.declare(arena_id,local_id,"Encounter","Conflict fixture",{"return_cell":Vector2i(20,20),"biome":"Plains"})
	var arena = world.ensure_map({"id":arena_id})
	var a: Dictionary = world._monster([6,6,6,6,6,6],rng,arena,false)
	var b: Dictionary = world._monster([1,1,1,1,1,1],rng,arena,false)
	a.family = "wolves"
	a.can_use_skills = false
	b.family = "raiders"
	world.add_actor(a,arena_id,Vector2i(4,6),"enemy")
	world.add_actor(b,arena_id,Vector2i(8,6),"enemy")
	check(world.hostile(a,b),"different families hostile")
	var saved: Dictionary = world.save_game(directory+"determinism/")
	check(saved.ok,"pre-conflict save")
	var clone = Sim.new(1)
	check(clone.load_game(saved.path).ok,"pre-conflict load")
	world.advance_hours(24)
	clone.advance_hours(24)
	check(world.snapshot() == clone.snapshot(),"deterministic offscreen fights and aging")
	check((a.hp <= 0) != (b.hp <= 0),"offscreen hostile pair resolves one death")
	var winner: Dictionary = b if a.hp <= 0 else a
	check(winner.xp > 0,"offscreen winner earns kill XP")
	if a.hp > 0: check(a.points == 0 and not a.get("stat_training",{}).is_empty(),"skill-less monster spends stat points")
	# Generate and clear the tutorial target without waiting for another day.
	var target = world.ensure_map({"id":rules.route_poi})
	var boss: Dictionary = world.actors[world.maps.records[target.id].constraints.boss_id]
	var source_before: int = world._hostility(target)
	boss.hp = 0
	world.resolve_death(boss,player)
	check(world._hostility(target) < source_before,"boss removal reduces hostility immediately")
	player.map_id = town_id
	player.pos = Vector2i(1,3)
	var points_before: int = player.points
	var prosperity_before: int = town.shops.values()[0].prosperity
	check(world.quest_action(player,target.id).ok and player.points == points_before+1,"tutorial grants one skill point")
	check(town.shops.values()[0].prosperity == prosperity_before+1,"tutorial raises prosperity")
	check(not world.quest_action(player,target.id).ok and player.points == points_before+1,"tutorial reward once")
	# Find a mutually dry boundary and cross through its matching opposite edge.
	var local = world.ensure_map({"id":local_id})
	check(local.props.size() >= 3,"local chests")
	player.map_id = local.id
	var chosen: int = -1
	var neighbor_id: String = ""
	for boundary: Dictionary in world.maps.records[local.id].constraints.boundaries:
		var candidates: Array = world.Entry.candidates(local,boundary.direction)
		if candidates.is_empty(): continue
		var neighbor = world.ensure_map(global_map.links[boundary.neighbor])
		if world.Entry.arrival(world,neighbor,(boundary.direction+3)%6) == Vector2i(-1,-1): continue
		player.pos = candidates[0]
		chosen = boundary.direction
		neighbor_id = neighbor.id
		break
	check(chosen >= 0,"dry crossing fixture")
	var hours_before: int = world.world_hours
	world.begin_turn(player)
	check(not world.cross_border(player,99).ok and world.world_hours == hours_before,"invalid crossing costs no time")
	check(world.cross_border(player,chosen).ok and player.map_id == neighbor_id and world.world_hours == hours_before+6,"local border costs exactly six hours")
	var neighbor = world.maps.maps[player.map_id]
	check(player.pos in world.Contracts.boundary_cells(neighbor,(chosen+3)%6,true) and world.Entry.dry(neighbor,player.pos),"opposite dry-edge arrival")
	# Move next to an existing scout to trigger a persistent arena.
	var foe: Dictionary = {}
	for actor: Dictionary in world.on_map(neighbor.id):
		if actor.faction == "enemy": foe = actor; break
	check(not foe.is_empty(),"local scout fixture")
	if not foe.is_empty():
		for cell: Vector2i in neighbor.neighbors(foe.pos):
			if world.Entry.dry(neighbor,cell) and world.actor_at(neighbor.id,cell).is_empty(): player.pos = cell; break
		var original: Vector2i = player.pos
		world._maybe_encounter()
		check(world.maps.records[player.map_id].template == "Encounter" and foe.map_id == player.map_id,"scout pulls player into arena without cloning")
		var battle_map = world.maps.maps[player.map_id]
		check(battle_map.hex_radius == 6 and battle_map.cells().size() == 127,"hex outdoor arena")
		world.begin_turn(player)
		check(world.travel(player).ok and player.map_id == neighbor.id and player.pos == original,"arena exit returns to exact encounter cell")
	var shore = load("res://Production/World/outdoor_arena.gd").generate("shore","shore","Lakes")
	check(shore.water_cells.is_empty() and shore.biomes[shore.spawn_cell] == "Plains","lake encounter has dry shoreline combat space")
	player.map_id = "global"
	player.pos = route[0]
	var event_destination := Vector2i(-1,-1)
	for cell: Vector2i in global_map.neighbors(player.pos):
		if global_map.walkable(cell) and world.actor_at("global",cell).is_empty() and not world._global_step_allowed(player.pos,cell): event_destination = cell; break
	check(event_destination != Vector2i(-1,-1),"event travel fixture")
	hours_before = world.world_hours
	check(world.register_event_step(player.pos,event_destination,"test-event").ok,"register event crossing")
	world.begin_turn(player)
	check(world.move(player,event_destination).ok and world.world_hours == hours_before+6,"event crossing costs six hours")
	check(not world._global_step_allowed(route[0],event_destination),"event permit consumed once")
	game._sync()
	game._arena_ui()
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	var loaded: Dictionary = restored.load_game(game.journal.path)
	print("Frontier save: ",loaded," validation: ",Sim.validate_snapshot(world.snapshot()))
	check(loaded.ok and restored.snapshot() == world.snapshot(),"calendar routes quests growth encounters exact save")
	if DisplayServer.get_name() != "headless":
		player.map_id = "global"
		player.pos = route[0]
		game._sync()
		game._arena_ui()
		await process_frame
		game.board.focus_player()
		game._toggle_panel("Quests",180)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/World Time and Frontier/tests/frontier_gameplay.png")
	game.queue_free()
	await process_frame
	print("Frontier: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
