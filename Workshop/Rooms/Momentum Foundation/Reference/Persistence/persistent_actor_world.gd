extends "res://Production/Actors/actor_world.gd"
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

func _make_maps(seed_value: int) -> RefCounted:
	return Locations.new(seed_value)

func ensure_map(link: Dictionary):
	var map = maps.ensure_location(link.id)
	if map == null: return null
	if initialized.has(map.id): return map
	var record: Dictionary = maps.records[map.id]
	var definition: Dictionary = Templates.get_template(record.template)
	ground[map.id] = []
	# Dedicated seeded population stream, independent of global RNG and visit order.
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(record.seed,"population")
	for index: int in range(definition.get("population",0)):
		var values: Array = []
		for stat: int in range(6): values.append(rng.randi_range(1,6))
		var actor: Dictionary = Actors.create(values,true,rng)
		var cell: Vector2i = arrival_cell(map,Vector2i(6,3))
		if cell != Vector2i(-1,-1): add_actor(actor,map.id,cell,"enemy")
	initialized[map.id] = true
	return map

func travel(actor: Dictionary) -> Dictionary:
	if not ready(actor) or actor.actions.activation <= 0: return result(false,"No travel action available.")
	var origin = maps.ensure_location(actor.map_id)
	if origin == null: return result(false,"The source location could not be loaded.")
	if origin.links.has(actor.pos):
		if maps.ensure_location(origin.links[actor.pos].id) == null: return result(false,"The destination could not be loaded.")
	return super.travel(actor)

func can_see(actor: Dictionary, cell: Vector2i) -> bool:
	if maps.ensure_location(actor.map_id) == null: return false
	return super.can_see(actor,cell)

func advance(brain: RefCounted) -> void:
	var player: Dictionary = actors[player_id]
	maps.ensure_location(player.map_id)
	for actor: Dictionary in actors.values():
		if actor.hp > 0 and (actor.map_id == player.map_id or not actor.trail.is_empty() or not actor.last_seen.is_empty()): maps.ensure_location(actor.map_id)
	super.advance(brain)

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
			if states[id].view_offset != map.view_offset or states[id].view_initialized != map.view_initialized or states[id].regional_revision != map.regional_revision:
				states = states.duplicate()
				states[id] = MapState.capture(map)
	return {"regeneration":regeneration.duplicate(true),"creation":creation.duplicate(true),"schema":SAVE_SCHEMA,"generator":Locations.GENERATOR_VERSION,"world_id":maps.world_id,"world_seed":maps.world_seed,"location_revision":maps.revision,"records":previous.records if unchanged_geography else _snapshot_records(),"regional_revision":maps.regional_revision,"regional_hexes":_snapshot_regions(previous),"regional_sources":maps.records.global.regional.sources.duplicate(true),"states":states,"next_instance":maps.next_instance,"actors":saved_actors,"ground":ground.duplicate(true),"initialized":initialized.duplicate(),"player_id":player_id,"next_id":next_id,"next_item_id":Items.next_item_id,"difficulty":difficulty,"tick":tick}

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
	for key: String in ["schema","generator","world_id","world_seed","records","states","next_instance","actors","ground","initialized","player_id","next_id","next_item_id","difficulty","tick","regional_hexes","regional_sources","regional_revision"]:
		if not data.has(key): return "missing "+key
	if data.schema != SAVE_SCHEMA or data.generator != Locations.GENERATOR_VERSION: return "unsupported save/generator version"
	for key: String in ["records","states","actors","ground","initialized","regional_hexes","regional_sources"]:
		if not data[key] is Dictionary: return "invalid "+key
	for key: String in ["world_seed","next_instance","player_id","next_id","next_item_id","difficulty","tick","regional_revision"]:
		if not data[key] is int: return "invalid counter"
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
	if not MapState.valid(data.states.get("global")): return "invalid Global state"
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
		if data.records[id].template != "Local" and state.hex_radius != 0: return "invalid interior/Global shape"
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
	var occupied: Dictionary = {}
	var item_ids: Dictionary = {}
	for id in data.actors:
		var actor = data.actors[id]
		if not actor is Dictionary: return "invalid actor"
		for field: String in ["id","map_id","pos","hp","max_hp","stats","skills","actions","clock_state","main","off","armor","belt","bag","faction","sprite","pending","retreat","riposte","last_seen","trail","known_items","dropped","level","xp","required_xp","points","name","effects_defense"]:
			if not actor.has(field): return "incomplete actor"
		if actor.has("global_approach") and (not actor.global_approach is int or actor.global_approach not in range(6)): return "invalid Global approach"
		var structure: String = _actor_structure(actor)
		if not structure.is_empty(): return structure
		if not id is int or actor.id != id or id >= data.next_id or not actor.pos is Vector2i or not data.states.has(actor.map_id) or not data.initialized.has(actor.map_id): return "invalid actor location/identity"
		var state: Dictionary = data.states[actor.map_id]
		if not MapState.restore(state).walkable(actor.pos): return "invalid actor position"
		var position: String = actor.map_id+str(actor.pos)
		if actor.hp > 0 and occupied.has(position): return "overlapping actors"
		if actor.hp > 0: occupied[position] = true
		for item: Dictionary in Inventory.possessions(actor):
			if not _unique_item(item,item_ids,data.next_item_id): return "duplicate/invalid item ID"
		if not Grid.valid(actor,[]): return "invalid actor inventory"
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
	if item.kind != "potion":
		for key: String in ["rarity","bonus","die","capacity"]:
			if not item.get(key) is int: return false
		if not item.get("contents") is Array or item.capacity < 0: return false
		for nested in item.contents:
			if not nested is Dictionary or nested.get("kind") != "potion" or not _item_structure(nested): return false
	return true

static func _actor_structure(actor: Dictionary) -> String:
	for field: String in ["id","level","xp","required_xp","points"]:
		if not actor[field] is int: return "invalid actor number"
	for field: String in ["hp","max_hp","effects_defense"]:
		if not (actor[field] is int or actor[field] is float) or not is_finite(float(actor[field])): return "invalid actor health"
	for field: String in ["map_id","faction","sprite","name"]:
		if not actor[field] is String: return "invalid actor label"
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
	for field: String in ["remaining","elapsed"]:
		if not actor.clock_state.get(field) is Dictionary: return "invalid clock"
		for ability in actor.clock_state[field]:
			var value = actor.clock_state[field][ability]
			if not ability is String or not (value is int or value is float) or not is_finite(float(value)) or value < 0: return "invalid clock value"
	for slot: String in Grid.EQUIPMENT:
		if not actor[slot] is Dictionary or (not actor[slot].is_empty() and not _item_structure(actor[slot])): return "invalid equipment"
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
		actor.clock = Clock.new()
		actor.clock.remaining = actor.clock_state.remaining
		actor.clock.elapsed = actor.clock_state.elapsed
		actor.erase("clock_state")
	maps = restored
	actors = restored_actors
	ground = decoded.ground
	initialized = decoded.initialized
	player_id = decoded.player_id
	next_id = decoded.next_id
	Items.next_item_id = maxi(Items.next_item_id,decoded.next_item_id)
	creation = decoded.get("creation",{})
	regeneration = decoded.get("regeneration",{})
	difficulty = decoded.difficulty
	tick = decoded.tick
	events.clear()
	last_save = path
	return result(true,"Recovered the last complete automatic checkpoint." if recovered else "World loaded.")

func move(actor: Dictionary, destination: Vector2i, expected: Array = []) -> Dictionary:
	var outcome: Dictionary = super.move(actor,destination,expected)
	if outcome.ok and actor.id == player_id and actor.map_id == "global": maps.resolve_regions(actor.pos)
	return outcome


func travel_arrival(actor: Dictionary, origin, destination, link: Dictionary) -> Vector2i:
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
