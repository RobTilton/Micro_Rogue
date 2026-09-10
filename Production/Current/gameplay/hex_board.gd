extends Control
signal selected(cell: Vector2i)
const Combat = preload("res://Production/Current/gameplay/combat.gd")
var player_cell: Vector2i = Vector2i(1, 3)
var enemy_cell: Vector2i = Vector2i(5, 3)
var enemy_alive: bool = true
var loot_cells: Array = []
var highlights: Array = []
var map_data = null
func board_cells() -> Array:
	if map_data != null: return map_data.cells()
	var result: Array = []
	for q: int in range(7):
		for r: int in range(7): result.append(Vector2i(q,r))
	return result
const SIZE: float = 32.0
static func inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < 7 and cell.y >= 0 and cell.y < 7
func center(cell: Vector2i) -> Vector2:
	return Vector2(45 + SIZE * sqrt(3.0) * (cell.x + cell.y * 0.5), 50 + SIZE * 1.5 * cell.y)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for q: int in range(7):
			for r: int in range(7):
				var cell: Vector2i = Vector2i(q,r)
				if center(cell).distance_to(event.position) < 27: selected.emit(cell)
func _draw() -> void:
	for cell: Vector2i in board_cells():
		var points: PackedVector2Array = []
		for corner: int in range(6):
			points.append(center(cell) + Vector2.from_angle(deg_to_rad(60 * corner - 30)) * SIZE)
		if map_data != null and not map_data.walkable(cell):
			draw_colored_polygon(points, Color.BLACK)
		else:
			_draw_floor(cell, points)
			points.append(points[0])
			draw_polyline(points, Color("53606a"), 1.0)
	for loot_cell: Vector2i in loot_cells:
		if (inside(loot_cell) if map_data == null else map_data.contains(loot_cell)): draw_rect(Rect2(center(loot_cell) + Vector2(10, 8), Vector2(12,10)), Color("d99245"))
	_draw_actor(player_cell, Color("82c6bd"))
	if enemy_alive: _draw_actor(enemy_cell, Color("d07570"))
func _draw_actor(cell: Vector2i, color: Color) -> void:
	var p: Vector2 = center(cell)
	draw_rect(Rect2(p + Vector2(-6,-14), Vector2(12,10)), Color("d5c9a5"))
	draw_rect(Rect2(p + Vector2(-9,-3), Vector2(18,15)), color)
	draw_rect(Rect2(p + Vector2(-9,12), Vector2(6,6)), color)
	draw_rect(Rect2(p + Vector2(3,12), Vector2(6,6)), color)

func _draw_floor(cell: Vector2i, points: PackedVector2Array) -> void:
	draw_colored_polygon(points, Color("354847") if cell in highlights else Color("202b36"))
