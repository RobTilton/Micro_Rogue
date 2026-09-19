extends "res://Production/UI/actor_sprite.gd"
func _draw() -> void:
	if not actor.has("adventure"):
		super._draw()
		return
	# Render a friendly humanoid without mutating the simulation's faction.
	var original: Dictionary = actor
	actor = actor.duplicate()
	actor.faction = "player"
	super._draw()
	actor = original
	draw_string(ThemeDB.fallback_font,Vector2(-35,-44),actor.name+(" (retired)" if actor.get("retired",false) else ""),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("f2dfa7"))
