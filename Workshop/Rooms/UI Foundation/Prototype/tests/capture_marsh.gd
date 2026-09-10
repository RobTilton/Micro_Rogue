extends SceneTree
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var game = load("res://Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	for biome: String in ["Marsh"]:
		game._start_run()
		game.map_world = game.MapWorld.new(1729)
		game.active_map = game.map_world.maps.global
		var link: Dictionary = game.active_map.links[game.player.pos]
		link.biome = biome
		link.label = biome+" terrain preview"
		game._enter_map()
		for frame: int in range(5): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/terrain_"+biome.to_lower()+".png")
	quit()
