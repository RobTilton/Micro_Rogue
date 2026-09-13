extends SceneTree
const Generator = preload("res://Workshop/Rooms/Loot Foundation/domain/loot_generator.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("Workshop/Rooms/Loot Foundation/tests/loot_test.gd: "+message)
func _initialize() -> void:
	var generator = Generator.new()
	check(generator.error.is_empty(),generator.error)
	if not generator.error.is_empty(): quit(1); return
	check(generator.catalog.base_types.size() == 161,"160 supplied bases plus belt")
	var counts: Dictionary = {}
	for roll: int in range(1,101):
		var quality: Dictionary = generator.quality_at(roll)
		counts[quality.id] = counts.get(quality.id,0)+1
	check(counts == {"trash":20,"common":40,"exceptional":20,"masterwork":15,"mythic":4,"touched_by_the_gods":1},"exact probability partition")
	check(generator.quality_at(0).is_empty() and generator.quality_at(101).is_empty(),"quality boundaries")
	var rng = RandomNumberGenerator.new()
	var twin = RandomNumberGenerator.new()
	rng.seed = 4107
	twin.seed = 4107
	var samples: Array = []
	for index: int in range(300):
		var result: Dictionary = generator.generate(rng,{"item_id":index+1})
		check(result.ok and result == generator.generate(twin,{"item_id":index+1}),"seeded reproducibility")
		samples.append(result.item)
	check(bytes_to_var(var_to_bytes(samples)) == samples,"save-safe record roundtrip")
	for base: Dictionary in generator.catalog.base_types:
		var result: Dictionary = generator.generate(rng,{"item_id":1000,"base_id":base.id})
		check(result.ok and result.item.base_id == base.id and result.item.affixes == {"prefixes":[],"suffixes":[]},"all base types generate")
	for tier: int in range(1,9):
		var item: Dictionary = generator.generate(rng,{"item_id":1001,"base_id":"swords_1","min_material_tier":tier,"max_material_tier":tier}).item
		check(item.base_rank == 1 and item.material_tier == tier,"independent base and material ranks")
	var saw_trash: bool = false
	var saw_other: bool = false
	for index: int in range(200):
		var item: Dictionary = generator.generate(rng,{"item_id":1002,"category":"belts"}).item
		check(item.material.family == "leather" and item.capacity == (1 if item.quality.id == "trash" else 2),"belt capacity/material contract")
		saw_trash = saw_trash or item.quality.id == "trash"
		saw_other = saw_other or item.quality.id != "trash"
	check(saw_trash and saw_other,"both belt outcomes exercised")
	for request: Dictionary in [{},{"item_id":-1},{"item_id":1,"category":"rings"},{"item_id":1,"base_id":"swords_1","material_family":"cloth"},{"item_id":1,"min_base_rank":8,"max_base_rank":1},{"item_id":1,"affixes":["fire"]},{"item_id":1,"min_material_tier":1.5},{"item_id":1,"material_id":"missing"}]:
		var state: int = rng.state
		check(not generator.generate(rng,request).ok and rng.state == state,"atomic invalid request refusal")
	# Demonstrate future jewelry and another affix layer by data registration only.
	var extended: Dictionary = generator.catalog.duplicate(true)
	extended.slots.append("ring")
	extended.affix_layers.append("implicit")
	extended.categories.rings = {"name":"Rings","kind":"jewelry","slot":"ring","material_families":["metal","gem"]}
	extended.base_types.append({"id":"test_ring","name":"Test Ring","rank":1,"category":"rings"})
	var jewelry = Generator.new(extended)
	var ring: Dictionary = jewelry.generate(rng,{"item_id":2000,"category":"rings","material_family":"gem"})
	check(ring.ok and ring.item.slot == "ring" and ring.item.material.family == "gem" and ring.item.affixes.implicit.is_empty(),"data-only ring and layer extension: "+str(ring))
	var before: Dictionary = generator.catalog.duplicate(true)
	var mutable: Dictionary = generator.generate(rng,{"item_id":2001}).item
	mutable.material.name = "changed"
	mutable.quality.name = "changed"
	mutable.affixes.prefixes.append("changed")
	check(generator.catalog == before,"output does not alias catalog")
	for field: String in ["qualities","slots","categories","material_families","base_types"]:
		var malformed: Dictionary = before.duplicate(true)
		malformed[field] = []
		var invalid = Generator.new(malformed)
		check(not invalid.error.is_empty() and not invalid.generate(rng,{"item_id":1}).ok,"bad catalog refuses "+field)
	print("Loot Foundation: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
