extends "res://Production/UI/world_view.gd"
const Sprite = preload("res://Production/UI/actor_sprite.gd")
var actor_sprites: Dictionary = {}
var motions: Dictionary = {}
func show_actors(actors: Array[Dictionary], selected_id: int) -> void:
	for sprite: Node2D in actor_sprites.values(): sprite.visible = false
	for actor: Dictionary in actors:
		if not actor_sprites.has(actor.id):
			var sprite := Sprite.new()
			add_child(sprite)
			actor_sprites[actor.id] = sprite
		var sprite: Node2D = actor_sprites[actor.id]
		sprite.actor = actor
		sprite.selected = actor.id == selected_id
		sprite.visible = true
		sprite.queue_redraw()
func _process(delta: float) -> void:
	for id: int in actor_sprites:
		var sprite: Node2D = actor_sprites[id]
		if not sprite.visible:
			motions.erase(id)
			continue
		sprite.scale = Vector2.ONE*zoom
		if not motions.has(id):
			sprite.position = center(sprite.actor.pos)
			continue
		var motion: Dictionary = motions[id]
		motion.elapsed += delta
		while motion.elapsed >= 0.25 and not motion.route.is_empty():
			motion.from = motion.route.pop_front()
			motion.elapsed -= 0.25
		if motion.route.is_empty():
			motions.erase(id)
			sprite.position = center(sprite.actor.pos)
		else:
			sprite.position = center(motion.from).lerp(center(motion.route[0]),motion.elapsed/0.25)

func animate_motion(event: Dictionary) -> void:
	var id: int = event.actor_id
	if not actor_sprites.has(id) or event.route.is_empty(): return
	if motions.has(id): motions[id].route.append_array(event.route)
	else: motions[id] = {"from":event.from,"route":event.route.duplicate(),"elapsed":0.0}

func _draw_actor(_cell: Vector2i, _color: Color) -> void:
	pass

var visible_props: Array = []
var scenery: Node2D
func _draw_overlays() -> void:
	super._draw_overlays()
	if not is_instance_valid(scenery):
		scenery = preload("res://Production/UI/scenery_layer.gd").new()
		add_child(scenery)
		move_child(scenery,0)
	scenery.entries.clear()
	if map_data != null:
		for cell: Vector2i in visible_props:
			var prop: Dictionary = map_data.props[cell]
			scenery.entries.append({"point":center(cell),"kind":prop.kind,"opened":prop.opened,"zoom":zoom})
		for cell: Vector2i in map_data.links:
			var kind: String = map_data.links[cell].kind
			if kind in ["Well","Ladder","Underground","DungeonFloor","TowerFloor"]:
				scenery.entries.append({"point":center(cell),"kind":kind,"opened":false,"zoom":zoom})
	scenery.queue_redraw()

func _interaction_cell_at(point: Vector2):
	for sprite: Node2D in actor_sprites.values():
		if sprite.visible and point.distance_to(sprite.position+Vector2(0,-10)*zoom) < 22*zoom: return sprite.actor.pos
	return _cell_at(point)

var item_tooltips: Dictionary = {}
func _get_tooltip(at_position: Vector2) -> String:
	var cell = _interaction_cell_at(at_position)
	return item_tooltips.get(cell,"") if cell != null else ""
