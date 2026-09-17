extends Control
const Art = preload("res://Production/UI/item_art.gd")
var item: Dictionary = {}
var rotated: bool = false
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
func _draw() -> void:
	var texture: Texture2D = Art.texture_for(item)
	if item.get("kind") == "ring":
		Art.draw_ring(self,Rect2(Vector2.ZERO,size),item.get("greater",false))
	elif texture != null:
		Art.draw_icon(self,texture,Rect2(Vector2.ZERO,size),rotated)
	else:
		var text: String = {"ration":"RN","potion":"HP","sword":"SW","weapon":"WP","shield":"SH","armor":"AR","belt":"BL"}.get(item.get("kind"),"?")
		draw_string(ThemeDB.fallback_font,Vector2(size.x*0.5-12,size.y*0.5+6),text,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("c9c4ac"))
