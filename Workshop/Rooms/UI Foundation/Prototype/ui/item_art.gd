extends RefCounted
const ART_ROOT: String = "res://Workshop/Rooms/UI Foundation/Prototype/art/items/"
const KEYS: Dictionary = {"Bronze Sword":"bronze_sword","Wooden Shield":"wooden_shield","Chainmail":"chainmail","Halfplate":"halfplate","Fullplate":"fullplate","Hide":"hide","Leather":"leather","Scale":"scale","Robe":"robe","Quilted":"quilted","Gambeson":"gambeson","Sash":"sash","Leather Belt":"leather_belt","Bandolier":"bandolier"}
const QUALITY_COLORS: Array[Color] = [Color("77777d"),Color("c9c4ac"),Color("78aa8a"),Color("76a2cf"),Color("ddb963")]
static var textures: Dictionary = {}
static func key(item: Dictionary) -> String:
	if item.get("kind") == "potion": return "lesser_health"
	return KEYS.get(item.get("appearance",""), {"sword":"bronze_sword","shield":"wooden_shield","armor":"leather","belt":"leather_belt"}.get(item.get("kind"),""))
static func texture_for(item: Dictionary) -> Texture2D:
	return texture_named(key(item))
static func texture_named(asset_key: String) -> Texture2D:
	if textures.has(asset_key): return textures[asset_key]
	var path: String = ART_ROOT + asset_key + ".png"
	if asset_key.is_empty() or not ResourceLoader.exists(path): return null
	var source: Texture2D = load(path) as Texture2D
	if source == null: return null
	var image: Image = source.get_image()
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = source
	atlas.region = image.get_used_rect()
	textures[asset_key] = atlas
	return atlas
static func quality_color(item: Dictionary, known: bool = true) -> Color:
	if not known: return Color("786d5f")
	return QUALITY_COLORS[clampi(item.get("rarity",1),0,4)]
static func draw_icon(canvas: CanvasItem, texture: Texture2D, area: Rect2, rotated: bool = false) -> void:
	if texture == null: return
	var available: Vector2 = Vector2(area.size.y,area.size.x) if rotated else area.size
	var factor: float = minf(available.x/texture.get_width(),available.y/texture.get_height())
	var draw_size: Vector2 = (texture.get_size()*factor).floor()
	canvas.draw_set_transform((area.position+area.size*0.5).floor(),PI*0.5 if rotated else 0.0)
	canvas.draw_texture_rect(texture,Rect2((-draw_size*0.5).floor(),draw_size),false)
	canvas.draw_set_transform(Vector2.ZERO)
