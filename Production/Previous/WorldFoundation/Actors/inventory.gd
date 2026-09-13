extends RefCounted
static func receive(actor: Dictionary, item: Dictionary) -> void:
	if item.kind == "potion" and actor.belt.get("contents", []).size() < actor.belt.get("capacity", 0):
		actor.belt.contents.append(item)
	else: actor.bag.append(item)
static func equip(actor: Dictionary, index: int) -> bool:
	var item: Dictionary = actor.bag[index]
	if item.kind == "potion":
		if actor.belt.get("contents", []).size() >= actor.belt.get("capacity", 0): return false
		actor.bag.remove_at(index)
		actor.belt.contents.append(item)
		return true
	var slot: String = ""
	match item.kind:
		"sword": slot = "off" if "Show-Off" in actor.skills and not actor.main.is_empty() else "main"
		"shield": slot = "off"
		"armor": slot = "armor"
		"belt": slot = "belt"
	if slot.is_empty(): return false
	var previous: Dictionary = actor[slot]
	actor.bag.remove_at(index)
	actor[slot] = item
	if not previous.is_empty(): actor.bag.append(previous)
	return true
static func possessions(actor: Dictionary) -> Array:
	var result: Array = []
	for slot: String in ["main", "off", "armor", "belt"]:
		if not actor[slot].is_empty(): result.append(actor[slot])
	result.append_array(actor.bag)
	return result

static func remove_potion(actor: Dictionary, belt: Dictionary) -> bool:
	if belt.get("contents", []).is_empty(): return false
	actor.bag.append(belt.contents.pop_back())
	return true
static func drop(actor: Dictionary, slot: String, index: int = -1) -> Dictionary:
	if slot == "bag":
		if index < 0 or index >= actor.bag.size(): return {}
		var item: Dictionary = actor.bag[index]
		actor.bag.remove_at(index)
		return item
	if slot not in ["main", "off", "armor", "belt"]: return {}
	var item: Dictionary = actor[slot]
	actor[slot] = {}
	return item
