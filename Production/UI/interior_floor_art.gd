extends RefCounted
const SHEET: Texture2D = preload("res://Production/Assets/Terrain/interior_floor_atlas.png")
static func column(map, template: String, cell: Vector2i) -> int:
	if map == null: return -1
	if not map.cave_layout.is_empty(): return 2
	if template == "Well": return 5
	if template in ["Ruin","Underground"]: return 4
	if template in ["Tower","TowerFloor"]: return 9
	if template in ["Dungeon","DungeonFloor"] or not map.room_layout.is_empty(): return posmod(cell.x*3+cell.y*5,2)
	# Compatibility for already-saved caves lacking a renderer template.
	if template == "Cave": return 2
	return -1
static func draw_floor(canvas: CanvasItem, map, template: String, cell: Vector2i, point: Vector2, radius: float) -> bool:
	var index: int = column(map,template,cell)
	if index < 0: return false
	var source_center := Vector2(119+index*144,176)
	var offsets: Array[Vector2] = [Vector2(53,-26),Vector2(53,26),Vector2(0,51),Vector2(-53,26),Vector2(-53,-26),Vector2(0,-51)]
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	for corner: int in range(6):
		vertices.append(point+Vector2.from_angle(deg_to_rad(60*corner-30))*radius)
		uvs.append((source_center+offsets[corner])/SHEET.get_size())
	canvas.draw_polygon(vertices,PackedColorArray([Color.WHITE]),uvs,SHEET)
	return true
