extends SceneTree
const World = preload("res://Production/World/location_world.gd")
const Art = preload("res://Production/UI/interior_floor_art.gd")
class Preview extends Node2D:
	func _draw() -> void:
		for index: int in range(3):
			var world = World.new(1,false)
			world.records["parent"] = {"label":"Town","children":[]}
			world.records["well"] = {"children":[]}
			var map = world._generate_well({"id":"well","label":"Well","parent":"parent","seed":index,"constraints":{"return_cell":Vector2i(3,3)}})
			for cell: Vector2i in map.cells():
				if not map.walkable(cell): continue
				var point := Vector2(15+index*420+(cell.x+cell.y*0.5)*22,45+cell.y*19)
				Art.draw_floor(self,map,"Well",cell,point,13)
				if map.links.has(cell): draw_circle(point,4,Color("efce70"))
			draw_string(ThemeDB.fallback_font,Vector2(90+index*420,350),"Deeper passage" if map.links.size() == 2 else "No deeper passage",HORIZONTAL_ALIGNMENT_LEFT,-1,20)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.add_child(Preview.new())
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Inventory Shortcuts and Wells/wells.png")
	quit()
