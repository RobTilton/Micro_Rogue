extends RefCounted
## Shared spatial requirements. Learned skills remain tags even when inactive.
const RADIUS: int = 4
const MAX_ORIGINS: int = 3
const DIRECTIONS: Array[Vector2i] = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
const DEFINITIONS: Dictionary = {}
# Retained only to validate and migrate pre-reset saves.
const LEGACY_DEFINITIONS: Dictionary = {
 "Lunge":{"family":"Martial","footprint":[Vector2i.ZERO],"chain":1,"adjacency":[],"cost":1,"prerequisites":[]},
 "Riposte":{"family":"Martial","footprint":[Vector2i.ZERO],"chain":2,"adjacency":[],"cost":1,"prerequisites":["Lunge"]},
 "Show-Off":{"family":"Martial","footprint":[Vector2i.ZERO],"chain":3,"adjacency":[],"cost":1,"prerequisites":["Riposte"]}}
static var cache: Dictionary = {}
static func blank() -> Dictionary: return {"origins":{},"placements":{}}
static func ensure(actor: Dictionary) -> void:
	if not actor.has("skill_board"): actor.skill_board = blank()
static func inside(cell: Vector2i) -> bool: return maxi(absi(cell.x),maxi(absi(cell.y),absi(cell.x+cell.y))) <= RADIUS
static func cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for q: int in range(-RADIUS,RADIUS+1):
		for r: int in range(-RADIUS,RADIUS+1):
			if inside(Vector2i(q,r)): result.append(Vector2i(q,r))
	return result
static func footprint(definition: Dictionary, placement: Dictionary) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for offset: Vector2i in definition.footprint:
		if placement.get("mirror",false): offset = Vector2i(offset.y,offset.x)
		for step: int in range(placement.get("rotation",0)): offset = Vector2i(-offset.y,offset.x+offset.y)
		result.append(placement.cell+offset)
	return result
static func occupied(board: Dictionary, definitions: Dictionary = DEFINITIONS) -> Dictionary:
	var result: Dictionary = {Vector2i.ZERO:{"id":"@center","family":"*"}}
	for family: String in board.origins: result[board.origins[family]] = {"id":"@"+family,"family":family}
	for skill: String in board.placements:
		for cell: Vector2i in footprint(definitions[skill],board.placements[skill]): result[cell] = {"id":skill,"family":definitions[skill].family}
	return result
static func families(actor: Dictionary, definitions: Dictionary = DEFINITIONS) -> Array[String]:
	var result: Array[String] = []
	for skill: String in actor.skills:
		if definitions.has(skill) and definitions[skill].family not in result: result.append(definitions[skill].family)
	return result
static func place_origin(actor: Dictionary, family: String, cell: Vector2i, definitions: Dictionary = DEFINITIONS) -> String:
	ensure(actor)
	var board: Dictionary = actor.skill_board
	if family not in families(actor,definitions): return "Learn a skill in this family first."
	if board.origins.has(family): return "This origin is permanent."
	if board.origins.size() >= MAX_ORIGINS: return "Only three family origins are available."
	if not inside(cell) or occupied(board,definitions).has(cell): return "Choose an empty board hex."
	board.origins[family] = cell
	return ""
static func place(actor: Dictionary, skill: String, cell: Vector2i, rotation: int = 0, mirror: bool = false, definitions: Dictionary = DEFINITIONS) -> String:
	ensure(actor)
	if skill not in actor.skills or not definitions.has(skill): return "Learn this skill first."
	var definition: Dictionary = definitions[skill]
	if not actor.skill_board.origins.has(definition.family): return "Place this family's origin first."
	if rotation < 0 or rotation > 5 or (rotation != 0 and not definition.get("allow_rotation",true)) or (mirror and not definition.get("allow_mirror",false)): return "This footprint does not allow that orientation."
	var proposed: Dictionary = actor.skill_board.duplicate(true)
	proposed.placements.erase(skill)
	var taken: Dictionary = occupied(proposed,definitions)
	var placement: Dictionary = {"cell":cell,"rotation":rotation,"mirror":mirror}
	for target: Vector2i in footprint(definition,placement):
		if not inside(target) or taken.has(target): return "The entire footprint must fit on empty board hexes."
	proposed.placements[skill] = placement
	actor.skill_board = proposed
	return ""
static func evaluate(actor: Dictionary, definitions: Dictionary = DEFINITIONS) -> Dictionary:
	var board: Dictionary = actor.get("skill_board",blank())
	var key: String = str(board)+str(actor.skills)+str(definitions)
	if cache.has(key): return cache[key]
	var taken: Dictionary = occupied(board,definitions)
	var result: Dictionary = {}
	for skill: String in actor.skills:
		if not definitions.has(skill): continue
		var reasons: Array[String] = []
		if not board.placements.has(skill):
			result[skill] = {"active":false,"reason":"Not placed"}
			continue
		var definition: Dictionary = definitions[skill]
		var family: String = definition.family
		if not board.origins.has(family): reasons.append("Missing family origin")
		var boundary: Dictionary = {}
		for cell: Vector2i in footprint(definition,board.placements[skill]):
			for direction: Vector2i in DIRECTIONS:
				var neighbor: Vector2i = cell+direction
				if taken.has(neighbor) and taken[neighbor].id != skill: boundary[neighbor] = taken[neighbor]
		for rule: Dictionary in definition.get("adjacency",[]):
			var count: int = 0
			for neighbor: Vector2i in boundary:
				if boundary[neighbor].family == "*" or boundary[neighbor].family in rule.families: count += 1
			if count < rule.count: reasons.append("Adjacent %s: %d/%d" % [", ".join(rule.families),count,rule.count])
		var required: int = definition.get("chain",0)
		if required > 0 and (not board.origins.has(family) or not chain_satisfied(taken,boundary,skill,family,board.origins.get(family,Vector2i.ZERO),required)):
			reasons.append("Needs chain %d to %s origin" % [required,family])
		result[skill] = {"active":reasons.is_empty(),"reason":"Active" if reasons.is_empty() else "; ".join(reasons)}
	if cache.size() >= 128: cache.clear()
	cache[key] = result
	return result
static func active(actor: Dictionary, skill: String) -> bool:
	return actor.get("humanoid",true) and actor.get("can_use_skills",true) and evaluate(actor).get(skill,{}).get("active",false)
static func chain_satisfied(taken: Dictionary, boundary: Dictionary, excluded: String, family: String, origin: Vector2i, required: int) -> bool:
	var graph: Dictionary = {}
	for cell: Vector2i in taken:
		if taken[cell].id != excluded and taken[cell].family in [family,"*"]: graph[cell] = taken[cell].id
	# Exact simple-hex paths; stop once a sufficient path reaches the origin.
	# Reachability bounds prune disconnected branches without changing longest-path semantics.
	for start: Vector2i in boundary:
		if graph.has(start) and _path(graph,start,origin,required,{},{}): return true
	return false
static func _path(graph: Dictionary, cell: Vector2i, origin: Vector2i, required: int, visited: Dictionary, skills: Dictionary) -> bool:
	visited[cell] = true
	var id: String = graph[cell]
	var previous: int = skills.get(id,0)
	skills[id] = previous+1
	var success: bool = cell == origin and skills.size() >= required
	if cell != origin:
		var reachable: Dictionary = {cell:true}
		var available: Dictionary = skills.duplicate()
		var queue: Array[Vector2i] = [cell]
		var index: int = 0
		while index < queue.size():
			var current: Vector2i = queue[index]
			index += 1
			for direction: Vector2i in DIRECTIONS:
				var next: Vector2i = current+direction
				if graph.has(next) and not visited.has(next) and not reachable.has(next):
					reachable[next] = true
					available[graph[next]] = 1
					queue.append(next)
		if reachable.has(origin) and available.size() >= required:
			for direction: Vector2i in DIRECTIONS:
				var next: Vector2i = cell+direction
				if graph.has(next) and not visited.has(next) and _path(graph,next,origin,required,visited,skills):
					success = true
					break
	visited.erase(cell)
	if previous == 0: skills.erase(id)
	else: skills[id] = previous
	return success
static func valid(actor: Dictionary, definitions: Dictionary = DEFINITIONS) -> bool:
	if not actor.has("skill_board"): return true # Old saves unlock placement, never auto-place permanent origins.
	var board = actor.skill_board
	if not board is Dictionary or not board.get("origins") is Dictionary or not board.get("placements") is Dictionary: return false
	if board.origins.size() > MAX_ORIGINS: return false
	var taken: Dictionary = {Vector2i.ZERO:true}
	for family in board.origins:
		var cell = board.origins[family]
		if not family is String or family not in families(actor,definitions) or not cell is Vector2i or not inside(cell) or taken.has(cell): return false
		taken[cell] = true
	for skill in board.placements:
		if not skill is String or skill not in actor.skills or not definitions.has(skill): return false
		var placement = board.placements[skill]
		if not placement is Dictionary or not placement.get("cell") is Vector2i or not placement.get("rotation") is int or not placement.get("mirror") is bool: return false
		if placement.rotation < 0 or placement.rotation > 5: return false
		if not board.origins.has(definitions[skill].family): return false
		if placement.rotation != 0 and not definitions[skill].get("allow_rotation",true): return false
		if placement.mirror and not definitions[skill].get("allow_mirror",false): return false
		for cell: Vector2i in footprint(definitions[skill],placement):
			if not inside(cell) or taken.has(cell): return false
			taken[cell] = true
	return true
static func auto_place(actor: Dictionary) -> void:
	ensure(actor)
	for family: String in families(actor):
		if not actor.skill_board.origins.has(family):
			for cell: Vector2i in [Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,-1)]:
				if place_origin(actor,family,cell).is_empty(): break
	for skill: String in actor.skills:
		if not DEFINITIONS.has(skill) or actor.skill_board.placements.has(skill): continue
		for cell: Vector2i in cells():
			var before: Dictionary = actor.skill_board.duplicate(true)
			if place(actor,skill,cell).is_empty():
				if active(actor,skill): break
				actor.skill_board = before

static func remove_legacy_skills(actor: Dictionary) -> void:
	for skill: String in LEGACY_DEFINITIONS:
		if skill in actor.skills:
			actor.points += LEGACY_DEFINITIONS[skill].cost
			actor.skills.erase(skill)
		actor.clock_state.remaining.erase(skill)
		actor.clock_state.elapsed.erase(skill)
	actor.skill_board = blank()
	actor.riposte = false
	actor.pending = {}
