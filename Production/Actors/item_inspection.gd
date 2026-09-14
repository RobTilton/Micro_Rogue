extends RefCounted
const Rules = preload("res://Production/Actors/equipment_rules.gd")
## Distant views reveal only visible properties; exact values require inspection.
static func describe(item: Dictionary, within_reach: bool) -> Dictionary:
	var title: String = item.get("appearance",item.get("kind","Item").capitalize())
	var lines: Array[String] = []
	for visible_trait: String in item.get("visible_traits",[]): lines.append(visible_trait)
	if within_reach:
		title = item.name
		if item.has("material_tier"): lines.append("Material tier %d · %s" % [item.material_tier,item.quality.name])
		if Rules.is_weapon(item):
			lines.append("%s damage: 1d%d %+d + stat bonus" % [item.get("damage_type","physical").capitalize(),item.die,Rules.damage_bonus(item)])
			var scaling: String = {"daggers":"DEX","bows":"DEX","staffs":"INT","maces":"STR (two hands: floor(1.5 × STR))"}.get(item.get("category","swords"),"floor((STR + DEX) / 2); two hands: STR + DEX")
			lines.append("Stats: "+scaling)
			lines.append("Hands: %s · Range: %d" % [item.get("hands","one"),item.get("range",1)])
		elif item.kind in ["shield","armor"]:
			lines.append("Slot: "+("Chest" if item.get("slot","armor") == "armor" else item.get("slot","off").capitalize()))
			lines.append("Physical Defense: %d\nMagical Defense: %d" % [Rules.defense_item(item,"physical"),Rules.defense_item(item,"magical")])
		elif item.kind == "belt": lines.append("Capacity: %d pouches · %d potions inside" % [item.capacity,item.contents.size()])
		elif item.kind == "potion": lines.append("Restores CON health, up to maximum HP.")
	return {"title":title,"details":"\n".join(lines)}

static func tooltip(item: Dictionary, within_reach: bool = true) -> String:
	if item.is_empty(): return ""
	var view: Dictionary = describe(item,within_reach)
	return view.title+("\n"+view.details if not view.details.is_empty() else "")
