extends RefCounted
## Presentation boundary: distant views contain only explicitly visible properties.
static func describe(item: Dictionary, within_reach: bool) -> Dictionary:
	var title: String = item.get("appearance", item.get("kind", "Item").capitalize())
	var lines: Array[String] = []
	for visible_trait: String in item.get("visible_traits", []): lines.append(visible_trait)
	if within_reach:
		title = item.name
		match item.kind:
			"sword": lines.append("Weapon: 1d%d %+d + 0.5 × (STR + DEX)" % [item.die,item.bonus])
			"shield", "armor": lines.append("Equipment Defense: 1d%d %+d per attack" % [item.die,item.bonus])
			"belt": lines.append("Capacity: %d pouches · %d potions inside" % [item.capacity,item.contents.size()])
			"potion": lines.append("Restores CON health, up to maximum HP.")
	return {"title":title,"details":"\n".join(lines)}
