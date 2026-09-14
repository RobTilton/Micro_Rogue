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
func _draw_overlays() -> void:
	super._draw_overlays()
	if map_data == null: return
	for cell: Vector2i in visible_props:
		var prop: Dictionary = map_data.props[cell]
		var point: Vector2 = center(cell)
		var color := Color("837b6d") if prop.opened else Color("dfb868")
		match prop.kind:
			"chest", "crate":
				draw_rect(Rect2(point-Vector2(13,9),Vector2(26,18)),color,false,2)
				draw_line(point+Vector2(-13,-3),point+Vector2(13,-3),color,2)
				if prop.kind == "crate": draw_line(point-Vector2(12,8),point+Vector2(12,8),color,2)
				elif not prop.opened: draw_rect(Rect2(point-Vector2(2,3),Vector2(4,6)),color)
			"barrel":
				draw_circle(point,11,color,false,2)
				draw_line(point+Vector2(-9,-4),point+Vector2(9,-4),color,2)
			"corpse", "bones":
				draw_line(point-Vector2(10,7),point+Vector2(10,7),color,3)
				draw_line(point-Vector2(10,-7),point+Vector2(10,-7),color,3)
				draw_circle(point+Vector2(0,-9),4,color)
			"rug": draw_rect(Rect2(point-Vector2(14,9),Vector2(28,18)),Color("74543c"))
			"rubble":
				for offset: Vector2 in [Vector2(-7,3),Vector2(0,-4),Vector2(8,4)]: draw_circle(point+offset,4,Color("89877d"))

func _interaction_cell_at(point: Vector2):
	for sprite: Node2D in actor_sprites.values():
		if sprite.visible and point.distance_to(sprite.position+Vector2(0,-10)*zoom) < 22*zoom: return sprite.actor.pos
	return _cell_at(point)
