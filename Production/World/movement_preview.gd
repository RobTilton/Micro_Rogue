extends RefCounted
const Combat = preload("res://Production/Actors/combat.gd")
static func inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < 7 and cell.y >= 0 and cell.y < 7
const Travel = preload("res://Production/World/travel_cost.gd")
static func paths(origin: Vector2i, limit: int, blocked: Array, map = null) -> Dictionary:
	var found: Dictionary = {origin: []}
	var costs: Dictionary = {origin: 0}
	var frontier: Array = [origin]
	while not frontier.is_empty():
		var best_index: int = 0
		for index: int in range(1,frontier.size()):
			if costs[frontier[index]] < costs[frontier[best_index]]: best_index = index
		var cell: Vector2i = frontier[best_index]
		frontier.remove_at(best_index)
		for direction: Vector2i in Combat.DIRECTIONS:
			var next: Vector2i = cell + direction
			if map != null: next = map.canonical(next)
			if (not inside(next) if map == null else not map.walkable(next)) or next in blocked: continue
			var cost: int = costs[cell]+Travel.units(map,next)
			if cost > limit*2 or (costs.has(next) and costs[next] <= cost): continue
			var path: Array = found[cell].duplicate()
			path.append(next)
			found[next] = path
			costs[next] = cost
			if next not in frontier: frontier.append(next)
	found.erase(origin)
	return found

## Targeted A* avoids building/copying every reachable route for each mouse click.
static func route_to(origin: Vector2i, goals: Array, blocked: Array, map, max_units: int = -1) -> Array:
	if origin in goals: return []
	if goals.is_empty(): return []
	var frontier: Array = [origin]
	var costs: Dictionary = {origin:0}
	var parents: Dictionary = {}
	while not frontier.is_empty():
		var best: int = 0
		var best_score: int = 2147483647
		for index: int in range(frontier.size()):
			var candidate: Vector2i = frontier[index]
			var distance: int = 2147483647
			for goal: Vector2i in goals: distance = mini(distance,map.distance(candidate,goal))
			var score: int = costs[candidate]+distance*2
			if score < best_score: best_score = score; best = index
		var cell: Vector2i = frontier[best]
		frontier.remove_at(best)
		if cell in goals:
			var result: Array = []
			while cell != origin:
				result.push_front(cell)
				cell = parents[cell]
			return result
		for next: Vector2i in map.neighbors(cell):
			if not map.walkable(next) or next in blocked: continue
			var cost: int = costs[cell]+Travel.units(map,next)
			if (max_units >= 0 and cost > max_units) or (costs.has(next) and costs[next] <= cost): continue
			costs[next] = cost
			parents[next] = cell
			if next not in frontier: frontier.append(next)
	return []
