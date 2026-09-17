extends "res://Workshop/Rooms/Playtest Refinement/refinement_test.gd"
func run() -> void:
	root.size = Vector2i(1280,800)
	var world := World.new()
	var map = preload("res://Production/World/cave_generator.gd").generate("global","Fog test",45)
	world.maps.maps.global = map
	var actor: Dictionary = Actors.create([3,3,3,3,3,3])
	world.add_actor(actor,"global",map.cave_layout.rooms[0].center,"player","player")
	Knowledge.observe(world,actor)
	actor.pos = map.cave_layout.rooms[1].center
	var observation: Dictionary = Knowledge.observe(world,actor)
	var board = preload("res://Production/UI/actor_view.gd").new()
	board.position = Vector2(220,0)
	board.size = Vector2(1060,800)
	board.map_data = observation.map
	board.source_map = map
	board.fog_enabled = true
	board.fog_known = observation.known
	board.fog_visible = observation.visible
	board.visible_props = observation.map.props.keys()
	board.player_cell = actor.pos
	board.interior_template = "Cave"
	root.add_child(board)
	board.zoom = 0.6
	board.focus_player()
	board.show_actors([actor],-1)
	var minimap = preload("res://Production/UI/mini_map.gd").new()
	minimap.position = Vector2(10,10)
	minimap.size = Vector2(200,160)
	minimap.fog_enabled = true
	minimap.fog_known = observation.known
	minimap.fog_visible = observation.visible
	root.add_child(minimap)
	minimap.update_map(observation.map,actor.pos,[actor])
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Playtest Refinement/fog.png")
	board.queue_free()
	minimap.queue_free()
	await process_frame
	quit()
