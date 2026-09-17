extends Node2D
## Visual cues only. Resolved combat owns damage and action timing.
const SHEET: Texture2D = preload("res://Production/Assets/Effects/placeholder_attacks_01.png")
const FRAMES: Dictionary = {
	"slash":[Rect2(205,15,100,100),Rect2(315,15,100,105),Rect2(422,25,100,100),Rect2(550,30,85,90)],
	"heavy":[Rect2(910,5,140,115),Rect2(1060,10,135,110),Rect2(1205,10,130,110),Rect2(1340,10,130,110)],
	"stab":[Rect2(205,150,110,60),Rect2(320,150,160,60),Rect2(495,150,150,75)],
	"dagger":[Rect2(205,255,95,70),Rect2(315,255,100,70),Rect2(430,260,100,65),Rect2(560,265,95,65)],
	"axe":[Rect2(200,350,115,105),Rect2(320,345,145,110),Rect2(470,350,145,105),Rect2(620,350,85,105)],
	"bonk":[Rect2(915,125,145,105),Rect2(1065,125,130,105),Rect2(1200,125,130,105),Rect2(1340,140,115,90)],
	"arrow":[Rect2(202,501,100,28)],
	"bolt":[Rect2(205,590,90,62),Rect2(305,590,120,62),Rect2(440,590,140,62),Rect2(620,590,110,62)],
	"magic_hit":[Rect2(994,570,125,110),Rect2(1120,570,125,110),Rect2(1250,570,115,110),Rect2(1380,580,100,100)],
	"hit":[Rect2(995,475,100,85),Rect2(1125,475,100,85),Rect2(1255,475,95,85)],
	"block":[Rect2(955,350,140,110),Rect2(1120,350,130,110),Rect2(1250,350,110,110),Rect2(1380,360,100,100)]
}
var board: Control
var active: Array[Dictionary] = []
func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var shader := Shader.new()
	# This source is a presentation sheet, not a clean transparent VFX atlas.
	# Additive bright-core rendering removes its dark/colored backdrop at runtime.
	shader.code = "shader_type canvas_item; render_mode blend_add; void fragment(){ vec4 c=COLOR; vec3 core=max(c.rgb-vec3(0.78),vec3(0.0))/0.22; COLOR=vec4(core,c.a); }"
	var surface := ShaderMaterial.new()
	surface.shader = shader
	material = surface
static func style(event: Dictionary) -> String:
	if event.get("lunge",false): return "stab"
	match event.get("category","swords"):
		"staffs": return "bolt"
		"bows": return "arrow"
		"spears": return "stab"
		"daggers": return "dagger"
		"axes": return "axe"
		"maces": return "bonk"
		_: return "heavy" if event.get("two_handed",false) else "slash"
func play(event: Dictionary) -> void:
	var copy: Dictionary = event.duplicate(true)
	copy.elapsed = 0.0
	copy.style = style(event)
	copy.ranged = copy.style in ["arrow","bolt"]
	copy.travel_time = 0.35 if copy.ranged else 0.24
	active.append(copy)
	if active.size() > 64: active.pop_front()
	queue_redraw()
func _process(delta: float) -> void:
	if active.is_empty(): return
	for index: int in range(active.size()-1,-1,-1):
		active[index].elapsed += delta
		if active[index].elapsed >= active[index].travel_time+0.20: active.remove_at(index)
	queue_redraw()
func _draw() -> void:
	if board == null or board.map_data == null: return
	for event: Dictionary in active:
		if event.map_id != board.map_data.id: continue
		if board.fog_enabled and (not board.fog_visible.has(event.from) or not board.fog_visible.has(event.to)): continue
		var origin: Vector2 = board.center(event.from)-Vector2(0,10)*board.zoom
		var target: Vector2 = board.center(event.to)-Vector2(0,10)*board.zoom
		var direction: float = (target-origin).angle()
		if event.elapsed < event.travel_time:
			var progress: float = event.elapsed/event.travel_time
			var point: Vector2 = origin.lerp(target,progress) if event.ranged else origin.lerp(target,0.70)
			_draw_frame(event.style,progress,point,direction,board.zoom)
		else:
			var impact: String = "block" if event.blocked else "magic_hit" if event.channel == "magical" else "hit"
			_draw_frame(impact,(event.elapsed-event.travel_time)/0.20,target,0.0,board.zoom*0.65)
	draw_set_transform(Vector2.ZERO)
func _draw_frame(kind: String, progress: float, point: Vector2, rotation_value: float, zoom_value: float) -> void:
	if kind == "arrow":
		# The sheet's brown arrow disappears with background rejection; use a readable fallback.
		draw_set_transform(point,rotation_value,Vector2.ONE*zoom_value)
		draw_line(Vector2(-14,0),Vector2(12,0),Color(1.0,0.95,0.85),2)
		draw_colored_polygon(PackedVector2Array([Vector2(14,0),Vector2(7,-4),Vector2(7,4)]),Color.WHITE)
		draw_line(Vector2(-13,0),Vector2(-17,-4),Color(1.0,0.95,0.85),2)
		draw_line(Vector2(-13,0),Vector2(-17,4),Color(1.0,0.95,0.85),2)
		return
	var frames: Array = FRAMES[kind]
	var index: int = mini(frames.size()-1,floori(progress*frames.size()))
	var source: Rect2 = frames[index]
	var extent: Vector2 = source.size*0.48*zoom_value
	draw_set_transform(point,rotation_value)
	draw_texture_rect_region(SHEET,Rect2(-extent*0.5,extent),source)
