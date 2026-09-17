extends SceneTree
var equipped: int = 0
var contextual: int = 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var grid = preload("res://Production/UI/inventory_grid.gd").new()
	var item: Dictionary = preload("res://Production/Actors/items.gd").make("belt")
	item.grid_pos = Vector2i.ZERO
	grid.items = [item]
	root.add_child(grid)
	var target = preload("res://Production/UI/item_target.gd").new()
	target.item = item
	target.source = {"zone":"equipment","slot":"belt","id":item.item_id}
	root.add_child(target)
	for control in [grid,target]:
		control.quick_equip.connect(func(_source: Dictionary): equipped += 1)
		control.item_context.connect(func(_source: Dictionary): contextual += 1)
		var event := InputEventMouseButton.new()
		event.pressed = true
		event.position = Vector2(5,5)
		event.button_index = MOUSE_BUTTON_LEFT
		event.shift_pressed = true
		control._gui_input(event)
		event.shift_pressed = false
		event.button_index = MOUSE_BUTTON_RIGHT
		control._gui_input(event)
	assert(equipped == 2 and contextual == 2)
	print("Bag and equipment controls emit Shift-click and right-click actions correctly.")
	quit()
