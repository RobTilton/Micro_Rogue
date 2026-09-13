extends RefCounted
const Variation = preload("res://Production/Previous/WorldFoundation/UI/terrain_variation.gd")
const SHEET: String = "res://Production/Assets/Terrain/Local_Map_Marsh.png"
## Explicit ground samples; buildings, boats and bridges remain unassigned props.
const CENTERS: Array[Vector2] = [Vector2(139,121),Vector2(350,121),Vector2(560,121),Vector2(770,121),Vector2(214,310),Vector2(766,496),Vector2(766,875)]
static func draw_tile(canvas: CanvasItem, texture: Texture2D, cell: Vector2i, center: Vector2, radius: float) -> void:
	var source: Vector2 = CENTERS[Variation.index(cell,"marsh",CENTERS.size())]
	var offsets: Array[Vector2] = [Vector2(85,-42),Vector2(85,42),Vector2(0,85),Vector2(-85,42),Vector2(-85,-42),Vector2(0,-85)]
	var points: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		points.append(center+Vector2.from_angle(deg_to_rad(60*corner-30))*radius)
		uvs.append((source+offsets[corner])/texture.get_size())
	canvas.draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,texture)
