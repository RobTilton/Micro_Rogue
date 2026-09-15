extends RefCounted
## Independent item construction. The caller owns RNG, unique IDs and progression policy.
const CATALOG_PATH = "res://Production/Actors/loot_catalog.json"
const ORIGIN = "Production/Actors/loot_generator.gd"
var catalog: Dictionary = {}
var error: String = ""

func _init(definitions: Dictionary = {}) -> void:
	if definitions.is_empty():
		var decoded = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
		if not decoded is Dictionary:
			error = ORIGIN+": invalid catalog JSON"
			return
		definitions = decoded
	catalog = definitions.duplicate(true)
	error = validate_catalog(catalog)

static func whole(value, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(float(value)) and value >= minimum and value <= maximum

static func validate_catalog(data: Dictionary) -> String:
	var reason: String = _catalog_error(data)
	return "" if reason.is_empty() else ORIGIN+": "+reason

static func _catalog_error(data: Dictionary) -> String:
	if data.get("schema_version") != 1: return "unsupported catalog schema"
	for field: String in ["material_families","categories"]:
		if not data.get(field) is Dictionary or data[field].is_empty(): return "missing "+field
	for field: String in ["qualities","slots","affix_layers","base_types"]:
		if not data.get(field) is Array or data[field].is_empty(): return "missing "+field
	for field: String in ["slots","affix_layers"]:
		var seen: Array = []
		for value in data[field]:
			if not value is String or value.is_empty() or value in seen: return "invalid "+field
			seen.append(value)
	var material_ids: Array = []
	for family in data.material_families:
		if not (family is String or family is StringName) or str(family).is_empty() or not data.material_families[family] is Array or data.material_families[family].is_empty(): return "invalid material family"
		for material in data.material_families[family]:
			if not _named(material) or not whole(material.get("tier"),1,8) or material.id in material_ids: return "invalid material"
			material_ids.append(material.id)
	var quality_ids: Array = []
	var total: int = 0
	for quality in data.qualities:
		if not _named(quality) or quality.id in quality_ids or not quality.get("color") is String or not whole(quality.get("weight"),1,100): return "invalid quality"
		quality_ids.append(quality.id)
		total += int(quality.weight)
	if total != 100: return "quality weights must total 100"
	for category_id in data.categories:
		var category = data.categories[category_id]
		if not (category_id is String or category_id is StringName) or str(category_id).is_empty() or not category is Dictionary: return "invalid category"
		for field: String in ["name","kind","slot"]:
			if not category.get(field) is String or category[field].is_empty(): return "invalid category "+field
		if category.slot not in data.slots or not _families(category.get("material_families"),data): return "invalid category compatibility"
	var base_ids: Array = []
	for base in data.base_types:
		if not _named(base) or base.id in base_ids or not base.get("category") is String or not data.categories.has(base.category) or not whole(base.get("rank"),1,8): return "invalid base type"
		if base.has("material_families") and not _families(base.material_families,data): return "invalid base compatibility"
		if data.categories[base.category].kind == "belt" and not whole(base.get("base_capacity"),1,100): return "invalid belt capacity"
		base_ids.append(base.id)
	return ""

static func _named(value) -> bool:
	return value is Dictionary and value.get("id") is String and not value.id.is_empty() and value.get("name") is String and not value.name.is_empty()

static func _families(value, data: Dictionary) -> bool:
	if not value is Array or value.is_empty(): return false
	var seen: Array = []
	for family in value:
		if not family is String or not data.material_families.has(family) or family in seen: return false
		seen.append(family)
	return true

func _materials(base: Dictionary, request: Dictionary) -> Array:
	var result: Array = []
	var category: Dictionary = catalog.categories[base.category]
	for family: String in base.get("material_families",category.material_families):
		if request.has("material_family") and request.material_family != family: continue
		for material: Dictionary in catalog.material_families[family]:
			if request.has("material_id") and request.material_id != material.id: continue
			if material.tier < request.get("min_material_tier",1) or material.tier > request.get("max_material_tier",8): continue
			var entry: Dictionary = material.duplicate(true)
			entry.family = family
			result.append(entry)
	return result

func generate(rng: RandomNumberGenerator, request: Dictionary) -> Dictionary:
	if not error.is_empty(): return {"ok":false,"error":error}
	if rng == null: return _refuse("caller RNG is required")
	# Validate before drawing randomness. Rejected requests leave caller RNG untouched.
	for key in request:
		if key not in ["item_id","base_id","category","material_family","material_id","min_base_rank","max_base_rank","min_material_tier","max_material_tier"]: return _refuse("unknown request field: "+str(key))
	if not request.get("item_id") is int or request.item_id <= 0: return _refuse("positive caller-owned item_id required")
	for field: String in ["base_id","category","material_family","material_id"]:
		if request.has(field) and (not request[field] is String or request[field].is_empty()): return _refuse("invalid "+field)
	for field: String in ["min_base_rank","max_base_rank","min_material_tier","max_material_tier"]:
		if request.has(field) and not whole(request[field],1,8): return _refuse("invalid "+field)
	if request.get("min_base_rank",1) > request.get("max_base_rank",8) or request.get("min_material_tier",1) > request.get("max_material_tier",8): return _refuse("inverted rank/tier bounds")
	var candidates: Array = []
	for base: Dictionary in catalog.base_types:
		if request.has("base_id") and request.base_id != base.id: continue
		if request.has("category") and request.category != base.category: continue
		if base.rank < request.get("min_base_rank",1) or base.rank > request.get("max_base_rank",8): continue
		var materials: Array = _materials(base,request)
		if not materials.is_empty(): candidates.append({"base":base,"materials":materials})
	if candidates.is_empty(): return _refuse("no compatible base/material matches request")
	var selected: Dictionary = candidates[rng.randi_range(0,candidates.size()-1)]
	var base: Dictionary = selected.base
	var material: Dictionary = selected.materials[rng.randi_range(0,selected.materials.size()-1)].duplicate(true)
	var category: Dictionary = catalog.categories[base.category]
	var quality: Dictionary = quality_at(rng.randi_range(1,100))
	var layers: Dictionary = {}
	for layer: String in catalog.affix_layers: layers[layer] = []
	var item: Dictionary = {
		"schema_version":1,"item_id":request.item_id,"base_id":base.id,
		"base_name":base.name,"base_rank":int(base.rank),"category":base.category,
		"kind":category.kind,"slot":category.slot,"material":material,
		"material_tier":int(material.tier),"quality":quality,"affixes":layers,
		"name":quality.name+" "+material.name+" "+base.name,
		"contents":[],"capacity":0
	}
	if category.kind == "belt":
		item.capacity = belt_capacity(item)
		item.belt_capacity_version = 2
	return {"ok":true,"item":item}

func quality_at(roll: int) -> Dictionary:
	if not error.is_empty() or roll < 1 or roll > 100: return {}
	for quality: Dictionary in catalog.qualities:
		roll -= int(quality.weight)
		if roll <= 0: return quality.duplicate(true)
	return {}

static func _refuse(reason: String) -> Dictionary:
	return {"ok":false,"error":ORIGIN+": "+reason}

static func belt_capacity(item: Dictionary) -> int:
	var bonus: int = {"trash":-1,"common":0,"exceptional":1,"masterwork":2,"mythic":3,"touched_by_the_gods":5}.get(item.quality.id,0)
	return clampi(2+int(item.material_tier)-1+bonus,1,14)
