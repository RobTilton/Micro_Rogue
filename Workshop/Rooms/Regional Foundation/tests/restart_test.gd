extends SceneTree
const World = preload("res://Workshop/Rooms/Regional Foundation/Persistence/persistent_actor_world.gd")
const Journal = preload("res://Workshop/Rooms/Regional Foundation/Persistence/autosave_journal.gd")
func _initialize() -> void:
	var path: String = FileAccess.get_file_as_string("res://Workshop/Rooms/Regional Foundation/tests/autosave_restart_path.txt")
	var world = World.new(1)
	var outcome: Dictionary = world.load_game(path)
	if not outcome.ok:
		push_error("Workshop/Rooms/Regional Foundation/tests/restart_test.gd: "+outcome.reason)
		quit(1)
		return
	var journal: Dictionary = Journal.read_snapshot(path)
	var exact: bool = world.snapshot() == journal.snapshot
	print("Fresh-process regional restart exact state: ",exact)
	quit(0 if exact else 1)
