extends SceneTree
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Items = preload("res://Production/Actors/items.gd")
var game: Control
var failures: int = 0
func verify(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("res://Workshop/Rooms/Production Promotion/tests/drag_input_test.gd: " + message)
func _initialize() -> void:
	call_deferred("run")
func click(point: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	Input.parse_input_event(event)
func motion(point: Vector2, relative: Vector2, held: bool = true) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.relative = relative
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	Input.parse_input_event(event)
func run() -> void:
	root.size = Vector2i(1440,900)
	game = load("res://Workshop/Rooms/Production Promotion/tests/ui_fixture.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,3,4,2,1,5,6]
	game._start_run()
	# These UI regressions retain their original open-arena fixture.
	game.active_map = null
	game._spawn_enemy()
	game.player.belt.contents = []
	var potion: Dictionary = Items.potion()
	Grid.place_auto(game.player.bag,potion)
	game._toggle_panel("Inventory",180)
	for frame: int in range(5): await process_frame
	var start: Vector2 = game.current_grid.global_position + Vector2(25,25)
	motion(start,Vector2.ZERO,false)
	click(start,true)
	motion(start+Vector2(24,12),Vector2(24,12))
	await process_frame
	verify(root.gui_is_dragging(),"Native mouse gesture starts item drag")
	verify(game.hud.belt_section.visible,"Native potion drag reveals targets")
	verify(game.player.bag.size() == 1,"Drag start leaves item at source")
	for frame: int in range(3): await process_frame
	var destination: Vector2 = game.hud.slots.get_child(0).get_global_rect().get_center()
	motion(destination,destination-start)
	await process_frame
	click(destination,false)
	for frame: int in range(5): await process_frame
	verify(game.player.bag.is_empty() and game.player.belt.contents.size() == 1,"Native drop commits potion into belt")
	verify(game.actions.activation == 0,"Native drop spends exactly one activation")
	# Drag a sword and rotate it with an actual R event before dropping.
	game.battle = false
	var sword: Dictionary = Items.make("sword")
	Grid.place_auto(game.player.bag,sword)
	game._refresh()
	for frame: int in range(4): await process_frame
	start = game.current_grid.global_position+Vector2(25,25)
	motion(start,Vector2.ZERO,false)
	click(start,true)
	motion(start+Vector2(24,12),Vector2(24,12))
	await process_frame
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_R
	key.pressed = true
	Input.parse_input_event(key)
	await process_frame
	verify(not game.drag.payload.is_empty() and game.drag.payload.rotated,"R rotates drag payload")
	destination = game.current_grid.global_position+Vector2(3*52+10,2*52+10)
	motion(destination,destination-start)
	await process_frame
	click(destination,false)
	for frame: int in range(5): await process_frame
	verify(game.player.bag[0].rotated and game.player.bag[0].grid_pos == Vector2i(3,2),"Native rotated drop respects target cell")
	verify(Grid.valid(game.player,game.loot),"Native UI preserves inventory invariants")
	game.queue_free()
	await process_frame
	print("res://Workshop/Rooms/Production Promotion/tests/drag_input_test.gd: 8 input checks, %d failures" % failures)
	quit(1 if failures else 0)
