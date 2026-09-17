extends SceneTree
class Gallery extends "res://Production/UI/attack_effects.gd":
	func _process(_delta: float) -> void: pass
	func _draw() -> void:
		var row: int = 0
		for kind: String in FRAMES:
			draw_set_transform(Vector2.ZERO)
			draw_string(ThemeDB.fallback_font,Vector2(20,40+row*65),kind,HORIZONTAL_ALIGNMENT_LEFT,-1,16)
			var frames: Array = FRAMES[kind]
			for index: int in range(frames.size()): _draw_frame(kind,float(index)/frames.size(),Vector2(230+index*145,30+row*65),0,1)
			row += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(850,750)
	var background := ColorRect.new()
	background.color = Color("35463b")
	background.size = Vector2(850,750)
	root.add_child(background)
	var gallery := Gallery.new()
	root.add_child(gallery)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Attack Effects/effects.png")
	gallery.free()
	background.free()
	quit()
