extends Control
signal transfer_requested(source: Dictionary, target: Dictionary)
signal item_selected(item_id: int)
signal selection_completed
const Art = preload("res://Workshop/Rooms/UI Foundation/Prototype/ui/item_art.gd")
const Grid = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/grid_inventory.gd")
const CELL: int = 52
var items: Array = []
var drag_context: RefCounted
var selected_id: int = -1
var hover_cell: Vector2i = Vector2i(-1,-1)
var preview_valid: bool = false
var validator: Callable
func _ready() -> void:
	custom_minimum_size = Vector2(Grid.COLUMNS * CELL, Grid.ROWS * CELL)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_exited.connect(func(): hover_cell = Vector2i(-1,-1); queue_redraw())
func cell_at(point: Vector2) -> Vector2i:
	return Vector2i(floori(point.x/CELL),floori(point.y/CELL))
func item_at(point: Vector2) -> Dictionary:
	var cell: Vector2i = cell_at(point)
	for item: Dictionary in items:
		if Rect2i(item.grid_pos,Grid.footprint(item,item.get("rotated",false))).has_point(cell): return item
	return {}
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not get_viewport().gui_is_dragging():
		selection_completed.emit()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var item: Dictionary = item_at(event.position)
		if not item.is_empty(): item_selected.emit(item.item_id)
func _get_drag_data(point: Vector2) -> Variant:
	var item: Dictionary = item_at(point)
	if item.is_empty(): return null
	return drag_context.begin(item,{"zone":"bag","id":item.item_id},self)
func _can_drop_data(point: Vector2, data: Variant) -> bool:
	if not data is Dictionary or not data.get("inventory_drag",false): return false
	hover_cell = cell_at(point)
	preview_valid = validator.call(data.source,{"zone":"bag","cell":hover_cell,"rotated":data.rotated})
	queue_redraw()
	return true
func _drop_data(point: Vector2, data: Variant) -> void:
	transfer_requested.emit(data.source,{"zone":"bag","cell":cell_at(point),"rotated":data.rotated})
	hover_cell = Vector2i(-1,-1)
func _draw() -> void:
	for y: int in range(Grid.ROWS):
		for x: int in range(Grid.COLUMNS):
			draw_rect(Rect2(x*CELL,y*CELL,CELL,CELL),Color("0f161d"))
			draw_rect(Rect2(x*CELL,y*CELL,CELL,CELL),Color("53646c"),false)
	var font: Font = ThemeDB.fallback_font
	for item: Dictionary in items:
		var rect: Rect2 = Rect2(Vector2(item.grid_pos)*CELL,Vector2(Grid.footprint(item,item.get("rotated",false)))*CELL).grow(-3)
		draw_rect(rect,Color("344b55") if item.item_id != selected_id else Color("596b48"))
		draw_rect(rect,Art.quality_color(item),false,2)
		var texture: Texture2D = Art.texture_for(item)
		if texture != null:
			Art.draw_icon(self,texture,rect.grow(-4),item.get("rotated",false))
		else:
			var abbreviation: String = {"potion":"HP","sword":"SW","shield":"SH","armor":"AR","belt":"BL"}[item.kind]
			draw_string(font,rect.position+Vector2(8,23),abbreviation,HORIZONTAL_ALIGNMENT_LEFT,-1,17)

	if hover_cell.x >= 0 and not drag_context.payload.is_empty():
		var rect: Rect2 = Rect2(Vector2(hover_cell)*CELL,Vector2(Grid.footprint(drag_context.payload.item,drag_context.payload.rotated))*CELL)
		draw_rect(rect,Color(0.4,0.8,0.5,0.4) if preview_valid else Color(0.9,0.3,0.3,0.4))
