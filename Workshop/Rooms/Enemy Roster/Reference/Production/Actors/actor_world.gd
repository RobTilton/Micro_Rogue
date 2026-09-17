extends RefCounted
const Maps = preload("res://Production/World/map_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Combat = preload("res://Production/Actors/combat.gd")
const Inventory = preload("res://Production/Actors/inventory.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Paths = preload("res://Production/World/movement_preview.gd")
const Clock = preload("res://Production/Actors/cooldowns.gd")
const Sight = preload("res://Production/Actors/perception.gd")
var discovered_maps: Dictionary = {}
var maps: RefCounted
var actors: Dictionary = {}
var ground: Dictionary = {}
var initialized: Dictionary = {}
var player_id: int = 0
var next_id: int = 1
var difficulty: int = 0
var events: Array[String] = []
var distant_pairs: Dictionary = {}
var hearing_map: String = ""
var hearing_fighting: bool = false
const Equipment = preload("res://Production/Actors/equipment_rules.gd")
const Momentum = preload("res://Production/Actors/momentum.gd")
var turn_threshold: int = Momentum.DEFAULT_THRESHOLD
var tick: int = 0
var motion_events: Array = []
var attack_events: Array = []

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
	Equipment.initialize(actor)
	Momentum.initialize(actor)
	actor.actions = {"move":0,"attack":0,"activation":0,"free":0,"used_attacks":0}
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
	return Sight.visible(maps.maps[actor.map_id],actor.pos,cell,Sight.radius(actor))

func hostiles(actor: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for other: Dictionary in on_map(actor.map_id):
		if hostile(actor,other) and can_see(actor,other.pos): result.append(other)
	return result

func engaged(actor: Dictionary) -> bool:
	for other: Dictionary in on_map(actor.map_id):
		if not hostile(actor,other): continue
		if can_see(other,actor.pos): return true
		if actor.faction != "player" and can_see(actor,other.pos): return true
		if other.get("pursuit_target",-1) == actor.id and (not other.trail.is_empty() or not other.last_seen.is_empty()): return true
	return false

func result(ok: bool, reason: String) -> Dictionary:
	return {"ok":ok,"reason":reason}

func refresh_action_mode(actor: Dictionary) -> void:
	var safe: bool = actor.hp > 0 and not engaged(actor) and actor.pending.is_empty() and not actor.retreat
	if actor.actions.get("exploration",false) and not safe:
		# Exploration cannot accumulate extra combat actions or momentum grants.
		actor.actions = Combat.allowance(actor)
	actor.actions.exploration = safe

func ready(actor: Dictionary) -> bool:
	refresh_action_mode(actor)
	return actor.hp > 0 and actor.pending.is_empty() and not actor.retreat

func move(actor: Dictionary, destination: Vector2i, expected: Array = []) -> Dictionary:
	if not ready(actor) or Combat.available(actor.actions,"move") <= 0: return result(false,"No movement action available.")
	var available: Dictionary = paths(actor)
	if not available.has(destination) or (not expected.is_empty() and available[destination] != expected): return result(false,"That path is no longer available.")
	var route: Array = detection_route(actor,available[destination])
	_record_motion(actor,route)
	record_global_approach(actor,route)
	actor.pos = route.back()
	refresh_action_mode(actor)
	Combat.spend(actor.actions,"move")
	return result(true,"Moved.")

func detection_route(actor: Dictionary, requested: Array) -> Array:
	var route: Array = requested.duplicate()
	if not actors.has(player_id): return route
	var player: Dictionary = actors[player_id]
	if actor.map_id != player.map_id or engaged(player): return route
	if actor.id != player_id and not hostile(actor,player): return route
	var origin: Vector2i = actor.pos
	for index: int in range(route.size()):
		actor.pos = route[index]
		if engaged(player):
			route.resize(index+1)
			break
	actor.pos = origin
	return route

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
	if Combat.available(actor.actions,"attack") <= 0: return {}
	if actor.actions.attack > 0 and actor.actions.used_attacks == 1 and "Show-Off" in actor.skills and actor.off.get("kind") == "sword": return actor.off
	return actor.main

func spend_attack(actor: Dictionary) -> Dictionary:
	var weapon: Dictionary = next_weapon(actor)
	Combat.spend(actor.actions,"attack")
	return weapon

func skill_available(actor: Dictionary, skill: String) -> bool:
	return ready(actor) and skill in actor.skills and actor.clock.ready(skill) and next_weapon(actor).get("kind") == "sword"

func lunge(actor: Dictionary, destination: Vector2i) -> Dictionary:
	if not skill_available(actor,"Lunge"): return result(false,"Lunge is unavailable.")
	if not paths(actor,actor.stats.DEX).has(destination): return result(false,"No legal Lunge path.")
	var route: Array = detection_route(actor,paths(actor,actor.stats.DEX)[destination])
	_record_motion(actor,route)
	record_global_approach(actor,route)
	actor.pos = route.back()
	refresh_action_mode(actor)
	actor.pending = spend_attack(actor)
	actor.clock.start("Lunge",4)
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
	_record_motion(actor,paths(actor,ceili(actor.stats.DEX*0.5))[destination])
	actor.pos = destination
	actor.retreat = false
	return result(true,"Retreated.")

func attack(actor: Dictionary, target_id: int) -> Dictionary:
	refresh_action_mode(actor)
	if actor.hp <= 0 or actor.retreat or not actors.has(target_id): return result(false,"No valid attack.")
	var target: Dictionary = actors[target_id]
	var map = maps.maps[actor.map_id]
	if target.hp <= 0 or not hostile(actor,target) or target.map_id != actor.map_id or not can_see(actor,target.pos) or map.distance(actor.pos,target.pos) > Combat.attack_range(actor): return result(false,"Target is out of reach or sight.")
	var lunging: bool = not actor.pending.is_empty()
	var weapon: Dictionary = actor.pending if lunging else next_weapon(actor)
	if weapon.is_empty(): return result(false,"No attack action or weapon available.")
	if not Equipment.compatible(actor,weapon,"main") and weapon != actor.off: return result(false,"Production/Actors/actor_world.gd: weapon requires a free second hand.")
	target.pursuit_target = actor.id
	target.last_seen = {"map_id":actor.map_id,"pos":actor.pos}
	refresh_action_mode(actor)
	refresh_action_mode(target)
	if lunging: actor.pending = {}
	else: spend_attack(actor)
	var counter: bool = target.riposte
	var damage: int = Combat.attack(actor,target,weapon,lunging,actor.faction == "player",difficulty)
	target.riposte = false
	record_attack_effect(actor,target,weapon,damage,lunging)
	report_combat(actor,target,"%s hits %s for %d." % [actor.name,target.name,damage])
	if counter and target.hp > 0 and not target.get("counter_weapon",{}).is_empty() and map.distance(actor.pos,target.pos) <= Combat.attack_range(target):
		var retaliation: int = Combat.attack(target,actor,target.counter_weapon,false,target.faction == "player",difficulty)
		record_attack_effect(target,actor,target.counter_weapon,retaliation,false)
		if retaliation > 0: target.retreat = true
		report_combat(target,actor,"%s counters for %d." % [target.name,retaliation])
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
		report_observed(actor,"%s falls and drops its possessions." % actor.name)

func transfer(actor: Dictionary, source: Dictionary, target: Dictionary, preview: bool = false) -> Dictionary:
	if not ready(actor): return result(false,"Finish the pending skill first.")
	if source.get("zone") == "ground":
		var visible: bool = false
		for entry: Dictionary in ground[actor.map_id]:
			if entry.item.item_id == source.get("id") and can_see(actor,entry.pos): visible = true
		if not visible: return result(false,"That item is not visible.")
	return Grid.transfer(actor,ground[actor.map_id],actor.actions,not actor.actions.get("exploration",false),source,target,preview,maps.maps[actor.map_id])

func drink(actor: Dictionary, item_id: int) -> Dictionary:
	if not ready(actor) or Combat.available(actor.actions,"activation") <= 0: return result(false,"No activation action available.")
	for storage: Array in [actor.belt.get("contents",[]),actor.bag]:
		for index: int in range(storage.size()):
			if storage[index].get("kind") == "potion" and storage[index].item_id == item_id:
				storage.remove_at(index)
				Combat.spend(actor.actions,"activation")
				var healed: int = Combat.heal(actor)
				report_observed(actor,"%s drinks a potion, restoring %d HP." % [actor.name,healed])
				return result(true,"Potion used.")
	return result(false,"Production/Actors/actor_world.gd: potion is not carried.")

func learn(actor: Dictionary, skill: String) -> Dictionary:
	var sequence: Array[String] = ["Lunge","Riposte","Show-Off"]
	var index: int = sequence.find(skill)
	if not actor.get("can_use_skills",true): return result(false,"This actor spends advancement points on stats.")
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
	if not ready(actor) or Combat.available(actor.actions,"activation") <= 0: return result(false,"Travel requires an activation and no pending skill.")
	var origin = maps.maps[actor.map_id]
	if not origin.links.has(actor.pos): return result(false,"Stand on an entrance to travel.")
	var link: Dictionary = origin.links[actor.pos]
	# Resolve on first use. Occupancy refusal does not transfer the actor or spend actions.
	var destination = ensure_map(link)
	var arrival: Vector2i = travel_arrival(actor,origin,destination,link)
	if arrival == Vector2i(-1,-1): return result(false,"No free, passable arrival is available; wait or approach from another side.")
	for observer: Dictionary in on_map(actor.map_id):
		if not hostile(actor,observer) or not can_see(observer,actor.pos): continue
		observer.last_seen = {"map_id":origin.id,"pos":actor.pos}
		observer.pursuit_target = actor.id
		observer.trail = [{"map_id":origin.id,"pos":actor.pos,"destination":destination.id,"arrival":arrival}]
	Combat.spend(actor.actions,"activation")
	actor.map_id = destination.id
	actor.pos = arrival
	report_observed(actor,"%s enters %s." % [actor.name,destination.title])
	return result(true,"Entered " + destination.title + ".")

func interact(actor: Dictionary, request: Dictionary) -> Dictionary:
	# Both controllers address existing world objects through this boundary.
	match request.get("kind",""):
		"entrance": return travel(actor)
		"search": return search_container(actor,request.get("cell",Vector2i(-1,-1)))
		"pickup": return transfer(actor,{"zone":"ground","id":request.get("item_id",-1)},{"zone":"pickup"})
	return result(false,"This world object has no implemented interaction.")

func begin_turn(actor: Dictionary) -> void:
	actor.clock.end_turn()
	var earned: int = Momentum.grants(actor,turn_threshold)
	actor.actions = Combat.allowance(actor) if earned > 0 else {"move":0,"attack":0,"activation":0,"used_attacks":0,"free":0}
	actor.actions.free = maxi(0,earned-1)
	actor.riposte = false
	actor.pending = {}

func advance(brain: RefCounted) -> void:
	tick += 1
	var player: Dictionary = actors[player_id]
	# Credit every living NPC once. Only active/pursuing NPCs run spatial AI.
	var living: Array = actors.values()
	var eligible: Array[int] = []
	for actor: Dictionary in living:
		if actor.hp <= 0 or actor.id == player_id: continue
		begin_turn(actor)
		if Combat.remaining(actor.actions) > 0 and (actor.map_id == player.map_id or not actor.trail.is_empty() or not actor.last_seen.is_empty()): eligible.append(actor.id)
	for id: int in eligible:
		var actor: Dictionary = actors[id]
		# A finite budget lets the same policy use additional moves/activations too.
		for attempt: int in range(Combat.remaining(actor.actions)+1):
			if player.hp <= 0 or actor.hp <= 0: break
			var before: int = Combat.remaining(actor.actions)
			brain.take_turn(self,actor)
			if Combat.remaining(actor.actions) >= before or Combat.remaining(actor.actions) == 0: break
	if player.hp > 0: begin_turn(player)

func advance_to_player(brain: RefCounted) -> void:
	# Slow actors wait in world time, not through repeated empty player prompts.
	advance(brain)
	var player: Dictionary = actors[player_id]
	for catch_up: int in range(255):
		if player.hp <= 0 or Combat.remaining(player.actions) > 0 or Momentum.speed(player) <= 0: break
		advance(brain)

func set_speed_effect(actor_id: int, source: String, modifier: float) -> Dictionary:
	if not actors.has(actor_id) or source.is_empty() or not is_finite(modifier): return result(false,"Production/Actors/actor_world.gd: invalid speed effect.")
	var actor: Dictionary = actors[actor_id]
	Momentum.initialize(actor)
	if modifier == 0.0: actor.speed_effects.erase(source)
	else: actor.speed_effects[source] = modifier
	return result(true,"Speed effect updated; applies on the next world tick.")

func adjust_momentum(actor_id: int, amount: float) -> Dictionary:
	if not actors.has(actor_id) or not is_finite(amount): return result(false,"Production/Actors/actor_world.gd: invalid momentum adjustment.")
	Momentum.initialize(actors[actor_id])
	actors[actor_id].momentum = maxf(0.0,actors[actor_id].momentum+amount)
	return result(true,"Momentum updated; grants resolve on the next world tick.")

func change_grip(actor: Dictionary) -> Dictionary:
	if not ready(actor) or actor.main.get("hands","") != "versatile": return result(false,"Production/Actors/actor_world.gd: weapon does not support alternate grips.")
	if not actor.off.is_empty(): return result(false,"Production/Actors/actor_world.gd: empty the offhand before two-handing.")
	if Combat.available(actor.actions,"activation") <= 0: return result(false,"Production/Actors/actor_world.gd: changing grip needs an activation.")
	Combat.spend(actor.actions,"activation")
	actor.grip = "one" if actor.get("grip","one") == "two" else "two"
	return result(true,"Using "+actor.grip+" hand(s).")

func inspect_shop(actor: Dictionary, cell: Vector2i) -> Dictionary:
	var map = maps.maps[actor.map_id]
	if actor.hp <= 0 or not map.shops.has(cell) or map.distance(actor.pos,cell) > 1 or not can_see(actor,cell): return result(false,"Production/Actors/actor_world.gd: approach the shop to interact.")
	return {"ok":true,"shop":map.shops[cell].duplicate(true)}

func search_container(actor: Dictionary, cell: Vector2i) -> Dictionary:
	var map = maps.maps[actor.map_id]
	if not ready(actor) or Combat.available(actor.actions,"activation") <= 0: return result(false,"Production/Actors/actor_world.gd: searching requires an activation.")
	if not map.props.has(cell) or map.distance(actor.pos,cell) > 1 or not can_see(actor,cell): return result(false,"Production/Actors/actor_world.gd: approach a visible container to search.")
	var prop: Dictionary = map.props[cell]
	if prop.kind in ["rug","rubble"] or prop.opened: return result(false,"Production/Actors/actor_world.gd: nothing left to search.")
	Combat.spend(actor.actions,"activation")
	for item: Dictionary in prop.contents: ground[map.id].append({"item":item,"pos":cell})
	actor.gold = actor.get("gold",0)+prop.get("gold",0)
	prop.gold = 0
	prop.contents = []
	prop.opened = true
	return result(true,"Searched "+prop.name+". Its contents are available nearby.")

func buy(actor: Dictionary, cell: Vector2i, item_id: int) -> Dictionary:
	var access: Dictionary = inspect_shop(actor,cell)
	if not access.ok or access.shop.closed or not ready(actor) or Combat.available(actor.actions,"activation") <= 0: return result(false,"Production/Actors/actor_world.gd: approach an open shop with an activation available.")
	var shop: Dictionary = maps.maps[actor.map_id].shops[cell]
	for index: int in range(shop.get("stock",[]).size()):
		var entry: Dictionary = shop.stock[index]
		if entry.item.item_id != item_id: continue
		if actor.get("gold",0) < entry.price: return result(false,"Production/Actors/actor_world.gd: not enough gold.")
		var staged: Array = actor.bag.duplicate(true)
		if not Grid.place_auto(staged,entry.item.duplicate(true)): return result(false,"Production/Actors/actor_world.gd: backpack is full.")
		actor.bag = staged
		actor.gold = actor.get("gold",0)-entry.price
		shop.stock.remove_at(index)
		Combat.spend(actor.actions,"activation")
		return result(true,"Bought "+entry.item.name+".")
	return result(false,"Production/Actors/actor_world.gd: that item is no longer in stock.")

func hostile(a: Dictionary, b: Dictionary) -> bool:
	if a.faction == "enemy" and b.faction == "enemy": return faction_key(a) != faction_key(b)
	return a.faction != b.faction and not (a.faction in ["player","town"] and b.faction in ["player","town"])

func _record_motion(actor: Dictionary, route: Array) -> void:
	motion_events.append({"actor_id":actor.id,"map_id":actor.map_id,"from":actor.pos,"route":route.duplicate()})
	if motion_events.size() > 256: motion_events.pop_front()

func spend_stat(actor: Dictionary, stat: String) -> Dictionary:
	if actor.hp <= 0 or stat not in Actors.STATS or actor.points < 1: return result(false,"Production/Actors/actor_world.gd: one skill point is required for a valid stat.")
	actor.points -= 1
	actor.stats[stat] += 1
	if not actor.has("stat_training"): actor.stat_training = {}
	actor.stat_training[stat] = actor.stat_training.get(stat,0)+1
	if stat == "WIL":
		actor.max_hp += 3
		actor.hp += 3
	return result(true,stat+" increased by 1.")

func sell(actor: Dictionary, cell: Vector2i, item_id: int) -> Dictionary:
	var access: Dictionary = inspect_shop(actor,cell)
	if not access.ok or access.shop.closed or access.shop.id == "inn" or not ready(actor) or Combat.available(actor.actions,"activation") <= 0:
		return result(false,"Production/Actors/actor_world.gd: approach an open merchant with an activation available during combat.")
	var pricing = preload("res://Production/World/village_shops.gd")
	for index: int in range(actor.bag.size()):
		var item: Dictionary = actor.bag[index]
		if item.item_id != item_id: continue
		if not pricing.sellable(item): return result(false,"Production/Actors/actor_world.gd: sell backpack gear; empty a loaded belt first.")
		var shop: Dictionary = maps.maps[actor.map_id].shops[cell]
		var price: int = pricing.sale_price(item)
		actor.bag.remove_at(index)
		shop.stock.append({"item":item,"price":pricing.retail_price(item)})
		actor.gold = actor.get("gold",0)+price
		Combat.spend(actor.actions,"activation")
		return result(true,"Sold "+item.name+" for "+str(price)+" gold.")
	return result(false,"Production/Actors/actor_world.gd: that gear is no longer in the backpack.")

static func faction_key(actor: Dictionary) -> String:
	return actor.get("faction_id",actor.get("family","goblins"))

func report_observed(actor: Dictionary, message: String) -> void:
	if not actors.has(player_id): return
	var player: Dictionary = actors[player_id]
	if actor.id == player_id or (actor.map_id == player.map_id and can_see(player,actor.pos)): events.append(message)

func _hearing_context() -> void:
	var current: String = actors[player_id].map_id if actors.has(player_id) else ""
	if current != hearing_map:
		hearing_map = current
		distant_pairs.clear()
		hearing_fighting = false

func report_combat(a: Dictionary, b: Dictionary, message: String) -> void:
	_hearing_context()
	if not actors.has(player_id) or a.map_id != hearing_map: return
	var player: Dictionary = actors[player_id]
	if a.id == player_id or b.id == player_id or (can_see(player,a.pos) and can_see(player,b.pos)):
		events.append(message)
		return
	var key: String = str(mini(a.id,b.id))+":"+str(maxi(a.id,b.id))
	distant_pairs[key] = [a.id,b.id]
	if not hearing_fighting:
		events.append("You hear fighting in the distance.")
		hearing_fighting = true

func finish_hearing() -> void:
	_hearing_context()
	if not hearing_fighting: return
	var player: Dictionary = actors[player_id]
	var became_visible: bool = false
	for key: String in distant_pairs.keys():
		var pair: Array = distant_pairs[key]
		if not actors.has(pair[0]) or not actors.has(pair[1]): distant_pairs.erase(key); continue
		var a: Dictionary = actors[pair[0]]
		var b: Dictionary = actors[pair[1]]
		if a.hp <= 0 or b.hp <= 0 or a.map_id != hearing_map or b.map_id != hearing_map or not hostile(a,b):
			distant_pairs.erase(key)
		elif can_see(player,a.pos) and can_see(player,b.pos):
			became_visible = true
			distant_pairs.erase(key)
		elif not can_see(a,b.pos) and not can_see(b,a.pos) and a.trail.is_empty() and b.trail.is_empty(): distant_pairs.erase(key)
	if distant_pairs.is_empty():
		if not became_visible: events.append("The distant fighting falls silent.")
		hearing_fighting = false

func set_sight_effect(actor: Dictionary, source: String, modifier: int) -> Dictionary:
	if source.is_empty(): return result(false,"Production/Actors/actor_world.gd: sight effects require a source.")
	if not actor.has("sight_effects"): actor.sight_effects = {}
	if modifier == 0: actor.sight_effects.erase(source)
	else: actor.sight_effects[source] = modifier
	if actors.has(player_id): refresh_action_mode(actors[player_id])
	return result(true,"Sight updated.")

func record_attack_effect(actor: Dictionary, target: Dictionary, weapon: Dictionary, damage: int, lunging: bool) -> void:
	if not actors.has(player_id): return
	var player: Dictionary = actors[player_id]
	if actor.map_id != player.map_id or not can_see(player,actor.pos) or not can_see(player,target.pos): return
	attack_events.append({"map_id":actor.map_id,"from":actor.pos,"to":target.pos,"category":weapon.get("category","swords"),"two_handed":Equipment.hands(actor,weapon)==2,"channel":weapon.get("damage_type","physical"),"blocked":damage==0,"lunge":lunging})
	if attack_events.size() > 64: attack_events.pop_front()
