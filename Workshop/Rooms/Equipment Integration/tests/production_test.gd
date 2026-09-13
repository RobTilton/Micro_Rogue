extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Items = preload("res://Production/Actors/items.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const DIR = "res://Workshop/Rooms/Equipment Integration/tests/saves/"
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Equipment Integration/tests/production_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func write_save(data: Dictionary, name: String) -> String:
	var path: String = DIR+name+".save"
	FileAccess.open(path,FileAccess.WRITE).store_buffer(var_to_bytes(data))
	return path
func run() -> void:
	create_timer(90).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	game.autosave_directory = DIR+"autosaves/"
	game.snapshot_directory = DIR+"snapshots/"
	game.preferences_path = DIR+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	check(game.player.main.has("rules_version"),"Production starter uses generator")
	for slot: String in ["head","arms","legs"]:
		var item: Dictionary = Items.generate({"category":"leather_"+slot}).item
		Grid.place_auto(game.player.bag,item)
		game.simulation.begin_turn(game.player)
		game._finish(game.simulation.transfer(game.player,{"zone":"bag","id":item.item_id},{"zone":"equipment","slot":slot}),false)
		check(game.player[slot].get("item_id")==item.item_id,"Production equips "+slot)
	game.simulation.begin_turn(game.player)
	await game._enter_map()
	check(game.active_map.layer == "Local","new items survive Local entry")
	var populated: bool = false
	for link: Dictionary in game.active_map.links.values():
		if game.map_world.records[link.id].template in ["Dungeon","Tower"]:
			game.simulation.ensure_map(link)
			var ground: Array = game.simulation.ground[link.id].duplicate(true)
			check(ground.size() == 1 and ground[0].item.has("rules_version"),"new populated location has generated loose loot")
			game.simulation.ensure_map(link)
			check(game.simulation.ground[link.id] == ground,"revisit does not reroll or duplicate loot")
			populated = true
			break
	check(populated,"populated location fixture found")
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	check(restored.load_game(game.journal.path).ok,"new equipment journal loads")
	check(restored.snapshot() == game.simulation.snapshot(),"exact generated equipment roundtrip")
	var snapshot: Dictionary = restored.snapshot()
	var legacy: Dictionary = snapshot.duplicate(true)
	for actor: Dictionary in legacy.actors.values():
		for slot: String in ["head","arms","legs","grip"]: actor.erase(slot)
		actor.main = {"item_id":actor.main.item_id,"kind":"sword","name":"Common Bronze Sword","appearance":"Bronze Sword","rarity":1,"bonus":0,"die":4,"capacity":0,"contents":[]}
	check(restored.load_game(write_save(legacy,"legacy")).ok,"old actor slots and weapon representation load")
	check(restored.actors[restored.player_id].head.is_empty() and restored.actors[restored.player_id].main.die == 4,"legacy item retained, missing slots initialized")
	var before: Dictionary = restored.snapshot()
	var bad: Dictionary = snapshot.duplicate(true)
	bad.actors[bad.player_id].head.physical_defense = 999
	check(not restored.load_game(write_save(bad,"malformed")).ok and restored.snapshot()==before,"invalid equipment refuses atomically")
	game._toggle_panel("Inventory",200)
	await process_frame
	await process_frame
	check(game.current_grid != null,"expanded inventory UI builds")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Equipment Integration/tests/inventory.png")
	game.queue_free()
	await process_frame
	print("Equipment Production integration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
