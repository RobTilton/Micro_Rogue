extends Node2D
const PROPS: Texture2D = preload("res://Production/Assets/Scenery/props_keyed.png")
const DECO: Texture2D = preload("res://Production/Assets/Scenery/dungeon_keyed.png")
var entries: Array = []
func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){vec4 c=COLOR; if(c.r>0.55 && c.b>0.55 && min(c.r,c.b)-c.g>0.3){c.a=0.0;} COLOR=c;}"
	var surface := ShaderMaterial.new()
	surface.shader = shader
	material = surface
static func region(kind: String, opened: bool) -> Rect2:
	match kind:
		"chest": return Rect2(680,5,218,239) if opened else Rect2(467,53,201,179)
		"barrel": return Rect2(172,262,211,190) if opened else Rect2(19,249,150,191)
		"crate": return Rect2(924,252,210,203) if opened else Rect2(737,248,175,197)
		"rug": return Rect2(239,458,160,151)
		"bones": return Rect2(598,473,188,141)
		"corpse": return Rect2(1348,479,178,146)
		"rubble": return Rect2(811,523,105,97)
		"Well": return Rect2(397,798,85,97)
		"Ladder": return Rect2(381,509,65,108)
		"Underground", "DungeonFloor": return Rect2(139,510,89,103)
		"TowerFloor": return Rect2(24,510,96,103)
	return Rect2()
func _draw() -> void:
	for entry: Dictionary in entries:
		var source: Rect2 = region(entry.kind,entry.opened)
		if not source.has_area(): continue
		var sheet: Texture2D = DECO if entry.kind in ["rubble","Well","Ladder","Underground","DungeonFloor","TowerFloor"] else PROPS
		var extent: Vector2 = source.size*(42.0/maxf(source.size.x,source.size.y))*entry.zoom
		var tint: Color = Color(0.7,0.7,0.7) if entry.opened and entry.kind in ["bones","corpse","chest"] else Color.WHITE
		draw_texture_rect_region(sheet,Rect2(entry.point-extent*0.5,extent),source,tint)
