extends RefCounted
static var next_item_id: int = 1
static func identity() -> int:
	var result: int = next_item_id
	next_item_id += 1
	return result
const RARITIES = ["Trash", "Common", "Exceptional", "Master Work", "Touched By The Gods"]
const BONUS = [-1, 0, 1, 2, 4]
const ARMORS = ["Chainmail", "Halfplate", "Fullplate", "Hide", "Leather", "Scale", "Robe", "Quilted", "Gambeson"]
const ARMOR_DICE = [3, 6, 8, 2, 4, 6, 1, 2, 4]
static func quality(enemy: bool, rng: RandomNumberGenerator = null) -> int:
	var roll: int = randi_range(1, 100) if rng == null else rng.randi_range(1,100)
	var weights: Array = [40, 60] if enemy else [20, 40, 20, 18, 2]
	for index: int in range(weights.size()):
		roll -= weights[index]
		if roll <= 0: return index
	return 0
static func make(kind: String, enemy: bool = false, rng: RandomNumberGenerator = null) -> Dictionary:
	var rarity: int = quality(enemy,rng)
	var item: Dictionary = {"item_id": identity(), "kind": kind, "rarity": rarity, "bonus": BONUS[rarity], "die": 0, "name": "", "contents": [], "capacity": 0}
	match kind:
		"sword":
			item.die = 4
			item.name = "Bronze Sword"
		"shield":
			item.die = 2
			item.name = "Wooden Shield"
		"armor":
			var tier: int = randi_range(0, 8) if rng == null else rng.randi_range(0,8)
			item.die = ARMOR_DICE[tier]
			item.name = ARMORS[tier]
		"belt":
			var tier: int = randi_range(0, 2) if rng == null else rng.randi_range(0,2)
			item.name = ["Sash", "Leather Belt", "Bandolier"][tier]
			item.capacity = [3, 4, 5, 6, 8][rarity] + tier
			for slot: int in range(item.capacity):
				if (randf() if rng == null else rng.randf()) < 0.05:
					var health_potion: Dictionary = potion()
					health_potion.pouch = slot
					item.contents.append(health_potion)
	item.appearance = item.name
	item.name = RARITIES[rarity] + " " + item.name
	return item
static func potion() -> Dictionary:
	return {"item_id": identity(), "kind": "potion", "name": "Lesser Health", "appearance": "Glass potion bottle"}
static func roll(item: Dictionary) -> int:
	return randi_range(1, item.die) + item.bonus
