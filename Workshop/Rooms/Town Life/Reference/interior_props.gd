extends RefCounted
const Items = preload("res://Production/Actors/items.gd")
const Contracts = preload("res://Production/World/geographic_contracts.gd")
const KINDS: Array = ["chest","crate","barrel","bones","corpse","rug","rubble"]
static func populate(map, layout: Dictionary, template: String) -> void:
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
		var choices: Array = ["bones","corpse","chest","rubble"] if template == "Cave" else ["chest","crate","barrel","bones","rug"]
		for index: int in range(mini(candidates.size(),rng.randi_range(2,3))):
			var selected: int = rng.randi_range(0,candidates.size()-1)
			var cell: Vector2i = candidates[selected]
			candidates.remove_at(selected)
			var kind: String = choices[rng.randi_range(0,choices.size()-1)]
			var contents: Array = []
			if kind not in ["rug","rubble"]:
				for item_index: int in range(rng.randi_range(1,3) if kind == "chest" else rng.randi_range(0,2)):
					var drop: Dictionary = Items.generate({"max_material_tier":3},rng)
					if drop.ok: contents.append(drop.item)
			map.props[cell] = {"kind":kind,"name":kind.capitalize(),"opened":false,"contents":contents,"room_id":room.id}
static func valid(data, map, walls: Array, links: Dictionary) -> bool:
	if not data is Dictionary: return false
	for cell in data:
		var prop = data[cell]
		if not cell is Vector2i or not map.contains(cell) or cell in walls or links.has(cell): return false
		if not prop is Dictionary or prop.get("kind") not in KINDS or not prop.get("name") is String or not prop.get("opened") is bool or not prop.get("contents") is Array or not prop.get("room_id") is int: return false
		if (prop.opened or prop.kind in ["rug","rubble"]) and not prop.contents.is_empty(): return false
	return true
