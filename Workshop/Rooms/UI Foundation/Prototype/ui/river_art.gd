extends RefCounted
const Edges = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/river_edges.gd")
const SHEET: String = "res://Workshop/Chad-Casso/River_Water_Texture.png"
const WATER_RECT: Rect2 = Rect2(720,820,80,20)
const HALF_WIDTH: float = 3.0
static func polygon(canvas: CanvasItem, texture: Texture2D, points: PackedVector2Array) -> void:
	var bounds: Rect2 = Rect2(points[0],Vector2.ZERO)
	for point: Vector2 in points: bounds = bounds.expand(point)
	var uvs: PackedVector2Array = []
	for point: Vector2 in points:
		var relative: Vector2 = (point-bounds.position)/bounds.size.max(Vector2.ONE)
		uvs.append((WATER_RECT.position+relative*WATER_RECT.size)/texture.get_size())
	canvas.draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,texture)
static func draw_rivers(canvas: CanvasItem, texture: Texture2D, map) -> void:
	var segments: Array = []
	var joins: Dictionary = {}
	var visible: Rect2 = Rect2(Vector2.ZERO,canvas.size).grow(40)
	for edge: Dictionary in map.rivers.values():
		var offsets: PackedVector2Array = Edges.endpoints(edge.direction,canvas.cell_radius())
		var a: Vector2 = canvas.center(edge.cell)+offsets[0]
		var b: Vector2 = canvas.center(edge.cell)+offsets[1]
		if not visible.has_point(a) and not visible.has_point(b): continue
		segments.append([a,b])
		joins[Vector2i((a*100).round())] = a
		joins[Vector2i((b*100).round())] = b
	# Draw all bank outlines first, then water, so joins don't acquire internal banks.
	for segment: Array in segments: canvas.draw_line(segment[0],segment[1],Color("596f70"),HALF_WIDTH*2+2)
	for point: Vector2 in joins.values(): canvas.draw_circle(point,HALF_WIDTH+1,Color("596f70"))
	for segment: Array in segments:
		var offset: Vector2 = (segment[1]-segment[0]).normalized().orthogonal()*HALF_WIDTH
		polygon(canvas,texture,PackedVector2Array([segment[0]+offset,segment[1]+offset,segment[1]-offset,segment[0]-offset]))
	for point: Vector2 in joins.values():
		var circle: PackedVector2Array = []
		for corner: int in range(12): circle.append(point+Vector2.from_angle(corner*TAU/12)*HALF_WIDTH)
		polygon(canvas,texture,circle)
