extends RefCounted
## Owning boundary for inventory mutations. Plans use copies; live state commits only after validation.
const Combat = preload("res://Workshop/Rooms/Regional Foundation/Actors/combat.gd")
const COLUMNS: int = 8
const ROWS: int = 5
const SHAPES: Dictionary = {"potion": Vector2i(1,1), "belt": Vector2i(2,1), "armor": Vector2i(2,2), "shield": Vector2i(2,2), "sword": Vector2i(1,2)}
const EQUIPMENT: Array[String] = ["main", "off", "armor", "belt"]

static func footprint(item: Dictionary, rotated: bool = false) -> Vector2i:
	var shape: Vector2i = SHAPES.get(item.get("kind", ""), Vector2i.ZERO)
	return Vector2i(shape.y,shape.x) if rotated else shape

static func fits(bag: Array, item: Dictionary, cell: Vector2i, rotated: bool) -> bool:
	var shape: Vector2i = footprint(item,rotated)
	if shape == Vector2i.ZERO or cell.x < 0 or cell.y < 0 or cell.x + shape.x > COLUMNS or cell.y + shape.y > ROWS: return false
	var area: Rect2i = Rect2i(cell,shape)
	for other: Dictionary in bag:
		if not other.has("grid_pos"): return false
		if area.intersects(Rect2i(other.grid_pos,footprint(other,other.get("rotated",false)))): return false
	return true

static func place(bag: Array, item: Dictionary, cell: Vector2i, rotated: bool) -> bool:
	if not fits(bag,item,cell,rotated): return false
	item.grid_pos = cell
	item.rotated = rotated
	bag.append(item)
	return true

static func place_auto(bag: Array, item: Dictionary) -> bool:
	var preferred: bool = item.get("rotated",false)
	for rotated: bool in [preferred, not preferred]:
		for y: int in range(ROWS):
			for x: int in range(COLUMNS):
				if place(bag,item,Vector2i(x,y),rotated): return true
	return false

static func belt_by_id(actor: Dictionary, item_id: int) -> Dictionary:
	if actor.belt.get("item_id",-1) == item_id: return actor.belt
	for item: Dictionary in actor.bag:
		if item.kind == "belt" and item.item_id == item_id: return item
	return {}

static func prepare(actor: Dictionary) -> void:
	# Only needed for newly generated baseline belt contents; gameplay moves preserve exact slots.
	var belts: Array = []
	if not actor.belt.is_empty(): belts.append(actor.belt)
	for item: Dictionary in actor.bag:
		if item.kind == "belt": belts.append(item)
	for belt: Dictionary in belts:
		for index: int in range(belt.contents.size()): belt.contents[index].pouch = index

static func source_item(actor: Dictionary, ground: Array, source: Dictionary) -> Dictionary:
	var item_id: int = source.get("id",-1)
	match source.get("zone", ""):
		"bag":
			for item: Dictionary in actor.bag:
				if item.item_id == item_id: return item
		"equipment":
			var slot: String = source.get("slot", "")
			if slot in EQUIPMENT and actor[slot].get("item_id",-1) == item_id: return actor[slot]
		"belt":
			var belt: Dictionary = belt_by_id(actor,source.get("belt_id",-1))
			for item: Dictionary in belt.get("contents",[]):
				if item.item_id == item_id: return item
		"ground":
			for entry: Dictionary in ground:
				if entry.item.item_id == item_id: return entry.item
	return {}

static func _detach(actor: Dictionary, ground: Array, source: Dictionary) -> Dictionary:
	var item: Dictionary = source_item(actor,ground,source)
	if item.is_empty(): return {}
	match source.zone:
		"bag": actor.bag.erase(item)
		"equipment": actor[source.slot] = {}
		"belt": belt_by_id(actor,source.belt_id).contents.erase(item)
		"ground":
			for index: int in range(ground.size()):
				if ground[index].item.item_id == item.item_id:
					ground.remove_at(index)
					break
	return item

static func _put_belt(actor: Dictionary, item: Dictionary, target: Dictionary) -> bool:
	var belt: Dictionary = belt_by_id(actor,target.get("belt_id",-1))
	if item.kind != "potion" or belt.is_empty(): return false
	var used: Array = []
	for other: Dictionary in belt.contents: used.append(other.pouch)
	var slot: int = target.get("pouch",-1)
	if slot < 0:
		for candidate: int in range(belt.capacity):
			if candidate not in used:
				slot = candidate
				break
	if slot < 0 or slot >= belt.capacity or slot in used: return false
	item.pouch = slot
	belt.contents.append(item)
	return true

static func _compatible(actor: Dictionary, item: Dictionary, slot: String) -> bool:
	match slot:
		"main": return item.kind == "sword"
		"off": return item.kind == "shield" or (item.kind == "sword" and "Show-Off" in actor.skills and actor.main.get("kind") == "sword")
		"armor": return item.kind == "armor"
		"belt": return item.kind == "belt"
	return false

static func _validate_item(item: Dictionary, seen: Dictionary) -> bool:
	var item_id: int = item.get("item_id",-1)
	if item_id < 1 or seen.has(item_id) or not SHAPES.has(item.get("kind","")): return false
	seen[item_id] = true
	if item.kind == "belt":
		var slots: Array = []
		for potion: Dictionary in item.contents:
			var slot: int = potion.get("pouch",-1)
			if potion.kind != "potion" or slot < 0 or slot >= item.capacity or slot in slots or not _validate_item(potion,seen): return false
			slots.append(slot)
	return true

static func valid(actor: Dictionary, ground: Array) -> bool:
	var seen: Dictionary = {}
	var placed: Array = []
	for item: Dictionary in actor.bag:
		if not item.has("grid_pos") or not fits(placed,item,item.grid_pos,item.get("rotated",false)) or not _validate_item(item,seen): return false
		placed.append(item)
	for slot: String in EQUIPMENT:
		if not actor[slot].is_empty() and not _validate_item(actor[slot],seen): return false
	for entry: Dictionary in ground:
		if not _validate_item(entry.item,seen): return false
	return true

static func transfer(actor: Dictionary, ground: Array, actions: Dictionary, battle: bool, source: Dictionary, target: Dictionary, preview: bool = false, map = null) -> Dictionary:
	if not valid(actor,ground): return {"ok":false,"reason":"Inventory state is invalid; transfer refused."}
	if actor.hp <= 0: return {"ok":false,"reason":"This adventurer cannot act."}
	if source == target: return {"ok":false,"reason":"Item is already there."}
	if source.get("zone") == "ground":
		var near: bool = false
		for entry: Dictionary in ground:
			if entry.item.item_id == source.get("id") and (Combat.distance(actor.pos,entry.pos) if map == null else map.distance(actor.pos,entry.pos)) <= 1: near = true
		if not near: return {"ok":false,"reason":"Move adjacent to that item first."}
		if target.get("zone") in ["equipment","ground"]: return {"ok":false,"reason":"Pick up the item before equipping or dropping it."}
	var planned: Dictionary = actor.duplicate(true)
	var planned_ground: Array = ground.duplicate(true)
	var planned_actions: Dictionary = actions.duplicate(true)
	var item: Dictionary = _detach(planned,planned_ground,source)
	if item.is_empty(): return {"ok":false,"reason":"That item is no longer at its source."}
	var accepted: bool = false
	match target.get("zone", ""):
		"bag":
			accepted = place(planned.bag,item,target.cell,target.get("rotated",item.get("rotated",false))) if target.has("cell") else place_auto(planned.bag,item)
		"pickup":
			if item.kind == "potion": accepted = _put_belt(planned,item,{"belt_id":planned.belt.get("item_id",-1)})
			if not accepted: accepted = place_auto(planned.bag,item)
		"equipment":
			var slot: String = target.get("slot","")
			if _compatible(planned,item,slot):
				var displaced: Dictionary = planned[slot]
				accepted = displaced.is_empty() or place_auto(planned.bag,displaced)
				if accepted: planned[slot] = item
		"belt": accepted = _put_belt(planned,item,target)
		"ground":
			planned_ground.append({"item":item,"pos":actor.pos})
			accepted = true
	if not accepted or not valid(planned,planned_ground): return {"ok":false,"reason":"No room or incompatible target. Nothing moved."}
	if battle:
		if source.zone == "ground":
			if not Combat.loot_cost(planned_actions): return {"ok":false,"reason":"No actions left to loot."}
		elif not (source.zone == "bag" and target.zone == "bag"):
			if planned_actions.activation <= 0: return {"ok":false,"reason":"This needs an activation action."}
			planned_actions.activation -= 1
	var allowance: int = Combat.allowance(planned).attack
	planned_actions.attack = mini(planned_actions.attack,maxi(0,allowance - planned_actions.used_attacks))
	if source.zone == "equipment" and source.get("slot") in ["main","off"]: planned.riposte = false
	if preview: return {"ok":true,"reason":"Transfer fits."}
	# Atomic commit: no mutation of live items, containers or actions before this point.
	for slot: String in EQUIPMENT: actor[slot] = planned[slot]
	actor.bag = planned.bag
	actor.riposte = planned.riposte
	ground.assign(planned_ground)
	actions.merge(planned_actions,true)
	return {"ok":true,"reason":"Moved " + item.name + "."}
