extends SceneTree
const Roster = preload("res://Production/Actors/enemy_roster.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440,1000)
	var panel := ColorRect.new()
	panel.color = Color("33443b")
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(panel)
	var index: int = 0
	for family: Dictionary in Roster.catalog.families.values():
		for entry: Dictionary in family.variants:
			var point := Vector2(100+(index%7)*195,90+int(index/7.0)*140)
			var sprite = preload("res://Production/UI/actor_sprite.gd").new()
			sprite.actor = {"faction":"enemy","family":"","enemy_variant":entry.id,"hp":10,"max_hp":10}
			sprite.position = point
			sprite.scale = Vector2.ONE*1.7
			root.add_child(sprite)
			var label := Label.new()
			label.text = entry.name+ (" · H" if entry.humanoid else " · N")
			label.position = point+Vector2(-75,45)
			root.add_child(label)
			index += 1
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Enemy Roster/roster.png")
	quit()
