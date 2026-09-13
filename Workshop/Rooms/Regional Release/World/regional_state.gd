extends RefCounted
## Global-owned regional facts. Local maps hold revision-tagged copies only.
const BASE: Dictionary = {"Ice Wall":0,"Plains":0,"Hills":1,"Mountains":2,"Sea":1,"Swamp":2,"Wasteland":4,"Desert":3,"Forest":2,"Marsh":2,"Salt Marsh":2,"Lakes":1}

static func create(global_map) -> Dictionary:
	var hexes: Dictionary = {}
	for cell: Vector2i in global_map.cells():
		var biome: String = global_map.biomes.get(cell,"Plains")
		hexes[cell] = {"biome":biome,"base_hostility":BASE[biome],"hostility":BASE[biome],"contributions":{},"pois":{},"resolved":false,"revision":0}
	return {"hexes":hexes,"sources":{}}

static func resolve_bubble(data: Dictionary, global_map, center: Vector2i) -> bool:
	var changed: bool = false
	for cell: Vector2i in data.hexes:
		if global_map.distance(center,cell) <= 2 and not data.hexes[cell].resolved:
			data.hexes[cell].resolved = true
			data.hexes[cell].revision += 1
			changed = true
	return changed

static func publish_poi(data: Dictionary, cell: Vector2i, id: String, template: String, label: String) -> void:
	var value: Dictionary = {"template":template,"label":label}
	if data.hexes[cell].pois.get(id,{}) == value: return
	data.hexes[cell].pois[id] = value
	data.hexes[cell].revision += 1

static func set_source(data: Dictionary, global_map, id: String, cell: Vector2i, strength: int) -> bool:
	var source: Dictionary = {"cell":cell,"strength":strength}
	if data.sources.get(id,{}) == source or (strength == 0 and not data.sources.has(id)): return false
	if strength == 0: data.sources.erase(id)
	else: data.sources[id] = source
	for target: Vector2i in data.hexes:
		var contribution: int = maxi(0,strength-global_map.distance(cell,target))
		var value: Dictionary = data.hexes[target]
		if value.contributions.get(id,0) == contribution: continue
		if contribution == 0: value.contributions.erase(id)
		else: value.contributions[id] = contribution
		value.hostility = value.base_hostility
		for amount: int in value.contributions.values(): value.hostility += amount
		value.revision += 1
	return true

static func valid(data, global_map, records: Dictionary) -> bool:
	if not data is Dictionary or not data.get("hexes") is Dictionary or not data.get("sources") is Dictionary: return false
	if data.hexes.size() != global_map.cells().size(): return false
	for id in data.sources:
		var source = data.sources[id]
		if not id is String or not records.has(id) or not source is Dictionary or not source.get("cell") is Vector2i or not source.get("strength") is int or source.strength <= 0 or not global_map.contains(source.cell) or source.cell != local_cell(records,id): return false
	for cell in data.hexes:
		var value = data.hexes[cell]
		if not cell is Vector2i or not global_map.contains(cell) or not value is Dictionary: return false
		if value.get("biome") != global_map.biomes.get(cell,"Plains") or not value.get("biome") is String or not BASE.has(value.biome) or value.get("base_hostility") != BASE[value.biome]: return false
		if not value.get("resolved") is bool or not value.get("revision") is int or value.revision < 0 or not value.get("contributions") is Dictionary or not value.get("pois") is Dictionary or not value.get("hostility") is int: return false
		var contributions: Dictionary = {}
		var total: int = value.base_hostility
		for id: String in data.sources:
			var source: Dictionary = data.sources[id]
			var pressure: int = maxi(0,source.strength-global_map.distance(cell,source.cell))
			if pressure > 0: contributions[id] = pressure; total += pressure
		if value.contributions != contributions or value.hostility != total: return false
		for id in value.pois:
			if not id is String or not records.has(id) or local_cell(records,id) != cell or value.pois[id] != {"template":records[id].template,"label":records[id].label}: return false
	return true

static func local_cell(records: Dictionary, id: String) -> Vector2i:
	while records.has(id) and id != "global":
		if records[id].template == "Local": return records[id].constraints.global_cell
		id = records[id].parent
	return Vector2i(-1,-1)
