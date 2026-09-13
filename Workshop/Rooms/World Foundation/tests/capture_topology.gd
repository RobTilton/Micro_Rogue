extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Topology = preload("res://Workshop/Rooms/World Foundation/domain/topology_generator.gd")
class Overview extends Control:
	var maps: Array = []
	var seeds: Array = []
	func _draw() -> void:
		var font: Font = ThemeDB.fallback_font
		draw_string(font,Vector2(22,36),"World Foundation · New-world topology · six independent seeds",HORIZONTAL_ALIGNMENT_LEFT,-1,25)
		for index: int in range(maps.size()):
			var map = maps[index]
			var origin := Vector2(22+(index%3)*475,110+(index/3)*380)
			var components: Dictionary = {}
			for id: int in map.continents.values(): components[id] = true
			draw_string(font,origin-Vector2(0,22),"Seed %d · %d%% land · %d landmasses" % [seeds[index],roundi(map.continents.size()/32.0),components.size()],HORIZONTAL_ALIGNMENT_LEFT,-1,18)
			for cell: Vector2i in map.cells():
				var center := origin+Vector2(fposmod(cell.x+cell.y*0.5,80)*5.35,cell.y*5.35)
				var polygon: PackedVector2Array = []
				for corner: int in range(6): polygon.append(center+Vector2.from_angle(deg_to_rad(corner*60-30))*3.55)
				var color := Color("28576b")
				if map.continents.has(cell): color = Color("94aa73")
				if map.biomes[cell] == "Ice Wall": color = Color("c5dce4")
				draw_colored_polygon(polygon,color)
			var cell: Vector2i = map.spawn_cell
			draw_circle(origin+Vector2(fposmod(cell.x+cell.y*0.5,80)*5.35,cell.y*5.35),4,Color("ffe99a"))
		draw_string(font,Vector2(22,865),"Gold point: starting land. East–west wrap; polar limits retained. Saved worlds are never regenerated.",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var view = Overview.new()
	view.seeds = [17,7936,15855,1729,2026,9001]
	for seed_value: int in view.seeds:
		var map = Map.new("global","The Marches","Global",Vector2i(80,42))
		map.wrap_horizontal = true
		map.spawn_cell = Topology.generate(map,seed_value)
		view.maps.append(map)
	root.add_child(view)
	for frame: int in range(4): await process_frame
	await RenderingServer.frame_post_draw
	var error: Error = root.get_texture().get_image().save_png("res://Workshop/Rooms/World Foundation/tests/topology_variants.png")
	print("Topology capture: ",error)
	quit(0 if error == OK else 1)
