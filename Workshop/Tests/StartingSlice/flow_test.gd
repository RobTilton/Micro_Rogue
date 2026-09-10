extends SceneTree
const Main = preload("res://Production/Gameplay/main.gd")
var game: Control
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	game = Main.new()
	root.add_child(game)
	await process_frame
	game._new_character()
	assert(game.dice_slots.size() == 12)
	game._swap_dice(0,6)
	assert(game.dice_slots[6] > 0 and game.dice_slots[0] == 0)
	game.dice_slots = [0,0,0,0,0,0,3,4,2,1,5,6]
	game._start_run()
	await process_frame
	assert(game.player.hp == 18 and game.actions.attack == 1)
	game.player.skills = ["Lunge", "Riposte", "Show-Off"]
	game.player.off = {"kind":"sword", "die":1, "bonus":0, "name":"Test Sword"}
	game.actions = game.Combat.allowance(game.player)
	game.enemy.pos = Vector2i(4,3)
	game.enemy.hp = 1000
	game.enemy.max_hp = 1000
	game.mode = "lunge"
	game._refresh()
	game._cell_selected(Vector2i(3,3))
	assert(game.player.pos == Vector2i(3,3) and game.actions.attack == 1)
	assert(not game.pending_weapon.is_empty())
	game._cell_selected(game.enemy.pos)
	assert(game.pending_weapon.is_empty())
	game.player.hp = game.player.max_hp
	game._riposte()
	assert(game.player.riposte and game.actions.attack == 0)
	game.enemy.main = {"kind":"sword", "die":1, "bonus":-100, "name":"Test Sword"}
	game.enemy.belt.contents = []
	game._end_turn()
	assert(not game.player.riposte)
	game.enemy.hp = 0
	game._check_death()
	game._refresh()
	assert(not game.battle and game.loot.size() == 4 and game.player.xp == 1)
	game.player.pos = game.enemy.pos + Vector2i(-1,0)
	game._take(0)
	assert(game.player.bag.size() == 1)
	game._equip(0)
	assert(game.player.off.kind == "sword")
	game._spawn_enemy()
	game.player.hp = 0
	game._check_death()
	game._refresh()
	game._new_character()
	await process_frame
	print("res://Workshop/Tests/StartingSlice/flow_test.gd: creation, arena, lunge, riposte, loot, equipment, next encounter and death flow passed")
	game.queue_free()
	await process_frame
	quit()
