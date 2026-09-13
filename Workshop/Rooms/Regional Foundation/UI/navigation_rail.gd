extends VBoxContainer
signal panel_requested(name: String, anchor_y: float)
const Parts = preload("res://Workshop/Rooms/Regional Foundation/UI/ui_parts.gd")
var entries: Dictionary = {}
var map_button: Button
func _ready() -> void:
	custom_minimum_size.x = 166
	add_theme_constant_override("separation",8)
	var map: Button = Parts.button(self,"⬡\nMap layer\nArena",func(): panel_requested.emit("Map",70))
	map_button = map
	map.custom_minimum_size = Vector2(166,110)
	map.tooltip_text = "Open the current map and enter a region or POI at your position."
	for index: int in range(9):
		var title: String = ["Character","Inventory","Skills","—","—","—","—","Logs","Options"][index]
		var button: Button = Button.new()
		button.text = "%d   %s" % [index+1,title]
		button.custom_minimum_size = Vector2(166,43)
		button.disabled = title == "—"
		button.pressed.connect(func(): panel_requested.emit(title,button.position.y+button.size.y*0.5))
		add_child(button)
		if title != "—": entries[title] = button
func select(name: String) -> void:
	for key: String in entries:
		entries[key].modulate = Color("dfd49e") if key == name else Color.WHITE
