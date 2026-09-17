extends SceneTree
func _initialize() -> void:
	var path: String = "res://Production/Actors/enemy_catalog.json"
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	for family_id: String in catalog.families:
		for variant: Dictionary in catalog.families[family_id].variants:
			var picture := Image.new()
			assert(picture.load_png_from_buffer(FileAccess.get_file_as_bytes(variant.sprite)) == OK)
			var divisions: Vector2i = Vector2i(6,3) if family_id == "mounds" else Vector2i(3,2)
			var extent := Vector2i(int(picture.get_width()/float(divisions.x)),int(picture.get_height()/float(divisions.y)))
			var origin := Vector2i(0,(int(variant.tier)-1)*extent.y) if family_id == "mounds" else Vector2i.ZERO
			var mask := PackedByteArray()
			mask.resize(extent.x*extent.y)
			for y: int in range(extent.y):
				for x: int in range(extent.x):
					if picture.get_pixelv(origin+Vector2i(x,y)).a >= 0.80: mask[y*extent.x+x] = 1
			var largest: int = 0
			var bounds := Rect2i(Vector2i.ZERO,extent)
			for start: int in range(mask.size()):
				if mask[start] != 1: continue
				var queue := PackedInt32Array([start])
				mask[start] = 2
				var minimum := Vector2i(start%extent.x,int(start/float(extent.x)))
				var maximum: Vector2i = minimum
				var head: int = 0
				while head < queue.size():
					var index: int = queue[head]
					head += 1
					var point := Vector2i(index%extent.x,int(index/float(extent.x)))
					minimum = minimum.min(point)
					maximum = maximum.max(point)
					for step: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
						var next: Vector2i = point+step
						if next.x < 0 or next.y < 0 or next.x >= extent.x or next.y >= extent.y: continue
						var next_index: int = next.y*extent.x+next.x
						if mask[next_index] == 1:
							mask[next_index] = 2
							queue.append(next_index)
				if queue.size() > largest:
					largest = queue.size()
					bounds = Rect2i(minimum,maximum-minimum+Vector2i.ONE)
			bounds = bounds.grow(2).intersection(Rect2i(Vector2i.ZERO,extent))
			variant.region = [bounds.position.x+origin.x,bounds.position.y+origin.y,bounds.size.x,bounds.size.y]
			variant.erase("sheet_column")
			print(variant.id," ",variant.region)
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(catalog,"\t")+"\n")
	quit()
