extends RefCounted
const Items = preload("res://Production/Actors/items.gd")
const Contracts = preload("res://Production/World/geographic_contracts.gd")
const KINDS: Array = ["chest","crate","barrel","bones","corpse","rug","rubble"]
static func populate(map, layout: Dictionary, template: String) -> void:
	var boss_assigned: bool = false
	for room: Dictionary in layout.rooms:
		if room.id == layout.entry_room: continue
		var rng := RandomNumberGenerator.new()
		rng.seed = Contracts.seed_for(room.seed,"scenery")
		var candidates: Array = []
		for cell: Vector2i in room.cells:
			if cell == room.center: continue
			var clear: bool = true
			for link: Vector2i in map.links:
				if map.distance(cell,link) <= 2: clear = false
			if clear: candidates.append(cell)
		var boss: bool = not boss_assigned and not map.links.has(room.center)
		if boss: boss_assigned = true
		var role: String = "boss" if boss else ["ordinary","ordinary","ordinary","armory","storeroom","camp"][rng.randi_range(0,5)]
		room.loot_role = role
		var count: int = 3 if boss else 1 if role != "ordinary" else (1 if rng.randf() < 0.15 else 0)
		var choices: Array = ["bones","corpse","chest","rubble"] if template == "Cave" else ["chest","crate","barrel","bones","rug"]
		for index: int in range(mini(candidates.size(),count)):
			var selected: int = rng.randi_range(0,candidates.size()-1)
			var cell: Vector2i = candidates[selected]
			candidates.remove_at(selected)
			var kind: String = "chest" if role in ["boss","armory"] else "crate" if role == "storeroom" else choices[rng.randi_range(0,choices.size()-1)]
			var contents: Array = []
			if kind not in ["rug","rubble"]:
				for item_index: int in range(rng.randi_range(1,2) if role != "ordinary" else 1):
					var request: Dictionary = {"max_material_tier":3}
					if role == "camp": request.category = "belts"
					var drop: Dictionary = {"ok":true,"item":Items.ration()} if role == "camp" and rng.randf() < 0.5 else Items.loot(request,rng,role == "storeroom")
					if drop.ok: contents.append(drop.item)
			map.props[cell] = {"kind":kind,"name":kind.capitalize(),"opened":false,"contents":contents,"room_id":room.id}
static func valid(data, map, walls: Array, links: Dictionary) -> bool:
	if not data is Dictionary: return false
	for cell in data:
		var prop = data[cell]
		if not cell is Vector2i or not map.contains(cell) or cell in walls or links.has(cell): return false
		if not prop is Dictionary or prop.get("kind") not in KINDS or not prop.get("name") is String or not prop.get("opened") is bool or not prop.get("contents") is Array or not prop.get("room_id") is int: return false
		if prop.has("chest_rarity") and (prop.kind != "chest" or prop.chest_rarity not in ["normal","rare"]): return false
		if not prop.get("gold",0) is int or prop.get("gold",0) < 0 or (prop.opened and prop.get("gold",0) != 0): return false
		if (prop.opened or prop.kind in ["rug","rubble"]) and not prop.contents.is_empty(): return false
	return true
