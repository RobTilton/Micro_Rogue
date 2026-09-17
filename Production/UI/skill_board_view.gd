extends Control
signal hex_clicked(cell: Vector2i)
const Board = preload("res://Production/Actors/skill_board.gd")
var actor: Dictionary = {"skills":[],"skill_board":Board.blank()}
var definitions: Dictionary = Board.DEFINITIONS
var selected: String = ""
var footprint_rotation: int = 0
var mirror: bool = false
var hovered: Vector2i = Vector2i(99,99)
const HEX_SIZE: float = 27.0
func _ready() -> void:
	custom_minimum_size = Vector2(470,410)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_exited.connect(func(): hovered = Vector2i(99,99); queue_redraw())
func center(cell: Vector2i) -> Vector2:
	return Vector2(size.x*0.5,205)+HEX_SIZE*Vector2(sqrt(3.0)*(cell.x+cell.y*0.5),1.5*cell.y)
func polygon(cell: Vector2i) -> PackedVector2Array:
	var points := PackedVector2Array()
	for corner: int in range(6): points.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*(HEX_SIZE-2))
	return points
func _draw() -> void:
	var occupied: Dictionary = Board.occupied(actor.get("skill_board",Board.blank()),definitions)
	var states: Dictionary = Board.evaluate(actor,definitions)
	var ghost: Array[Vector2i] = []
	if Board.inside(hovered) and definitions.has(selected): ghost = Board.footprint(definitions[selected],{"cell":hovered,"rotation":footprint_rotation,"mirror":mirror})
	for cell: Vector2i in Board.cells():
		var entry: Dictionary = occupied.get(cell,{})
		var id: String = entry.get("id","")
		var color := Color("27343e")
		var label: String = ""
		if id == "@center": color = Color("86642d"); label = "FREE"
		elif id.begins_with("@"): color = Color("62518e"); label = "ORIGIN"
		elif not id.is_empty():
			color = Color("327565") if states.get(id,{}).get("active",false) else Color("844d49")
			label = id.left(7)
		if cell in ghost or cell == hovered: color = color.lightened(0.25)
		var points: PackedVector2Array = polygon(cell)
		draw_colored_polygon(points,color)
		points.append(points[0])
		draw_polyline(points,Color("d7c591") if not selected.is_empty() and id == selected else Color("647780"),2.0)
		if not label.is_empty(): draw_string(ThemeDB.fallback_font,center(cell)+Vector2(-22,4),label,HORIZONTAL_ALIGNMENT_LEFT,45,10)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hovered = Vector2i(99,99)
		for cell: Vector2i in Board.cells():
			if Geometry2D.is_point_in_polygon(event.position,polygon(cell)): hovered = cell; break
		var entry: Dictionary = Board.occupied(actor.get("skill_board",Board.blank()),definitions).get(hovered,{})
		var id: String = entry.get("id","")
		tooltip_text = "Free center: every family; chain link; not an origin." if id == "@center" else entry.get("family","")+" origin · permanent" if id.begins_with("@") else id+"\n"+Board.evaluate(actor,definitions).get(id,{}).get("reason","") if not id.is_empty() else "Empty hex"
		queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for cell: Vector2i in Board.cells():
			if Geometry2D.is_point_in_polygon(event.position,polygon(cell)):
				hex_clicked.emit(cell)
				accept_event()
				break
