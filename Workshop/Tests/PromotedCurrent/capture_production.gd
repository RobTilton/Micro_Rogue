extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var entry: String = ProjectSettings.get_setting("application/run/main_scene")
	assert(entry == "res://Production/Current/ui/main.tscn")
	var game = load(entry).instantiate()
	assert(game.get_script().resource_path == "res://Production/Current/ui/workshop_game.gd")
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	game._enter_map()
	var cell := Vector2i(4,2)
	game.loot.append({"item":load("res://Production/Current/gameplay/items.gd").potion(),"pos":cell})
	game._board_intent(cell,false)
	for frame: int in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Tests/PromotedCurrent/production_tile_choices.png")
	print("Workshop/Tests/PromotedCurrent/capture_production.gd: production launch and tile menu captured")
	quit()
