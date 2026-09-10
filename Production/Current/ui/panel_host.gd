extends Control
signal closed
const Parts = preload("res://Production/Current/ui/ui_parts.gd")
const DEFAULT_SIZE: Vector2 = Vector2(550,460)
const PANEL_SIZES: Dictionary = {"Tile":Vector2(390,350),"Look":Vector2(520,480),"Character":Vector2(390,430),"Inventory":Vector2(670,570),"Skills":Vector2(540,410),"Logs":Vector2(620,460),"Options":Vector2(430,350),"Activate":Vector2(430,480)}
const EDGE_MARGIN: float = 8.0
const SNAP_DISTANCE: float = 20.0
var placements: Dictionary = {}
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var panel: PanelContainer
var content: VBoxContainer
var title: Label
var panel_name: String = ""
var anchor_y: float = 140.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel",Parts.style(Color("202a32")))
	add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	panel.add_child(box)
	var heading: HBoxContainer = HBoxContainer.new()
	box.add_child(heading)
	title = Parts.label(heading,"",21)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.mouse_filter = Control.MOUSE_FILTER_STOP
	title.mouse_default_cursor_shape = Control.CURSOR_MOVE
	title.tooltip_text = "Drag to move. Release near a viewport edge to dock."
	title.gui_input.connect(_title_input)
	Parts.button(heading,"×",close)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",8)
	scroll.add_child(content)
	panel.hide()
	resized.connect(_layout)
func toggle(name: String, rail_y: float) -> void:
	if name == panel_name:
		close()
		return
	dragging = false
	panel_name = name
	anchor_y = rail_y
	title.text = name
	panel.show()
	_layout()
func close() -> void:
	dragging = false
	panel_name = ""
	panel.hide()
	queue_redraw()
	closed.emit()
func _limits() -> Vector2:
	return (size - panel.size - Vector2.ONE * EDGE_MARGIN).max(Vector2.ONE * EDGE_MARGIN)

func _contained(position_value: Vector2) -> Vector2:
	return position_value.clamp(Vector2.ONE * EDGE_MARGIN,_limits())

func _layout() -> void:
	if not is_instance_valid(panel): return
	panel.size = PANEL_SIZES.get(panel_name,DEFAULT_SIZE).min((size - Vector2.ONE*EDGE_MARGIN*2).max(Vector2.ONE))
	var placement: Dictionary = placements.get(panel_name,{"position":Vector2(34,anchor_y-30),"dock_x":0,"dock_y":0})
	var destination: Vector2 = placement.position
	if placement.dock_x == -1: destination.x = EDGE_MARGIN
	elif placement.dock_x == 1: destination.x = _limits().x
	if placement.dock_y == -1: destination.y = EDGE_MARGIN
	elif placement.dock_y == 1: destination.y = _limits().y
	panel.position = _contained(destination)

func _title_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = true
		drag_offset = get_local_mouse_position() - panel.position
		title.accept_event()

func _input(event: InputEvent) -> void:
	if not dragging or panel_name.is_empty(): return
	if event is InputEventMouseMotion:
		panel.position = _contained(get_local_mouse_position() - drag_offset)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false
		_finish_drag()
		get_viewport().set_input_as_handled()

func _finish_drag() -> void:
	var position_value: Vector2 = _contained(panel.position)
	var dock_x: int = 0
	var dock_y: int = 0
	if position_value.x - EDGE_MARGIN <= SNAP_DISTANCE:
		position_value.x = EDGE_MARGIN
		dock_x = -1
	elif _limits().x - position_value.x <= SNAP_DISTANCE:
		position_value.x = _limits().x
		dock_x = 1
	if position_value.y - EDGE_MARGIN <= SNAP_DISTANCE:
		position_value.y = EDGE_MARGIN
		dock_y = -1
	elif _limits().y - position_value.y <= SNAP_DISTANCE:
		position_value.y = _limits().y
		dock_y = 1
	panel.position = position_value
	placements[panel_name] = {"position":position_value,"dock_x":dock_x,"dock_y":dock_y}
