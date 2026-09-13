extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Journal = preload("res://Production/Persistence/autosave_journal.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Production Promotion/tests/autosave_restart_test.gd: "+message)
func _initialize() -> void:
	var path: String = FileAccess.get_file_as_string("res://Workshop/Rooms/Production Promotion/tests/autosave_restart_path.txt")
	var world = Sim.new(1)
	check(world.load_game(path).ok,"separate process restores automatic journal")
	check(world.player_id > 0 and world.actors[world.player_id].map_id != "global","automatically restored nested position")
	var record_count: int = world.maps.records.size()
	var snapshot: Dictionary = world.snapshot()
	var journal = Journal.new()
	check(journal.checkpoint(snapshot,"res://Workshop/Rooms/Production Promotion/tests/saves/autosave_validation/").ok,"resume starts a durable new journal")
	world.begin_turn(world.actors[world.player_id])
	world.tick += 1
	check(journal.checkpoint(world.snapshot(journal.previous)).ok,"resumed world records another change")
	var restored = Sim.new(2)
	check(restored.load_game(journal.path).ok and restored.maps.records.size() == record_count and restored.tick == world.tick,"resumed journal remains self-contained")
	# Existing schema-one manual snapshots retain their resolved Global terrain.
	var old_path: String = ""
	for filename: String in DirAccess.get_files_at("res://Workshop/Rooms/Production Promotion/tests/saves/"):
		if filename.get_extension() != "world": continue
		var candidate: String = "res://Workshop/Rooms/Production Promotion/tests/saves/"+filename
		var file := FileAccess.open(candidate,FileAccess.READ)
		var value = bytes_to_var(file.get_buffer(file.get_length()))
		if value is Dictionary and value.get("generator") == 1:
			old_path = candidate
			check(restored.load_game(old_path).ok,"previous generator save still loads")
			check(restored.maps.read_state("global").biomes == value.states.global.biomes,"old Global layout is not regenerated")
			break
	check(not old_path.is_empty(),"legacy snapshot fixture exercised")
	print("Autosave restart/compatibility: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
