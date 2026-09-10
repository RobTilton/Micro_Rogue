extends SceneTree
var checks: int = 0
var failures: int = 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("res://Workshop/Rooms/UI Foundation/Prototype/tests/floating_panels_test.gd: " + message)
func _initialize() -> void:
	call_deferred("run")
func mouse_button(point: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	Input.parse_input_event(event)
func motion(point: Vector2, relative: Vector2, held: bool) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.relative = relative
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	Input.parse_input_event(event)
func run() -> void:
	root.size = Vector2i(1440,900)
	var game: Control = load("res://Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,3,4,2,1,5,6]
	game._start_run()
	# These UI regressions retain their original open-arena fixture.
	game.active_map = null
	game._spawn_enemy()
	game._toggle_panel("Character",180)
	for frame: int in range(5): await process_frame
	var host: Control = game.host
	var before: Vector2 = host.panel.position
	var actor_before: Dictionary = game.player.duplicate(true)
	var actions_before: Dictionary = game.actions.duplicate(true)
	var start: Vector2 = host.title.get_global_rect().get_center()
	motion(start,Vector2.ZERO,false)
	mouse_button(start,true)
	await process_frame
	check(host.dragging,"Title press starts drag")
	var movement: Vector2 = Vector2(160,30)
	motion(start+movement,movement,true)
	await process_frame
	check(host.panel.position.is_equal_approx(before+movement),"Mouse moves panel by intended offset")
	mouse_button(start+movement,false)
	await process_frame
	check(not host.dragging,"Release ends drag")
	check(game.player == actor_before and game.actions == actions_before,"Panel dragging does not affect gameplay")
	var remembered: Vector2 = host.panel.position
	host.close()
	game._toggle_panel("Character",400)
	await process_frame
	check(host.panel.position.is_equal_approx(remembered),"Reopening remembers position independently of rail anchor")
	game._toggle_panel("Inventory",200)
	await process_frame
	check(not host.panel.position.is_equal_approx(remembered),"Different panel keeps independent placement")
	game._toggle_panel("Character",180)
	host.panel.position = Vector2(host._limits().x-5,host._limits().y-5)
	host._finish_drag()
	check(host.placements.Character.dock_x == 1 and host.placements.Character.dock_y == 1,"Bottom-right edge docking")
	check(host.panel.position.is_equal_approx(host._limits()),"Snap lands on edge margin")
	var old_host_size: Vector2 = host.size
	host.size = old_host_size-Vector2(50,20)
	host._layout()
	check(host.panel.position.is_equal_approx(host._limits()),"Dock follows viewport resize")
	host.size = old_host_size
	host.panel.position = Vector2(-100,-100)
	host._finish_drag()
	check(host.panel.position == Vector2(8,8),"Cannot lose window outside viewport")
	check(host.placements.Character.dock_x == -1 and host.placements.Character.dock_y == -1,"Top-left edge docking")
	host.panel.position = Vector2(100,90)
	host._finish_drag()
	check(host.placements.Character.dock_x == 0 and host.placements.Character.dock_y == 0,"Moving away undocks")
	host.close()
	check(not host.panel.visible and not host.dragging,"Close stops dragging and hides panel")
	game._spawn_enemy()
	game._toggle_panel("Character",400)
	await process_frame
	check(game.host.panel.position.is_equal_approx(Vector2(100,90)),"Placement survives the next encounter")
	game.queue_free()
	await process_frame
	print("res://Workshop/Rooms/UI Foundation/Prototype/tests/floating_panels_test.gd: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
