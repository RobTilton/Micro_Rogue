extends RefCounted
## Checksummed append-only transactions. An interrupted tail cannot replace earlier state.
const Storage = preload("res://Workshop/Rooms/Regional Foundation/Persistence/storage_paths.gd")
const DIRECTORY: String = Storage.AUTOSAVES
const MAGIC: int = 0x57464a32
const MAX_BYTES: int = 67108864
const COLLECTIONS: Array[String] = ["records","states","actors","ground","initialized","regional_hexes","regional_sources"]
var path: String = ""
var previous: Dictionary = {}
var writes: int = 0

static func digest(bytes: PackedByteArray) -> PackedByteArray:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish()

func checkpoint(snapshot: Dictionary, directory: String = DIRECTORY) -> Dictionary:
	var delta: Dictionary = {"values":{},"collections":{}}
	for key in snapshot:
		if previous.has(key) and previous[key] == snapshot[key]: continue
		if key in COLLECTIONS:
			var old: Dictionary = previous.get(key,{})
			var patch: Dictionary = {"set":{},"erase":[]}
			for id in snapshot[key]:
				if not old.has(id) or old[id] != snapshot[key][id]: patch.set[id] = snapshot[key][id]
			for id in old:
				if not snapshot[key].has(id): patch.erase.append(id)
			delta.collections[key] = patch
		else: delta.values[key] = snapshot[key]
	if delta.values.is_empty() and delta.collections.is_empty(): return {"ok":true,"changed":false,"path":path}
	var bytes: PackedByteArray = var_to_bytes(delta).compress(FileAccess.COMPRESSION_GZIP)
	if bytes.size() > MAX_BYTES: return {"ok":false,"reason":"Automatic save exceeds the supported transaction size."}
	var file: FileAccess
	if path.is_empty():
		var error: Error = DirAccess.make_dir_recursive_absolute(directory)
		if error != OK: return {"ok":false,"reason":"Automatic save folder could not be created."}
		var filename: String = "%020d_%s_%d.journal" % [int(Time.get_unix_time_from_system()*1000000),snapshot.world_id,Time.get_ticks_usec()]
		path = directory.path_join(filename)
		file = FileAccess.open(path,FileAccess.WRITE)
		if file != null: file.store_32(MAGIC)
	else:
		file = FileAccess.open(path,FileAccess.READ_WRITE)
		if file != null: file.seek_end()
	if file == null:
		path = ""
		previous = {}
		return {"ok":false,"reason":"Automatic save could not be opened."}
	file.store_32(bytes.size())
	file.store_buffer(digest(bytes))
	file.store_buffer(bytes)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		# A failed tail is retained; next attempt starts a complete new journal.
		path = ""
		previous = {}
		return {"ok":false,"reason":"Automatic save write failed; earlier checkpoints remain intact."}
	previous = snapshot
	writes += 1
	return {"ok":true,"changed":true,"path":path}

static func read_snapshot(source: String) -> Dictionary:
	var file := FileAccess.open(source,FileAccess.READ)
	if file == null or file.get_length() < 4 or file.get_32() != MAGIC: return {"ok":false,"reason":"Invalid automatic save header."}
	var state: Dictionary = {}
	var transactions: int = 0
	var incomplete: bool = false
	while file.get_position() < file.get_length():
		if file.get_length()-file.get_position() < 36: incomplete = true; break
		var length: int = file.get_32()
		var checksum: PackedByteArray = file.get_buffer(32)
		if length < 1 or length > MAX_BYTES or file.get_length()-file.get_position() < length: incomplete = true; break
		var bytes: PackedByteArray = file.get_buffer(length)
		if digest(bytes) != checksum: incomplete = true; break
		var decoded = bytes_to_var(bytes.decompress_dynamic(MAX_BYTES,FileAccess.COMPRESSION_GZIP))
		if not valid_delta(decoded): incomplete = true; break
		for key in decoded.values: state[key] = decoded.values[key]
		for key in decoded.collections:
			if not state.has(key): state[key] = {}
			for id in decoded.collections[key].erase: state[key].erase(id)
			for id in decoded.collections[key].set: state[key][id] = decoded.collections[key].set[id]
		transactions += 1
	if transactions == 0: return {"ok":false,"reason":"No complete automatic checkpoint found."}
	return {"ok":true,"snapshot":state,"recovered":incomplete,"transactions":transactions}

static func valid_delta(value) -> bool:
	if not value is Dictionary or not value.get("values") is Dictionary or not value.get("collections") is Dictionary: return false
	for key in value.values:
		if key in COLLECTIONS: return false
	for key in value.collections:
		var patch = value.collections[key]
		if key not in COLLECTIONS or not patch is Dictionary or not patch.get("set") is Dictionary or not patch.get("erase") is Array: return false
	return true
