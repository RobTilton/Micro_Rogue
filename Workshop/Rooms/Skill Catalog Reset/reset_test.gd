extends SceneTree
const Board = preload("res://Production/Actors/skill_board.gd")
func _initialize() -> void:
 assert(Board.DEFINITIONS.is_empty())
 var actor = {"skills":["Lunge","Riposte","Show-Off"],"points":2,"skill_board":Board.blank(),"clock_state":{"remaining":{"Lunge":3},"elapsed":{}},"riposte":true,"pending":{}}
 Board.remove_legacy_skills(actor)
 assert(actor.skills.is_empty() and actor.points == 5)
 assert(actor.clock_state.remaining.is_empty() and not actor.riposte)
 Board.remove_legacy_skills(actor)
 assert(actor.points == 5)
 print("Catalog reset: 4 checks passed")
 quit()
