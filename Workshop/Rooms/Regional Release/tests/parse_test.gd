extends SceneTree
func _initialize() -> void:
	var scene = load("res://Workshop/Rooms/Regional Release/main.tscn")
	var instance = scene.instantiate()
	root.add_child.call_deferred(instance)
	create_timer(1.0).timeout.connect(func(): quit())
