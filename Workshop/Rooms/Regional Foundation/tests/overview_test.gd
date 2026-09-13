extends SceneTree
const World = preload("res://Workshop/Rooms/Regional Foundation/Persistence/persistent_actor_world.gd")
const View = preload("res://Workshop/Rooms/Regional Foundation/UI/world_view.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(40.0).timeout.connect(func(): quit(2))
	var world = World.new(1729)
	var global_map = world.maps.maps.global
	var local = world.maps.ensure_location(global_map.links[global_map.spawn_cell].id)
	var board = View.new()
	board.map_data = local
	board.player_cell = local.spawn_cell
	board.enemy_alive = false
	board.size = Vector2(root.size)/0.3
	board.scale = Vector2(0.3,0.3)
	root.add_child(board)
	for frame: int in range(4): await process_frame
	board.focus_player()
	await RenderingServer.frame_post_draw
	var error: Error = root.get_texture().get_image().save_png("res://Workshop/Rooms/Regional Foundation/tests/local_overview.png")
	print("Hex overview render: ",error)
	board.queue_free()
	await process_frame
	quit(0 if error == OK else 1)
