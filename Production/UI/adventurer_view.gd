extends "res://Production/UI/actor_view.gd"
const AdventurerSprite = preload("res://Production/UI/adventurer_sprite.gd")
func show_actors(actors: Array[Dictionary], selected_id: int) -> void:
	for sprite: Node2D in actor_sprites.values(): sprite.visible = false
	for actor: Dictionary in actors:
		if not actor_sprites.has(actor.id):
			var sprite := AdventurerSprite.new()
			sprite.position = center(actor.pos)
			sprite.scale = Vector2.ONE*zoom
			add_child(sprite)
			actor_sprites[actor.id] = sprite
		var sprite: Node2D = actor_sprites[actor.id]
		sprite.actor = actor
		sprite.selected = actor.id == selected_id
		sprite.visible = true
		sprite.queue_redraw()
