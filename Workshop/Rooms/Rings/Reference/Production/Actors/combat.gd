extends RefCounted
const Rules = preload("res://Production/Actors/equipment_rules.gd")
const Items = preload("res://Production/Actors/items.gd")
const DIRECTIONS = [Vector2i(1,0), Vector2i(1,-1), Vector2i(0,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,1)]
static func distance(a: Vector2i, b: Vector2i) -> int:
	var delta: Vector2i = a - b
	return maxi(absi(delta.x), maxi(absi(delta.y), absi(delta.x + delta.y)))
static func allowance(actor: Dictionary) -> Dictionary:
	return {"attack": 2 if preload("res://Production/Actors/skill_board.gd").active(actor,"Show-Off") and actor.main.get("kind") == "sword" and actor.off.get("kind") == "sword" else 1, "move": 1, "activation": 1, "used_attacks": 0, "free": 0}
static func final_damage(raw: float, _player_attacking: bool = true, _difficulty: int = 0) -> int:
	return maxi(0,floori(raw))
static func weapon_damage(actor: Dictionary, weapon: Dictionary) -> float:
	return Items.roll(weapon)+Rules.stat_bonus(actor,weapon)+actor.get("attack_modifier",0)
static func attack_range(actor: Dictionary) -> int:
	return int((actor.main if actor.get("humanoid",true) else actor.get("natural_attack",{})).get("range",1))+int(actor.get("range_modifier",0))
static func defense(actor: Dictionary, channel: String = "physical") -> int:
	var value: int = actor.stats.CON if channel == "physical" else actor.stats.WIL
	value += int(actor.get("effects_defense",0))+int(actor.get(channel+"_defense_modifier",0))
	for slot: String in Rules.ARMOR_SLOTS: value += Rules.defense_item(actor.get(slot,{}),channel)
	if actor.get("humanoid",true) and actor.off.get("kind") == "shield": value += Rules.defense_item(actor.off,channel)
	if actor.get("humanoid",true) and actor.riposte and preload("res://Production/Actors/skill_board.gd").active(actor,"Riposte") and channel == "physical": value += actor.stats.DEX
	return maxi(0,value)
static func attack(source: Dictionary, target: Dictionary, weapon: Dictionary, lunge: bool, player_attacking: bool, difficulty: int) -> int:
	var power: float = weapon_damage(source,weapon)
	if lunge: power += floori(source.stats.STR*1.5)
	var damage: int = final_damage(power-defense(target,weapon.get("damage_type","physical")),player_attacking,difficulty)
	target.hp = maxi(0,target.hp-damage)
	return damage
static func heal(actor: Dictionary) -> int:
	var before: int = actor.hp
	actor.hp = mini(actor.max_hp, actor.hp + actor.stats.CON)
	return actor.hp - before
static func loot_cost(actions: Dictionary) -> bool:
	if actions.get("exploration",false): return true
	for kind: String in ["activation", "attack", "move"]:
		if actions[kind] > 0:
			actions[kind] -= 1
			if kind == "attack": actions.used_attacks += 1
			return true
	return spend(actions,"free")

static func available(actions: Dictionary, kind: String) -> int:
	if actions.get("exploration",false): return maxi(1,int(actions.get(kind,0)))
	return int(actions.get(kind,0))+int(actions.get("free",0))

static func spend(actions: Dictionary, kind: String) -> bool:
	if actions.get("exploration",false): return true
	if actions.get(kind,0) > 0:
		actions[kind] -= 1
		if kind == "attack": actions.used_attacks += 1
		return true
	if actions.get("free",0) > 0:
		actions.free -= 1
		return true
	return false

static func remaining(actions: Dictionary) -> int:
	return int(actions.get("move",0))+int(actions.get("attack",0))+int(actions.get("activation",0))+int(actions.get("free",0))
