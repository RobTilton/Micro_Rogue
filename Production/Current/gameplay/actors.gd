extends RefCounted
const Items = preload("res://Production/Current/gameplay/items.gd")
const STATS = ["CON", "STR", "DEX", "INT", "WIS", "WIL"]
static func dice() -> Array:
	var result: Array = []
	for index: int in range(6): result.append(randi_range(1, 6))
	return result
static func create(values: Array, enemy: bool = false) -> Dictionary:
	var stats: Dictionary = {}
	for index: int in range(6): stats[STATS[index]] = values[index]
	return {"stats": stats, "hp": stats.WIL * 3, "max_hp": stats.WIL * 3, "level": 1, "xp": 0, "required_xp": 5, "points": 0 if enemy else 1, "skills": [], "main": Items.make("sword", enemy), "off": Items.make("shield", enemy), "armor": Items.make("armor", enemy), "belt": Items.make("belt", enemy), "bag": [], "effects_defense": 0.0, "riposte": false, "pos": Vector2i(1, 3)}
static func award_xp(actor: Dictionary, amount: int) -> void:
	actor.xp += amount
	while actor.xp >= actor.required_xp:
		actor.xp -= actor.required_xp
		actor.required_xp *= 2
		actor.level += 1
		actor.points += 1
