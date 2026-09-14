extends Control
signal cell_selected(cell: Vector2i)
var map_data = null
var player_cell: Vector2i
var actors: Array = []
var projected: Dictionary = {}
var trade_route: Array = []
func _ready() -> void:
	custom_minimum_size = Vector2(190,150)
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = "Current map · click to move the camera"
func update_map(map, player: Vector2i, visible_actors: Array) -> void:
	map_data = map
	player_cell = player
	actors = visible_actors
	queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("101820"))
	draw_rect(Rect2(Vector2.ZERO,size),Color("8e856e"),false,1)
	if map_data == null: return
	projected.clear()
	var cells: Array = map_data.cells()
	var extent := Vector2(map_data.dimensions.x+map_data.dimensions.y*0.5,map_data.dimensions.y*0.866)
	var scale_value: float = minf((size.x-16)/extent.x,(size.y-16)/extent.y)
	var origin: Vector2 = (size-extent*scale_value)*0.5
	var blocked: Dictionary = {}
	for cell: Vector2i in map_data.walls: blocked[cell] = true
	for cell: Vector2i in cells:
		var point: Vector2 = origin+Vector2(cell.x+cell.y*0.5,cell.y*0.866)*scale_value
		projected[cell] = point
		if blocked.has(cell): continue
		var color := Color("42635a") if not map_data.water_cells.has(cell) else Color("285675")
		if map_data.layer == "Global":
			color = Color({"Sea":"285675","Lakes":"34748b","Ice Wall":"bdced5","Mountains":"858579","Desert":"ac975e","Wasteland":"77614b"}.get(map_data.biomes.get(cell,""),"42635a"))
		if map_data.shops.has(cell): color = Color("b49258")
		elif map_data.links.has(cell) and map_data.layer != "Global": color = Color("d8b367")
		draw_circle(point,maxf(1,scale_value*0.42),color)
	for index: int in range(1,trade_route.size()):
		if projected.has(trade_route[index-1]) and projected.has(trade_route[index]): draw_line(projected[trade_route[index-1]],projected[trade_route[index]],Color("eac56d"),2)
	for actor: Dictionary in actors:
		if actor.pos == player_cell or not projected.has(actor.pos): continue
		draw_circle(projected[actor.pos],2.5,Color("dc7066") if actor.faction == "enemy" else Color("9fb2ce"))
	if projected.has(player_cell): draw_circle(projected[player_cell],3.5,Color("fff2b6"))
func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT: return
	var best := Vector2i(-1,-1)
	var distance: float = INF
	for cell: Vector2i in projected:
		var candidate: float = projected[cell].distance_squared_to(event.position)
		if candidate < distance: distance = candidate; best = cell
	if best != Vector2i(-1,-1): cell_selected.emit(best)
	accept_event()
