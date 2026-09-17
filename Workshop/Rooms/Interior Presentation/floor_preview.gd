extends SceneTree
const Art = preload("res://Production/UI/interior_floor_art.gd")
const Map = preload("res://Production/World/hex_map.gd")
class Preview extends Node2D:
	func _draw() -> void:
		var types: Array = ["Cave","Dungeon","Ruin","Well","Tower"]
		for index: int in range(types.size()):
			var map = Map.new("preview",types[index],"POI",Vector2i(4,4))
			draw_string(ThemeDB.fallback_font,Vector2(65+index*265,40),types[index],HORIZONTAL_ALIGNMENT_LEFT,-1,24)
			for y: int in range(4):
				for x: int in range(4):
					var point := Vector2(35+index*265+(x+y*0.5)*42,95+y*36)
					assert(Art.draw_floor(self,map,types[index],Vector2i(x,y),point,24))
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var preview := Preview.new()
	root.add_child(preview)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Interior Presentation/floors.png")
	print("Five existing-art interior floor treatments rendered.")
	quit()
