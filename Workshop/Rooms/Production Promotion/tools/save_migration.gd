extends RefCounted
## One-time migration tooling. This file is deliberately outside Production.
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Journal = preload("res://Production/Persistence/autosave_journal.gd")

static func read(path: String) -> Dictionary:
	var data
	if path.get_extension() == "journal":
		var decoded: Dictionary = Journal.read_snapshot(path)
		if not decoded.ok: return decoded
		data = decoded.snapshot
	else: data = bytes_to_var(FileAccess.get_file_as_bytes(path))
	if not data is Dictionary: return {"ok":false,"reason":"Invalid snapshot."}
	var reason: String = Sim.validate_snapshot(data)
	return {"ok":reason.is_empty(),"reason":reason,"snapshot":data}

static func migrate(source_root: String, target_root: String) -> Dictionary:
	var planned: Array[Dictionary] = []
	var rejected: Array[Dictionary] = []
	for directory: String in [source_root,source_root.path_join("autosaves/")]:
		if not DirAccess.dir_exists_absolute(directory): continue
		for name: String in DirAccess.get_files_at(directory):
			if name.get_extension() not in ["world","journal"]: continue
			var path: String = directory.path_join(name)
			var hash: String = FileAccess.get_sha256(path)
			var loaded: Dictionary = read(path)
			if FileAccess.get_sha256(path) != hash: return {"ok":false,"reason":"A source save changed during validation; retry after its current action."}
			if not loaded.ok:
				rejected.append({"source":path,"reason":loaded.reason})
				continue
			var destination: String = target_root.path_join("imports/"+hash+"_"+name)
			if FileAccess.file_exists(destination) and FileAccess.get_sha256(destination) != hash: return {"ok":false,"reason":"Import destination collision; nothing copied."}
			planned.append({"source":path,"destination":destination,"sha256":hash,"modified":FileAccess.get_modified_time(path),"snapshot":loaded.snapshot})
	planned.sort_custom(func(a: Dictionary,b: Dictionary):
		if a.modified != b.modified: return a.modified > b.modified
		if a.source.get_extension() != b.source.get_extension(): return a.source.get_extension() == "journal"
		return a.source.get_file() > b.source.get_file())
	if planned.is_empty(): return {"ok":true,"copied":[],"rejected":rejected,"active":"","reason":"No complete user saves available to migrate."}
	for entry: Dictionary in planned:
		if FileAccess.get_sha256(entry.source) != entry.sha256: return {"ok":false,"reason":"A source save changed before migration; retry after its current action."}
	var imports: String = target_root.path_join("imports/")
	if DirAccess.make_dir_recursive_absolute(imports) != OK: return {"ok":false,"reason":"Unable to create import folder."}
	var copied: Array[Dictionary] = []
	for entry: Dictionary in planned:
		if not FileAccess.file_exists(entry.destination):
			var error: Error = DirAccess.copy_absolute(ProjectSettings.globalize_path(entry.source),ProjectSettings.globalize_path(entry.destination))
			if error != OK: return {"ok":false,"reason":"Copy failed; sources and earlier copies preserved.","copied":copied}
		if FileAccess.get_sha256(entry.destination) != entry.sha256: return {"ok":false,"reason":"Copy checksum mismatch; sources preserved.","copied":copied}
		copied.append({"source":entry.source,"destination":entry.destination,"sha256":entry.sha256,"world_id":entry.snapshot.world_id})
	# Never make an old import supersede already active Production progress.
	var active_exists: bool = false
	for directory: String in [target_root.path_join("autosaves/"),target_root.path_join("snapshots/")]:
		if not DirAccess.dir_exists_absolute(directory): continue
		for name: String in DirAccess.get_files_at(directory):
			if name.get_extension() in ["world","journal"]: active_exists = true
	var active: String = ""
	if not active_exists:
		var journal = Journal.new()
		var outcome: Dictionary = journal.checkpoint(planned[0].snapshot,target_root.path_join("autosaves/"))
		if not outcome.ok: return {"ok":false,"reason":outcome.reason,"copied":copied}
		active = outcome.path
		var restored: Dictionary = Journal.read_snapshot(active)
		if not restored.ok or restored.snapshot != planned[0].snapshot: return {"ok":false,"reason":"Activated checkpoint did not match source.","copied":copied}
	return {"ok":true,"copied":copied,"rejected":rejected,"active":active,"selected_source":planned[0].source,"kept_existing_production_progress":active_exists}
