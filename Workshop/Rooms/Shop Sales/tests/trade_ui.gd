extends "res://Production/UI/actor_game.gd"
var outcome: Dictionary = {}
func _ready() -> void: pass
func _finish(value: Dictionary, _advance_outside: bool = true) -> void: outcome = value
