extends RefCounted
const Combat = preload("res://Production/Current/gameplay/combat.gd")
static func inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < 7 and cell.y >= 0 and cell.y < 7
static func paths(origin: Vector2i, limit: int, blocked: Array, map = null) -> Dictionary:
	var found: Dictionary = {origin: []}
	var frontier: Array = [origin]
	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_front()
		if found[cell].size() >= limit: continue
		for direction: Vector2i in Combat.DIRECTIONS:
			var next: Vector2i = cell + direction
			if (not inside(next) if map == null else not map.walkable(next)) or next in blocked or found.has(next): continue
			var path: Array = found[cell].duplicate()
			path.append(next)
			found[next] = path
			frontier.append(next)
	found.erase(origin)
	return found
