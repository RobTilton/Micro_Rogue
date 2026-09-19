extends SceneTree
const Momentum = preload("res://Production/Actors/momentum.gd")
const Actors = preload("res://Production/Actors/actors.gd")
func _initialize() -> void:
 var actor = Actors.create([3,3,1,3,3,3])
 actor.actions = {"free":0}
 actor.stats.DEX = 0
 assert(Momentum.speed(actor) == 3.0)
 assert(Momentum.grants(actor,3) == 1)
 actor.stats.DEX = 1
 assert(Momentum.speed(actor) == 3.0)
 actor.stats.DEX = 2
 assert(Momentum.speed(actor) == 4.0)
 actor.stats.DEX = 3
 assert(Momentum.speed(actor) == 4.0)
 actor.momentum = 0.0
 assert(Momentum.grants(actor,3) == 1)
 assert(Momentum.grants(actor,3) == 1)
 assert(Momentum.grants(actor,3) == 2)
 actor.stats.DEX = 6
 assert(Momentum.speed(actor) == 6.0)
 actor.stats.DEX = 0
 assert(Momentum.speed(actor,5) == 5.0)
 assert(Momentum.grants(actor,5) == 1)
 actor.speed_effects = {"test":-2.0}
 assert(Momentum.speed(actor) == 1.0)
 print("Innate momentum: 12 checks passed")
 quit()
