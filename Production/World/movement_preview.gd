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
