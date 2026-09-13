extends PanelContainer
const Art = preload("res://Workshop/Rooms/Regional Foundation/UI/item_art.gd")
const Icon = preload("res://Workshop/Rooms/Regional Foundation/UI/item_icon.gd")
const Parts = preload("res://Workshop/Rooms/Regional Foundation/UI/ui_parts.gd")
const Inspection = preload("res://Workshop/Rooms/Regional Foundation/Actors/item_inspection.gd")
const Grid = preload("res://Workshop/Rooms/Regional Foundation/Actors/grid_inventory.gd")
var item: Dictionary = {}
var within_reach: bool = true
var horizontal: bool = false
var card_width: float = 180
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	var frame: StyleBoxFlat = Parts.style(Color("171f27"))
	frame.border_color = Art.quality_color(item,within_reach)
	frame.content_margin_left = 8
	frame.content_margin_right = 8
	add_theme_stylebox_override("panel",frame)
	var layout: BoxContainer = HBoxContainer.new() if horizontal else VBoxContainer.new()
	layout.add_theme_constant_override("separation",10)
	add_child(layout)
	var icon: Control = Icon.new()
	icon.item = item
	icon.custom_minimum_size = Vector2(72,72) if horizontal else Vector2(100,100)
	layout.add_child(icon)
	var words: VBoxContainer = VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(words)
	var view: Dictionary = Inspection.describe(item,within_reach)
	var width: float = card_width-100 if horizontal else card_width-16
	var name_label: Label = Parts.label(words,view.title,16)
	name_label.custom_minimum_size.x = width
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_color_override("font_color",Art.quality_color(item,within_reach))
	if not view.details.is_empty():
		var details: Label = Parts.label(words,view.details,14)
		details.custom_minimum_size.x = width
		details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if within_reach:
		var shape: Vector2i = Grid.footprint(item,item.get("rotated",false))
		Parts.label(words,"%d × %d cells" % [shape.x,shape.y],13)
