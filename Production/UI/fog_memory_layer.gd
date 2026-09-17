extends Node2D
var board: Control
func _draw() -> void:
	if board == null: return
	for cell: Vector2i in board.board_cells():
		if board.fog_visible.has(cell): continue
		var points: PackedVector2Array = []
		for corner: int in range(6): points.append(board.center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*board.cell_radius())
		draw_colored_polygon(points,Color(0.0,0.0,0.0,0.65))
