extends SceneTree
func _initialize() -> void:
	var scene = load("res://Workshop/Rooms/Regional Foundation/main.tscn")
	print("Regional scene loaded: ",scene != null)
	quit(0 if scene != null else 1)
