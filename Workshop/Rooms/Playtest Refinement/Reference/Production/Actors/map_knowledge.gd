extends RefCounted
const Sight = preload("res://Production/Actors/perception.gd")
const Map = preload("res://Production/World/hex_map.gd")
# Memory contains observed presentation only, never actors or container inventories.
static func observe(world, actor: Dictionary) -> Dictionary:
	var source = world.maps.maps[actor.map_id]
	var visible: Dictionary = Sight.cells(source,actor)
	if not world.discovered_maps.has(source.id): world.discovered_maps[source.id] = {}
	var memory: Dictionary = world.discovered_maps[source.id]
	for cell: Vector2i in visible:
		var entry: Dictionary = {"wall":cell in source.walls,"biome":source.biomes.get(cell,""),"water":source.water_cells.has(cell),"rivers":{}}
		if source.links.has(cell): entry.link = source.links[cell].duplicate(true)
		if source.props.has(cell):
			var prop: Dictionary = source.props[cell]
			entry.prop = {"kind":prop.kind,"name":prop.name,"opened":prop.opened}
		if source.shops.has(cell):
			var shop: Dictionary = source.shops[cell]
			entry.shop = {"name":shop.name,"roof":shop.roof,"closed":shop.closed}
		memory[cell] = entry
	for key in source.rivers:
		var edge: Dictionary = source.rivers[key]
		if visible.has(edge.cell): memory[edge.cell].rivers[key] = edge.duplicate(true)
	var display = Map.new(source.id,source.title,source.layer,source.dimensions)
	for field: String in ["hex_radius","wrap_horizontal","region_biome","view_zoom","view_offset","view_initialized"]: display.set(field,source.get(field))
	# Floor selection needs layout identity, not unrevealed room geometry.
	display.cave_layout = {"observed":true} if not source.cave_layout.is_empty() else {}
	display.room_layout = {"observed":true} if not source.room_layout.is_empty() else {}
	for cell: Vector2i in memory:
		var entry: Dictionary = memory[cell]
		if entry.wall: display.walls.append(cell)
		if not entry.biome.is_empty(): display.biomes[cell] = entry.biome
		if entry.water: display.water_cells[cell] = true
		if entry.has("link"): display.links[cell] = entry.link
		if entry.has("prop"): display.props[cell] = entry.prop
		if entry.has("shop"): display.shops[cell] = entry.shop
		display.rivers.merge(entry.rivers,true)
	return {"map":display,"known":memory,"visible":visible}

static func valid(value: Variant, states: Dictionary) -> bool:
	if not value is Dictionary: return false
	for id in value:
		if not id is String or not states.has(id) or not value[id] is Dictionary: return false
		var state: Dictionary = states[id]
		var geometry = Map.new(id,"","",state.dimensions)
		geometry.hex_radius = state.hex_radius
		for cell in value[id]:
			if not cell is Vector2i or not geometry.contains(cell): return false
			var entry = value[id][cell]
			if not entry is Dictionary: return false
			if not entry.get("wall") is bool or not entry.get("water") is bool or not entry.get("biome") is String or not entry.get("rivers") is Dictionary: return false
			for field: String in ["link","prop","shop"]:
				if entry.has(field) and not entry[field] is Dictionary: return false
			if entry.has("link") and (not entry.link.get("kind") is String or not entry.link.get("label") is String): return false
			if entry.has("prop") and (not entry.prop.get("kind") is String or not entry.prop.get("name") is String or not entry.prop.get("opened") is bool): return false
			if entry.has("shop") and (not entry.shop.get("roof") is int or not entry.shop.get("name") is String or not entry.shop.get("closed") is bool): return false
			for edge in entry.rivers.values():
				if not edge is Dictionary or edge.get("cell") != cell or not edge.get("direction") is int or edge.direction not in range(6): return false
	return true
