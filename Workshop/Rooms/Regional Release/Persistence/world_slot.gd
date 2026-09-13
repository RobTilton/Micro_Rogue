extends RefCounted
const Journal = preload("res://Workshop/Rooms/Regional Release/Persistence/autosave_journal.gd")

static func summary(path: String) -> Dictionary:
	var data
	if path.get_extension() == "journal":
		var decoded: Dictionary = Journal.read_snapshot(path)
		if not decoded.ok: return {}
		data = decoded.snapshot
	else:
		var file := FileAccess.open(path,FileAccess.READ)
		if file == null: return {}
		data = bytes_to_var(file.get_buffer(file.get_length()))
	if not data is Dictionary or not data.get("world_id") is String or not data.get("world_seed") is int or not data.get("generator") is int: return {}
	return {"path":path,"world_id":data.world_id,"world_seed":data.world_seed,"generator":data.generator,"difficulty":data.get("difficulty",0),"player_id":data.get("player_id",0),"locations":data.get("states",{}).size(),"sources":data.get("regional_sources",{}).size()}

static func prune(keep: String, world_id: String, directories: Array[String], archive_directory: String = "") -> Dictionary:
	# A complete durable replacement is mandatory before any removal.
	var current: Dictionary = summary(keep)
	if current.is_empty() or current.world_id != world_id: return {"ok":false,"reason":"Workshop/Rooms/Regional Release/Persistence/world_slot.gd: replacement save is not complete."}
	var obsolete: Array[String] = []
	for directory: String in directories:
		if not DirAccess.dir_exists_absolute(directory): continue
		for filename: String in DirAccess.get_files_at(directory):
			var path: String = directory.path_join(filename)
			if path == keep or filename.get_extension() not in ["journal","world"]: continue
			# These are dedicated game-save directories; never remove unrelated extensions.
			obsolete.append(path)
	if not archive_directory.is_empty() and DirAccess.dir_exists_absolute(archive_directory):
		for filename: String in DirAccess.get_files_at(archive_directory):
			if filename.begins_with("world_") and filename.ends_with(".bin") and not filename.begins_with(world_id+"_"):
				obsolete.append(archive_directory.path_join(filename))
	var failures: Array[String] = []
	for path: String in obsolete:
		if DirAccess.remove_absolute(path) != OK: failures.append(path)
	return {"ok":failures.is_empty(),"removed":obsolete.size()-failures.size(),"reason":"Workshop/Rooms/Regional Release/Persistence/world_slot.gd: could not remove old saves: "+", ".join(failures) if not failures.is_empty() else ""}
