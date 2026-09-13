extends RefCounted
## Inset hex badges sampled from the supplied presentation sheet.
const SHEET: String = "res://Production/Assets/Terrain/POI_Overlay_Tiles.png"
const CENTERS: Dictionary = {"Town":Vector2(1332,326),"Dungeon":Vector2(576,738),"Tower":Vector2(958,738)}
static func supports(kind: String) -> bool:
	return CENTERS.has(kind)
static func draw_badge(canvas: CanvasItem, texture: Texture2D, kind: String, center: Vector2, radius: float) -> void:
	if not supports(kind): return
	var source: Vector2 = CENTERS[kind]
	var offsets: Array[Vector2] = [Vector2(145,-72),Vector2(145,72),Vector2(0,157),Vector2(-145,72),Vector2(-145,-72),Vector2(0,-157)]
	var vertices: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		vertices.append(center+Vector2.from_angle(deg_to_rad(60*corner-30))*radius)
		uvs.append((source+offsets[corner])/texture.get_size())
	canvas.draw_polygon(vertices,PackedColorArray([Color.WHITE]),uvs,texture)
	vertices.append(vertices[0])
	canvas.draw_polyline(vertices,Color("d99245"),2)
