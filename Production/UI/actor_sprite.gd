extends Node2D
const SHEET: Texture2D = preload("res://Production/Assets/Actors/actor_sprites_keyed.png")
const PEOPLE: Texture2D = preload("res://Production/Assets/Scenery/people_keyed.png")
const ENEMIES: Texture2D = preload("res://Production/Assets/Scenery/enemies_keyed.png")
const Roster = preload("res://Production/Actors/enemy_roster.gd")
static var enemy_textures: Dictionary = {}
var legacy_surface: ShaderMaterial
var enemy_surface: ShaderMaterial
var actor: Dictionary = {}
var selected: bool = false
func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var key := Shader.new()
	key.code = "shader_type canvas_item; void fragment(){ vec4 c=COLOR; if(c.r>0.55 && c.b>0.55 && min(c.r,c.b)-c.g>0.3){c.a=0.0;} COLOR=c; }"
	var surface := ShaderMaterial.new()
	surface.shader = key
	legacy_surface = surface
	material = surface
	var alpha_shader := Shader.new()
	alpha_shader.code = "shader_type canvas_item; void fragment(){ COLOR.a=smoothstep(0.5,0.95,COLOR.a); }"
	enemy_surface = ShaderMaterial.new()
	enemy_surface.shader = alpha_shader
func _draw() -> void:
	if actor.is_empty(): return
	var hero: bool = actor.faction == "player"
	var source := Rect2(240,190,420,600) if hero else Rect2(1120,330,420,460)
	var sheet: Texture2D = SHEET
	if actor.faction == "town":
		sheet = PEOPLE
		source = Rect2(1226,550,91,136) if actor.get("role","") == "crier" else (Rect2(944,546,90,142) if posmod(actor.id,2) == 0 else Rect2(1039,550,91,138))
	elif actor.faction == "enemy" and actor.get("family","") == "goblins":
		sheet = ENEMIES
		source = Rect2(995,22,271,259) if actor.get("boss",false) else Rect2(47,68,178,205)
	elif actor.faction == "enemy" and actor.get("family","") == "raiders":
		sheet = PEOPLE
		source = Rect2(509,312,104,142)
	var entry: Dictionary = Roster.variant(actor.get("enemy_variant","")) if actor.faction == "enemy" else {}
	if not entry.is_empty():
		if not enemy_textures.has(entry.sprite): enemy_textures[entry.sprite] = load(entry.sprite)
		sheet = enemy_textures[entry.sprite]
		var region: Array = entry.region
		source = Rect2(region[0],region[1],region[2],region[3])
		material = enemy_surface
	else: material = legacy_surface
	var extent: Vector2 = source.size*(48.0/source.size.y) if sheet != SHEET else source.size*0.088
	if not entry.is_empty(): extent = source.size*minf(48.0/source.size.y,56.0/source.size.x)
	var color := Color("82c6bd") if actor.faction in ["player","town"] else Color("d07570")
	draw_arc(Vector2(0,12),17,0,TAU,24,color,2.0)
	if selected: draw_arc(Vector2(0,12),20,0,TAU,24,Color("e6c877"),2.0)
	draw_texture_rect_region(sheet,Rect2(Vector2(-extent.x*0.5,15-extent.y),extent),source)
	draw_rect(Rect2(-16,19,32,3),Color("282b30"))
	draw_rect(Rect2(-16,19,32*float(actor.hp)/maxi(1,actor.max_hp),3),color)

	if actor.faction == "town" or actor.get("boss",false):
		draw_string(ThemeDB.fallback_font,Vector2(-30,-44),actor.name,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("f2dfa7"))
