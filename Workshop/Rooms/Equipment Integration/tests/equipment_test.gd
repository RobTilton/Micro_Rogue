extends SceneTree
const Items = preload("res://Production/Actors/items.gd")
const Rules = preload("res://Production/Actors/equipment_rules.gd")
const Combat = preload("res://Production/Actors/combat.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
var failures: int = 0
var checks: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Equipment Integration/tests/equipment_test.gd: "+message)
func fixed(base_id: String, tier: int, quality: int) -> Dictionary:
	var result: Dictionary = Items.generate({"base_id":base_id,"min_material_tier":tier,"max_material_tier":tier})
	var item: Dictionary = result.item
	item.quality = Items.generator.catalog.qualities[quality].duplicate(true)
	for base: Dictionary in Items.generator.catalog.base_types:
		if base.id == base_id:
			item.kind = Items.generator.catalog.categories[base.category].kind
			item.slot = Items.generator.catalog.categories[base.category].slot
			item = Rules.resolve(item,base)
	return item
func _initialize() -> void:
	var actor: Dictionary = Actors.create([6,6,6,6,6,6])
	actor.actions = Combat.allowance(actor)
	for base: Dictionary in Items.generator.catalog.base_types:
		var item: Dictionary = Items.generate({"base_id":base.id}).item
		check(Items.valid_generated(item),"valid generated "+base.id)
	var sword: Dictionary = fixed("swords_3",4,3)
	check(sword.die == 8 and sword.bonus == 5,"Masterwork Steel Longsword")
	var maul: Dictionary = fixed("maces_8",8,5)
	check(maul.die == 12 and maul.bonus == 12,"God-Touched Orichalcum Great Maul")
	var plate: Dictionary = fixed("plate_body_1",6,3)
	check(plate.physical_defense == 12 and plate.magical_defense == 8,"Masterwork tier6 plate")
	check(fixed("plate_head_1",6,3).physical_defense == 6 and fixed("plate_arms_1",6,3).physical_defense == 3 and fixed("plate_legs_1",6,3).magical_defense == 2,"slot weighting after quality")
	check(fixed("shields_1",6,3).physical_defense == 5,"shield half contribution")
	var expected: Array = [[4,2],[5,3],[6,4],[8,5],[9,5],[10,6],[11,7],[13,8]]
	for tier: int in range(1,9):
		var item: Dictionary = fixed("plate_body_1",tier,1)
		check([item.physical_defense,item.magical_defense] == expected[tier-1],"plate rounding "+str(tier))
		var cloth: Dictionary = fixed("cloth_body_1",tier,1)
		check([cloth.magical_defense,cloth.physical_defense] == expected[tier-1],"cloth rounding "+str(tier))
	actor.main = sword
	actor.off = {}
	check(Rules.stat_bonus(actor,sword)==6,"one hand sword")
	actor.grip = "two"
	check(Rules.stat_bonus(actor,sword)==12,"two hand sword")
	check(Rules.stat_bonus(actor,maul)==9,"two hand mace")
	check(not Rules.compatible(actor,Items.make("shield"),"off"),"two hand blocks shield")
	actor.grip = "one"
	actor.off = Items.make("shield")
	check(not Rules.compatible(actor,maul,"main"),"shield blocks maul")
	for slot: String in Rules.SLOTS: actor[slot] = {}
	actor.armor = plate
	check(Combat.defense(actor,"physical")==18 and Combat.defense(actor,"magical")==14,"innate plus fixed armor")
	actor.head = fixed("cloth_head_1",1,1)
	check(Combat.defense(actor,"physical")==19 and Combat.defense(actor,"magical")==16,"mixed armor accumulation")
	var source: Dictionary = Actors.create([1,1,1,1,1,1])
	var weak: Dictionary = {"die":1,"bonus":0,"category":"daggers","damage_type":"physical"}
	var hp: int = actor.hp
	check(Combat.attack(source,actor,weak,false,true,0)==0 and actor.hp==hp,"full absorption no minimum chip")
	for slot: String in Rules.SLOTS: actor[slot] = {}
	actor.stats.CON = 20
	actor.stats.WIL = 1
	weak.damage_type = "magical"
	check(Combat.attack(source,actor,weak,false,true,0)==1,"magical uses WIL not CON")
	check(bytes_to_var(var_to_bytes(sword))==sword,"resolved item serialization")
	var invalid: Dictionary = sword.duplicate(true)
	invalid.bonus = 999
	check(not Items.valid_generated(invalid),"tampered resolved stats refuse")
	print("Equipment rules: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
