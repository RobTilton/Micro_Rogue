extends Button
const Art = preload("res://Production/Previous/WorldFoundation/UI/item_art.gd")
signal transfer_requested(source: Dictionary, target: Dictionary)
var item: Dictionary = {}
var source: Dictionary = {}
var target: Dictionary = {}
var drag_context: RefCounted
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not item.is_empty():
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
