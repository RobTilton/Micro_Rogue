extends RefCounted
const ARMOR_SLOTS = ["armor","head","arms","legs"]
const SLOTS = ["main","off","armor","head","arms","legs","belt"]
const QUALITY_MODIFIERS = [-1,0,1,2,3,5]
static func is_weapon(item: Dictionary) -> bool:
	return item.get("kind","") in ["sword","weapon"]
static func initialize(actor: Dictionary) -> void:
	for slot: String in SLOTS:
		if not actor.has(slot): actor[slot] = {}
	if not actor.has("grip"): actor.grip = "one"
static func hands(actor: Dictionary, weapon: Dictionary) -> int:
	if weapon.get("hands","one") == "two": return 2
	if weapon.get("hands","one") == "versatile" and actor.get("grip","one") == "two" and actor.off.is_empty(): return 2
	return 1
static func compatible(actor: Dictionary, item: Dictionary, slot: String) -> bool:
	if slot == "main": return is_weapon(item) and (item.get("hands","one") != "two" or actor.off.is_empty())
	if slot == "off":
		if not actor.main.is_empty() and hands(actor,actor.main) == 2: return false
		return item.kind == "shield" or (item.kind == "sword" and item.get("hands","one") != "two" and actor.main.get("kind") == "sword" and "Show-Off" in actor.skills)
	if slot in ARMOR_SLOTS: return item.kind == "armor" and item.get("slot","armor") == slot
	return slot == "belt" and item.kind == "belt"
static func defense_item(item: Dictionary, channel: String) -> int:
	if item.is_empty(): return 0
	if item.has("physical_defense"): return int(item[channel+"_defense"])
	# Legacy records keep their properties; interpret their former defense die as a fixed value.
	var legacy: int = maxi(0,int(item.get("die",0))+int(item.get("bonus",0))) if item.get("kind") in ["armor","shield"] else 0
	return roundi(legacy*0.5) if item.get("kind") == "shield" else legacy
static func stat_bonus(actor: Dictionary, weapon: Dictionary) -> int:
	var stats: Dictionary = actor.stats
	var two: bool = hands(actor,weapon) == 2
	match weapon.get("category","swords"):
		"bows": return stats.STR
		"staffs": return stats.INT
		"maces": return floori(stats.STR*1.5) if two else stats.STR
		_: return floori(stats.STR*1.5) if two else stats.STR
static func resolve(item: Dictionary, base: Dictionary, weapon_scale: int = 2) -> Dictionary:
	item = item.duplicate(true)
	item.rules_version = 1
	item.rarity = ["trash","common","exceptional","masterwork","mythic","touched_by_the_gods"].find(item.quality.id)
	var quality: int = QUALITY_MODIFIERS[item.rarity]
	item.bonus = quality
	item.die = 0
	item.appearance = item.material.name+" "+item.base_name
	if item.slot == "body": item.slot = "armor"
	if item.kind == "weapon":
		if item.category == "swords": item.kind = "sword"
		item.die = int(base.damage_die)
		item.rules_version = weapon_scale
		item.bonus = int(base.damage_flat)+weapon_scale*(item.material_tier-1+quality)
		item.hands = base.hands
		item.damage_type = base.damage_type
		item.range = int(base.range)
	elif item.kind in ["armor","shield"]:
		var baseline: int = item.material_tier+2
		var skew: float = 0.0
		if item.kind == "armor":
			if item.category.begins_with("plate_"): skew = 0.25
			elif item.category.begins_with("cloth_"): skew = -0.25
		item.physical_defense = maxi(0,roundi(baseline*(1.0+skew))+quality)
		item.magical_defense = maxi(0,roundi(baseline*(1.0-skew))+quality)
		var contribution: float = 0.5 if item.kind == "shield" or item.slot == "head" else 0.25 if item.slot in ["arms","legs"] else 1.0
		item.physical_defense = roundi(item.physical_defense*contribution)
		item.magical_defense = roundi(item.magical_defense*contribution)
	return item

static func damage_bonus(item: Dictionary) -> int:
	var bonus: int = int(item.get("bonus",0))
	# Existing v1 gear receives current balance without rewriting saved identities/properties.
	if is_weapon(item) and item.get("rules_version",0) == 1:
		bonus += int(item.material_tier)-1+int(item.quality.modifier)
	return bonus
