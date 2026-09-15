extends SceneTree
func _initialize() -> void:
	ProjectSettings.set_setting("debug/gdscript/warnings/integer_division",2)
	var script = load("res://Production/UI/world_game.gd")
	if script == null or not script.can_instantiate():
		push_error("Workshop/Rooms/Warning Cleanup/warning_audit.gd: runtime scripts failed strict integer-division validation")
		quit(1)
		return
	print("Runtime scripts loaded with integer-division warnings treated as errors.")
	quit()
