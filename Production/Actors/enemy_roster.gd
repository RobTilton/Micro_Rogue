extends RefCounted
const PATH: String = "res://Production/Actors/enemy_catalog.json"
static var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PATH))
static func pressure(hostility: int, player_level: int) -> float:
	return maxi(0,hostility)+maxi(0,player_level-1)/float(catalog.levels_per_pressure)
static func weights(hostility: int, player_level: int) -> Dictionary:
	var result: Dictionary = {}
	var value: float = pressure(hostility,player_level)
	for id: String in catalog.families:
		var family: Dictionary = catalog.families[id]
		if value < family.minimum_pressure: continue
		var separation: float = absf(value-float(family.preferred_pressure))/5.0
		result[id] = float(family.weight)/pow(1.0+separation,2.0)
	return result
static func choose_family(rng: RandomNumberGenerator, hostility: int, player_level: int, exclude: String = "") -> String:
	var choices: Dictionary = weights(hostility,player_level)
	choices.erase(exclude)
	var total: float = 0.0
	for value: float in choices.values(): total += value
	var roll: float = rng.randf()*total
	for id: String in choices:
		roll -= choices[id]
		if roll <= 0: return id
	return choices.keys().back() if not choices.is_empty() else "goblins"
static func choose_variant(family: String, rng: RandomNumberGenerator, hostility: int, player_level: int, boss: bool = false) -> Dictionary:
	var variants: Array = catalog.families[family].variants
	var ceiling: int = mini(variants.size(),1+floori((pressure(hostility,player_level)+(2.0 if boss else 0.0))/float(catalog.pressure_per_tier)))
	var total: int = int(ceiling*(ceiling+1)/2.0)
	var roll: int = rng.randi_range(1,total)
	for index: int in range(ceiling):
		roll -= index+1
		if roll <= 0: return variants[index].duplicate(true)
	return variants[0].duplicate(true)
static func variant(id: String) -> Dictionary:
	for family: Dictionary in catalog.families.values():
		for entry: Dictionary in family.variants:
			if entry.id == id: return entry
	return {}
static func natural_attack(entry: Dictionary) -> Dictionary:
	return {"kind":"natural","name":entry.natural_name,"category":"natural","die":int(entry.natural_die)+int(entry.tier)-1,"bonus":2*(int(entry.tier)-1),"damage_type":"physical","range":1,"hands":"one"}
static func apply(actor: Dictionary, family: String, entry: Dictionary) -> void:
	actor.family = family
	actor.faction_id = family
	actor.enemy_variant = entry.id
	actor.humanoid = entry.humanoid
	actor.can_use_skills = entry.humanoid
	actor.natural_attack = {} if entry.humanoid else natural_attack(entry)
	actor.name = entry.name+(" Boss" if actor.get("boss",false) else "")
static func valid_actor(actor: Dictionary) -> bool:
	if not actor.get("humanoid",true) is bool: return false
	if not actor.has("enemy_variant"): return true # Legacy actors are upgraded after structural validation.
	if not actor.enemy_variant is String: return false
	var entry: Dictionary = variant(actor.enemy_variant)
	if entry.is_empty() or actor.humanoid != entry.humanoid or actor.get("can_use_skills") != entry.humanoid: return false
	if not catalog.families.has(actor.get("family","")): return false
	if entry not in catalog.families[actor.family].variants: return false
	return actor.get("natural_attack",{}) == ({} if entry.humanoid else natural_attack(entry))
