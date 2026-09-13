extends Button
var lift: float = 0.0
var motion: Tween
var accent := Color("cfaa69")
var menu_font: SystemFont
func _ready() -> void:
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_color_override("font_color",Color.TRANSPARENT)
	add_theme_color_override("font_hover_color",Color.TRANSPARENT)
	add_theme_color_override("font_pressed_color",Color.TRANSPARENT)
	add_theme_color_override("font_disabled_color",Color.TRANSPARENT)
	add_theme_color_override("font_focus_color",Color.TRANSPARENT)
	for style: String in ["normal","hover","pressed","focus","disabled"]: add_theme_stylebox_override(style,StyleBoxEmpty.new())
	menu_font = SystemFont.new()
	menu_font.font_names = PackedStringArray(["Georgia","DejaVu Serif","serif"])
	menu_font.font_italic = true
	mouse_entered.connect(func(): _animate(true))
	mouse_exited.connect(func(): _animate(has_focus()))
	focus_entered.connect(func(): _animate(true))
	focus_exited.connect(func(): _animate(is_hovered()))
func _animate(raised: bool) -> void:
	if disabled: return
	if motion != null: motion.kill()
	motion = create_tween()
	motion.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	motion.tween_method(func(value: float): lift = value; queue_redraw(),lift,7.0 if raised else 0.0,0.14)
func _draw() -> void:
	if menu_font == null: return
	var offset := Vector2(0,-lift)
	var color: Color = Color("555c63") if disabled else accent.lerp(Color("f7e8c5"),lift/7.0)
	var outline := PackedVector2Array([Vector2(100,27),Vector2(52,0),Vector2(4,27),Vector2(4,83),Vector2(52,110),Vector2(100,83)])
	for index: int in range(outline.size()): outline[index] += offset
	var fill := PackedVector2Array([Vector2(52,0),Vector2(100,27),Vector2(100,83),Vector2(52,110),Vector2(4,83),Vector2(4,27)])
	for index: int in range(fill.size()): fill[index] += offset
	draw_colored_polygon(fill,Color("131d24") if lift < 1 else Color("1b2b34"))
	draw_polyline(outline,color,2.0,true)
	var font_size: int = 35
	draw_string(menu_font,Vector2(36,68)+offset,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("72787c") if disabled else Color("eee8dc"))
	var width: float = menu_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	draw_line(Vector2(35,77)+offset,Vector2(40+width,77)+offset,color,1.5,true)
