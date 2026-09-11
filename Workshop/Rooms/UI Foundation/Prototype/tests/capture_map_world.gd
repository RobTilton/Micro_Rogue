extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var game = load("res://Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	game._enter_map()
	game.player.pos = poi_cell(game.active_map,"Dungeon")
	game._enter_map()
	game._toggle_panel("Map",70)
	for frame: int in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/map_world.png")
	quit()

func poi_cell(map, kind: String) -> Vector2i:
	for cell: Vector2i in map.links:
		if map.links[cell].kind == kind: return cell
	assert(false, "Workshop/Rooms/UI Foundation/Prototype/tests/capture_map_world.gd: missing POI " + kind)
	return Vector2i(-1,-1)
