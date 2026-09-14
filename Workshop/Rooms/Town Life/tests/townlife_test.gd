extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("Workshop/Rooms/Town Life/tests/townlife_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(120).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/Town Life/tests/saves/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	var world = game.simulation
	var player: Dictionary = game.player
	var town = game.active_map
	check(world.maps.records[town.id].template == "Town" and town.title != "Town","named town startup")
	check(player.gold == 100 and world.Inventory.possessions(player).is_empty(),"empty equipped start with 100 gold")
	check(world.on_map(town.id).size() == 4,"three NPCs plus player")
	check(world.hostiles(player).is_empty() and not world.engaged(player),"peaceful town")
	check(Sim.validate_snapshot(world.snapshot()).is_empty(),"valid named regional state")
	player.pos = Vector2i(1,3)
	var quests: Dictionary = world.town_quests(player)
	check(quests.size() == 3,"three nearby POI bounties")
	var target_id: String = quests.keys()[0]
	check(world.quest_action(player,target_id).ok,"accept bounty at crier")
	var record: Dictionary = world.maps.records[target_id]
	var dungeon = world.ensure_map({"id":target_id})
	var boss: Dictionary = world.actors[record.constraints.boss_id]
	check(boss.boss,"persistent target boss")
	for index: int in range(6): check(boss.stats[world.Actors.STATS[index]] == roundi((boss.base_roll[index]+boss.level-1)*1.25),"25 percent base-stat bonus")
	var hostility: int = world._hostility(dungeon)
	check(boss.gold >= hostility+1 and boss.gold <= hostility*3+1,"monster gold bounds")
	for actor: Dictionary in world.on_map(dungeon.id): check(absi(actor.level-player.level) <= 2,"monster level band")
	for prop: Dictionary in dungeon.props.values():
		if prop.kind == "chest": check(prop.gold in [3*hostility,6*hostility,9*hostility],"chest gold formula")
	player.level += 4
	var alive_hp: float = boss.hp
	world._scale_monsters()
	for actor: Dictionary in world.on_map(dungeon.id): check(absi(actor.level-player.level) <= 2,"existing monster level band")
	var coins: int = boss.gold
	boss.hp = 0
	world.resolve_death(boss,player)
	check(dungeon.props.has(boss.pos) and dungeon.props[boss.pos].gold == coins,"corpse holds monster gold")
	player.map_id = dungeon.id
	player.pos = boss.pos
	world.begin_turn(player)
	var before: int = player.gold
	check(world.interact(player,{"kind":"search","cell":boss.pos}).ok and player.gold == before+coins,"search transfers gold")
	world.begin_turn(player)
	check(not world.interact(player,{"kind":"search","cell":boss.pos}).ok and player.gold == before+coins,"no repeated corpse gold")
	player.map_id = town.id
	player.pos = Vector2i(1,3)
	var reward: int = quests[target_id].reward
	before = player.gold
	check(world.quest_action(player,target_id).ok and player.gold == before+reward,"claim boss reward")
	check(not world.quest_action(player,target_id).ok and player.gold == before+reward,"reward only once")
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	var loaded: Dictionary = restored.load_game(game.journal.path)
	print("Town life load: ",loaded," validation: ",Sim.validate_snapshot(world.snapshot()))
	check(loaded.ok and restored.snapshot() == world.snapshot(),"quests NPCs bosses and gold exact save roundtrip")
	game._refresh()
	game._toggle_panel("Activate",280)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Town Life/tests/townlife_gameplay.png")
	game.queue_free()
	await process_frame
	print("Town life: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
