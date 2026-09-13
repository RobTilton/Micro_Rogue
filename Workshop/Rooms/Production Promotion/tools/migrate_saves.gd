extends SceneTree
const Migration = preload("res://Workshop/Rooms/Production Promotion/tools/save_migration.gd")
const Storage = preload("res://Production/Persistence/storage_paths.gd")
func _initialize() -> void:
	var result: Dictionary = Migration.migrate("res://Workshop/Rooms/World Foundation/saves/",Storage.ROOT)
	result.user_data_directory = OS.get_user_data_dir()
	FileAccess.open("res://Workshop/Rooms/Production Promotion/SAVE_MIGRATION.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"))
	print("Production save migration: ",JSON.stringify(result))
	quit(0 if result.ok else 1)
