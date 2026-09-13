extends SceneTree
const Migration = preload("res://Workshop/Rooms/Production Promotion/tools/save_migration.gd")
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Journal = preload("res://Production/Persistence/autosave_journal.gd")
const Actors = preload("res://Production/Actors/actors.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Production Promotion/tests/migration_test.gd: "+message)
func _initialize() -> void:
	var root_path: String = "res://Workshop/Rooms/Production Promotion/tests/saves/migration_%d/" % Time.get_ticks_usec()
	var source: String = root_path+"source/"
	var target: String = root_path+"target/"
	DirAccess.make_dir_recursive_absolute(source)
	var legacy: String = ""
	for filename: String in DirAccess.get_files_at("res://Workshop/Rooms/World Foundation/tests/saves/"):
		if filename.get_extension() != "world": continue
		var path: String = "res://Workshop/Rooms/World Foundation/tests/saves/"+filename
		var data = bytes_to_var(FileAccess.get_file_as_bytes(path))
		if data is Dictionary and data.get("generator") == 1:
			legacy = path
			break
	check(not legacy.is_empty(),"actual legacy snapshot fixture found")
	DirAccess.copy_absolute(legacy,source+"legacy.world")
	var preserved_fixture: String = "res://Workshop/Rooms/Production Promotion/tests/saves/legacy_fixture.world"
	if not FileAccess.file_exists(preserved_fixture): DirAccess.copy_absolute(legacy,preserved_fixture)
	var sim = Sim.new(993)
	var player: Dictionary = Actors.create([4,4,4,4,4,4])
	sim.add_actor(player,"global",sim.maps.maps.global.spawn_cell,"player","player")
	var journal = Journal.new()
	check(journal.checkpoint(sim.snapshot(),source+"autosaves/").ok,"current journal fixture created")
	player.hp -= 1
	check(journal.checkpoint(sim.snapshot()).ok,"journal fixture includes subsequent progress")
	var original_hash: String = FileAccess.get_sha256(journal.path)
	var outcome: Dictionary = Migration.migrate(source,target)
	check(outcome.ok and outcome.copied.size() == 2,"both legacy snapshot and journal imported")
	check(not outcome.active.is_empty(),"latest progress activated")
	var restored = Sim.new(1)
	check(restored.load_game(outcome.active).ok,"Production loads migrated progress")
	check(restored.snapshot() == sim.snapshot(),"world identity, geography, actors, inventory and counters unchanged")
	check(FileAccess.get_sha256(journal.path) == original_hash and FileAccess.file_exists(legacy),"original source files untouched")
	for entry: Dictionary in outcome.copied: check(FileAccess.get_sha256(entry.destination) == entry.sha256,"retained copy checksum")
	var again: Dictionary = Migration.migrate(source,target)
	check(again.ok and again.active.is_empty() and again.kept_existing_production_progress,"repeat migration does not roll back Production progress")
	check(Migration.migrate(root_path+"empty/",root_path+"unused/").ok,"absent user saves handled without invented worlds")
	print("Production migration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
