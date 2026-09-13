extends "res://Workshop/Rooms/Regional Release/UI/world_view.gd"
const Sprite = preload("res://Workshop/Rooms/Regional Release/UI/actor_sprite.gd")
var actor_sprites: Dictionary = {}
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
func _process(_delta: float) -> void:
	for sprite: Node2D in actor_sprites.values():
		if sprite.visible: sprite.position = center(sprite.actor.pos)
func _draw_actor(_cell: Vector2i, _color: Color) -> void:
	pass
