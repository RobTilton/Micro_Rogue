extends RefCounted
## Base stats remain permanent; equipment bonuses are derived at the point of use.
const SLOTS: Array[String] = ["ring_1","ring_2","ring_3","ring_4","ring_5","ring_6","ring_7","ring_8"]
const FAMILIES: Dictionary = {
	"CON":"Constitution", "STR":"Strength", "DEX":"Dexterity", "INT":"Intelligence", "WIS":"Wisdom", "WIL":"Will",
	"physical_damage":"Physical Damage", "magical_damage":"Magical Damage", "sight":"Eagle's Eye",
	"movement":"Movement Speed", "momentum":"Momentum", "healing":"Healing",
	"physical_defense":"Physical Armor", "magical_defense":"Magical Armor",
	"attack_action":"Attack Action", "move_action":"Movement Action", "free_action":"Free Action"}
const ACTIONS: Array[String] = ["attack_action","move_action","free_action"]
const STATS: Array[String] = ["CON","STR","DEX","INT","WIS","WIL"]
static func amount(family: String, greater: bool) -> int:
	if family in ACTIONS: return 1
	return (2 if family in STATS else 3) if greater else 1
static func make(item_id: int, family: String, greater: bool = false) -> Dictionary:
	assert(FAMILIES.has(family) and (greater or family not in ACTIONS),"Production/Actors/rings.gd: invalid ring family or grade")
	return {"item_id":item_id,"kind":"ring","ring_version":1,"family":family,"greater":greater,
		"name":("Greater" if greater else "Lesser")+" Ring of "+FAMILIES[family],"appearance":"Gem-set ring" if greater else "Plain ring",
		"rarity":4 if greater else 2}
static func generate(item_id: int, rng: RandomNumberGenerator) -> Dictionary:
	# Paired families always retain their exact 99/1 grade split. Action drops are separate.
	if rng.randi_range(1,100) == 100 and rng.randi_range(1,17) <= 3: return make(item_id,ACTIONS[rng.randi_range(0,2)],true)
	var family: String = FAMILIES.keys()[rng.randi_range(0,13)]
	return make(item_id,family,rng.randi_range(1,100) == 100)
static func valid(item: Dictionary) -> bool:
	return item.get("kind") == "ring" and item.get("ring_version") == 1 and item.get("family") is String and FAMILIES.has(item.family) and item.get("greater") is bool and (item.greater or item.family not in ACTIONS) and item.get("rarity") == (4 if item.greater else 2)
static func bonus(actor: Dictionary, family: String) -> int:
	if not actor.get("humanoid",true): return 0
	var value: int = 0
	for slot: String in SLOTS:
		var item: Dictionary = actor.get(slot,{})
		if item.get("family","") == family: value += amount(family,item.greater)
	return value
static func stat(actor: Dictionary, key: String) -> int:
	return int(actor.stats[key])+bonus(actor,key)
static func stats(actor: Dictionary) -> Dictionary:
	var result: Dictionary = actor.stats.duplicate()
	for key: String in STATS: result[key] = stat(actor,key)
	return result
static func movement(actor: Dictionary) -> int: return 3+stat(actor,"DEX")+bonus(actor,"movement")
static func healing(actor: Dictionary, multiplier: int = 1) -> int: return multiplier*stat(actor,"CON")+bonus(actor,"healing")
static func sync_health(actor: Dictionary) -> void:
	var added: int = 3*bonus(actor,"WIL")
	actor.max_hp += added-int(actor.get("ring_hp_bonus",0))
	actor.ring_hp_bonus = added
	actor.hp = mini(actor.hp,actor.max_hp)
static func description(item: Dictionary) -> String:
	var family: String = item.family
	var label: String = {"sight":"hexes of sight","movement":"hexes per movement action","momentum":"momentum per world tick","healing":"HP restored per healing/rest event"}.get(family,FAMILIES[family])
	return "+%d %s while equipped" % [amount(family,item.greater),label]
static func first_slot(actor: Dictionary) -> String:
	for slot: String in SLOTS:
		if actor.get(slot,{}).is_empty(): return slot
	return SLOTS[0]
