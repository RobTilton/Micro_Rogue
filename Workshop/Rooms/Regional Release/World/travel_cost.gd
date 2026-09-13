extends RefCounted
## Half-step units preserve forest's 1.5 multiplier without rounding each tile.
const GLOBAL_UNITS: Dictionary = {"Mountains":6,"Hills":4,"Forest":3,"Swamp":4,"Marsh":4,"Salt Marsh":4,"Wasteland":2,"Plains":2,"Desert":2}
static func units(map, cell: Vector2i) -> int:
	if map == null or map.layer != "Global": return 2
	# Sea/Lakes retain the existing placeholder traversal until water travel is defined.
	return GLOBAL_UNITS.get(map.biomes.get(cell,""),2)
static func path_cost(map, path: Array) -> float:
	var total: int = 0
	for cell: Vector2i in path: total += units(map,cell)
	return total*0.5
