extends Control
signal chosen(action: String)
const HexButton = preload("res://Workshop/Rooms/Regional Release/UI/hex_menu_button.gd")
var has_world: bool = false
var can_continue: bool = false
var world_description: String = "A world waiting to be discovered."
var buttons: Dictionary = {}
var canvas: Control
var detail: Label
func _ready() -> void:
	canvas = Control.new()
	canvas.size = Vector2(1160,780)
	add_child(canvas)
	var title := Label.new()
	title.text = "MICRO ROGUE"
	title.position = Vector2(70,28)
	title.add_theme_font_size_override("font_size",38)
	title.add_theme_color_override("font_color",Color("eee8dc"))
	canvas.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "A WORLD OF CONSEQUENCES"
	subtitle.position = Vector2(73,84)
	subtitle.add_theme_font_size_override("font_size",13)
	subtitle.add_theme_color_override("font_color",Color("a59b86"))
	canvas.add_child(subtitle)
	var definitions: Array = [
		["options","Options","Make yourself at home. Adjust movement confirmation."],
		["continue","Continue","Return to your adventurer and the world you left behind."],
		["world_data","World Data",world_description],
		["new_world","New World","Create a world and roll a new adventurer. Replaces the current save."],
		["regenerate","Regenerate World","Roll a different world seed and start fresh. Replaces the current save."]]
	for index: int in range(definitions.size()):
		var entry: Array = definitions[index]
		var button = HexButton.new()
		button.text = entry[1]
		button.position = Vector2(76+(48 if index%2 else 0),140+index*83)
		button.size = Vector2(410,112)
		button.disabled = (not has_world and entry[0] in ["continue","world_data","regenerate"]) or (entry[0] == "continue" and not can_continue)
		button.pressed.connect(func(): chosen.emit(entry[0]))
		button.mouse_entered.connect(func(): detail.text = entry[2])
		button.focus_entered.connect(func(): detail.text = entry[2])
		canvas.add_child(button)
		buttons[entry[0]] = button
	detail = Label.new()
	detail.position = Vector2(665,345)
	detail.size = Vector2(390,150)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.text = world_description
	detail.add_theme_font_size_override("font_size",23)
	detail.add_theme_color_override("font_color",Color("b7b5ad"))
	canvas.add_child(detail)
	var note := Label.new()
	note.text = "ONE WORLD · ONE SAVE"
	note.position = Vector2(667,305)
	note.add_theme_font_size_override("font_size",13)
	note.add_theme_color_override("font_color",Color("cfaa69"))
	canvas.add_child(note)
	var exit_button := Button.new()
	exit_button.text = "Quit"
	exit_button.flat = true
	exit_button.position = Vector2(1000,700)
	exit_button.size = Vector2(100,45)
	exit_button.pressed.connect(func(): chosen.emit("quit"))
	canvas.add_child(exit_button)
	resized.connect(_layout)
	_layout()
func _layout() -> void:
	if canvas == null: return
	var factor: float = minf(1.0,minf(size.x/1160.0,size.y/780.0))
	canvas.scale = Vector2(factor,factor)
	canvas.position = (size-canvas.size*factor)*0.5
