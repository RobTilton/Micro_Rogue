extends SceneTree
const Sim = preload("res://Workshop/Rooms/World Foundation/domain/persistent_actor_world.gd")
const Actors = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/actors.gd")
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var game = load("res://Workshop/Rooms/World Foundation/main.tscn").instantiate()
	game.autosave_directory = "res://Workshop/Rooms/World Foundation/tests/saves/autosaves/"
	root.add_child(game)
	game.simulation = Sim.new(1729)
	game.map_world = game.simulation.maps
	game.player = Actors.create([4,4,4,4,4,4])
	game.simulation.add_actor(game.player,"global",game.map_world.maps.global.spawn_cell,"player","player")
	game.cooldowns = game.player.clock
	game._sync()
	game._arena_ui()
	await game._enter_map()
	for frame: int in range(8): await process_frame
	game.board.focus_player()
	await RenderingServer.frame_post_draw
	var error: Error = root.get_texture().get_image().save_png("res://Workshop/Rooms/World Foundation/tests/local_gameplay.png")
	for kind: String in ["Town","Well","Underground"]:
		for cell: Vector2i in game.active_map.links:
			if game.active_map.links[cell].kind == kind: game.player.pos = cell; break
		await game._enter_map()
	for frame: int in range(8): await process_frame
	game.board.focus_player()
	await RenderingServer.frame_post_draw
	error = error | root.get_texture().get_image().save_png("res://Workshop/Rooms/World Foundation/tests/underground_gameplay.png")
	print("World capture result: ",error)
	quit(0 if error == OK else 1)
