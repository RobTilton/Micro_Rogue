extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var game = load("res://Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	game._enter_map()
	game.player.pos = Vector2i(4,2)
	game._enter_map()
	game._toggle_panel("Map",70)
	for frame: int in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/map_world.png")
	quit()
