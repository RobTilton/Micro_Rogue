extends SceneTree
func _initialize() -> void:
	for path: String in ["Animals/Wolves/T1_Wolf.png","Humans/PaperDollModelHairless_6Directions.png","Goblins/T1_Goblin.png"]:
		var picture := Image.load_from_file("res://Workshop/Chad-Casso/Enemies/"+path)
		print(path)
		for point: Vector2i in [Vector2i(10,10),Vector2i(450,250),Vector2i(250,250),Vector2i(750,80),Vector2i(750,400)]: print(point," ",picture.get_pixelv(point))
	quit()
