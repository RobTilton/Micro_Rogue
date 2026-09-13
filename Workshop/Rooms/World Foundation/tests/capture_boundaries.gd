extends SceneTree
const Locations = preload("res://Workshop/Rooms/World Foundation/domain/location_world.gd")
const Contracts = preload("res://Workshop/Rooms/World Foundation/domain/geographic_contracts.gd")
class Proof extends Control:
	var maps: Array = []
	var contracts: Array = []
	func _draw() -> void:
		var font: Font = ThemeDB.fallback_font
		draw_string(font,Vector2(25,32),"Neighbor contract proof · generated Local maps · seed 1729",HORIZONTAL_ALIGNMENT_LEFT,-1,24)
		draw_string(font,Vector2(25,60),"Gold: corresponding boundary sections. Violet: inherited river route. Blue: water. Separate logical maps, not a stitched projection.",HORIZONTAL_ALIGNMENT_LEFT,-1,17)
		for index: int in range(maps.size()):
			var map = maps[index]
			var contract: Dictionary = contracts[index]
			var radius: float = minf(610.0/(sqrt(3.0)*(map.dimensions.x+map.dimensions.y*0.5)),500.0/(1.5*map.dimensions.y))
			var origin := Vector2(30+index*700,160)
			draw_string(font,origin-Vector2(0,45),"%s · %s · side %d" % [map.id,map.dimensions,contract.direction],HORIZONTAL_ALIGNMENT_LEFT,-1,21)
			for cell: Vector2i in map.cells():
				var center: Vector2 = origin+Vector2(sqrt(3.0)*(cell.x+cell.y*0.5),cell.y*1.5)*radius
				var polygon: PackedVector2Array = []
				for corner: int in range(6): polygon.append(center+Vector2.from_angle(deg_to_rad(corner*60-30))*radius)
				draw_colored_polygon(polygon,Color("287baa") if map.water_cells.has(cell) else Color("63795a"))
			for cell: Vector2i in Contracts.boundary_cells(map,contract.direction):
				var center: Vector2 = origin+Vector2(sqrt(3.0)*(cell.x+cell.y*0.5),cell.y*1.5)*radius
				draw_arc(center,radius*0.6,0,TAU,12,Color("ffd269"),1.4)
			for route: Dictionary in map.river_routes:
				if route.get("parent_edge","") != contract.key: continue
				for step: int in range(1,route.vertices.size()):
					var a: Vector2i = route.vertices[step-1]
					var b: Vector2i = route.vertices[step]
					draw_line(origin+Vector2(a.x*sqrt(3.0)*0.5,a.y*0.5)*radius,origin+Vector2(b.x*sqrt(3.0)*0.5,b.y*0.5)*radius,Color("f097ed"),3)
			draw_string(font,Vector2(origin.x,735),"Shared edge "+contract.key,HORIZONTAL_ALIGNMENT_LEFT,-1,19)
			for sample: int in range(5): draw_rect(Rect2(origin.x+sample*60,758,54,30),Color("287baa") if contract.water[sample] else Color("63795a"))
			draw_string(font,Vector2(origin.x,815),"Canonical five-sample water profile",HORIZONTAL_ALIGNMENT_LEFT,-1,17)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var world = Locations.new(1729)
	var selected: Dictionary = {}
	var first_id: String = ""
	for id: String in world.records:
		if world.records[id].template != "Local": continue
		for contract: Dictionary in world.records[id].constraints.boundaries:
			if contract.river and (selected.is_empty() or true in contract.water):
				first_id = id
				selected = contract
		if not selected.is_empty() and true in selected.water: break
	var second_id: String = world.maps.global.links[selected.neighbor].id
	var paired: Dictionary = {}
	for contract: Dictionary in world.records[second_id].constraints.boundaries:
		if contract.key == selected.key: paired = contract
	var proof = Proof.new()
	proof.maps = [world.ensure_location(first_id),world.ensure_location(second_id)]
	proof.contracts = [selected,paired]
	root.add_child(proof)
	for frame: int in range(4): await process_frame
	await RenderingServer.frame_post_draw
	var error: Error = root.get_texture().get_image().save_png("res://Workshop/Rooms/World Foundation/tests/boundary_proof.png")
	for id: String in world.records:
		if world.records[id].template != "Local": continue
		for contract: Dictionary in world.records[id].constraints.boundaries:
			if true in contract.water and false in contract.water:
				selected = contract
				first_id = id
				break
		if true in selected.water and false in selected.water: break
	second_id = world.maps.global.links[selected.neighbor].id
	for contract: Dictionary in world.records[second_id].constraints.boundaries:
		if contract.key == selected.key: paired = contract
	proof.maps = [world.ensure_location(first_id),world.ensure_location(second_id)]
	proof.contracts = [selected,paired]
	proof.queue_redraw()
	for frame: int in range(4): await process_frame
	await RenderingServer.frame_post_draw
	error = error | root.get_texture().get_image().save_png("res://Workshop/Rooms/World Foundation/tests/coast_proof.png")
	print("Boundary proof capture: ",error)
	quit(0 if error == OK else 1)
