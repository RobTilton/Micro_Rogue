extends SceneTree
const Actors = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/actors.gd")
const Items = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/items.gd")
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var game = load("res://Workshop/Rooms/Actor Foundation/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	game._enter_map()
	game.player.pos = Vector2i(8,8)
	game.player.hp = 99
	game.player.max_hp = 99
	for cell: Vector2i in [Vector2i(10,8),Vector2i(9,10)]:
		game.simulation.add_actor(Actors.create([4,4,4,4,4,4],true),game.player.map_id,cell,"enemy")
	game.loot.append({"item":Items.make("armor"),"pos":Vector2i(11,9)})
	game._refresh()
	for frame: int in range(8): await process_frame
	game.board.focus_player()
	await process_frame
	await RenderingServer.frame_post_draw
	var output: String = "res://Workshop/Rooms/Actor Foundation/tests/actor_gameplay.png"
	var error: Error = root.get_texture().get_image().save_png(output)
	if error != OK:
		push_error("Workshop/Rooms/Actor Foundation/tests/capture_actors.gd: failed to save " + output)
		quit(1)
	else:
		print("Workshop/Rooms/Actor Foundation/tests/capture_actors.gd: saved " + output)
		quit()
