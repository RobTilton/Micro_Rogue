extends SceneTree
const Actors = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/actors.gd")
const Combat = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/combat.gd")
const Items = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/items.gd")
const Inventory = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/inventory.gd")
var checks: int = 0
func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		push_error("res://Workshop/Rooms/UI Foundation/Prototype/tests/baseline_rules_test.gd: " + description)
		quit(1)
func _initialize() -> void:
	seed(713)
	var actor: Dictionary = Actors.create([3,4,2,1,5,6])
	check(actor.max_hp == 18, "WIL maximum HP")
	actor.hp = 17
	check(Combat.heal(actor) == 1 and actor.hp == 18, "Healing caps at max")
	for mode: int in range(3):
		check(Combat.final_damage(-8.0,true,mode) == 0, "No negative damage")
	check(Combat.final_damage(1.5,true,0) == 2, "Normal outgoing rounds up")
	check(Combat.final_damage(1.5,false,0) == 1, "Normal incoming rounds down")
	check(Combat.final_damage(1.5,false,1) == 2, "Hard incoming rounds up")
	check(Combat.final_damage(1.5,true,2) == 1, "True Rogue outgoing rounds down")
	check(Combat.final_damage(1.5,false,2) == 2, "True Rogue incoming rounds up")
	var sword: Dictionary = {"die": 1, "bonus": 0, "kind": "sword", "name": "Test sword"}
	check(Combat.weapon_damage(actor,sword) == 4.0, "Sword scaling, no duplicate STR")
	actor.stats.STR += 4
	check(Combat.weapon_damage(actor,sword) == 6.0, "Live stat effects")
	actor.stats.STR -= 4
	actor.skills = ["Lunge", "Riposte", "Show-Off"]
	actor.off = sword
	var actions: Dictionary = Combat.allowance(actor)
	check(actions.attack == 2, "Show-Off extra attack")
	for expected: Array in [[2,1,0],[1,1,0],[0,1,0],[0,0,0]]:
		check(Combat.loot_cost(actions), "Loot consumes action")
		check([actions.attack,actions.move,actions.activation] == expected, "Loot action priority")
	check(not Combat.loot_cost(actions), "No free looting after exhausted actions")
	Actors.award_xp(actor, 15)
	check(actor.level == 3 and actor.points == 3 and actor.required_xp == 20 and actor.xp == 0, "XP multiple thresholds")
	actor.belt.contents = []
	Inventory.receive(actor,Items.potion())
	check(actor.belt.contents.size() == 1, "Loot potion to belt")
	var stocked: Dictionary = Items.make("belt")
	stocked.contents = [Items.potion(),Items.potion()]
	actor.bag = [stocked]
	var old_belt: Dictionary = actor.belt
	check(Inventory.equip(actor,0), "Equip stocked belt")
	check(actor.belt.contents.size() == 2 and actor.bag[0] == old_belt, "Belt contents persist")
	var foe: Dictionary = Actors.create([1,1,1,1,1,1],true)
	foe.belt.contents = [Items.potion()]
	foe.belt.contents.pop_back()
	var drops: Array = Inventory.possessions(foe)
	check(drops[0] == foe.main and drops[3].contents.is_empty(), "Drop actual possessions")
	for index: int in range(1000):
		var generated: Dictionary = Actors.create(Actors.dice(),true)
		check(generated.main.rarity <= 1 and generated.armor.rarity <= 1 and generated.belt.rarity <= 1, "Enemy rarity limits")
		check(generated.belt.contents.size() <= generated.belt.capacity, "Belt capacity")
	print("res://Workshop/Rooms/UI Foundation/Prototype/tests/baseline_rules_test.gd: %d checks passed" % checks)
	quit()
