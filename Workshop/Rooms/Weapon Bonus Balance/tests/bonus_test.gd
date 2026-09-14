extends SceneTree
const Rules = preload("res://Production/Actors/equipment_rules.gd")
const Items = preload("res://Production/Actors/items.gd")
const Inspect = preload("res://Production/Actors/item_inspection.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Weapon Bonus Balance/tests/bonus_test.gd: "+message)
func _initialize() -> void:
	for base: Dictionary in Items.generator.catalog.base_types:
		var category: Dictionary = Items.generator.catalog.categories[base.category]
		if category.kind != "weapon": continue
		for tier: int in range(1,9):
			for quality: Dictionary in Items.generator.catalog.qualities:
				var raw: Dictionary = {"quality":quality,"material":{"name":"Test"},"material_tier":tier,"base_name":base.name,"slot":category.slot,"category":base.category,"kind":category.kind}
				var current: Dictionary = Rules.resolve(raw,base)
				var legacy: Dictionary = Rules.resolve(raw,base,1)
				check(current.bonus == int(base.damage_flat)+2*(tier-1+int(quality.modifier)) and current.die == int(base.damage_die),"only tier and quality doubled")
				check(Rules.damage_bonus(legacy) == Rules.damage_bonus(current),"saved v1 and new v2 damage match")
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var generated: Dictionary = Items.generate({"base_id":"swords_1","min_material_tier":1,"max_material_tier":1},rng).item
	check(Items.valid_generated(generated),"new weapon validates")
	var legacy: Dictionary = generated.duplicate(true)
	legacy.rules_version = 1
	legacy.bonus -= legacy.material_tier-1+int(legacy.quality.modifier)
	check(Items.valid_generated(legacy),"legacy weapon still validates")
	for iteration: int in range(20):
		var roll: int = Items.roll(legacy)
		check(roll >= 1+Rules.damage_bonus(legacy) and roll <= legacy.die+Rules.damage_bonus(legacy),"combat roll uses current bonus for old weapon")
	var armor: Dictionary = Items.generate({"category":"leather_body","min_material_tier":1,"max_material_tier":1},rng).item
	check(armor.rules_version == 1 and Items.valid_generated(armor),"armor rules unchanged")
	print("Weapon Bonus: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
