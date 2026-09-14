extends RefCounted
const Map = preload("res://Production/World/hex_map.gd")
const FIELDS: Array[String] = ["hex_radius","regional_revision","regional_values","id","title","layer","dimensions","wrap_horizontal","continents","spawn_cell","walls","view_offset","view_initialized","rivers","elevations","river_routes","water_cells","biomes","region_biome","links","shops"]
static func capture(map) -> Dictionary:
	var result: Dictionary = {}
	for field: String in FIELDS:
		var value = map.get(field)
		result[field] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result
static func restore(state: Dictionary):
	var map = Map.new(state.id,state.title,state.layer,state.dimensions)
	for field: String in FIELDS: map.set(field,state.get(field,{}) if field == "shops" else state[field])
	return map
static func valid(state) -> bool:
	if not state is Dictionary: return false
	for field: String in FIELDS:
		if field != "shops" and not state.has(field): return false
	for field: String in ["id","title","layer","region_biome"]:
		if not state[field] is String: return false
	if not state.hex_radius is int or state.hex_radius < 0 or not state.regional_revision is int or not state.regional_values is Dictionary: return false
	if state.hex_radius > 0 and state.dimensions != Vector2i(state.hex_radius*2+1,state.hex_radius*2+1): return false
	for field: String in ["continents","rivers","elevations","water_cells","biomes","links"]:
		if not state[field] is Dictionary: return false
	if not state.dimensions is Vector2i or state.dimensions.x < 1 or state.dimensions.y < 1 or state.dimensions.x > 1024 or state.dimensions.y > 1024: return false
	if not state.spawn_cell is Vector2i or not state.view_offset is Vector2 or not state.view_initialized is bool or not state.wrap_horizontal is bool: return false
	if not state.walls is Array or not state.river_routes is Array: return false
	for cell in state.walls:
		if not cell is Vector2i: return false
	for cell in state.biomes:
		if not cell is Vector2i or not state.biomes[cell] is String: return false
	for cell in state.water_cells:
		if not cell is Vector2i or not state.water_cells[cell] is bool: return false
	for edge in state.rivers.values():
		if not edge is Dictionary or not edge.get("cell") is Vector2i or not edge.get("direction") is int or edge.direction not in range(6): return false
	for route in state.river_routes:
		if not route is Dictionary or not route.get("vertices") is Array: return false
		for vertex in route.vertices:
			if not vertex is Vector2i: return false
	if not state.get("shops",{}) is Dictionary: return false
	var geometry = Map.new(state.id,state.title,state.layer,state.dimensions)
	geometry.hex_radius = state.hex_radius
	var ids: Array = []
	for cell in state.get("shops",{}):
		var shop = state.shops[cell]
		if not cell is Vector2i or not geometry.contains(cell) or cell in state.walls or state.links.has(cell) or cell == state.spawn_cell: return false
		if not shop is Dictionary or not shop.get("id") is String or shop.id in ids or not shop.get("name") is String or not shop.get("roof") is int or shop.roof not in range(6) or not shop.get("closed") is bool: return false
		ids.append(shop.id)
	return true
