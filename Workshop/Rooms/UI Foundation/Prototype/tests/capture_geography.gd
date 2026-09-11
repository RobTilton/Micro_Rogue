extends SceneTree
const World = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/map_world.gd")
const River = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/river_generator.gd")
class Overview extends Control:
	var map
	func _draw() -> void:
		for cell: Vector2i in map.cells():
			var center: Vector2 = Vector2(35+fposmod(cell.x+cell.y*0.5,80)*10,40+cell.y*8.66)
			var points: PackedVector2Array = []
			for corner: int in range(6): points.append(center+Vector2.from_angle(deg_to_rad(corner*60-30))*5.8)
			var color: Color = Color("3d697d")
			if map.continents.has(cell): color = Color("819565") if map.continents[cell] == 0 else Color("a5a16b")
			if map.biomes[cell] == "Ice Wall": color = Color("d5e9ed")
			draw_colored_polygon(points,color)
		for edge: Dictionary in map.rivers.values():
			var c := Vector2i(edge.cell.x*2+edge.cell.y,edge.cell.y*3)
			var a: Vector2i = River.vertex(map,c+River.CORNERS[posmod(-edge.direction,6)])
			var b: Vector2i = River.vertex(map,c+River.CORNERS[posmod(1-edge.direction,6)])
			if abs(a.x-b.x)>80: continue
			draw_line(Vector2(35+a.x*5,40+a.y*2.8867),Vector2(35+b.x*5,40+b.y*2.8867),Color("7fd5fa"),1.5)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size = Vector2i(900,460)
	var view = Overview.new()
	view.map = World.new(1729).maps.global
	root.add_child(view)
	for frame: int in range(4): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/UI Foundation/Prototype/tests/generated_geography.png")
	quit()
