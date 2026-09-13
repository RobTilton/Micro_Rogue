extends RefCounted
## Whole-source atlas rendering: no image file is cropped or rewritten.
const SOURCE = "res://Production/Assets/Buildings/Civilization_roof_tiles.png"
const REGIONS = [Rect2(98,12,256,222),Rect2(1410,12,256,222),Rect2(1080,12,256,222),Rect2(1080,665,256,222),Rect2(750,12,256,222),Rect2(428,12,256,222)]
static var texture: Texture2D
static var material: ShaderMaterial
static func make(roof: int) -> Sprite2D:
	if texture == null:
		if ResourceLoader.exists(SOURCE): texture = load(SOURCE) as Texture2D
		else: texture = ImageTexture.create_from_image(Image.load_from_file(SOURCE))
		var shader := Shader.new()
		shader.code = "shader_type canvas_item; void fragment(){ vec4 c = texture(TEXTURE, UV); if(max(c.r,max(c.g,c.b)) < 0.08){discard;} COLOR = c; }"
		material = ShaderMaterial.new()
		material.shader = shader
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = REGIONS[clampi(roof,0,REGIONS.size()-1)]
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.material = material
	return sprite
