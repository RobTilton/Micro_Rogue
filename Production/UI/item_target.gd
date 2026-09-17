extends Button
const Art = preload("res://Production/UI/item_art.gd")
signal quick_equip(source: Dictionary)
signal item_context(source: Dictionary)
signal transfer_requested(source: Dictionary, target: Dictionary)
var item: Dictionary = {}
var source: Dictionary = {}
var target: Dictionary = {}
var drag_context: RefCounted
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not item.is_empty():
		tooltip_text = preload("res://Production/Actors/item_inspection.gd").tooltip(item)
		icon = Art.texture_for(item)
		expand_icon = true
		add_theme_constant_override("icon_max_width",30)

func _get_drag_data(_position: Vector2) -> Variant:
	if item.is_empty(): return null
	return drag_context.begin(item,source,self)
func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("inventory_drag",false)
func _drop_data(_position: Vector2, data: Variant) -> void:
	transfer_requested.emit(data.source,target)

func _gui_input(event: InputEvent) -> void:
	if item.is_empty() or not event is InputEventMouseButton or not event.pressed: return
	if event.button_index == MOUSE_BUTTON_RIGHT:
		item_context.emit(source)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_LEFT and event.shift_pressed:
		quick_equip.emit(source)
		accept_event()
