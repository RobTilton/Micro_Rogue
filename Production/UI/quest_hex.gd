extends Control
const Biomes = preload("res://Production/World/biome_generator.gd")
var biome: String = "Plains"
var texture: Texture2D = preload("res://Production/Assets/Terrain/OVERWORLD_TILES_BIOME.png")
func _ready() -> void:
	custom_minimum_size = Vector2(64,64)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
func _draw() -> void:
	var display: String = {"Swamp":"Forest","Salt Marsh":"Sea","Marsh":"Forest"}.get(biome,biome)
	var index: int = maxi(0,Biomes.NAMES.find(display))
	var source := Vector2(198+(index%4)*379,343+(int(index/4.0))*398)
	var offsets: Array[Vector2] = [Vector2(149,-76),Vector2(149,76),Vector2(0,155),Vector2(-149,76),Vector2(-149,-76),Vector2(0,-155)]
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	for corner: int in range(6):
		vertices.append(size*0.5+Vector2.from_angle(deg_to_rad(60*corner-30))*30)
		uvs.append((source+offsets[corner])/texture.get_size())
	draw_polygon(vertices,PackedColorArray([Color.WHITE]),uvs,texture)
