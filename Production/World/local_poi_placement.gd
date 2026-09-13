extends RefCounted
const HexMap = preload("res://Production/World/hex_map.gd")

## Spread destinations over existing land; never reshape water to fit them.
static func generate(map: HexMap, seed_value: int) -> void:
	var planned: Dictionary = {}
	var pending: Array[Dictionary] = []
	for cell: Vector2i in map.links:
		var link: Dictionary = map.links[cell]
		if link.kind == "Return" or link.get("island", false):
			planned[cell] = link
		else:
			pending.append(link.duplicate(true))
	var candidates: Array[Vector2i] = []
	for cell: Vector2i in map.cells():
		if map.walkable(cell) and not map.water_cells.has(cell) and not planned.has(cell):
			candidates.append(cell)
	if candidates.size() < pending.size():
		push_error("Production/World/local_poi_placement.gd: insufficient dry cells for Local POIs; links preserved.")
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for link: Dictionary in pending:
		var scores: Array[int] = []
		var best: int = 0
		for cell: Vector2i in candidates:
			var distance: int = map.dimensions.x + map.dimensions.y
			for occupied: Vector2i in planned:
				distance = mini(distance, map.distance(cell, occupied))
			scores.append(distance)
			best = maxi(best, distance)
		# Random choice within the best-spaced band avoids fixed corner placements.
		var choices: Array[int] = []
		for index: int in range(candidates.size()):
			if scores[index] >= maxi(1, ceili(best * 0.8)):
				choices.append(index)
		var selected: int = choices[rng.randi_range(0, choices.size() - 1)]
		var destination: Vector2i = candidates[selected]
		link.return_cell = destination
		planned[destination] = link
		candidates.remove_at(selected)
	map.links = planned
