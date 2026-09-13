extends RefCounted
const Maps = preload("res://Production/World/map_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Combat = preload("res://Production/Actors/combat.gd")
const Inventory = preload("res://Production/Actors/inventory.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Paths = preload("res://Production/World/movement_preview.gd")
const Clock = preload("res://Production/Actors/cooldowns.gd")
const Sight = preload("res://Production/Actors/perception.gd")
var maps: RefCounted
var actors: Dictionary = {}
var ground: Dictionary = {}
var initialized: Dictionary = {}
var player_id: int = 0
var next_id: int = 1
var difficulty: int = 0
var events: Array[String] = []
var tick: int = 0

func _init(seed_value: int = 1729) -> void:
	maps = _make_maps(seed_value)
	ground.global = []
	initialized.global = true

func _make_maps(seed_value: int) -> RefCounted:
	return Maps.new(seed_value)

func add_actor(actor: Dictionary, map_id: String, cell: Vector2i, faction: String, sprite: String = "goblin") -> int:
	assert(maps.maps.has(map_id) and maps.maps[map_id].walkable(cell) and actor_at(map_id,cell).is_empty(), "Production/Actors/actor_world.gd: invalid or occupied actor spawn")
	var id: int = next_id
	next_id += 1
	actor.merge({"id":id,"map_id":map_id,"faction":faction,"sprite":sprite,"pos":cell,"actions":Combat.allowance(actor),"clock":Clock.new(),"pending":{},"retreat":false,"last_seen":{},"trail":[],"known_items":{},"dropped":false,"name":"Adventurer" if faction == "player" else "Goblin"},true)
	Grid.prepare(actor)
	actors[id] = actor
	if faction == "player": player_id = id
	if not ground.has(map_id): ground[map_id] = []
	return id

func on_map(map_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for actor: Dictionary in actors.values():
		if actor.map_id == map_id and actor.hp > 0: result.append(actor)
	return result

func actor_at(map_id: String, cell: Vector2i, except_id: int = -1) -> Dictionary:
	for actor: Dictionary in on_map(map_id):
		if actor.id != except_id and actor.pos == cell: return actor
	return {}

func blocked(actor: Dictionary) -> Array:
	var result: Array = []
	for other: Dictionary in on_map(actor.map_id):
		if actor.id != other.id: result.append(other.pos)
	return result

func paths(actor: Dictionary, limit: int = -1) -> Dictionary:
	return Paths.paths(actor.pos,3+actor.stats.DEX if limit < 0 else limit,blocked(actor),maps.maps[actor.map_id])

func can_see(actor: Dictionary, cell: Vector2i) -> bool:
	return Sight.visible(maps.maps[actor.map_id],actor.pos,cell)

func hostiles(actor: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for other: Dictionary in on_map(actor.map_id):
		if other.faction != actor.faction and can_see(actor,other.pos): result.append(other)
	return result

func engaged(actor: Dictionary) -> bool:
	if not hostiles(actor).is_empty(): return true
	for other: Dictionary in actors.values():
		if other.hp > 0 and other.faction != actor.faction and (not other.trail.is_empty() or not other.last_seen.is_empty()): return true
	return false

func result(ok: bool, reason: String) -> Dictionary:
	return {"ok":ok,"reason":reason}

func ready(actor: Dictionary) -> bool:
	return actor.hp > 0 and actor.pending.is_empty() and not actor.retreat

func move(actor: Dictionary, destination: Vector2i, expected: Array = []) -> Dictionary:
	if not ready(actor) or actor.actions.move <= 0: return result(false,"No movement action available.")
	var available: Dictionary = paths(actor)
	if not available.has(destination) or (not expected.is_empty() and available[destination] != expected): return result(false,"That path is no longer available.")
	record_global_approach(actor,available[destination])
	actor.pos = destination
	actor.actions.move -= 1
	return result(true,"Moved.")

func record_global_approach(actor: Dictionary, route: Array) -> void:
	if actor.map_id != "global" or route.is_empty(): return
	var previous: Vector2i = route[route.size()-2] if route.size() > 1 else actor.pos
	var destination: Vector2i = route.back()
	var global_map = maps.maps.global
	for direction: int in range(6):
		if global_map.canonical(previous+global_map.DIRECTIONS[direction]) == destination:
			actor.global_approach = direction
			return

func next_weapon(actor: Dictionary) -> Dictionary:
	if actor.actions.attack <= 0: return {}
	if actor.actions.used_attacks == 0: return actor.main
	if "Show-Off" in actor.skills and actor.off.get("kind") == "sword": return actor.off
	return {}

func spend_attack(actor: Dictionary) -> Dictionary:
	var weapon: Dictionary = next_weapon(actor)
	actor.actions.attack -= 1
	actor.actions.used_attacks += 1
	return weapon

func skill_available(actor: Dictionary, skill: String) -> bool:
	return ready(actor) and skill in actor.skills and actor.clock.ready(skill) and next_weapon(actor).get("kind") == "sword"

func lunge(actor: Dictionary, destination: Vector2i) -> Dictionary:
	if not skill_available(actor,"Lunge"): return result(false,"Lunge is unavailable.")
	if not paths(actor,actor.stats.DEX).has(destination): return result(false,"No legal Lunge path.")
	record_global_approach(actor,paths(actor,actor.stats.DEX)[destination])
	actor.pending = spend_attack(actor)
	actor.clock.start("Lunge",4)
	actor.pos = destination
	return result(true,"Lunge: choose a target or cancel the optional attack.")

func riposte(actor: Dictionary) -> Dictionary:
	if not skill_available(actor,"Riposte"): return result(false,"Riposte is unavailable.")
	actor.counter_weapon = spend_attack(actor)
	actor.riposte = true
	actor.clock.start("Riposte",2)
	return result(true,"Riposte ready.")

func cancel(actor: Dictionary) -> void:
	actor.pending = {}
	actor.retreat = false

func retreat(actor: Dictionary, destination: Vector2i) -> Dictionary:
	if not actor.retreat or actor.hp <= 0 or not paths(actor,ceili(actor.stats.DEX*0.5)).has(destination): return result(false,"No legal retreat.")
	actor.pos = destination
	actor.retreat = false
	return result(true,"Retreated.")

func attack(actor: Dictionary, target_id: int) -> Dictionary:
	if actor.hp <= 0 or actor.retreat or not actors.has(target_id): return result(false,"No valid attack.")
	var target: Dictionary = actors[target_id]
	var map = maps.maps[actor.map_id]
	if target.hp <= 0 or target.faction == actor.faction or target.map_id != actor.map_id or not can_see(actor,target.pos) or map.distance(actor.pos,target.pos) > Combat.attack_range(actor): return result(false,"Target is out of reach or sight.")
	var lunging: bool = not actor.pending.is_empty()
	var weapon: Dictionary = actor.pending if lunging else next_weapon(actor)
	if weapon.is_empty(): return result(false,"No attack action or weapon available.")
	if lunging: actor.pending = {}
	else: spend_attack(actor)
	var counter: bool = target.riposte
	var damage: int = Combat.attack(actor,target,weapon,lunging,actor.faction == "player",difficulty)
	target.riposte = false
	events.append("%s hits %s for %d." % [actor.name,target.name,damage])
	if counter and target.hp > 0 and not target.get("counter_weapon",{}).is_empty() and map.distance(actor.pos,target.pos) <= Combat.attack_range(target):
		var retaliation: int = Combat.attack(target,actor,target.counter_weapon,false,target.faction == "player",difficulty)
		if retaliation > 0: target.retreat = true
		events.append("%s counters for %d." % [target.name,retaliation])
	resolve_death(target,actor)
	resolve_death(actor,target)
	return result(true,"Attack resolved.")

func resolve_death(actor: Dictionary, killer: Dictionary) -> void:
	if actor.hp > 0 or actor.dropped: return
	actor.dropped = true
	actor.pending = {}
	actor.retreat = false
	actor.trail = []
	actor.last_seen = {}
	if actor.faction != "player":
		for item: Dictionary in Inventory.possessions(actor): ground[actor.map_id].append({"item":item,"pos":actor.pos})
		for slot: String in Grid.EQUIPMENT: actor[slot] = {}
		actor.bag = []
		if killer.hp > 0: Actors.award_xp(killer,actor.level)
		events.append("%s falls and drops its possessions." % actor.name)

func transfer(actor: Dictionary, source: Dictionary, target: Dictionary, preview: bool = false) -> Dictionary:
	if not ready(actor): return result(false,"Finish the pending skill first.")
	if source.get("zone") == "ground":
		var visible: bool = false
		for entry: Dictionary in ground[actor.map_id]:
			if entry.item.item_id == source.get("id") and can_see(actor,entry.pos): visible = true
		if not visible: return result(false,"That item is not visible.")
	return Grid.transfer(actor,ground[actor.map_id],actor.actions,true,source,target,preview,maps.maps[actor.map_id])

func drink(actor: Dictionary, item_id: int) -> Dictionary:
	if not ready(actor) or actor.actions.activation <= 0: return result(false,"No activation action available.")
	for index: int in range(actor.belt.get("contents",[]).size()):
		if actor.belt.contents[index].item_id == item_id:
			actor.belt.contents.remove_at(index)
			actor.actions.activation -= 1
			var healed: int = Combat.heal(actor)
			events.append("%s drinks a potion, restoring %d HP." % [actor.name,healed])
			return result(true,"Potion used.")
	return result(false,"Potion must be in an equipped belt pouch.")

func learn(actor: Dictionary, skill: String) -> Dictionary:
	var sequence: Array[String] = ["Lunge","Riposte","Show-Off"]
	var index: int = sequence.find(skill)
	if actor.hp <= 0 or index < 0 or actor.points <= 0 or skill in actor.skills or (index > 0 and sequence[index-1] not in actor.skills): return result(false,"Skill prerequisites are not met.")
	actor.skills.append(skill)
	actor.points -= 1
	return result(true,"Learned " + skill + ".")

func ensure_map(link: Dictionary):
	var map = maps.resolve(link)
	if initialized.has(map.id): return map
	initialized[map.id] = true
	ground[map.id] = []
	if link.kind in ["Dungeon","Tower"]:
		add_actor(Actors.create(Actors.dice(),true),map.id,Vector2i(6,3),"enemy")
	return map

func arrival_cell(map, origin: Vector2i) -> Vector2i:
	# Occupied entrances wait; only immediately adjacent arrival cells are alternatives.
	var candidates: Array[Vector2i] = [origin]
	candidates.append_array(map.neighbors(origin))
	for candidate: Vector2i in candidates:
		if map.walkable(candidate) and actor_at(map.id,candidate).is_empty(): return candidate
	return Vector2i(-1,-1)

func travel_arrival(_actor: Dictionary, _origin, destination, link: Dictionary) -> Vector2i:
	return arrival_cell(destination,link.get("arrival",Vector2i(1,3)))

func travel(actor: Dictionary) -> Dictionary:
	if not ready(actor) or actor.actions.activation <= 0: return result(false,"Travel requires an activation and no pending skill.")
	var origin = maps.maps[actor.map_id]
	if not origin.links.has(actor.pos): return result(false,"Stand on an entrance to travel.")
	var link: Dictionary = origin.links[actor.pos]
	# Resolve on first use. Occupancy refusal does not transfer the actor or spend actions.
	var destination = ensure_map(link)
	var arrival: Vector2i = travel_arrival(actor,origin,destination,link)
	if arrival == Vector2i(-1,-1): return result(false,"No free, passable arrival is available; wait or approach from another side.")
	for observer: Dictionary in on_map(actor.map_id):
		if observer.faction == actor.faction or not can_see(observer,actor.pos): continue
		observer.last_seen = {"map_id":origin.id,"pos":actor.pos}
		observer.trail = [{"map_id":origin.id,"pos":actor.pos,"destination":destination.id,"arrival":arrival}]
	actor.actions.activation -= 1
	actor.map_id = destination.id
	actor.pos = arrival
	events.append("%s enters %s." % [actor.name,destination.title])
	return result(true,"Entered " + destination.title + ".")

func interact(actor: Dictionary, request: Dictionary) -> Dictionary:
	# Both controllers address existing world objects through this boundary.
	match request.get("kind",""):
		"entrance": return travel(actor)
		"pickup": return transfer(actor,{"zone":"ground","id":request.get("item_id",-1)},{"zone":"pickup"})
	return result(false,"This world object has no implemented interaction.")

func begin_turn(actor: Dictionary) -> void:
	actor.clock.end_turn()
	actor.actions.merge(Combat.allowance(actor),true)
	actor.riposte = false
	actor.pending = {}

func advance(brain: RefCounted) -> void:
	tick += 1
	var player: Dictionary = actors[player_id]
	# Snapshot identities prevents transferred/new actors taking duplicate turns.
	var eligible: Array[int] = []
	for actor: Dictionary in actors.values():
		if actor.hp > 0 and actor.id != player_id and (actor.map_id == player.map_id or not actor.trail.is_empty() or not actor.last_seen.is_empty()): eligible.append(actor.id)
	for id: int in eligible:
		if player.hp <= 0: break
		var actor: Dictionary = actors[id]
		if actor.hp <= 0: continue
		begin_turn(actor)
		brain.take_turn(self,actor)
	begin_turn(player)
