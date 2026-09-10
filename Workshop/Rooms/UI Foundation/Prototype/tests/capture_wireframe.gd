extends SceneTree
const Game = preload("res://Workshop/Rooms/UI Foundation/Prototype/ui/workshop_game.gd")
const Grid = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/grid_inventory.gd")
const Items = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/items.gd")
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var game: Control = load("res://Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,3,4,2,1,5,6]
	game._start_run()
	game.player.skills = ["Lunge","Riposte"]
	for kind: String in ["sword","shield","armor","belt"]:
		Grid.place_auto(game.player.bag,Items.make(kind))
	for index: int in range(4): Grid.place_auto(game.player.bag,Items.potion())
	game._toggle_panel("Inventory",220)
	game.inspected_belt = game.player.belt.item_id
	game._refresh()
	for frame: int in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/wireframe_inventory.png")
	game.host.close()
	game._board_intent(Vector2i(3,3),false)
	for frame: int in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/wireframe_movement.png")
	print("res://Workshop/Rooms/UI Foundation/Prototype/tests/capture_wireframe.gd: captured inventory and movement wireframes")
	quit()
