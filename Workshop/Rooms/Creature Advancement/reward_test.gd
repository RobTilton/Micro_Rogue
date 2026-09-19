extends SceneTree
const Actors = preload("res://Production/Actors/actors.gd")
func _initialize() -> void:
 var human = Actors.create([3,3,3,3,3,3],true,null,true)
 var beast = Actors.create([3,3,3,3,3,3],true,null,false)
 Actors.award_xp(human,15)
 Actors.award_xp(beast,15)
 assert(human.level == 3 and human.points == 2)
 assert(beast.level == 3 and beast.points == 4)
 assert(not beast.can_use_skills)
 assert(Actors.level_point_reward({}) == 1)
 print("Creature advancement: 4 checks passed")
 quit()
