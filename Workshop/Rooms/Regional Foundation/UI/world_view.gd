extends "res://Workshop/Rooms/Regional Foundation/UI/hex_board.gd"
signal hex_intent(cell: Vector2i, bypass: bool)
var preview_path: Array = []
var pan_offset: Vector2 = Vector2.ZERO
var pan_button: int = 0
var press_position: Vector2
var press_offset: Vector2
var dragged: bool = false
const Variation = preload("res://Workshop/Rooms/Regional Foundation/UI/terrain_variation.gd")
const DRAG_THRESHOLD: float = 7.0
const WastelandArt = preload("res://Workshop/Rooms/Regional Foundation/UI/wasteland_art.gd")
var wasteland_textures: Array[Texture2D] = []
const MarshArt = preload("res://Workshop/Rooms/Regional Foundation/UI/marsh_art.gd")
var marsh_texture: Texture2D
var local_textures: Dictionary = {}
var water_texture: Texture2D
const Water = preload("res://Workshop/Rooms/Regional Foundation/World/local_water.gd")
const Biomes = preload("res://Workshop/Rooms/Regional Foundation/World/biome_generator.gd")
const PoiArt = preload("res://Workshop/Rooms/Regional Foundation/UI/poi_art.gd")
var poi_texture: Texture2D
var biome_texture: Texture2D
const RiverArt = preload("res://Workshop/Rooms/Regional Foundation/UI/river_art.gd")
var river_texture: Texture2D
var floor_texture: Texture2D
const FLOOR_SHEET: String = "res://Production/Assets/Terrain/ground_prototype_02.png"
func _ready() -> void:
	resized.connect(_resize_view)
	if map_data != null: pan_offset = map_data.view_offset
	_initialize_view.call_deferred()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	river_texture = load(RiverArt.SHEET) as Texture2D
	floor_texture = load(FLOOR_SHEET) as Texture2D
	marsh_texture = load(MarshArt.SHEET) as Texture2D
	for path: String in WastelandArt.SHEETS: wasteland_textures.append(load(path) as Texture2D)
	water_texture = load("res://Production/Assets/Terrain/Ocean_And_Lake_Tiles.png") as Texture2D
	for biome: String in ["Plains","Forest","Hills","Mountains","Desert"]:
		local_textures[biome] = load("res://Production/Assets/Terrain/Local_Map_"+biome+".png") as Texture2D
	poi_texture = load(PoiArt.SHEET) as Texture2D
	biome_texture = load("res://Production/Assets/Terrain/OVERWORLD_TILES_BIOME.png") as Texture2D
func cell_radius() -> float:
	return SIZE
func center(cell: Vector2i) -> Vector2:
	var radius: float = cell_radius()
	var extent: Vector2i = map_data.dimensions if map_data != null else Vector2i(7,7)
	var bounds: Vector2 = Vector2(radius*sqrt(3.0)*(extent.x+(extent.y-1)*0.5),radius*(1.5*(extent.y-1)+2))
	var point: Vector2 = pan_offset + (size-bounds)*0.5 + Vector2(radius*sqrt(3.0)*(0.5+cell.x+cell.y*0.5),radius+radius*1.5*cell.y)
	if map_data != null and map_data.wrap_horizontal:
		var period: float = radius*sqrt(3.0)*extent.x
		point.x += round((size.x*0.5-point.x)/period)*period
	return point
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_MIDDLE]:
		if event.pressed:
			if pan_button != 0: return
			pan_button = event.button_index
			press_position = event.position
			press_offset = pan_offset
			dragged = false
		else:
			if event.button_index != pan_button: return
			var click: bool = pan_button == MOUSE_BUTTON_LEFT and not dragged and event.position.distance_to(press_position) < DRAG_THRESHOLD
			pan_button = 0
			mouse_default_cursor_shape = Control.CURSOR_ARROW
			if click:
				var cell = _cell_at(event.position)
				if cell != null: hex_intent.emit(cell,event.shift_pressed)
		accept_event()
	elif event is InputEventMouseMotion:
		if pan_button != 0:
			if event.position.distance_to(press_position) >= DRAG_THRESHOLD: dragged = true
			if dragged:
				pan_offset = press_offset + event.position-press_position
				_store_view()
				mouse_default_cursor_shape = Control.CURSOR_DRAG
				tooltip_text = ""
				queue_redraw()
			accept_event()
		else:
			tooltip_text = ""
			var cell = _cell_at(event.position)
			if cell != null and map_data != null and map_data.links.has(cell): tooltip_text = map_data.links[cell].label

func _cell_at(position_value: Vector2):
	for cell: Vector2i in board_cells():
		var polygon: PackedVector2Array = []
		for corner: int in range(6): polygon.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*cell_radius())
		if Geometry2D.is_point_in_polygon(position_value,polygon): return cell
	return null

func board_cells() -> Array:
	var visible_cells: Array = []
	var visible_area: Rect2 = Rect2(Vector2.ZERO,size).grow(SIZE)
	for cell: Vector2i in super.board_cells():
		if visible_area.has_point(center(cell)): visible_cells.append(cell)
	return visible_cells

func _initialize_view() -> void:
	if not is_inside_tree(): return
	await get_tree().process_frame
	if not is_inside_tree(): return
	if map_data != null and not map_data.view_initialized: focus_player()
	else: queue_redraw()

func focus_player() -> void:
	pan_offset += size*0.5-center(player_cell)
	_store_view()
	queue_redraw()

func _store_view() -> void:
	if map_data != null:
		map_data.view_offset = pan_offset
		map_data.view_initialized = true

func _resize_view() -> void:
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		pan_button = 0
		dragged = false
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func _draw() -> void:
	super._draw()
	if map_data != null:
		for cell: Vector2i in map_data.links:
			if map_data.layer == "Global": continue
			if map_data.layer == "Local" and PoiArt.supports(map_data.links[cell].kind): continue
			draw_arc(center(cell), 20, 0, TAU, 6, Color("d99245"), 2)
			var label: String = "IS" if map_data.links[cell].kind == "Island" else map_data.links[cell].kind.left(1)
			draw_string(ThemeDB.fallback_font,center(cell)+Vector2(-5,6),label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("f5d879"))
	var last: Vector2 = center(player_cell)
	for cell: Vector2i in preview_path:
		var next: Vector2 = center(cell)
		draw_line(last,next,Color("f1d291"),3)
		draw_circle(next,5,Color("f1d291"))
		last = next

func _draw_floor(cell: Vector2i, _points: PackedVector2Array) -> void:
	if map_data != null and map_data.layer == "Local" and map_data.links.has(cell) and PoiArt.supports(map_data.links[cell].kind):
		PoiArt.draw_badge(self,poi_texture,map_data.links[cell].kind,center(cell),cell_radius()-2)
		return
	if map_data != null and map_data.layer == "Local":
		var terrain: String = map_data.biomes.get(cell,map_data.region_biome)
		if map_data.water_cells.has(cell): _draw_water(cell)
		elif terrain == "Wasteland": _draw_wasteland(cell)
		elif terrain == "Marsh": MarshArt.draw_tile(self,marsh_texture,cell,center(cell),cell_radius())
		else: _draw_local_floor(cell,terrain)
		return
	if map_data != null and map_data.biomes.get(cell,"") == "Marsh":
		MarshArt.draw_tile(self,marsh_texture,cell,center(cell),cell_radius())
		return
	if map_data != null and map_data.biomes.has(cell):
		_draw_biome(cell)
		return
	if floor_texture == null:
		super._draw_floor(cell, _points)
		return
	# Source vertices are inset from the painted outlines/background.
	# UVs map their slightly flattened shape to the board's exact hex geometry.
	var column: int = posmod(cell.x * 3 + cell.y * 5, 7)
	var source_center: Vector2 = Vector2(137 + column * 210, 542)
	var offsets: Array[Vector2] = [Vector2(76,-38), Vector2(76,38), Vector2(0,80), Vector2(-76,38), Vector2(-76,-38), Vector2(0,-80)]
	var vertices: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		vertices.append(center(cell) + Vector2.from_angle(deg_to_rad(60 * corner - 30)) * cell_radius())
		uvs.append((source_center + offsets[corner]) / floor_texture.get_size())
	draw_polygon(vertices, PackedColorArray([Color.WHITE]), uvs, floor_texture)
	if cell in highlights:
		draw_colored_polygon(vertices, Color(0.3, 0.7, 0.6, 0.25))

func _draw_biome(cell: Vector2i) -> void:
	var display_biome: String = {"Swamp":"Forest","Salt Marsh":"Sea"}.get(map_data.biomes[cell],map_data.biomes[cell])
	var index: int = Biomes.NAMES.find(display_biome)
	var source_center: Vector2 = Vector2(198+(index%4)*379,343+(index/4)*398)
	var offsets: Array[Vector2] = [Vector2(149,-76),Vector2(149,76),Vector2(0,155),Vector2(-149,76),Vector2(-149,-76),Vector2(0,-155)]
	var points: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		points.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*cell_radius())
		uvs.append((source_center+offsets[corner])/biome_texture.get_size())
	draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,biome_texture)
	if cell in highlights: draw_colored_polygon(points,Color(0.8,0.9,1.0,0.12))

func _draw_local_floor(cell: Vector2i, terrain: String) -> void:
	var biome: String = "Forest" if terrain == "Swamp" else "Plains" if terrain in ["Sea","Lakes","Salt Marsh"] else terrain
	if not local_textures.has(biome): biome = "Plains"
	var texture: Texture2D = local_textures[biome]
	# First row contains eight base-ground variations; road/decor rows are reserved.
	var variant: int = Variation.index(cell,map_data.id,8)
	var source: Vector2 = Vector2(105+variant*190,104) if biome == "Forest" else Vector2(117+variant*177.5,112)
	if biome == "Desert": source = Vector2(121+variant*190,110)
	if biome == "Hills": source = Vector2(114+(variant%2)*187,127)
	if biome == "Mountains": source = Vector2(100+(variant%2)*185,98)
	var half_width: float = 77 if biome == "Forest" else 70
	var half_height: float = 82 if biome == "Forest" else 78
	if biome == "Mountains": half_width = 69; half_height = 71
	var offsets: Array[Vector2] = [Vector2(half_width,-half_height*0.5),Vector2(half_width,half_height*0.5),Vector2(0,half_height),Vector2(-half_width,half_height*0.5),Vector2(-half_width,-half_height*0.5),Vector2(0,-half_height)]
	var points: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		points.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*cell_radius())
		uvs.append((source+offsets[corner])/texture.get_size())
	draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,texture)
	if cell in highlights: draw_colored_polygon(points,Color(0.8,0.9,1,0.12))

func _draw_water(cell: Vector2i) -> void:
	var ocean: bool = map_data.region_biome in ["Sea","Salt Marsh"]
	var variant: int = 1 # Consistent palette; vary orientation to break repeated wave motifs.
	var rotation: int = Variation.index(cell,map_data.id,6,71)
	var source: Vector2 = Vector2(106+variant*152,322 if ocean else 716)
	var offsets: Array[Vector2] = [Vector2(22,-12),Vector2(22,12),Vector2(0,24),Vector2(-22,12),Vector2(-22,-12),Vector2(0,-24)]
	var points: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		points.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*cell_radius())
		uvs.append((source+offsets[(corner+rotation)%6])/water_texture.get_size())
	draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,water_texture)
	if cell in highlights: draw_colored_polygon(points,Color(0.8,0.9,1,0.12))

func _draw_wasteland(cell: Vector2i) -> void:
	var sample: Vector3 = WastelandArt.sample(cell,map_data.id)
	var texture: Texture2D = wasteland_textures[int(sample.x)]
	var source: Vector2 = Vector2(sample.y,sample.z)
	var offsets: Array[Vector2] = [Vector2(64,-32),Vector2(64,32),Vector2(0,65),Vector2(-64,32),Vector2(-64,-32),Vector2(0,-65)]
	var points: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	for corner: int in range(6):
		points.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*cell_radius())
		uvs.append((source+offsets[corner])/texture.get_size())
	draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,texture)
	if cell in highlights: draw_colored_polygon(points,Color(0.8,0.9,1,0.12))

func wall_color(cell: Vector2i) -> Color:
	if map_data != null and map_data.biomes.get(cell,"") == "Ice Wall": return Color("bfdce7")
	return Color.BLACK

func _draw_overlays() -> void:
	if map_data != null: RiverArt.draw_rivers(self,river_texture,map_data)
