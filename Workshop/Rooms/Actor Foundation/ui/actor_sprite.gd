extends Node2D
const SHEET: Texture2D = preload("res://Workshop/Rooms/Actor Foundation/art/actor_sprites_keyed.png")
var actor: Dictionary = {}
var selected: bool = false
func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var key := Shader.new()
	key.code = "shader_type canvas_item; void fragment(){ vec4 c=COLOR; if(c.r>0.55 && c.b>0.55 && min(c.r,c.b)-c.g>0.3){c.a=0.0;} COLOR=c; }"
	var surface := ShaderMaterial.new()
	surface.shader = key
	material = surface
func _draw() -> void:
	if actor.is_empty(): return
	var hero: bool = actor.sprite == "player"
	var source := Rect2(240,190,420,600) if hero else Rect2(1120,330,420,460)
	var extent: Vector2 = source.size*0.088
	var color := Color("82c6bd") if hero else Color("d07570")
	draw_arc(Vector2(0,12),17,0,TAU,24,color,2.0)
	if selected: draw_arc(Vector2(0,12),20,0,TAU,24,Color("e6c877"),2.0)
	draw_texture_rect_region(SHEET,Rect2(Vector2(-extent.x*0.5,15-extent.y),extent),source)
	draw_rect(Rect2(-16,19,32,3),Color("282b30"))
	draw_rect(Rect2(-16,19,32*float(actor.hp)/maxi(1,actor.max_hp),3),color)
