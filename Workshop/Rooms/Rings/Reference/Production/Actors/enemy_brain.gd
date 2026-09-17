extends RefCounted
const Rules = preload("res://Production/Actors/equipment_rules.gd")
const Combat = preload("res://Production/Actors/combat.gd")
## Deliberately small policy. Legal actions and mutations belong to ActorWorld.
static func score(item: Dictionary) -> float:
	if item.is_empty(): return -1000.0
	if item.kind == "belt": return float(item.capacity)
	if item.kind in ["armor","shield"]: return Rules.defense_item(item,"physical")+Rules.defense_item(item,"magical")
	return (float(item.get("die",0))+1.0)*0.5+float(preload("res://Production/Actors/equipment_rules.gd").damage_bonus(item))

static func upgrade_slot(actor: Dictionary, item: Dictionary) -> String:
	if not actor.get("humanoid",true): return ""
	var slots: Array[String] = []
	match item.kind:
		"sword":
			slots.append("main")
			if preload("res://Production/Actors/skill_board.gd").active(actor,"Show-Off") and actor.main.get("kind") == "sword": slots.append("off")
		"shield": slots.append("off")
		"armor": slots.append(item.get("slot","armor"))
		"weapon": slots.append("main")
		"belt": slots.append("belt")
	var best: String = ""
	var gain: float = 0.0
	for slot: String in slots:
		var planned: Dictionary = actor.duplicate(true)
		var displaced_score: float = 0.0
		if slot == "main" and item.get("hands","one") == "two" and not actor.off.is_empty():
			displaced_score = score(actor.off)
			planned.off = {}
		if not Rules.compatible(planned,item,slot): continue
		var improvement: float = score(item)-score(actor.get(slot,{}))-displaced_score
		if Rules.is_weapon(item): improvement += Rules.stat_bonus(planned,item)-(Rules.stat_bonus(actor,actor[slot]) if Rules.is_weapon(actor.get(slot,{})) else 0)
		if improvement > gain:
			best = slot
			gain = improvement
	return best

func approach(world, actor: Dictionary, goal: Vector2i, adjacent: bool = false) -> bool:
	if Combat.available(actor.actions,"move") <= 0: return false
	var map = world.maps.maps[actor.map_id]
	var occupied: Array = world.blocked(actor)
	var distances: Dictionary = {}
	var queue: Array[Vector2i] = []
	var targets: Array = map.neighbors(goal) if adjacent else [goal]
	for cell: Vector2i in targets:
		if map.walkable(cell) and cell not in occupied:
			distances[cell] = 0
			queue.append(cell)
	var head: int = 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		for neighbor: Vector2i in map.neighbors(cell):
			if map.walkable(neighbor) and neighbor not in occupied and not distances.has(neighbor):
				distances[neighbor] = distances[cell]+1
				queue.append(neighbor)
	var best: Vector2i = actor.pos
	var best_distance: int = distances.get(best,2147483647)
	for cell: Vector2i in world.paths(actor):
		if distances.get(cell,2147483647) < best_distance:
			best = cell
			best_distance = distances[cell]
	return best != actor.pos and world.move(actor,best).ok

func take_turn(world, actor: Dictionary) -> void:
	if actor.get("exploration_tick",-1) != world.tick:
		actor.exploration_tick = world.tick
		actor.idle_rounds = actor.get("idle_rounds",0)+1
		if not actor.has("explored_cells"): actor.explored_cells = {}
		if not actor.explored_cells.has(actor.map_id): actor.explored_cells[actor.map_id] = {}
		var seen: Dictionary = preload("res://Production/Actors/perception.gd").cells(world.maps.maps[actor.map_id],actor)
		for cell: Vector2i in seen: actor.explored_cells[actor.map_id][cell] = true
	if actor.faction == "town" and world.hostiles(actor).is_empty(): return
	if not actor.get("humanoid",true) or not actor.get("can_use_skills",true):
		while actor.points > 0:
			var weakest: String = "CON"
			for stat: String in world.Actors.STATS:
				if actor.stats[stat] < actor.stats[weakest]: weakest = stat
			world.spend_stat(actor,weakest)
	for skill: String in ["Lunge","Riposte","Show-Off"]:
		if skill not in actor.skills and actor.points > 0: world.learn(actor,skill)
	if actor.get("humanoid",true) and not world.engaged(actor): world.SkillBoard.auto_place(actor)
	if actor.retreat:
		var enemies: Array[Dictionary] = world.hostiles(actor)
		var best: Vector2i = actor.pos
		var distance: int = 0
		if not enemies.is_empty():
			for cell: Vector2i in world.paths(actor,ceili(actor.stats.DEX*0.5)):
				var candidate: int = world.maps.maps[actor.map_id].distance(cell,enemies[0].pos)
				if candidate > distance: best = cell; distance = candidate
		if best != actor.pos: world.retreat(actor,best)
		else: world.cancel(actor)
	if actor.hp <= actor.max_hp*0.5 and not actor.belt.get("contents",[]).is_empty():
		world.drink(actor,actor.belt.contents[0].item_id)
	# Equip only inspected possessions, paying the same activation as the player.
	for item: Dictionary in (actor.bag.duplicate() if actor.get("humanoid",true) else []):
		if Combat.available(actor.actions,"activation") <= 0: break
		if item.kind == "potion":
			world.transfer(actor,{"zone":"bag","id":item.item_id},{"zone":"belt","belt_id":actor.belt.get("item_id",-1)})
		else:
			var slot: String = upgrade_slot(actor,item)
			if not slot.is_empty(): world.transfer(actor,{"zone":"bag","id":item.item_id},{"zone":"equipment","slot":slot})
	var enemies: Array[Dictionary] = world.hostiles(actor)
	var target: Dictionary = {}
	var map = world.maps.maps[actor.map_id]
	for other: Dictionary in enemies:
		if target.is_empty() or map.distance(actor.pos,other.pos) < map.distance(actor.pos,target.pos): target = other
	if not target.is_empty():
		actor.idle_rounds = 0
		actor.last_seen = {"map_id":actor.map_id,"pos":target.pos}
		actor.pursuit_target = target.id
		actor.trail = []
	# An adjacent opponent is urgent; otherwise investigate visible equipment.
	if target.is_empty() and actor.get("humanoid",true):
		for entry: Dictionary in world.ground[actor.map_id].duplicate():
			if not world.can_see(actor,entry.pos): continue
			var item: Dictionary = entry.item
			if actor.known_items.has(item.item_id) and not actor.known_items[item.item_id]: continue
			if map.distance(actor.pos,entry.pos) > 1:
				# Only the visible type is considered remotely, never its bonus/rarity.
				if item.kind not in ["sword","weapon","shield","armor","belt","potion"]: continue
				if approach(world,actor,entry.pos,true): actor.idle_rounds = 0
			if map.distance(actor.pos,entry.pos) <= 1 and world.can_see(actor,entry.pos):
				var desired: bool = item.kind == "potion" or not upgrade_slot(actor,item).is_empty()
				actor.known_items[item.item_id] = desired
				if desired:
					var pickup: Dictionary = world.interact(actor,{"kind":"pickup","item_id":item.item_id})
					if pickup.ok:
						actor.idle_rounds = 0
						world.report_observed(actor,actor.name + " collects " + item.name + ".")
			break
	if target.is_empty() and actor.get("humanoid",true) and Combat.available(actor.actions,"activation") > 0:
		for cell: Vector2i in map.props:
			var prop: Dictionary = map.props[cell]
			if prop.opened or prop.kind in ["rug","rubble"] or not world.can_see(actor,cell): continue
			if map.distance(actor.pos,cell) > 1 and approach(world,actor,cell,true): actor.idle_rounds = 0
			if world.interact(actor,{"kind":"search","cell":cell}).ok: actor.idle_rounds = 0
			break
	if not target.is_empty():
		if map.distance(actor.pos,target.pos) > 1 and world.skill_available(actor,"Lunge"):
			for cell: Vector2i in world.paths(actor,actor.stats.DEX):
				if map.distance(cell,target.pos) <= 1:
					world.lunge(actor,cell)
					break
		if map.distance(actor.pos,target.pos) > Combat.attack_range(actor): approach(world,actor,target.pos,true)
		# All available legal weapon attacks, including Show-Off and pending Lunge.
		for index: int in range(Combat.available(actor.actions,"attack")+(1 if not actor.pending.is_empty() else 0)):
			if target.hp <= 0: break
			if not world.attack(actor,target.id).ok: break
		if world.skill_available(actor,"Riposte"): world.riposte(actor)
		world.cancel(actor)
		return
	if not actor.trail.is_empty():
		var exit_memory: Dictionary = actor.trail[0]
		if exit_memory.map_id == actor.map_id:
			if actor.pos != exit_memory.pos: approach(world,actor,exit_memory.pos)
			if actor.pos == exit_memory.pos:
				var travel_result: Dictionary = world.cross_border(actor,exit_memory.border) if exit_memory.has("border") else world.interact(actor,{"kind":"entrance"})
				if travel_result.ok:
					actor.trail.pop_front()
					actor.last_seen = {"map_id":actor.map_id,"pos":exit_memory.arrival}
		return
	if not actor.last_seen.is_empty() and actor.last_seen.map_id == actor.map_id:
		var remembered: Vector2i = actor.last_seen.pos
		if actor.pos == remembered or not approach(world,actor,remembered): actor.last_seen = {}
	if actor.idle_rounds >= 3 and actor.last_seen.is_empty(): explore(world,actor)
	world.cancel(actor)

func explore(world, actor: Dictionary) -> bool:
	var map = world.maps.maps[actor.map_id]
	var memory: Dictionary = actor.explored_cells.get(actor.map_id,{})
	var reachable: Dictionary = world.paths(actor)
	var best: Vector2i = actor.pos
	var score_value: float = 0.0
	for cell: Vector2i in reachable:
		if not memory.has(cell): continue
		var unknown: int = 0
		for neighbor: Vector2i in map.neighbors(cell):
			if not memory.has(neighbor): unknown += 1
		var score_candidate: float = unknown*10.0-map.distance(actor.pos,cell)
		if unknown > 0 and score_candidate > score_value:
			best = cell
			score_value = score_candidate
	if best != actor.pos: return world.move(actor,best).ok
	# A remembered frontier farther away is reached using the same legal movement.
	var distance: int = 2147483647
	for cell: Vector2i in memory:
		if cell == actor.pos or not map.walkable(cell): continue
		for neighbor: Vector2i in map.neighbors(cell):
			if not memory.has(neighbor) and map.distance(actor.pos,cell) < distance:
				best = cell
				distance = map.distance(actor.pos,cell)
	return best != actor.pos and approach(world,actor,best)
