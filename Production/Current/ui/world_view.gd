extends "res://Production/Current/gameplay/hex_board.gd"
signal hex_intent(cell: Vector2i, bypass: bool)
var preview_path: Array = []
var floor_texture: Texture2D
const FLOOR_SHEET: String = "res://Production/Current/art/terrain/ground_prototype_02.png"
func _ready() -> void:
	resized.connect(queue_redraw)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	floor_texture = load(FLOOR_SHEET) as Texture2D
func center(cell: Vector2i) -> Vector2:
	var extent: Vector2i = map_data.dimensions if map_data != null else Vector2i(7,7)
	var bounds: Vector2 = Vector2(SIZE*sqrt(3.0)*(extent.x+(extent.y-1)*0.5),SIZE*(1.5*(extent.y-1)+2))
	return (size-bounds)*0.5 + Vector2(SIZE*sqrt(3.0)*(0.5+cell.x+cell.y*0.5),SIZE+SIZE*1.5*cell.y)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for cell: Vector2i in board_cells():
			var polygon: PackedVector2Array = []
			for corner: int in range(6): polygon.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*SIZE)
			if Geometry2D.is_point_in_polygon(event.position,polygon):
				hex_intent.emit(cell,event.shift_pressed)
				return
func _draw() -> void:
	super._draw()
	if map_data != null:
		for cell: Vector2i in map_data.links:
			draw_arc(center(cell), 20, 0, TAU, 6, Color("d99245"), 2)
			var label: String = map_data.links[cell].kind.left(1)
			draw_string(ThemeDB.fallback_font,center(cell)+Vector2(-5,6),label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("f5d879"))
	var last: Vector2 = center(player_cell)
	for cell: Vector2i in preview_path:
		var next: Vector2 = center(cell)
		draw_line(last,next,Color("f1d291"),3)
		draw_circle(next,5,Color("f1d291"))
		last = next

func _draw_floor(cell: Vector2i, _points: PackedVector2Array) -> void:
	if floor_texture == null:
		super._draw_floor(cell, _points)
		return
	# Source vertices are inset from the painted outlines/background.
	# UVs map their slightly flattened shape to the board's exact hex geometry.
	var column: int = posmod(cell.x * 3 + cell.y * 5, 7)
	var source_center: Vector2 = Vector2(137 + column * 210, 542)
	var offsets: Array[Vector2] = [Vector2(76,-38), Vector2(76,38), Vector2(0,80), Vector2(-76,38), Vector2(-76,-38), Vector2(0,-80)]
	var vertices: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		vertices.append(center(cell) + Vector2.from_angle(deg_to_rad(60 * corner - 30)) * SIZE)
		uvs.append((source_center + offsets[corner]) / floor_texture.get_size())
	draw_polygon(vertices, PackedColorArray([Color.WHITE]), uvs, floor_texture)
	if cell in highlights:
		draw_colored_polygon(vertices, Color(0.3, 0.7, 0.6, 0.25))
