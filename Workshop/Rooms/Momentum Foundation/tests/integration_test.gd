extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var failures: int = 0
var checks: int = 0
const DIR = "res://Workshop/Rooms/Momentum Foundation/tests/integration_saves/"
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func _initialize() -> void: call_deferred("run")
func write_data(data: Dictionary, name: String) -> String:
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
	game.dice_slots = [0,0,0,0,0,0,4,4,6,4,4,4]
	game._start_run()
	await process_frame
	check(game.player.actions.free == 1,"DEX6 initial free action")
	check(game.simulation.turn_threshold == 3,"Production threshold3")
	var tick: int = game.simulation.tick
	var destination: Vector2i = game.simulation.paths(game.player).keys()[0]
	game._finish(game.simulation.move(game.player,destination))
	check(game.simulation.tick == tick and game.player.actions.free == 1,"normal move preserves free and tick")
	game.player.actions.activation = 0
	await game._enter_map()
	check(game.active_map.layer == "Local","free activation travels through fade")
	check(game.player.actions.free == 0 and game.simulation.tick == tick,"travel does not refill actions")
	game.simulation.set_speed_effect(game.player.id,"effect:test",0.5)
	game.simulation.adjust_momentum(game.player.id,1.25)
	game._automatic_checkpoint()
	var restored = Sim.new(1)
	check(restored.load_game(game.journal.path).ok,"journal loads")
	check(restored.snapshot() == game.simulation.snapshot(),"momentum effects budgets exact journal roundtrip")
	var baseline: Dictionary = restored.snapshot()
	var old: Dictionary = baseline.duplicate(true)
	old.erase("turn_threshold")
	for actor: Dictionary in old.actors.values():
		actor.erase("momentum"); actor.erase("speed_effects"); actor.actions.erase("free")
	check(restored.load_game(write_data(old,"legacy")).ok,"legacy current-generator save accepted")
	check(restored.turn_threshold == 3 and restored.actors[restored.player_id].momentum == 0 and restored.actors[restored.player_id].actions.free == 0,"legacy defaults")
	var before: Dictionary = restored.snapshot()
	for field: String in ["actions","momentum","speed_effects","turn_threshold"]:
		var bad: Dictionary = baseline.duplicate(true)
		if field == "turn_threshold": bad[field] = 0
		else: bad.actors[bad.player_id][field] = "invalid"
		check(not restored.load_game(write_data(bad,"invalid_"+field)).ok and restored.snapshot() == before,"atomic refusal "+field)
	game.queue_free()
	await process_frame
	print("Momentum integration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
