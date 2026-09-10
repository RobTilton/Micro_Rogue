extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	root.size = Vector2i(900,600)
	var board = load("res://Workshop/Rooms/UI Foundation/Prototype/ui/world_view.gd").new()
	board.size = Vector2(900,600)
	root.add_child(board)
	assert(board.floor_texture != null, "Prototype/tests/capture_floor_patch.gd: floor texture missing")
	for frame: int in range(4): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/floor_patch_02.png")
	print("Prototype/tests/capture_floor_patch.gd: captured joined floor patch")
	quit()
