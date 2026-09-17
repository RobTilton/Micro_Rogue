extends RefCounted
const Contracts = preload("res://Production/World/geographic_contracts.gd")
const NORMAL_PERCENT: int = 75
const RARE_PERCENT: int = 25
static func for_roll(value: int) -> String:
	assert(value >= 1 and value <= 100,"Production/World/chest_rarity.gd: chest roll must be between 1 and 100.")
	return "normal" if value <= NORMAL_PERCENT else "rare"

## An independent per-cell stream keeps loot, gold, placement and other RNG rolls intact.
static func ensure(map, seed_value: int) -> bool:
	var changed: bool = false
	for cell: Vector2i in map.props:
		var prop: Dictionary = map.props[cell]
		if prop.kind != "chest" or prop.has("chest_rarity"): continue
		var rng := RandomNumberGenerator.new()
		rng.seed = Contracts.seed_for(seed_value,"chest-rarity:%d:%d" % [cell.x,cell.y])
		prop.chest_rarity = for_roll(rng.randi_range(1,100))
		prop.name = prop.chest_rarity.capitalize()+" "+prop.name
		changed = true
	return changed
