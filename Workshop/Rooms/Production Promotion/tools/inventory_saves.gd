extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Journal = preload("res://Production/Persistence/autosave_journal.gd")
const SOURCE: String = "res://Workshop/Rooms/World Foundation/saves/"
const REPORT: String = "res://Workshop/Rooms/Production Promotion/SAVE_INVENTORY.json"
func _initialize() -> void:
	var entries: Array[Dictionary] = []
	for directory: String in [SOURCE,SOURCE+"autosaves/"]:
		if not DirAccess.dir_exists_absolute(directory): continue
		for filename: String in DirAccess.get_files_at(directory):
			if filename.get_extension() not in ["world","journal"]: continue
			var path: String = directory.path_join(filename)
			var state = null
			var reason: String = ""
			var recovered: bool = false
			if filename.get_extension() == "journal":
				var result: Dictionary = Journal.read_snapshot(path)
				if result.ok: state = result.snapshot; recovered = result.recovered
				else: reason = result.reason
			else: state = bytes_to_var(FileAccess.get_file_as_bytes(path))
			if state is Dictionary: reason = Sim.validate_snapshot(state)
			elif reason.is_empty(): reason = "Invalid snapshot data."
			var entry: Dictionary = {"source":path,"sha256":FileAccess.get_sha256(path),"modified":FileAccess.get_modified_time(path),"valid":reason.is_empty(),"reason":reason,"recovered_tail":recovered}
			if reason.is_empty():
				entry.world_id = state.world_id
				entry.tick = state.tick
				entry.player_id = state.player_id
				entry.location = "character creation" if state.player_id == 0 else state.actors[state.player_id].map_id
			entries.append(entry)
	entries.sort_custom(func(a: Dictionary,b: Dictionary):
		if a.modified != b.modified: return a.modified > b.modified
		if a.source.get_extension() != b.source.get_extension(): return a.source.get_extension() == "journal"
		return a.source.get_file() > b.source.get_file())
	var report: Dictionary = {"user_data_directory":OS.get_user_data_dir(),"entries":entries}
	FileAccess.open(REPORT,FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("Production save inventory: ",JSON.stringify(report))
	quit()
