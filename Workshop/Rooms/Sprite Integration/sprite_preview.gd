extends SceneTree
const Layer = preload("res://Production/UI/scenery_layer.gd")
const Actor = preload("res://Production/UI/actor_sprite.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1400,650)
	var background := ColorRect.new()
	background.color = Color("33493c")
	background.size = Vector2(1400,650)
	root.add_child(background)
	var layer := Layer.new()
	root.add_child(layer)
	var kinds: Array = ["chest","barrel","crate","rug","bones","corpse","rubble","Well","Ladder","DungeonFloor","TowerFloor"]
	for index: int in range(kinds.size()):
		for state: int in range(2):
			layer.entries.append({"point":Vector2(75+index*118,110+state*155),"kind":kinds[index],"opened":state == 1,"zoom":2.0})
		var label := Label.new()
		label.text = kinds[index]
		label.position = Vector2(40+index*118,25)
		root.add_child(label)
	for index: int in range(6):
		var actor := Actor.new()
		actor.actor = {"id":index,"sprite":"enemy","faction":"town" if index < 3 else "enemy","role":"crier" if index == 0 else "resident","family":"raiders" if index == 3 else "goblins","boss":index == 5,"hp":10,"max_hp":10,"name":"Preview"}
		actor.position = Vector2(120+index*165,490)
		actor.scale = Vector2(1.8,1.8)
		root.add_child(actor)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Sprite Integration/preview.png")
	print("Sprite Integration: all 7 props, 4 transition appearances and matched actor variants rendered.")
	quit()
