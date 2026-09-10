extends RefCounted
const Items = preload("res://Production/Gameplay/items.gd")
const DIRECTIONS = [Vector2i(1,0), Vector2i(1,-1), Vector2i(0,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,1)]
static func distance(a: Vector2i, b: Vector2i) -> int:
	var delta: Vector2i = a - b
	return maxi(absi(delta.x), maxi(absi(delta.y), absi(delta.x + delta.y)))
static func allowance(actor: Dictionary) -> Dictionary:
	return {"attack": 2 if "Show-Off" in actor.skills and actor.main.get("kind") == "sword" and actor.off.get("kind") == "sword" else 1, "move": 1, "activation": 1, "used_attacks": 0}
static func final_damage(raw: float, player_attacking: bool, difficulty: int) -> int:
	var positive: float = maxf(raw, 0.0)
	var round_up: bool = player_attacking
	if difficulty == 1: round_up = true
	if difficulty == 2: round_up = not player_attacking
	return ceili(positive) if round_up else floori(positive)
static func weapon_damage(actor: Dictionary, weapon: Dictionary) -> float:
	return Items.roll(weapon) + (actor.stats.STR + actor.stats.DEX) * 0.5 + actor.get("attack_modifier", 0.0)
static func attack_range(actor: Dictionary) -> int:
	return 1 + actor.get("range_modifier", 0)
static func defense(actor: Dictionary) -> float:
	var value: float = actor.stats.DEX + actor.stats.WIL * 0.5 + actor.effects_defense
	if not actor.armor.is_empty(): value += Items.roll(actor.armor)
	if actor.off.get("kind") == "shield": value += Items.roll(actor.off)
	if actor.riposte: value += actor.stats.DEX
	return value
static func attack(source: Dictionary, target: Dictionary, weapon: Dictionary, lunge: bool, player_attacking: bool, difficulty: int) -> int:
	var power: float = weapon_damage(source, weapon)
	if lunge: power += source.stats.STR * 1.5
	var damage: int = final_damage(power - defense(target), player_attacking, difficulty)
	# Landing effects own this boundary before health mutation; none defined for slice.
	target.hp = maxi(0, target.hp - damage)
	return damage
static func heal(actor: Dictionary) -> int:
	var before: int = actor.hp
	actor.hp = mini(actor.max_hp, actor.hp + actor.stats.CON)
	return actor.hp - before
static func loot_cost(actions: Dictionary) -> bool:
	for kind: String in ["activation", "attack", "move"]:
		if actions[kind] > 0:
			actions[kind] -= 1
			if kind == "attack": actions.used_attacks += 1
			return true
	return false
