extends RefCounted
const Topology = preload("res://Production/Previous/WorldFoundation/World/topology_generator.gd")
const Map = preload("res://Production/Previous/WorldFoundation/World/hex_map.gd")
const Water = preload("res://Production/Previous/WorldFoundation/World/local_water.gd")
const Terrain = preload("res://Production/Previous/WorldFoundation/World/local_terrain.gd")
const Pois = preload("res://Production/Previous/WorldFoundation/World/local_poi_placement.gd")
const Rivers = preload("res://Production/Previous/WorldFoundation/World/river_generator.gd")
const Templates = preload("res://Production/Previous/WorldFoundation/World/location_templates.gd")
const Contracts = preload("res://Production/Previous/WorldFoundation/World/geographic_contracts.gd")
const State = preload("res://Production/Previous/WorldFoundation/Persistence/map_state.gd")
const Storage = preload("res://Production/Previous/WorldFoundation/Persistence/storage_paths.gd")
const ARCHIVES: String = Storage.ARCHIVES
const GENERATOR_VERSION: int = 2
var maps: Dictionary = {}
var records: Dictionary = {}
var archives: Dictionary = {}
var archived_states: Dictionary = {}
var world_seed: int
var world_id: String
var next_instance: int = 1
var revision: int = 0

func _init(seed_value: int = 1729, create_root: bool = true) -> void:
	world_seed = seed_value
	world_id = "world_"+Crypto.new().generate_random_bytes(8).hex_encode()
	if not create_root: return
	var global_map = Map.new("global","The Marches","Global",Vector2i(80,42))
	global_map.wrap_horizontal = true
	global_map.spawn_cell = Topology.generate(global_map,seed_value)
	Rivers.generate(global_map,seed_value)
	for cell: Vector2i in global_map.cells():
		if global_map.walkable(cell): global_map.links[cell] = {"id":"local_%d_%d" % [cell.x,cell.y],"label":"%s region %d, %d" % [global_map.biomes[cell],cell.x,cell.y],"biome":global_map.biomes[cell]}
	maps.global = global_map
	records.global = {"id":"global","address":world_id+"/global","parent":"","template":"Global","role":"Global","seed":seed_value,"generated":true,"label":"The Marches","constraints":{},"children":[],"instance":0}
	for cell: Vector2i in maps.global.links:
		var link: Dictionary = maps.global.links[cell]
		declare(link.id,"global","Local",link.label,{"biome":link.biome,"global_cell":cell,"return_cell":cell,"boundaries":Contracts.from_global(maps.global,cell,world_seed)})
		maps.global.links[cell] = entrance(link.id,link.label,"Local")

func declare(id: String, parent: String, template: String, label: String, constraints: Dictionary) -> void:
	assert(not records.has(id) and records.has(parent) and not Templates.get_template(template).is_empty(),"Production/World/location_world.gd: invalid location declaration")
	var definition: Dictionary = Templates.get_template(template)
	records[id] = {"id":id,"address":world_id+"/"+id,"parent":parent,"template":template,"role":definition.role,"seed":Contracts.seed_for(world_seed,id+":"+template),"generated":false,"label":label,"constraints":constraints.duplicate(true),"children":[],"instance":next_instance}
	next_instance += 1
	revision += 1
	records[parent].children.append(id)

func entrance(id: String, label: String, kind: String, arrival: Vector2i = Vector2i(1,3)) -> Dictionary:
	return {"id":id,"label":label,"kind":kind,"arrival":arrival}

func resolve(link: Dictionary):
	return ensure_location(link.id)

func ensure_location(id: String):
	if maps.has(id): return maps[id]
	if not records.has(id):
		push_error("Production/World/location_world.gd: unknown location " + id)
		return null
	var record: Dictionary = records[id]
	if record.generated:
		var state: Dictionary = read_state(id)
		if state.is_empty(): return null
		maps[id] = State.restore(state)
		return maps[id]
	var map = _generate_local(record) if record.template == "Local" else _generate_interior(record)
	maps[id] = map
	record.generated = true
	revision += 1
	return map

func _generate_local(record: Dictionary):
	var rng := RandomNumberGenerator.new()
	rng.seed = record.seed
	var half_height: int = rng.randi_range(10,15)
	var map = Map.new(record.id,record.label,"Local",Vector2i(half_height*3,half_height*2))
	map.region_biome = record.constraints.biome
	map.links[Vector2i(1,3)] = entrance(record.parent,"Return to Global","Return",record.constraints.return_cell)
	# Existing water generator exposes its island anchor through the Tower link.
	for entry: Array in [[Vector2i(4,2),"Dungeon"],[Vector2i(3,4),"Town"],[Vector2i(5,4),"Tower"]]:
		map.links[entry[0]] = {"kind":entry[1],"return_cell":entry[0]}
	Water.generate(map,Contracts.seed_for(record.seed,"water"))
	Terrain.generate(map,Contracts.seed_for(record.seed,"terrain"))
	Contracts.apply_surface(map,record.constraints.boundaries)
	Rivers.generate(map,Contracts.seed_for(record.seed,"rivers"))
	Contracts.route_constraints(map,record.constraints.boundaries)
	Pois.generate(map,Contracts.seed_for(record.seed,"pois"))
	for cell: Vector2i in map.links.keys():
		var link: Dictionary = map.links[cell]
		if link.kind == "Return": continue
		var id: String = record.id+"/poi_"+link.kind.to_lower()+"_1"
		declare(id,record.id,link.kind,link.kind,{"return_cell":cell,"biome":map.region_biome})
		map.links[cell] = entrance(id,link.kind,link.kind)
		if link.get("island",false): map.links[cell].island = true
	return map

func _generate_interior(record: Dictionary):
	var definition: Dictionary = Templates.get_template(record.template)
	var extent := Vector2i(12,10) if definition.layout == "well" else Vector2i(18,14)
	var map = Map.new(record.id,record.label,"POI",extent)
	map.links[Vector2i(1,3)] = entrance(record.parent,"Return to "+records[record.parent].label,"Return",record.constraints.return_cell)
	var rng := RandomNumberGenerator.new()
	rng.seed = record.seed
	for cell: Vector2i in map.cells():
		if cell.x == 0 or cell.y == 0 or cell.x == extent.x-1 or cell.y == extent.y-1: map.walls.append(cell)
	if definition.layout in ["ruin","tower"]:
		for x: int in [5,11]:
			var door: int = rng.randi_range(2,extent.y-3)
			for y: int in range(1,extent.y-1):
				if y != door: map.walls.append(Vector2i(x,y))
	elif definition.layout == "town":
		for corner: Vector2i in [Vector2i(4,5),Vector2i(11,5)]:
			for offset: Vector2i in [Vector2i.ZERO,Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]: map.walls.append(corner+offset)
	for child: Dictionary in definition.children:
		var cell := Vector2i(extent.x-3,extent.y-3)
		var id: String = record.id+"/"+child.slot
		declare(id,record.id,child.template,child.label,{"return_cell":cell,"biome":record.constraints.get("biome","")})
		map.links[cell] = entrance(id,child.label,child.template)
	# Guarantee an accessible spawn and child link; never generate descendants here.
	for goal: Vector2i in map.links.keys()+[Vector2i(6,3)]:
		var cell := Vector2i(1,3)
		while cell.x != goal.x:
			cell.x += signi(goal.x-cell.x)
			map.walls.erase(cell)
		while cell.y != goal.y:
			cell.y += signi(goal.y-cell.y)
			map.walls.erase(cell)
	return map

func request_poi(parent_id: String, template: String, requested_cell: Vector2i = Vector2i(-1,-1), label: String = "") -> Dictionary:
	# Validate entire request against existing resolved geography before declaring anything.
	var definition: Dictionary = Templates.get_template(template)
	if not records.has(parent_id) or definition.is_empty() or template == "Local" or parent_id == "global": return {"ok":false,"reason":"Unknown template or invalid parent."}
	if not records[parent_id].generated:
		# Resolve an unseen parent in a staging registry; rejected event changes nothing.
		var staged = get_script().new(world_seed,false)
		staged.world_id = world_id
		staged.records = records.duplicate(true)
		staged.maps = maps.duplicate()
		staged.archives = archives.duplicate()
		staged.archived_states = archived_states.duplicate(true)
		staged.next_instance = next_instance
		staged.revision = revision
		staged.ensure_location(parent_id)
		var outcome: Dictionary = staged.request_poi(parent_id,template,requested_cell,label)
		if outcome.ok:
			records = staged.records
			maps = staged.maps
			next_instance = staged.next_instance
			revision = staged.revision
		return outcome
	var state: Dictionary = State.capture(maps[parent_id]) if maps.has(parent_id) else read_state(parent_id)
	if state.is_empty(): return {"ok":false,"reason":"Parent state unavailable."}
	var parent = State.restore(state)
	var candidates: Array[Vector2i] = []
	for cell: Vector2i in parent.cells():
		if not parent.walkable(cell) or parent.water_cells.has(cell) or parent.links.has(cell): continue
		if not definition.allowed.is_empty() and parent.biomes.get(cell,parent.region_biome) not in definition.allowed: continue
		candidates.append(cell)
	if requested_cell != Vector2i(-1,-1) and requested_cell not in candidates: return {"ok":false,"reason":"Requested position violates placement rules."}
	if candidates.is_empty(): return {"ok":false,"reason":"No valid position."}
	var cell: Vector2i = requested_cell
	if cell == Vector2i(-1,-1):
		var rng := RandomNumberGenerator.new()
		rng.seed = Contracts.seed_for(world_seed,parent_id+":event:"+str(next_instance))
		cell = candidates[rng.randi_range(0,candidates.size()-1)]
	var id: String = parent_id+"/poi_event_"+str(next_instance)
	var title: String = template if label.is_empty() else label
	declare(id,parent_id,template,title,{"return_cell":cell,"biome":parent.region_biome})
	# Commit only now, after all refusal conditions have passed.
	var live = maps[parent_id] if maps.has(parent_id) else parent
	live.links[cell] = entrance(id,title,template)
	maps[parent_id] = live
	return {"ok":true,"id":id,"cell":cell,"reason":"Created "+title+"."}

func read_state(id: String) -> Dictionary:
	if archived_states.has(id): return archived_states[id].duplicate(true)
	if not archives.has(id):
		push_error("Production/World/location_world.gd: missing generated state " + id)
		return {}
	var file := FileAccess.open(archives[id],FileAccess.READ)
	if file == null: return {}
	var value = bytes_to_var(file.get_buffer(file.get_length()))
	return value if value is Dictionary and State.valid(value) else {}

func unload(id: String) -> bool:
	if not maps.has(id): return records.has(id) and records[id].generated
	if DirAccess.make_dir_recursive_absolute(ARCHIVES) != OK: return false
	var bytes: PackedByteArray = var_to_bytes(State.capture(maps[id]))
	var path: String = ARCHIVES+world_id+"_location_"+str(Time.get_ticks_usec())+"_"+str(randi())+".bin"
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null: return false
	file.store_buffer(bytes)
	file.flush()
	if file.get_error() != OK: return false
	archives[id] = path
	archived_states.erase(id)
	maps.erase(id)
	return true

func all_states() -> Dictionary:
	var result: Dictionary = {}
	for id: String in records:
		if not records[id].generated: continue
		result[id] = State.capture(maps[id]) if maps.has(id) else read_state(id)
	return result
