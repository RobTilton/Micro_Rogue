extends SceneTree
const Map = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const World = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/map_world.gd")
const View = preload("res://Workshop/Rooms/UI Foundation/Prototype/ui/world_view.gd")
var clicked: Array = []
var checks: int = 0
func check(value: bool, reason: String) -> void:
	checks += 1
	assert(value,"tests/map_pan_test.gd: "+reason)
func mouse(view, position: Vector2, pressed: bool, index: int = MOUSE_BUTTON_LEFT) -> void:
	var event = InputEventMouseButton.new()
	event.position = position
	event.button_index = index
	event.pressed = pressed
	view._gui_input(event)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var world = World.new(1729)
	check(world.maps.global.dimensions == Vector2i(80,42),"global quadrupled")
	var region = world.resolve(world.maps.global.links[Vector2i(2,2)])
	check(region.dimensions.x*2 == region.dimensions.y*3,"local ratio")
	check(world.resolve(region.links[Vector2i(4,2)]).dimensions == Vector2i(18,14),"POI quadrupled")
	for layer: String in ["Global","Local","POI"]:
		var view = View.new()
		view.size = Vector2(800,500)
		view.map_data = Map.new(layer,layer,layer,Vector2i(14,12))
		root.add_child(view)
		view.hex_intent.connect(func(cell, _bypass): clicked.append(cell))
		for frame: int in range(3): await process_frame
		var before: Vector2 = view.pan_offset
		var start: Vector2 = view.center(view.player_cell)
		var count: int = clicked.size()
		mouse(view,start,true)
		var motion = InputEventMouseMotion.new()
		motion.position = start+Vector2(80,40)
		view._gui_input(motion)
		mouse(view,motion.position,false)
		check(view.pan_offset == before+Vector2(80,40),layer+" drag pans")
		check(clicked.size() == count,layer+" drag never selects")
		check(view.map_data.view_offset == view.pan_offset,layer+" stores camera")
		var target: Vector2 = view.center(view.player_cell)
		mouse(view,target,true)
		mouse(view,target,false)
		check(clicked.back() == view.player_cell,layer+" click after pan hits correct hex")
		check(view.board_cells().size() < view.map_data.cells().size(),layer+" offscreen floor culling")
		var middle_start: Vector2 = view.pan_offset
		mouse(view,target,true,MOUSE_BUTTON_MIDDLE)
		motion.position = target+Vector2(-30,20)
		view._gui_input(motion)
		mouse(view,motion.position,false,MOUSE_BUTTON_MIDDLE)
		check(view.pan_offset == middle_start+Vector2(-30,20),layer+" middle drag pans")
		var restored = View.new()
		restored.size = view.size
		restored.map_data = view.map_data
		root.add_child(restored)
		for frame: int in range(3): await process_frame
		check(restored.pan_offset == view.pan_offset,layer+" view persists across reentry")
		restored.queue_free()
		view.focus_player()
		check(view.center(view.player_cell).distance_to(view.size*0.5)<0.1,layer+" recenter")
		view.queue_free()
		await process_frame
	print("tests/map_pan_test.gd: %d checks passed" % checks)
	quit()
