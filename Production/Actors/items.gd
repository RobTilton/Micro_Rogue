extends RefCounted
const Generator = preload("res://Production/Actors/loot_generator.gd")
const Rings = preload("res://Production/Actors/rings.gd")
const Rules = preload("res://Production/Actors/equipment_rules.gd")
static var generator = Generator.new()
static var next_item_id: int = 1
const RARITIES = ["Trash","Common","Exceptional","Masterwork","Mythic","Touched by the Gods"]
const BONUS = [-1,0,1,2,3,5]
static func identity() -> int:
	var result: int = next_item_id
	next_item_id += 1
	return result
static func quality(_enemy: bool = false, rng: RandomNumberGenerator = null) -> int:
	var roll_value: int = randi_range(1,1000) if rng == null else rng.randi_range(1,1000)
	return ["trash","common","exceptional","masterwork","mythic","touched_by_the_gods"].find(generator.quality_at(roll_value).id)
static func generate(request: Dictionary, rng: RandomNumberGenerator = null) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var input: Dictionary = request.duplicate(true)
	input.item_id = next_item_id
	var result: Dictionary = generator.generate(rng,input)
	if not result.ok: return result
	for base: Dictionary in generator.catalog.base_types:
		if base.id == result.item.base_id:
			result.item = Rules.resolve(result.item,base)
			break
	next_item_id += 1
	return result
static func make(kind: String, _enemy: bool = false, rng: RandomNumberGenerator = null) -> Dictionary:
	# Provisional starter policy, shared by player and NPC; source progression remains separate.
	var request: Dictionary = {"min_material_tier":1,"max_material_tier":3}
	match kind:
		"sword": request.base_id = "swords_1"
		"shield": request.category = "shields"
		"armor": request.category = ["plate_body","leather_body","cloth_body"][randi_range(0,2) if rng == null else rng.randi_range(0,2)]
		"belt": request.category = "belts"
		_: request.category = kind
	var result: Dictionary = generate(request,rng)
	if not result.ok:
		push_error("Production/Actors/items.gd: "+result.error)
		return {}
	if kind == "belt":
		for slot: int in range(result.item.capacity):
			if (randf() if rng == null else rng.randf()) < 0.05:
				var bottle: Dictionary = potion()
				bottle.pouch = slot
				result.item.contents.append(bottle)
	return result.item
static func potion() -> Dictionary:
	return {"item_id":identity(),"kind":"potion","name":"Lesser Health","appearance":"Glass potion bottle"}
static func roll(item: Dictionary) -> int:
	return randi_range(1,item.die)+Rules.damage_bonus(item)
static func valid_generated(item: Dictionary) -> bool:
	if item.get("rules_version") not in [1,2] or not item.get("base_id") is String or not item.get("quality") is Dictionary or not item.get("material") is Dictionary: return false
	for field: String in ["material_tier","base_rank","rarity","die","bonus","capacity"]:
		if not item.get(field) is int: return false
	var base: Dictionary = {}
	for candidate: Dictionary in generator.catalog.base_types:
		if candidate.id == item.base_id: base = candidate; break
	if base.is_empty() or item.get("category") != base.category or item.base_rank != int(base.rank): return false
	var category: Dictionary = generator.catalog.categories[base.category]
	var matching: bool = false
	for family: String in base.get("material_families",category.material_families):
		for candidate: Dictionary in generator.catalog.material_families[family]:
			if candidate.id == item.material.get("id") and candidate.name == item.material.get("name") and int(candidate.tier) == item.material_tier and item.material.get("tier") == candidate.tier and item.material.get("family") == family: matching = true
	if not matching: return false
	matching = false
	for candidate: Dictionary in generator.catalog.qualities:
		if item.quality.get("id") == candidate.id and item.quality.get("name") == candidate.name and item.quality.get("color") == candidate.color and item.quality.get("modifier") == candidate.modifier: matching = true
	if not matching or not item.get("affixes") is Dictionary: return false
	for layer: String in generator.catalog.affix_layers:
		if not item.affixes.get(layer) is Array or not item.affixes[layer].is_empty(): return false
	var expected: Dictionary = Rules.resolve({"quality":item.quality,"material":item.material,"material_tier":item.material_tier,"base_name":base.name,"slot":category.slot,"category":base.category,"kind":category.kind},base,int(item.rules_version))
	for field: String in ["kind","slot","die","bonus","rarity"]:
		if item.get(field) != expected[field]: return false
	if Rules.is_weapon(item):
		for field: String in ["hands","damage_type","range"]:
			if item.get(field) != expected[field]: return false
	elif item.kind in ["armor","shield"]:
		for field: String in ["physical_defense","magical_defense"]:
			if not item.get(field) is int or item[field] != expected[field]: return false
	if item.kind == "belt":
		var version = item.get("belt_capacity_version",1)
		if not version is int or version not in [1,2]: return false
		var expected_capacity: int = Generator.belt_capacity(item) if version == 2 else (1 if item.quality.id == "trash" else 2)
		if item.capacity != expected_capacity: return false
	return true

static func ration() -> Dictionary:
	return {"item_id":identity(),"kind":"ration","name":"Travel Ration","appearance":"Wrapped travel food"}

static func upgrade_belts(value: Variant) -> void:
	# Called only after save validation; visit actors, shops, ground and archived containers.
	if value is Dictionary:
		if value.get("kind","") == "belt" and value.has("material_tier"):
			value.capacity = Generator.belt_capacity(value)
			value.belt_capacity_version = 2
		for child: Variant in value.values(): upgrade_belts(child)
	elif value is Array:
		for child: Variant in value: upgrade_belts(child)

# Independent non-equipment layer; equipment-only callers retain generate().
static func loot(request: Dictionary, rng: RandomNumberGenerator, supplies: bool = false) -> Dictionary:
	if not supplies and rng.randf() < 0.05: return {"ok":true,"item":Rings.generate(identity(),rng)}
	if supplies or rng.randf() < 0.20: return {"ok":true,"item":potion()}
	return generate(request,rng)
