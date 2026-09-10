extends SceneTree
const Main = preload("res://Production/Gameplay/main.gd")
const Cooldowns = preload("res://Production/Gameplay/cooldowns.gd")
const Items = preload("res://Production/Gameplay/items.gd")
var checks: int = 0
var failures: int = 0
func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("res://Workshop/Tests/StartingSlice/inventory_cooldowns_test.gd: " + description)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var clock: RefCounted = Cooldowns.new()
	clock.start("Lunge", 4)
	for expected: int in [3,2,1,0]:
		check(not clock.ready("Lunge"), "Lunge locked until fourth End Turn")
		clock.end_turn()
		check(clock.ticks("Lunge") == expected, "End Turn decrement")
	check(clock.ready("Lunge"), "Lunge available after fourth End Turn")
	clock.start("Riposte", 2)
	clock.end_turn()
	check(not clock.ready("Riposte"), "Riposte unavailable on following turn")
	clock.end_turn()
	check(clock.ready("Riposte"), "Riposte ready after second End Turn")
	clock.start("future_spell", 4)
	check(not clock.advance_outside(2.99), "No early real-time tick")
	check(clock.advance_outside(0.02) and clock.ticks("future_spell") == 3, "Three seconds per tick")
	clock.advance_outside(6.0)
	check(clock.ticks("future_spell") == 1, "Large frame catches up")
	clock.enter_combat()
	check(clock.ticks("future_spell") == 1, "Entering combat does not reset cooldown")
	clock.end_turn()
	check(clock.ready("future_spell"), "Mixed clock reaches ready")
	var game: Control = Main.new()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,3,4,2,1,5,6]
	game._start_run()
	game.player.skills = ["Lunge", "Riposte", "Show-Off"]
	game.player.off = Items.make("sword")
	game.actions = game.Combat.allowance(game.player)
	game.enemy.hp = 1000
	game.enemy.max_hp = 1000
	game.enemy.main = {"kind":"sword", "die":1, "bonus":-100, "name":"Test sword"}
	game.mode = "lunge"
	game._refresh()
	game._cell_selected(Vector2i(2,3))
	check(game.cooldowns.ticks("Lunge") == 4, "Movement-only Lunge starts cooldown")
	game.pending_weapon = {}
	game.mode = "lunge"
	game._refresh()
	game._cell_selected(Vector2i(3,3))
	check(game.player.pos == Vector2i(2,3) and game.actions.attack == 1, "Show-Off cannot bypass Lunge cooldown")
	game._end_turn()
	check(game.cooldowns.ticks("Lunge") == 3, "Wired End Turn ticks once")
	game._riposte()
	check(game.cooldowns.ticks("Riposte") == 2, "Riposte starts two ticks")
	game._end_turn()
	check(game.cooldowns.ticks("Riposte") == 1 and not game._skill_available("Riposte"), "Riposte following-turn gate")
	game.player.belt.contents = [Items.potion(), Items.potion()]
	game._remove_potion(-1)
	check(game.actions.activation == 0 and game.player.bag.size() == 1 and game.player.belt.contents.size() == 1, "Remove potion costs activation and transfers once")
	game._drop_item("bag",0)
	check(game.loot.is_empty() and game.player.bag.size() == 1, "Exhausted activation blocks dropping")
	game.actions.activation = 1
	var location: Vector2i = game.player.pos
	game._drop_item("belt")
	check(game.player.belt.is_empty() and game.loot[0].pos == location and game.loot[0].item.contents.size() == 1, "Drop stocked equipped belt at feet")
	check(game.actions.activation == 0, "Equipped drop activation cost")
	game._drink()
	game._end_turn()
	check(game.player.hp > 0, "Missing belt is safe in combat")
	game.actions.activation = 1
	game._take(0)
	check(game.loot.is_empty() and game.player.bag.size() == 2, "Belt picked up intact")
	game.actions.activation = 1
	game._equip(1)
	check(game.player.belt.contents.size() == 1 and game.player.bag.size() == 1, "Reequip into empty slot without phantom item")
	game.battle = false
	game._drop_item("bag",0)
	check(game.loot.size() == 1, "Outside drop free")
	game.player.pos = Vector2i(0,0)
	game._take(0)
	check(game.loot.size() == 1, "Cannot take distant drop")
	game._drop_item("armor")
	check(game.loot.size() == 2 and game.loot[1].pos == Vector2i(0,0), "Separate ground positions")
	check(game.Combat.defense(game.player) >= 0, "Defense supports empty armor")
	game._drop_item("main")
	game._drop_item("off")
	check(game.player.main.is_empty() and not game._skill_available("Lunge"), "Empty weapons cannot attack")
	game.cooldowns.start("Lunge",4)
	game._process(3.0)
	check(game.cooldowns.ticks("Lunge") == 3, "Outside scene clock wired")
	game._spawn_enemy()
	game._process(30.0)
	check(game.cooldowns.ticks("Lunge") == 3, "Real time cannot cool in combat or reset at encounter")
	check(game.loot[0].pos == location and game.loot[1].pos == Vector2i(0,0), "Encounter preserves drop locations")
	game._new_character()
	game._process(30.0)
	check(game.cooldowns.ticks("Lunge") == 3, "Creation screen cannot tick old actor")
	game.queue_free()
	await process_frame
	print("res://Workshop/Tests/StartingSlice/inventory_cooldowns_test.gd: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
