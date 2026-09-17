extends "res://Production/Actors/actor_world.gd"
const Roster = preload("res://Production/Actors/enemy_roster.gd")
const Locations = preload("res://Production/World/location_world.gd")
const Templates = preload("res://Production/World/location_templates.gd")
const Contracts = preload("res://Production/World/geographic_contracts.gd")
const Items = preload("res://Production/Actors/items.gd")
const MapState = preload("res://Production/Persistence/map_state.gd")
const Journal = preload("res://Production/Persistence/autosave_journal.gd")
const SAVE_SCHEMA: int = 1
const Storage = preload("res://Production/Persistence/storage_paths.gd")
const SAVE_DIR: String = Storage.SNAPSHOTS
const Entry = preload("res://Production/World/local_entry.gd")
var last_save: String = ""
var regeneration: Dictionary = {}
var creation: Dictionary = {}
var world_hours: int = 0

func _make_maps(seed_value: int) -> RefCounted:
	return Locations.new(seed_value)

func ensure_map(link: Dictionary):
	var map = maps.ensure_location(link.id)
	if map == null: return null
	if initialized.has(map.id):
		if maps.records[map.id].template == "Town" and preload("res://Production/World/village_shops.gd").ensure_supplies(map): maps.revision += 1
		_balance_chest_gold(map)
		_scale_monsters()
		return map
	var record: Dictionary = maps.records[map.id]
	var definition: Dictionary = Templates.get_template(record.template)
	ground[map.id] = []
	if record.template == "Local": _populate_local(map)
	if record.template == "Town":
		preload("res://Production/World/village_shops.gd").stock(map,record.seed)
		_populate_town(map)
		maps.revision += 1
	# Dedicated seeded population stream, independent of global RNG and visit order.
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(record.seed,"population")
	if not map.room_layout.is_empty():
		_populate_rooms(map,map.room_layout,"dungeon_room_id")
		preload("res://Production/World/interior_props.gd").populate(map,map.room_layout,record.template)
		maps.revision += 1
		_seed_prop_gold(map)
		initialized[map.id] = true
		return map
	if not map.cave_layout.is_empty():
		_populate_cave(map)
		preload("res://Production/World/interior_props.gd").populate(map,map.cave_layout,"Cave")
		maps.revision += 1
		_seed_prop_gold(map)
		initialized[map.id] = true
		return map
	for index: int in range(definition.get("population",0)):
		var values: Array = []
		for stat: int in range(6): values.append(rng.randi_range(1,6))
		var actor: Dictionary = _monster(values,rng,map,false)
		var cell: Vector2i = arrival_cell(map,Vector2i(6,3))
		if cell != Vector2i(-1,-1): add_actor(actor,map.id,cell,"enemy")
	if definition.get("population",0) > 0:
		var drop: Dictionary = Items.loot({"max_material_tier":3},rng)
		var loot_cell: Vector2i = arrival_cell(map,map.spawn_cell)
		if drop.ok and loot_cell != Vector2i(-1,-1): ground[map.id].append({"item":drop.item,"pos":loot_cell})
	_seed_prop_gold(map)
	initialized[map.id] = true
	return map

func travel(actor: Dictionary) -> Dictionary:
	if not ready(actor) or Combat.available(actor.actions,"activation") <= 0: return result(false,"No travel action available.")
	var origin = maps.ensure_location(actor.map_id)
	if origin == null: return result(false,"The source location could not be loaded.")
	if origin.links.has(actor.pos):
		if maps.ensure_location(origin.links[actor.pos].id) == null: return result(false,"The destination could not be loaded.")
	var departure: Vector2i = actor.pos
	var link: Dictionary = origin.links.get(departure,{})
	var outcome: Dictionary = super.travel(actor)
	if outcome.ok and link.get("reveal_ladder",false) and actor.faction == "player":
		var destination = maps.maps[actor.map_id]
		destination.links[link.arrival] = maps.entrance(origin.id,"Climb ladder to top floor","Ladder",departure)
		maps.revision += 1
	return outcome

func can_see(actor: Dictionary, cell: Vector2i) -> bool:
	if maps.ensure_location(actor.map_id) == null: return false
	return super.can_see(actor,cell)

func advance(brain: RefCounted) -> void:
	_scale_monsters()
	var player: Dictionary = actors[player_id]
	maps.ensure_location(player.map_id)
	for actor: Dictionary in actors.values():
		if actor.hp > 0 and (actor.map_id == player.map_id or not actor.trail.is_empty() or not actor.last_seen.is_empty()): maps.ensure_location(actor.map_id)
	_maybe_encounter()
	super.advance(brain)
	_maybe_encounter()

func unload_location(id: String) -> Dictionary:
	if actors.has(player_id) and actors[player_id].map_id == id: return result(false,"Cannot unload the player's active map.")
	return result(maps.unload(id),"Location unload attempted; its state and actors are retained.")

func snapshot(previous: Dictionary = {}) -> Dictionary:
	var saved_actors: Dictionary = {}
	for id: int in actors:
		var source: Dictionary = actors[id]
		var saved: Dictionary = {}
		for key: String in source:
			if key == "clock": continue
			var value = source[key]
			saved[key] = value.duplicate(true) if value is Dictionary or value is Array else value
		saved.clock_state = {"remaining":source.clock.remaining.duplicate(),"elapsed":source.clock.elapsed.duplicate()}
		saved_actors[id] = saved
	var unchanged_geography: bool = previous.get("world_id","") == maps.world_id and previous.get("location_revision",-1) == maps.revision
	var states: Dictionary = previous.states if unchanged_geography else maps.all_states()
	if unchanged_geography:
		# Camera offsets change outside generation, without changing map geography.
		for id: String in maps.maps:
			var map = maps.maps[id]
			if states[id].get("view_zoom",1.0) != map.view_zoom or states[id].view_offset != map.view_offset or states[id].view_initialized != map.view_initialized or states[id].regional_revision != map.regional_revision:
				states = states.duplicate()
				states[id] = MapState.capture(map)
	return {"discovered_maps":discovered_maps.duplicate(true),"world_hours":world_hours,"turn_threshold":turn_threshold,"regeneration":regeneration.duplicate(true),"creation":creation.duplicate(true),"schema":SAVE_SCHEMA,"generator":Locations.GENERATOR_VERSION,"world_id":maps.world_id,"world_seed":maps.world_seed,"location_revision":maps.revision,"records":previous.records if unchanged_geography else _snapshot_records(),"regional_revision":maps.regional_revision,"regional_hexes":_snapshot_regions(previous),"regional_sources":maps.records.global.regional.sources.duplicate(true),"states":states,"next_instance":maps.next_instance,"actors":saved_actors,"ground":ground.duplicate(true),"initialized":initialized.duplicate(),"player_id":player_id,"next_id":next_id,"next_item_id":Items.next_item_id,"difficulty":difficulty,"tick":tick}

func _snapshot_records() -> Dictionary:
	var result: Dictionary = {}
	for id: String in maps.records:
		if id != "global": result[id] = maps.records[id].duplicate(true); continue
		var root_record: Dictionary = {}
		for key: String in maps.records.global:
			if key == "regional": continue
			var value = maps.records.global[key]
			root_record[key] = value.duplicate(true) if value is Dictionary or value is Array else value
		result[id] = root_record
	return result

func _snapshot_regions(previous: Dictionary) -> Dictionary:
	if previous.get("world_id","") == maps.world_id and previous.get("regional_revision",-1) == maps.regional_revision:
		return previous.regional_hexes
	var result: Dictionary = {}
	var old: Dictionary = previous.get("regional_hexes",{}) if previous.get("world_id","") == maps.world_id else {}
	for cell: Vector2i in maps.records.global.regional.hexes:
		var value: Dictionary = maps.records.global.regional.hexes[cell]
		result[cell] = old[cell] if old.has(cell) and old[cell].revision == value.revision else value.duplicate(true)
	return result

func save_game(directory: String = SAVE_DIR) -> Dictionary:
	var data: Dictionary = snapshot()
	var reason: String = validate_snapshot(data)
	if not reason.is_empty(): return result(false,"Save refused: "+reason)
	if DirAccess.make_dir_recursive_absolute(directory) != OK: return result(false,"Unable to create snapshot folder.")
	var bytes: PackedByteArray = var_to_bytes(data)
	var path: String = directory.path_join(maps.world_id+"_"+str(Time.get_unix_time_from_system()).replace(".","_")+"_"+str(Time.get_ticks_usec())+".world")
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null: return result(false,"Unable to create save snapshot.")
	file.store_buffer(bytes)
	file.flush()
	if file.get_error() != OK: return result(false,"Save write failed; previous snapshots remain intact.")
	last_save = path
	return {"ok":true,"reason":"World saved.","path":path}

static func validate_snapshot(data: Dictionary) -> String:
	if not data.get("states",{}) is Dictionary: return "invalid states"
	if not preload("res://Production/Actors/map_knowledge.gd").valid(data.get("discovered_maps",{}),data.get("states",{})): return "invalid discovered-map memory"
	if not data.get("world_hours",0) is int or data.get("world_hours",0) < 0: return "invalid calendar"
	for key: String in ["schema","generator","world_id","world_seed","records","states","next_instance","actors","ground","initialized","player_id","next_id","next_item_id","difficulty","tick","regional_hexes","regional_sources","regional_revision"]:
		if not data.has(key): return "missing "+key
	if data.schema != SAVE_SCHEMA or data.generator != Locations.GENERATOR_VERSION: return "unsupported save/generator version"
	for key: String in ["records","states","actors","ground","initialized","regional_hexes","regional_sources"]:
		if not data[key] is Dictionary: return "invalid "+key
	for key: String in ["world_seed","next_instance","player_id","next_id","next_item_id","difficulty","tick","regional_revision"]:
		if not data[key] is int: return "invalid counter"
	if not data.get("turn_threshold",Momentum.DEFAULT_THRESHOLD) is int or data.get("turn_threshold",Momentum.DEFAULT_THRESHOLD) < 1: return "invalid turn threshold"
	if data.has("regeneration") and not data.regeneration is Dictionary: return "invalid regeneration provenance"
	if data.has("creation"):
		if not data.creation is Dictionary: return "invalid character creation"
		if not data.creation.is_empty():
			if not data.creation.get("dice_slots") is Array or data.creation.dice_slots.size() != 12: return "invalid creation dice"
			var assigned: int = 0
			for value in data.creation.dice_slots:
				if not value is int or value < 0 or value > 6: return "invalid creation die"
				if value > 0: assigned += 1
			if assigned != 6: return "invalid creation roll"
	if data.has("location_revision") and (not data.location_revision is int or data.location_revision < 0): return "invalid location revision"
	if data.regional_revision < 0: return "invalid regional revision"
	if not data.world_id is String or data.world_id.is_empty() or data.next_instance < 1 or data.next_id < 1 or data.next_item_id < 1 or data.tick < 0 or data.difficulty not in [0,1,2]: return "invalid world identity/counter"
	if not data.records.has("global") or (not data.actors.has(data.player_id) and not (data.player_id == 0 and data.actors.is_empty())): return "missing world or player"
	for id in data.records:
		var record = data.records[id]
		if not record is Dictionary: return "invalid location record"
		for key: String in ["id","parent","template","generated","constraints","seed","children","role","label","address","instance"]:
			if not record.has(key): return "incomplete location record"
		if not (id is String or id is StringName) or not record.id is String or not record.parent is String or not record.template is String or not record.generated is bool or not record.constraints is Dictionary or not record.children is Array or not record.seed is int or not record.instance is int or not record.label is String or not record.role is String or not record.address is String: return "invalid location types"
		if record.instance < 0 or record.instance >= data.next_instance or record.address != data.world_id+"/"+id: return "invalid location identity"
		if id == "global" and (record.parent != "" or record.template != "Global" or not record.generated): return "invalid root"
		if record.id != id or (id != "global" and not data.records.has(record.parent)): return "invalid location ancestry"
		if id != "global" and Templates.get_template(record.template).is_empty(): return "unknown template"
		if id != "global" and not record.constraints.get("return_cell") is Vector2i: return "invalid return constraint"
		if record.template == "Local":
			if not record.constraints.get("biome") is String or not record.constraints.get("global_cell") is Vector2i or not record.constraints.get("boundaries") is Array: return "invalid Local constraints"
			for boundary in record.constraints.boundaries:
				if not boundary is Dictionary or not boundary.get("key") is String or not boundary.get("direction") is int or boundary.direction not in range(6) or not boundary.get("neighbor") is Vector2i or not boundary.get("river") is bool or not boundary.get("dry") is String or not boundary.get("water") is Array or boundary.water.size() != 5: return "invalid boundary"
				for sample in boundary.water:
					if not sample is bool: return "invalid water sample"
		if record.generated and (not data.states.has(id) or not MapState.valid(data.states[id])): return "missing resolved map state"
		if record.generated and record.template == "Cave" and data.states[id].get("cave_layout",{}).is_empty(): return "missing Cave room topology"
	if not MapState.valid(data.states.get("global")): return "invalid Global state"
	var travel_rules: Dictionary = data.records.global.constraints
	if not travel_rules.get("trade_routes",{}) is Dictionary or not travel_rules.get("event_steps",{}) is Dictionary or not travel_rules.get("starter_route",[]) is Array: return "invalid global routes"
	for cell in travel_rules.get("starter_route",[]):
		if not cell is Vector2i or not MapState.restore(data.states.global).contains(cell): return "invalid trade-route cell"
	var listed_children: Dictionary = {}
	for id: String in data.records:
		var record: Dictionary = data.records[id]
		for child in record.children:
			if not child is String or not data.records.has(child) or data.records[child].parent != id or listed_children.has(child): return "invalid child reference"
			listed_children[child] = true
		var seen: Dictionary = {}
		var ancestor: String = id
		while not ancestor.is_empty():
			if seen.has(ancestor) or not data.records.has(ancestor): return "cyclic/missing ancestor"
			seen[ancestor] = true
			ancestor = data.records[ancestor].parent
	for id in data.records:
		if id != "global" and not listed_children.has(id): return "missing child reference"
	for record: Dictionary in data.records.values():
		if record.template == "Local" and not data.regional_hexes.has(record.constraints.global_cell): return "invalid regional address"
	if not Locations.Regional.valid({"hexes":data.regional_hexes,"sources":data.regional_sources},MapState.restore(data.states.global),data.records): return "invalid regional truth"
	for id in data.states:
		var state = data.states[id]
		if not data.records.has(id) or not MapState.valid(state) or state.id != id or not data.records[id].generated: return "invalid map state"
		if data.records[id].template == "Local" and state.hex_radius != 20: return "invalid Local radius"
		if data.records[id].template == "Town" and state.hex_radius not in [0,3]: return "invalid Town radius"
		if data.records[id].template == "Encounter" and state.hex_radius != 6: return "invalid encounter radius"
		if data.records[id].template not in ["Local","Town","Encounter"] and state.hex_radius != 0: return "invalid interior/Global shape"
		if id != "global":
			var ancestor: String = id
			while data.records[ancestor].template != "Local":
				ancestor = data.records[ancestor].parent
				if ancestor == "global" or ancestor.is_empty(): return "missing Local ancestor"
			var truth: Dictionary = data.regional_hexes[data.records[ancestor].constraints.global_cell]
			if state.regional_revision > truth.revision or state.regional_revision < 0: return "invalid regional cache revision"
			if state.regional_revision == truth.revision and state.regional_values != truth: return "invalid current regional cache"
		var geometry = MapState.restore(state)
		for field: String in ["biomes","water_cells","elevations","links"]:
			for cell in state[field]:
				if not cell is Vector2i or not geometry.contains(cell): return "map data outside geometry"
		for cell in state.links:
			var link = state.links[cell]
			if not cell is Vector2i or not link is Dictionary or not link.has("id") or not data.records.has(link.id) or not link.get("arrival") is Vector2i or not link.get("kind") is String or not link.get("label") is String: return "invalid entrance reference"
	for record: Dictionary in data.records.values():
		for marker: String in ["population_week","settlement_month"]:
			if not record.constraints.get(marker,0) is int or record.constraints.get(marker,0) < 0: return "invalid population calendar marker"
		if record.constraints.has("boss_id"):
			var boss_id = record.constraints.boss_id
			if not boss_id is int or not data.actors.has(boss_id) or not data.actors[boss_id] is Dictionary or data.actors[boss_id].get("boss") != true: return "invalid bounty boss"
		if not record.constraints.get("quests",{}) is Dictionary: return "invalid quests"
		for target in record.constraints.get("quests",{}):
			var quest = record.constraints.quests[target]
			if not quest is Dictionary or not quest.get("skill_reward",0) is int or quest.get("skill_reward",0) < 0 or not quest.get("tutorial",false) is bool or not data.records.has(target) or quest.get("target") != target or not quest.get("title") is String or quest.get("status") not in ["available","accepted","rewarded"] or not quest.get("reward") is int or quest.reward < 0: return "invalid bounty"
	var occupied: Dictionary = {}
	var item_ids: Dictionary = {}
	for id in data.actors:
		var actor = data.actors[id]
		if not actor is Dictionary: return "invalid actor"
		if actor.has("settled_poi") and (not actor.settled_poi is String or not data.records.has(actor.settled_poi) or data.records[actor.settled_poi].template not in ["Cave","Dungeon","Tower"]): return "invalid settlement reference"
		for field: String in ["id","map_id","pos","hp","max_hp","stats","skills","actions","clock_state","main","off","armor","belt","bag","faction","sprite","pending","retreat","riposte","last_seen","trail","known_items","dropped","level","xp","required_xp","points","name","effects_defense"]:
			if not actor.has(field): return "incomplete actor"
		if actor.has("global_approach") and (not actor.global_approach is int or actor.global_approach not in range(6)): return "invalid Global approach"
		if actor.get("spawn_hour",0) > data.get("world_hours",0): return "monster spawned in future"
		if not Sight.valid(actor): return "invalid actor sight/effects"
		if not Roster.valid_actor(actor): return "invalid enemy anatomy/variant"
		if not Momentum.valid(actor): return "invalid actor momentum/effects"
		if not actor.get("gold",0) is int or actor.get("gold",0) < 0: return "invalid gold"
		var structure: String = _actor_structure(actor)
		if not structure.is_empty(): return structure
		if not actor.actions.get("free",0) is int or actor.actions.get("free",0) < 0: return "invalid free actions"
		if not id is int or actor.id != id or id >= data.next_id or not actor.pos is Vector2i or not data.states.has(actor.map_id) or not data.initialized.has(actor.map_id): return "invalid actor location/identity"
		var state: Dictionary = data.states[actor.map_id]
		if not MapState.restore(state).walkable(actor.pos): return "invalid actor position"
		var position: String = actor.map_id+str(actor.pos)
		if actor.hp > 0 and occupied.has(position): return "overlapping actors"
		if actor.hp > 0: occupied[position] = true
		for item: Dictionary in Inventory.possessions(actor):
			if not _unique_item(item,item_ids,data.next_item_id): return "duplicate/invalid item ID"
		if not Grid.valid(actor,[]): return "invalid actor inventory"
	for state: Dictionary in data.states.values():
		for shop: Dictionary in state.get("shops",{}).values():
			for entry in shop.get("stock",[]):
				if not _unique_item(entry.item,item_ids,data.next_item_id): return "invalid shop item"
		for prop: Dictionary in state.get("props",{}).values():
			for item in prop.contents:
				if not _unique_item(item,item_ids,data.next_item_id): return "invalid container item"
	for id in data.initialized:
		if not data.states.has(id) or not data.ground.has(id): return "initialization missing ground/map"
	for id in data.ground:
		if not data.states.has(id) or not data.ground[id] is Array: return "invalid ground map"
		for entry in data.ground[id]:
			if not entry is Dictionary or not entry.has("pos") or not entry.pos is Vector2i or not entry.has("item") or not _unique_item(entry.item,item_ids,data.next_item_id): return "invalid ground item"
			if not MapState.restore(data.states[id]).contains(entry.pos): return "ground item outside geometry"
	return ""

static func _unique_item(item, seen: Dictionary, next_item: int) -> bool:
	if not _item_structure(item): return false
	if not item.has("item_id") or item.item_id <= 0 or item.item_id >= next_item or seen.has(item.item_id): return false
	seen[item.item_id] = true
	for nested: Dictionary in item.get("contents",[]):
		if not _unique_item(nested,seen,next_item): return false
	return true

static func _item_structure(item) -> bool:
	if not item is Dictionary or not item.get("item_id") is int or not item.get("kind") is String or not item.get("name") is String or not item.get("appearance") is String: return false
	if not Grid.SHAPES.has(item.kind): return false
	if item.has("grid_pos") and not item.grid_pos is Vector2i: return false
	if item.has("rotated") and not item.rotated is bool: return false
	if item.has("pouch") and not item.pouch is int: return false
	if item.has("rules_version") and not Items.valid_generated(item): return false
	if item.kind not in ["potion","ration"]:
		for key: String in ["rarity","bonus","die","capacity"]:
			if not item.get(key) is int: return false
		if not item.get("contents") is Array or item.capacity < 0: return false
		for nested in item.contents:
			if not nested is Dictionary or nested.get("kind") != "potion" or not _item_structure(nested): return false
	return true

static func _actor_structure(actor: Dictionary) -> String:
	if actor.has("faction_id") and (not actor.faction_id is String or actor.faction_id.is_empty()): return "invalid faction identity"
	if not actor.get("can_use_skills",true) is bool or not actor.get("family","goblins") is String: return "invalid actor family"
	if not actor.get("stat_training",{}) is Dictionary: return "invalid stat training"
	for stat in actor.get("stat_training",{}):
		if stat not in Actors.STATS or not actor.stat_training[stat] is int or actor.stat_training[stat] < 0: return "invalid stat point allocation"
	for field: String in ["spawn_hour","age_days","age_fifths"]:
		if not actor.get(field,0) is int or actor.get(field,0) < 0: return "invalid monster age"
	if actor.get("age_fifths",0) > 4: return "invalid fractional monster level"
	if actor.has("base_roll"):
		if not actor.base_roll is Array or actor.base_roll.size() != 6 or not actor.get("level_offset") is int or actor.level_offset not in range(-2,3) or not actor.get("boss") is bool: return "invalid monster scaling"
		for value in actor.base_roll:
			if not value is int or value < 1: return "invalid monster base stat"
	for field: String in ["id","level","xp","required_xp","points"]:
		if not actor[field] is int: return "invalid actor number"
	for field: String in ["hp","max_hp","effects_defense"]:
		if not (actor[field] is int or actor[field] is float) or not is_finite(float(actor[field])): return "invalid actor health"
	for field: String in ["map_id","faction","sprite","name"]:
		if not actor[field] is String: return "invalid actor label"
	if not actor.get("explored_cells",{}) is Dictionary: return "invalid exploration memory"
	for map_id in actor.get("explored_cells",{}):
		if not map_id is String or not actor.explored_cells[map_id] is Dictionary: return "invalid exploration map"
		for cell in actor.explored_cells[map_id]:
			if not cell is Vector2i or actor.explored_cells[map_id][cell] != true: return "invalid exploration cell"
	for field: String in ["idle_rounds","exploration_tick","pursuit_target"]:
		if not actor.get(field,0) is int: return "invalid exploration counter"
	for field: String in ["stats","actions","clock_state","pending","last_seen","known_items"]:
		if not actor[field] is Dictionary: return "invalid actor dictionary"
	for field: String in ["skills","bag","trail"]:
		if not actor[field] is Array: return "invalid actor array"
	for field: String in ["retreat","riposte","dropped"]:
		if not actor[field] is bool: return "invalid actor flag"
	for stat: String in Actors.STATS:
		if not actor.stats.get(stat) is int or actor.stats[stat] < 1: return "invalid stats"
	for action: String in ["move","attack","activation","used_attacks"]:
		if not actor.actions.get(action) is int or actor.actions[action] < 0: return "invalid actions"
	for skill in actor.skills:
		if not skill is String: return "invalid skill"
	if not preload("res://Production/Actors/skill_board.gd").valid(actor): return "invalid skill board"
	for field: String in ["remaining","elapsed"]:
		if not actor.clock_state.get(field) is Dictionary: return "invalid clock"
		for ability in actor.clock_state[field]:
			var value = actor.clock_state[field][ability]
			if not ability is String or not (value is int or value is float) or not is_finite(float(value)) or value < 0: return "invalid clock value"
	if actor.get("grip","one") not in ["one","two"]: return "invalid weapon grip"
	for slot: String in Grid.EQUIPMENT:
		if not actor.get(slot,{}) is Dictionary or (not actor.get(slot,{}).is_empty() and not _item_structure(actor[slot])): return "invalid equipment"
	for item in actor.bag:
		if not _item_structure(item): return "invalid backpack item"
	if not actor.pending.is_empty() and not _item_structure(actor.pending): return "invalid pending weapon"
	if not actor.last_seen.is_empty() and (not actor.last_seen.get("map_id") is String or not actor.last_seen.get("pos") is Vector2i): return "invalid observation"
	for step in actor.trail:
		if not step is Dictionary or not step.get("map_id") is String or not step.get("destination") is String or not step.get("pos") is Vector2i or not step.get("arrival") is Vector2i: return "invalid pursuit"
	return ""

func load_game(path: String) -> Dictionary:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return result(false,"Save file could not be opened.")
	var decoded
	var recovered: bool = false
	if path.get_extension() == "journal":
		var journal: Dictionary = Journal.read_snapshot(path)
		if not journal.ok: return result(false,journal.reason)
		decoded = journal.snapshot
		recovered = journal.recovered
	else: decoded = bytes_to_var(file.get_buffer(file.get_length()))
	if not decoded is Dictionary: return result(false,"Invalid save data.")
	var reason: String = validate_snapshot(decoded)
	if not reason.is_empty(): return result(false,"Load refused: "+reason)
	Items.upgrade_belts(decoded)
	# Stage all restored objects before changing this simulation.
	var restored = Locations.new(decoded.world_seed,false)
	restored.world_id = decoded.world_id
	restored.records = decoded.records
	restored.records.global.regional = {"hexes":decoded.regional_hexes,"sources":decoded.regional_sources}
	restored.regional_revision = decoded.regional_revision
	restored.next_instance = decoded.next_instance
	restored.revision = decoded.get("location_revision",0)
	restored.archived_states = decoded.states
	restored.ensure_location("global" if decoded.player_id == 0 else decoded.actors[decoded.player_id].map_id)
	var restored_actors: Dictionary = decoded.actors
	for actor: Dictionary in restored_actors.values():
		Equipment.initialize(actor)
		Momentum.initialize(actor)
		actor.clock = Clock.new()
		actor.clock.remaining = actor.clock_state.remaining
		actor.clock.elapsed = actor.clock_state.elapsed
		actor.erase("clock_state")
	maps = restored
	discovered_maps = decoded.get("discovered_maps",{})
	actors = restored_actors
	ground = decoded.ground
	_upgrade_enemy_anatomy()
	initialized = decoded.initialized
	player_id = decoded.player_id
	next_id = decoded.next_id
	Items.next_item_id = maxi(Items.next_item_id,decoded.next_item_id)
	world_hours = decoded.get("world_hours",0)
	creation = decoded.get("creation",{})
	regeneration = decoded.get("regeneration",{})
	difficulty = decoded.difficulty
	tick = decoded.tick
	turn_threshold = decoded.get("turn_threshold",Momentum.DEFAULT_THRESHOLD)
	for loaded_map in maps.maps.values():
		if not initialized.has(loaded_map.id): continue
		if maps.records[loaded_map.id].template == "Town" and preload("res://Production/World/village_shops.gd").ensure_supplies(loaded_map): maps.revision += 1
		_balance_chest_gold(loaded_map)
	events.clear()
	last_save = path
	return result(true,"Recovered the last complete automatic checkpoint." if recovered else "World loaded.")

func move(actor: Dictionary, destination: Vector2i, expected: Array = []) -> Dictionary:
	var previous_cell: Vector2i = actor.pos
	if actor.map_id == "global" and not _global_step_allowed(actor.pos,destination): return result(false,"Global travel requires an adjacent trade-route or event step.")
	var outcome: Dictionary = super.move(actor,destination,expected)
	if outcome.ok and actor.id == player_id:
		if actor.map_id == "global":
			maps.resolve_regions(actor.pos)
			if maps.records.global.constraints.get("event_steps",{}).erase(str(previous_cell)+">"+str(actor.pos)): maps.revision += 1
			advance_hours(6)
		else: _maybe_encounter()
	return outcome


func walk_step(actor: Dictionary, destination: Vector2i) -> Dictionary:
	var previous: Vector2i = actor.pos
	if actor.map_id == "global" and not _global_step_allowed(previous,destination): return result(false,"Global travel requires an adjacent trade-route or event step.")
	var outcome: Dictionary = super.walk_step(actor,destination)
	if outcome.ok and actor.id == player_id and actor.map_id == "global":
		maps.resolve_regions(actor.pos)
		if maps.records.global.constraints.get("event_steps",{}).erase(str(previous)+">"+str(actor.pos)): maps.revision += 1
		advance_hours(6)
	return outcome

func complete_walk_step(actor: Dictionary) -> void:
	if actor.id == player_id and actor.hp > 0: _maybe_encounter()


func travel_arrival(actor: Dictionary, origin, destination, link: Dictionary) -> Vector2i:
	if maps.records[destination.id].template == "Town" and destination.hex_radius == 3 and maps.records[origin.id].parent != destination.id: return arrival_cell(destination,destination.spawn_cell)
	if not destination.room_layout.is_empty() and link.kind != "Ladder" and maps.records[origin.id].parent != destination.id: return arrival_cell(destination,destination.spawn_cell)
	if not destination.cave_layout.is_empty(): return arrival_cell(destination,destination.spawn_cell)
	if origin.id == "global" and destination.layer == "Local":
		var side: int = posmod(int(actor.global_approach)+3,6) if actor.has("global_approach") else Entry.default_side(destination)
		return Entry.arrival(self,destination,side) if side >= 0 else Vector2i(-1,-1)
	if destination.layer == "Local":
		var origin_cell: Vector2i = link.get("arrival",Vector2i(1,3))
		var candidates: Array[Vector2i] = [origin_cell]
		candidates.append_array(destination.neighbors(origin_cell))
		for cell: Vector2i in candidates:
			if Entry.dry(destination,cell) and actor_at(destination.id,cell).is_empty(): return cell
		return Vector2i(-1,-1)
	return super.travel_arrival(actor,origin,destination,link)

func _populate_cave(map) -> void:
	_populate_rooms(map,map.cave_layout,"cave_room_id")

func _populate_rooms(map, layout: Dictionary, owner_key: String) -> void:
	var residents: Dictionary = room_families(maps.records[map.id].seed,_hostility(map),actors[player_id].level if actors.has(player_id) else 1)
	maps.records[map.id].constraints.population_families = residents
	var boss_created: bool = false
	for room: Dictionary in layout.rooms:
		if room.id == layout.entry_room or map.links.has(room.center): continue
		var rng := RandomNumberGenerator.new()
		rng.seed = Contracts.seed_for(room.seed,"population")
		var boss: bool = not boss_created
		if boss or rng.randf() < 0.6:
			var values: Array = []
			for stat: int in range(6): values.append(rng.randi_range(1,6))
			var family_rng := RandomNumberGenerator.new()
			family_rng.seed = Contracts.seed_for(room.seed,"resident-family")
			var family: String = residents.primary if boss or residents.rival.is_empty() or family_rng.randf() < 0.75 else residents.rival
			var actor: Dictionary = _monster(values,rng,map,boss,family)
			actor[owner_key] = room.id
			var actor_id: int = add_actor(actor,map.id,room.center,"enemy")
			if boss:
				maps.records[map.id].constraints.boss_id = actor_id
				boss_created = true
		if boss or rng.randf() < 0.10:
			var drop: Dictionary = Items.loot({"max_material_tier":3},rng)
			if drop.ok:
				var cell: Vector2i = room.cells[rng.randi_range(0,room.cells.size()-1)]
				var entry: Dictionary = {"item":drop.item,"pos":cell}
				entry[owner_key] = room.id
				ground[map.id].append(entry)

func interact(actor: Dictionary, request: Dictionary) -> Dictionary:
	var outcome: Dictionary = super.interact(actor,request)
	if outcome.ok and request.get("kind") == "search": maps.revision += 1
	return outcome

func resolve_death(actor: Dictionary, killer: Dictionary) -> void:
	var was_dropped: bool = actor.dropped
	var first_drop: int = ground[actor.map_id].size()
	super.resolve_death(actor,killer)
	if was_dropped or not actor.dropped or actor.faction == "player": return
	if actor.get("gold_balance_version",2) < 3:
		actor.gold = int(actor.get("gold",0)/2.0)
		actor.gold_balance_version = 3
	if actor.has("settled_poi"):
		var surviving: bool = false
		for other: Dictionary in actors.values():
			if other.hp > 0 and other.get("settled_poi","") == actor.settled_poi: surviving = true
		if not surviving: maps.set_poi_hostility(actor.settled_poi,0)
	if actor.get("boss",false) and actor.has("home_poi"):
		var local_id: String = maps.regional_local(actor.home_poi)
		var before: int = maps.records.global.regional.hexes[maps.records[local_id].constraints.global_cell].hostility
		maps.set_poi_hostility(actor.home_poi,0)
		var after: int = maps.records.global.regional.hexes[maps.records[local_id].constraints.global_cell].hostility
		maps.records[actor.home_poi].constraints.cleared_hostility = [before,after]
		maps.revision += 1
	var map = maps.maps[actor.map_id]
	# Do not conceal existing props or entrances beneath a corpse.
	if map.props.has(actor.pos) or map.links.has(actor.pos):
		# The normal item drop remains accessible; transfer coin directly to the killer.
		killer.gold = killer.get("gold",0)+actor.get("gold",0)
		actor.gold = 0
		_scale_monsters()
		return
	var contents: Array = []
	while ground[actor.map_id].size() > first_drop:
		contents.push_front(ground[actor.map_id].pop_back().item)
	map.props[actor.pos] = {"kind":"corpse","name":actor.name+" corpse","opened":false,"contents":contents,"room_id":-1,"gold":actor.get("gold",0),"mob_death":true}
	actor.gold = 0
	_scale_monsters()
	maps.revision += 1

func buy(actor: Dictionary, cell: Vector2i, item_id: int) -> Dictionary:
	var outcome: Dictionary = super.buy(actor,cell,item_id)
	if outcome.ok: maps.revision += 1
	return outcome

func start_in_town() -> void:
	for town_id: String in maps.records.global.constraints.get("route_towns",[]): ensure_map({"id":town_id})
	var player: Dictionary = actors[player_id]
	var global_map = maps.maps.global
	var local = ensure_map(global_map.links[global_map.spawn_cell])
	for link: Dictionary in local.links.values():
		if link.kind != "Town": continue
		var town = ensure_map(link)
		player.map_id = town.id
		player.pos = arrival_cell(town,town.spawn_cell)
		return

func _populate_town(map) -> void:
	var record: Dictionary = maps.records[map.id]
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(record.seed,"town-life")
	var name: String = ["Ash","Briar","Oak","Raven","Willow","Stone","Amber","Mist"][rng.randi_range(0,7)]+["ford","haven","bridge","wick","hollow","brook","stead","vale"][rng.randi_range(0,7)]
	map.title = name
	record.label = name
	var local_record: Dictionary = maps.records[record.parent]
	var town_truth: Dictionary = maps.records.global.regional.hexes[local_record.constraints.global_cell]
	if not town_truth.has("prosperity"):
		town_truth.prosperity = map.shops.values()[0].get("prosperity",1)
		town_truth.revision += 1
	maps.Regional.publish_poi(maps.records.global.regional,local_record.constraints.global_cell,map.id,"Town",name)
	maps.regional_revision += 1
	maps.sync_loaded_regions()
	var parent = maps.maps[record.parent]
	for link: Dictionary in parent.links.values():
		if link.id == map.id: link.label = name
	var quests: Dictionary = {}
	for target_id: String in maps.records[record.parent].children:
		var target: Dictionary = maps.records[target_id]
		if target.template not in ["Cave","Dungeon","Tower"]: continue
		quests[target_id] = {"target":target_id,"title":"Defeat the "+target.label+" boss near "+str(target.constraints.return_cell),"status":"available","reward":5*maxi(1,_hostility(map))}
	var routes: Dictionary = maps.records.global.constraints
	if routes.get("route_towns",[]).size() == 2 and routes.route_towns[0] == map.id:
		var target_id: String = routes.route_poi
		quests[target_id] = {"target":target_id,"title":"Reopen the trade road: defeat the route Dungeon boss near global "+str(maps.records[maps.records[target_id].parent].constraints.global_cell),"status":"available","reward":0,"skill_reward":1,"tutorial":true}
	record.constraints.quests = quests
	for index: int in range(3):
		var npc: Dictionary = Actors.create([3,3,3,3,3,3],true,rng)
		for slot: String in Grid.EQUIPMENT: npc[slot] = {}
		npc.gold = 0
		var cell := Vector2i(2,3) if index == 0 else Vector2i(3,2) if index == 1 else Vector2i(4,3)
		add_actor(npc,map.id,cell,"town","player")
		npc.name = "Town Crier" if index == 0 else ["Mara the Miller","Oren the Carter"][index-1]
		npc.role = "crier" if index == 0 else "resident"
	maps.revision += 1

func town_quests(actor: Dictionary) -> Dictionary:
	var quests: Dictionary = maps.records[actor.map_id].constraints.get("quests",{}).duplicate(true)
	for quest: Dictionary in quests.values():
		var boss_id: int = maps.records[quest.target].constraints.get("boss_id",-1)
		if quest.status != "rewarded" and actors.has(boss_id) and actors[boss_id].hp <= 0: quest.status = "claim reward"
	var ordered: Dictionary = {}
	for tutorial_first: bool in [true,false]:
		for id: String in quests:
			if quests[id].get("tutorial",false) == tutorial_first: ordered[id] = quests[id]
	return ordered

func quest_action(actor: Dictionary, target_id: String) -> Dictionary:
	var map = maps.maps[actor.map_id]
	var nearby: bool = false
	for npc: Dictionary in on_map(map.id):
		if npc.get("role","") == "crier" and map.distance(actor.pos,npc.pos) <= 1 and can_see(actor,npc.pos): nearby = true
	if actor.id != player_id or not nearby or not ready(actor): return result(false,"Production/Persistence/persistent_actor_world.gd: approach the town crier.")
	var quests: Dictionary = maps.records[map.id].constraints.get("quests",{})
	if not quests.has(target_id): return result(false,"Production/Persistence/persistent_actor_world.gd: unknown bounty.")
	var quest: Dictionary = quests[target_id]
	if quest.status == "rewarded": return result(false,"Production/Persistence/persistent_actor_world.gd: reward already claimed.")
	var boss_id: int = maps.records[target_id].constraints.get("boss_id",-1)
	if actors.has(boss_id) and actors[boss_id].hp <= 0:
		quest.status = "rewarded"
		actor.gold = actor.get("gold",0)+quest.reward
		actor.points += quest.get("skill_reward",0)
		if quest.get("tutorial",false): quest.effects = _complete_route_tutorial(target_id)
		maps.revision += 1
		return result(true,"Trade-road quest complete. Received 1 skill point. "+quest.effects if quest.get("tutorial",false) else "Bounty complete. Received "+str(quest.reward)+" gold.")
	quest.status = "accepted"
	maps.revision += 1
	return result(true,"Bounty accepted: "+quest.title+".")

func _hostility(map) -> int:
	return maxi(0,int(map.regional_values.get("hostility",0)))

func _seed_prop_gold(map) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(maps.records[map.id].seed,"container-gold")
	for prop: Dictionary in map.props.values():
		if prop.has("gold"): continue
		var amount: int = 0
		if prop.kind == "chest":
			amount = int((rng.randi_range(1,3)*3*_hostility(map))/4.0)
			prop.gold_balance_version = 3
		prop.gold = amount
	maps.revision += 1

func _monster(values: Array, rng: RandomNumberGenerator, map, boss: bool, family_override: String = "") -> Dictionary:
	var offset: int = rng.randi_range(-2,2)
	var level: int = maxi(1,(actors[player_id].level if actors.has(player_id) else 1)+offset)
	var scaled: Array = []
	for value: int in values: scaled.append(roundi((value+level-1)*(1.25 if boss else 1.0)))
	var player_level: int = actors[player_id].level if actors.has(player_id) else 1
	var family: String = family_override if not family_override.is_empty() else Roster.choose_family(rng,_hostility(map),player_level)
	var entry: Dictionary = Roster.choose_variant(family,rng,_hostility(map),player_level,boss)
	var actor: Dictionary = Actors.create(scaled,true,rng,entry.humanoid)
	actor.home_poi = map.id
	actor.base_roll = values.duplicate()
	actor.level_offset = offset
	actor.boss = boss
	actor.level = level
	actor.scaled_level = level
	actor.spawn_hour = world_hours
	actor.age_days = 0
	actor.age_fifths = 0
	Roster.apply(actor,family,entry)
	actor.points = level-1
	actor.required_xp = 5*level
	actor.gold = 1
	for die: int in range(_hostility(map)): actor.gold += rng.randi_range(1,3)
	actor.gold = int(actor.gold/2.0)
	actor.gold_balance_version = 3
	return actor

func _scale_monsters() -> void:
	for actor: Dictionary in actors.values():
		if actor.hp <= 0 or actor.faction != "enemy": continue
		if not actor.has("base_roll"):
			actor.base_roll = []
			for stat: String in Actors.STATS: actor.base_roll.append(maxi(1,actor.stats[stat]-actor.level+1))
			actor.level_offset = 0
			actor.boss = false
		if actor.get("scaled_level",actor.level) != actor.level:
			var missing_hp: int = actor.max_hp-actor.hp
			for index: int in range(Actors.STATS.size()):
				var stat: String = Actors.STATS[index]
				actor.stats[stat] = roundi((actor.base_roll[index]+actor.level-1)*(1.25 if actor.boss else 1.0))+actor.get("stat_training",{}).get(stat,0)
			actor.max_hp = actor.stats.WIL*3
			actor.hp = maxi(1,actor.max_hp-missing_hp)
		actor.scaled_level = actor.level

func paths(actor: Dictionary, limit: int = -1) -> Dictionary:
	if actor.map_id != "global": return super.paths(actor,limit)
	var result: Dictionary = {}
	var global_map = maps.ensure_location("global")
	for cell: Vector2i in global_map.neighbors(actor.pos):
		if global_map.walkable(cell) and actor_at("global",cell).is_empty() and _global_step_allowed(actor.pos,cell): result[cell] = [cell]
	return result

func _global_step_allowed(origin: Vector2i, destination: Vector2i) -> bool:
	var global_map = maps.ensure_location("global")
	if global_map.distance(origin,destination) != 1: return false
	var key: String = str(origin)+">"+str(destination)
	var rules: Dictionary = maps.records.global.constraints
	return rules.get("trade_routes",{}).has(key) or rules.get("event_steps",{}).has(key)

func register_event_step(origin: Vector2i, destination: Vector2i, event_id: String) -> Dictionary:
	var global_map = maps.ensure_location("global")
	if event_id.is_empty() or global_map.distance(origin,destination) != 1 or not global_map.walkable(origin) or not global_map.walkable(destination): return result(false,"Production/Persistence/persistent_actor_world.gd: event travel must identify one legal adjacent border.")
	if not maps.records.global.constraints.has("event_steps"): maps.records.global.constraints.event_steps = {}
	maps.records.global.constraints.event_steps[str(origin)+">"+str(destination)] = event_id
	maps.revision += 1
	return result(true,"Event crossing registered.")

func border_options(actor: Dictionary) -> Array:
	var options: Array = []
	if not maps.records.has(actor.map_id) or maps.records[actor.map_id].template != "Local": return options
	var map = maps.maps[actor.map_id]
	if not Entry.dry(map,actor.pos): return options
	for boundary: Dictionary in maps.records[map.id].constraints.boundaries:
		if actor.pos in Contracts.boundary_cells(map,boundary.direction,true): options.append({"side":boundary.direction,"global_cell":boundary.neighbor})
	return options

func cross_border(actor: Dictionary, side: int) -> Dictionary:
	if not ready(actor) or Combat.available(actor.actions,"move") <= 0: return result(false,"Crossing a border requires a movement action.")
	var selected: Dictionary = {}
	for option: Dictionary in border_options(actor):
		if option.side == side: selected = option
	if selected.is_empty(): return result(false,"Stand on a dry Local edge to cross that border.")
	var global_map = maps.ensure_location("global")
	if not global_map.links.has(selected.global_cell): return result(false,"No traversable neighboring region.")
	var destination = ensure_map(global_map.links[selected.global_cell])
	var arrival: Vector2i = Entry.arrival(self,destination,posmod(side+3,6))
	if arrival == Vector2i(-1,-1): return result(false,"The opposite edge has no free dry arrival; a boat may be needed.")
	var origin_id: String = actor.map_id
	var origin_cell: Vector2i = actor.pos
	for observer: Dictionary in on_map(origin_id):
		if hostile(actor,observer) and can_see(observer,origin_cell):
			observer.last_seen = {"map_id":origin_id,"pos":origin_cell}
			observer.pursuit_target = actor.id
			observer.trail = [{"map_id":origin_id,"pos":origin_cell,"destination":destination.id,"arrival":arrival,"border":side}]
	Combat.spend(actor.actions,"move")
	actor.map_id = destination.id
	actor.pos = arrival
	if actor.id == player_id: advance_hours(6)
	return result(true,"Crossed into "+destination.title+". Six hours passed." if actor.id == player_id else "Crossed border.")

func advance_hours(hours: int) -> void:
	if hours <= 0: return
	for actor: Dictionary in actors.values():
		if actor.faction == "enemy" and not actor.has("spawn_hour"):
			actor.spawn_hour = world_hours
			actor.age_days = 0
			actor.age_fifths = 0
	var remaining: int = hours
	while remaining > 0:
		var previous_week: int = int(world_hours/168.0)
		var previous_day: int = int(world_hours/24.0)
		var previous_month: int = int(world_hours/720.0)
		var step: int = mini(6-posmod(world_hours,6),remaining)
		world_hours += step
		remaining -= step
		_age_monsters()
		if int(world_hours/24.0) > previous_day: _offscreen_day(int(world_hours/24.0))
		if int(world_hours/168.0) > previous_week:
			_restock_week(int(world_hours/168.0))
			_repopulate_week(int(world_hours/168.0))
		if int(world_hours/720.0) > previous_month: _settle_month(int(world_hours/720.0))

func _age_monsters() -> void:
	for actor: Dictionary in actors.values():
		if actor.hp <= 0 or actor.faction != "enemy": continue
		if not actor.has("spawn_hour"): actor.spawn_hour = world_hours; actor.age_days = 0; actor.age_fifths = 0
		var days: int = int((world_hours-actor.spawn_hour)/24.0)
		var gained: int = days-actor.get("age_days",0)
		if gained <= 0: continue
		actor.age_days = days
		var fifths: int = actor.get("age_fifths",0)+gained
		actor.level += int(fifths/5.0)
		actor.points += int(fifths/5.0)
		actor.age_fifths = fifths%5
	_scale_monsters()
	for actor: Dictionary in actors.values(): _spend_creature_points(actor)

func _spend_creature_points(actor: Dictionary) -> void:
	if actor.hp <= 0 or actor.get("can_use_skills",true): return
	while actor.points > 0:
		var stat: String = "CON"
		for candidate: String in Actors.STATS:
			if actor.stats[candidate] < actor.stats[stat]: stat = candidate
		spend_stat(actor,stat)

func _offscreen_day(day: int) -> void:
	var groups: Dictionary = {}
	for actor: Dictionary in actors.values():
		if actor.hp <= 0 or actor.id == player_id or (actors.has(player_id) and actor.map_id == actors[player_id].map_id): continue
		if not groups.has(actor.map_id): groups[actor.map_id] = []
		groups[actor.map_id].append(actor)
	for map_id: String in groups:
		var pairs: Array = []
		var group: Array = groups[map_id]
		for a: int in range(group.size()):
			for b: int in range(a+1,group.size()):
				if hostile(group[a],group[b]): pairs.append([group[a],group[b]])
		if pairs.is_empty(): continue
		var rng := RandomNumberGenerator.new()
		rng.seed = Contracts.seed_for(maps.world_seed,map_id+":conflict:"+str(day))
		var pair: Array = pairs[rng.randi_range(0,pairs.size()-1)]
		var a: Dictionary = pair[0]
		var b: Dictionary = pair[1]
		var winner: Dictionary = a if rng.randf() < _strength(a)/(_strength(a)+_strength(b)) else b
		var loser: Dictionary = b if winner.id == a.id else a
		maps.ensure_location(map_id)
		loser.hp = 0
		resolve_death(loser,winner)
		_spend_creature_points(winner)
		# Off-map simulation results are not player-observed information.

func _strength(actor: Dictionary) -> float:
	var total: float = 0
	for value in actor.stats.values(): total += float(value)
	for slot: String in Grid.EQUIPMENT:
		var item: Dictionary = actor.get(slot,{})
		if not item.is_empty(): total += maxf(0,preload("res://Production/Actors/enemy_brain.gd").score(item))
	if not actor.get("humanoid",true) and not actor.get("natural_attack",{}).is_empty(): total += maxf(0,preload("res://Production/Actors/enemy_brain.gd").score(actor.natural_attack))
	return maxf(1,total)

func _populate_local(map) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(maps.records[map.id].seed,"local-life")
	var cells: Array = []
	for cell: Vector2i in map.cells():
		if not Entry.dry(map,cell) or map.links.has(cell) or map.distance(cell,map.spawn_cell) < 6: continue
		var clear: bool = true
		for link_cell: Vector2i in map.links:
			if map.distance(cell,link_cell) < 5: clear = false
		if clear: cells.append(cell)
	for index: int in range(mini(3,cells.size())):
		var selected: int = rng.randi_range(0,cells.size()-1)
		var cell: Vector2i = cells[selected]
		cells.remove_at(selected)
		var drop: Dictionary = Items.loot({"max_material_tier":3},rng)
		map.props[cell] = {"kind":"chest","name":"Wild Chest","opened":false,"contents":[drop.item] if drop.ok else [],"room_id":-1}
	for index: int in range(mini(3,cells.size())):
		var selected: int = rng.randi_range(0,cells.size()-1)
		var cell: Vector2i = cells[selected]
		cells.remove_at(selected)
		var values: Array = []
		for stat: int in range(6): values.append(rng.randi_range(1,6))
		var actor: Dictionary = _monster(values,rng,map,false)
		add_actor(actor,map.id,cell,"enemy")
		actor.name += " scout"
	maps.revision += 1

func _maybe_encounter() -> void:
	if not actors.has(player_id): return
	var player: Dictionary = actors[player_id]
	if player.hp <= 0 or maps.records[player.map_id].template != "Local" or not engaged(player): return
	var foes: Array[Dictionary] = []
	for enemy: Dictionary in on_map(player.map_id):
		if hostile(player,enemy) and (can_see(enemy,player.pos) or can_see(player,enemy.pos)): foes.append(enemy)
	if foes.is_empty(): return
	var parent = maps.maps[player.map_id]
	var id: String = parent.id+"/encounter_"+str(foes[0].id)
	if not maps.records.has(id): maps.declare(id,parent.id,"Encounter",parent.region_biome+" encounter",{"return_cell":player.pos,"biome":parent.biomes.get(player.pos,parent.region_biome)})
	var arena = ensure_map({"id":id})
	var arrival: Vector2i = arena.spawn_cell
	maps.records[id].constraints.return_cell = player.pos
	arena.links[arrival] = maps.entrance(parent.id,"Return to Local","Return",player.pos)
	# Store the encounter entrance for persistent returns; preserve a pre-existing POI link.
	if not parent.links.has(player.pos): parent.links[player.pos] = maps.entrance(id,arena.title,"Encounter",arrival)
	player.map_id = id
	player.pos = arrival
	var cells: Array = []
	for cell: Vector2i in arena.cells():
		if arena.distance(cell,arrival) >= 6: cells.append(cell)
	for enemy: Dictionary in foes:
		if cells.is_empty(): break
		enemy.map_id = id
		enemy.pos = cells.pop_back()
		enemy.trail = []
		enemy.last_seen = {}
	maps.revision += 1
	events.append("Encounter! "+arena.title+". Retreat through the entrance or defeat the opposition.")

func _complete_route_tutorial(target_id: String) -> String:
	var changes: Array = []
	for town_id: String in maps.records.global.constraints.get("route_towns",[]):
		var town = ensure_map({"id":town_id})
		var local_id: String = maps.records[town_id].parent
		var cell: Vector2i = maps.records[local_id].constraints.global_cell
		var truth: Dictionary = maps.records.global.regional.hexes[cell]
		var before: int = town.shops.values()[0].get("prosperity",1)
		truth.prosperity = before+1
		truth.revision += 1
		for shop: Dictionary in town.shops.values(): shop.prosperity = before+1
		changes.append(town.title+" prosperity "+str(before)+" → "+str(before+1))
	maps.regional_revision += 1
	maps.sync_loaded_regions()
	maps.revision += 1
	var pressure: Array = maps.records[target_id].constraints.get("cleared_hostility",[])
	return ("Hostility "+str(pressure[0])+" → "+str(pressure[1])+". " if pressure.size() == 2 else "Hostile route POI cleared. ")+", ".join(changes)+". Higher prosperity improves the next stock tier/count."

func _restock_week(week: int) -> void:
	for id: String in initialized:
		if maps.records[id].template != "Town": continue
		var town = maps.ensure_location(id)
		var prosperity: int = town.shops.values()[0].get("prosperity",1)
		for shop: Dictionary in town.shops.values(): shop.erase("stock")
		preload("res://Production/World/village_shops.gd").stock(town,Contracts.seed_for(maps.records[id].seed,"week:"+str(week)),prosperity)
		maps.revision += 1

func lunge(actor: Dictionary, destination: Vector2i) -> Dictionary:
	if actor.map_id == "global": return result(false,"Global borders must use route or event travel, not combat movement.")
	return super.lunge(actor,destination)

func retreat(actor: Dictionary, destination: Vector2i) -> Dictionary:
	if actor.map_id == "global": return result(false,"Global borders must use route or event travel, not combat movement.")
	return super.retreat(actor,destination)

func rest_at_inn(actor: Dictionary, cell: Vector2i) -> Dictionary:
	var access: Dictionary = inspect_shop(actor,cell)
	if not access.ok or access.shop.id != "inn" or access.shop.closed or not ready(actor) or Combat.available(actor.actions,"activation") <= 0:
		return result(false,"Production/Persistence/persistent_actor_world.gd: approach an open inn with an activation available.")
	if actor.get("gold",0) < 1: return result(false,"Production/Persistence/persistent_actor_world.gd: inn recovery costs 1 gold.")
	actor.gold -= 1
	Combat.spend(actor.actions,"activation")
	var healed: int = mini(actor.max_hp-actor.hp,2*actor.stats.CON)
	actor.hp += healed
	advance_hours(6)
	maps.revision += 1
	return result(true,"Rested one six-hour block for 1 gold. Recovered "+str(healed)+" HP.")

func _local_survivors(local_id: String) -> Array[Dictionary]:
	var survivors: Array[Dictionary] = []
	for actor: Dictionary in actors.values():
		if actor.hp <= 0 or actor.faction != "enemy": continue
		var record: Dictionary = maps.records[actor.map_id]
		if actor.map_id == local_id or (record.template == "Encounter" and record.parent == local_id): survivors.append(actor)
	return survivors

func _repopulate_week(week: int) -> void:
	for local_id: String in initialized.keys():
		var record: Dictionary = maps.records[local_id]
		if record.template != "Local" or record.constraints.get("population_week",-1) >= week: continue
		record.constraints.population_week = week
		if not _local_survivors(local_id).is_empty(): continue
		var map = maps.ensure_location(local_id)
		var rng := RandomNumberGenerator.new()
		rng.seed = Contracts.seed_for(record.seed,"weekly-population-"+str(week))
		var cells: Array = []
		for cell: Vector2i in map.cells():
			if not Entry.dry(map,cell) or map.links.has(cell) or map.props.has(cell) or map.distance(cell,map.spawn_cell) < 6: continue
			var occupied: bool = false
			for actor: Dictionary in on_map(local_id):
				if actor.hp > 0 and (actor.pos == cell or (actor.id == player_id and map.distance(actor.pos,cell) < 6)): occupied = true
			if not occupied: cells.append(cell)
		for index: int in range(mini(3,cells.size())):
			var selected: int = rng.randi_range(0,cells.size()-1)
			var cell: Vector2i = cells[selected]
			cells.remove_at(selected)
			var values: Array = []
			for stat: int in range(6): values.append(rng.randi_range(1,6))
			var actor: Dictionary = _monster(values,rng,map,false)
			add_actor(actor,local_id,cell,"enemy")
			actor.name += " scout"
	maps.revision += 1

func _settle_month(month: int) -> void:
	for local_id: String in initialized.keys():
		var record: Dictionary = maps.records[local_id]
		if record.template != "Local" or record.constraints.get("settlement_month",-1) >= month: continue
		record.constraints.settlement_month = month
		var survivors: Array[Dictionary] = _local_survivors(local_id)
		# Actors engaged in an encounter remain there; only Local residents migrate.
		survivors = survivors.filter(func(actor: Dictionary): return actor.map_id == local_id)
		for poi_id: String in record.children:
			if survivors.is_empty(): break
			var poi: Dictionary = maps.records[poi_id]
			if poi.template not in ["Cave","Dungeon","Tower"] or not initialized.has(poi_id): continue
			var occupied: bool = false
			for actor: Dictionary in actors.values():
				if actor.hp > 0 and (actor.map_id == poi_id or actor.map_id.begins_with(poi_id+"/")): occupied = true
			if occupied: continue
			var map = maps.ensure_location(poi_id)
			var cell: Vector2i = arrival_cell(map,map.spawn_cell)
			if cell == Vector2i(-1,-1): continue
			var settler: Dictionary = survivors.pop_front()
			settler.map_id = poi_id
			settler.pos = cell
			settler.home_poi = poi_id
			settler.settled_poi = poi_id
			maps.set_poi_hostility(poi_id,maps.default_hostility(poi.template))
			settler.trail = []
			settler.last_seen = {}
			report_observed(settler,settler.name+" occupied "+poi.label+".")
	maps.revision += 1

func quest_destination(actor: Dictionary, target_id: String) -> Dictionary:
	var target: Dictionary = maps.records[target_id]
	var local_id: String = target_id
	while maps.records[local_id].template != "Local":
		local_id = maps.records[local_id].parent
	var destination: Vector2i = maps.records[local_id].constraints.global_cell
	var origin_id: String = actor.map_id
	while origin_id != "global" and maps.records[origin_id].template != "Local": origin_id = maps.records[origin_id].parent
	var origin: Vector2i = actor.pos if origin_id == "global" else maps.records[origin_id].constraints.global_cell
	var delta := Vector2(destination-origin)
	if maps.maps.global.wrap_horizontal:
		var width: int = maps.maps.global.dimensions.x
		var best: float = Vector2(delta.x+delta.y*0.5,delta.y*0.8660254).length_squared()
		for shift: int in [-width,width]:
			var candidate := Vector2(destination-origin)+Vector2(shift,0)
			var distance: float = Vector2(candidate.x+candidate.y*0.5,candidate.y*0.8660254).length_squared()
			if distance < best: delta = candidate; best = distance
	var scope: String = "Global direction"
	if destination == origin and actor.map_id != "global":
		var position: Vector2i = actor.pos
		if actor.map_id != local_id:
			var entrance_id: String = actor.map_id
			while maps.records[entrance_id].parent != local_id: entrance_id = maps.records[entrance_id].parent
			position = maps.records[entrance_id].constraints.get("return_cell",position)
		delta = Vector2(target.constraints.get("return_cell",position)-position)
		scope = "Local entrance direction"
	var direction := Vector2(delta.x+delta.y*0.5,delta.y*0.8660254)
	var arrow: String = "●"
	if direction.length_squared() > 0:
		arrow = ["→","↘","↓","↙","←","↖","↑","↗"][posmod(roundi(direction.angle()/(PI/4.0)),8)]
	return {"scope":scope,"cell":destination,"arrow":arrow,"biome":maps.maps.global.biomes.get(destination,"Unknown"),"label":target.label,"local_cell":target.constraints.get("return_cell",Vector2i.ZERO)}

func sell(actor: Dictionary, cell: Vector2i, item_id: int) -> Dictionary:
	var outcome: Dictionary = super.sell(actor,cell,item_id)
	if outcome.ok: maps.revision += 1
	return outcome

func _balance_chest_gold(map) -> void:
	for prop: Dictionary in map.props.values():
		if prop.get("kind") == "chest" and prop.has("gold") and prop.get("gold_balance_version",1) < 3:
			var divisor: float = 4.0 if prop.get("gold_balance_version",1) < 2 else 2.0
			prop.gold = int(int(prop.gold)/divisor)
			prop.gold_balance_version = 3
			maps.revision += 1
		elif prop.get("gold",0) > 0 and prop.get("kind") != "chest" and not prop.get("mob_death",false) and not prop.get("name","").ends_with(" corpse"):
			prop.gold = 0
			maps.revision += 1

func camp(actor: Dictionary) -> Dictionary:
	if not ready(actor) or engaged(actor) or actor.map_id == "global": return result(false,"Production/Persistence/persistent_actor_world.gd: camp in a safe location outside combat.")
	for index: int in range(actor.bag.size()):
		if actor.bag[index].get("kind") != "ration": continue
		actor.bag.remove_at(index)
		var healed: int = mini(actor.max_hp-actor.hp,2*actor.stats.CON)
		actor.hp += healed
		advance_hours(6)
		maps.revision += 1
		return result(true,"Camped one six-hour block. Used 1 ration and recovered "+str(healed)+" HP.")
	return result(false,"Production/Persistence/persistent_actor_world.gd: camping requires a ration in your backpack.")

static func room_families(seed_value: int, hostility: int = 0, player_level: int = 1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(seed_value,"resident-families")
	var primary: String = Roster.choose_family(rng,hostility,player_level)
	return {"primary":primary,"rival":Roster.choose_family(rng,hostility,player_level,primary) if rng.randf() < 0.5 else ""}

func _upgrade_enemy_anatomy() -> void:
	for actor: Dictionary in actors.values():
		if actor.faction != "enemy":
			if not actor.has("humanoid"): actor.humanoid = true
			continue
		if actor.has("enemy_variant"): continue
		var family: String = actor.get("family","goblins")
		if not Roster.catalog.families.has(family):
			actor.humanoid = actor.get("humanoid",true)
			continue
		var variants: Array = Roster.catalog.families[family].variants
		var entry: Dictionary = variants[mini(1,variants.size()-1) if actor.get("boss",false) else 0]
		var old_name: String = actor.name
		var old_faction: String = actor.get("faction_id",family)
		Roster.apply(actor,family,entry)
		actor.name = old_name
		actor.faction_id = old_faction
		if actor.humanoid: continue
		# Preserve former creature equipment as actual loot at its position.
		for slot: String in Grid.EQUIPMENT:
			if not actor.get(slot,{}).is_empty(): ground[actor.map_id].append({"pos":actor.pos,"item":actor[slot]})
			actor[slot] = {}
		for item: Dictionary in actor.bag: ground[actor.map_id].append({"pos":actor.pos,"item":item})
		actor.bag = []
		actor.pending = {}
		actor.riposte = false
		actor.counter_weapon = {}
