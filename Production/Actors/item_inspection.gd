extends RefCounted
const Rules = preload("res://Production/Actors/equipment_rules.gd")
## Distant views reveal only visible properties; exact values require inspection.
static func describe(item: Dictionary, within_reach: bool) -> Dictionary:
	var title: String = item.get("appearance",item.get("kind","Item").capitalize())
	var lines: Array[String] = []
	for visible_trait: String in item.get("visible_traits",[]): lines.append(visible_trait)
	if within_reach:
		title = item.name
		var prices = preload("res://Production/World/village_shops.gd")
		if prices.buyable(item): lines.append("Baseline cost: %d gold" % prices.retail_price(item))
		else: lines.append("Cannot be bought or sold.")
		if prices.sellable(item): lines.append("Sell value: %d gold" % prices.sale_price(item))
		if item.has("material_tier"): lines.append("Material tier %d · %s" % [item.material_tier,item.quality.name])
		if Rules.is_weapon(item):
			lines.append("%s damage: 1d%d %+d + stat bonus" % [item.get("damage_type","physical").capitalize(),item.die,Rules.damage_bonus(item)])
			var scaling: String = {"bows":"STR","staffs":"INT"}.get(item.get("category","swords"),"STR (two hands: floor(1.5 × STR))")
			lines.append("Stats: "+scaling)
			lines.append("Hands: %s · Range: %d" % [item.get("hands","one"),item.get("range",1)])
		elif item.kind in ["shield","armor"]:
			lines.append("Slot: "+("Chest" if item.get("slot","armor") == "armor" else item.get("slot","off").capitalize()))
			lines.append("Physical Defense: %d\nMagical Defense: %d" % [Rules.defense_item(item,"physical"),Rules.defense_item(item,"magical")])
		elif item.kind == "ring": lines.append(Rules.Rings.description(item))
		elif item.kind == "belt": lines.append("Capacity: %d pouches · %d potions inside" % [item.capacity,item.contents.size()])
		elif item.kind == "ration": lines.append("Camp: consumes one ration, passes one six-hour block and restores 2 × CON HP. Requires safety.")
		elif item.kind == "potion": lines.append("Restores CON + healing bonuses, up to maximum HP.")
	return {"title":title,"details":"\n".join(lines)}

static func tooltip(item: Dictionary, within_reach: bool = true) -> String:
	if item.is_empty(): return ""
	var view: Dictionary = describe(item,within_reach)
	return view.title+("\n"+view.details if not view.details.is_empty() else "")
