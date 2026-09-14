extends Control
func _ready() -> void:
	custom_minimum_size = Vector2(416,330)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	var shade := Color("34434d")
	draw_circle(Vector2(210,37),29,shade)
	draw_colored_polygon(PackedVector2Array([Vector2(160,80),Vector2(260,80),Vector2(246,179),Vector2(174,179)]),shade)
	draw_line(Vector2(167,91),Vector2(117,177),shade,22,true)
	draw_line(Vector2(253,91),Vector2(303,177),shade,22,true)
	draw_line(Vector2(192,181),Vector2(179,305),shade,27,true)
	draw_line(Vector2(228,181),Vector2(241,305),shade,27,true)
