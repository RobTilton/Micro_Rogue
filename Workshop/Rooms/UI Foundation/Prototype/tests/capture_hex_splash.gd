extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	root.add_child(load("res://Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn").instantiate())
	for frame: int in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/hex_splash.png")
	quit()
