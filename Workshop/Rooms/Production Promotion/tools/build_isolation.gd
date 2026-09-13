extends SceneTree
const ROOM: String = "res://Workshop/Rooms/Production Promotion/"
func _initialize() -> void:
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(ROOM+"PROMOTION.json"))
	var files: Dictionary = {}
	for entry: Dictionary in manifest.files:
		var path: String = "res://"+entry.destination
		files[path] = path
		if path.ends_with(".png"):
			files[path+".import"] = path+".import"
			var config := ConfigFile.new()
			assert(config.load(path+".import") == OK,"Workshop/Rooms/Production Promotion/tools/build_isolation.gd: texture import unavailable")
			var imported: String = config.get_value("remap","path")
			files[imported] = imported
	files["res://Production/Persistence/storage_paths.gd"] = "res://Production/Persistence/storage_paths.gd"
	files["res://isolation_test.gd"] = ROOM+"tests/isolation_test.gd"
	var settings: String = FileAccess.get_file_as_string("res://project.godot")
	settings = settings.replace('config/name="Micro Rogue"','config/name="Micro Rogue Promotion Isolation"')
	var pattern := RegEx.new()
	pattern.compile('run/main_scene="[^"]+"')
	settings = pattern.sub(settings,'run/main_scene="res://Production/main.tscn"')
	FileAccess.open(ROOM+"tests/isolation.cfg",FileAccess.WRITE).store_string(settings)
	files["res://project.godot"] = ROOM+"tests/isolation.cfg"
	var packer := PCKPacker.new()
	assert(packer.pck_start(ROOM+"tests/production_isolation.pck") == OK,"Workshop/Rooms/Production Promotion/tools/build_isolation.gd: pack creation failed")
	for destination: String in files:
		assert(packer.add_file(destination,files[destination]) == OK,"Workshop/Rooms/Production Promotion/tools/build_isolation.gd: pack input failed: "+destination)
	assert(packer.flush() == OK,"Workshop/Rooms/Production Promotion/tools/build_isolation.gd: pack flush failed")
	print("Isolated package built with %d entries; no Workshop or earlier Production runtime files included." % files.size())
	quit()
