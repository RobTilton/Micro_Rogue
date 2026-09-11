extends RefCounted
const HexMap = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
const Continents = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/continent_generator.gd")
const LocalTerrain = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_terrain.gd")
const Water = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_water.gd")
const Rivers = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/river_generator.gd")
const LocalPois = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_poi_placement.gd")
var world_seed: int
var maps: Dictionary = {}
var states: Dictionary = {}
func _init(seed_value: int = 1729) -> void:
	world_seed = seed_value
	var world = HexMap.new("global","The Marches","Global",Vector2i(80,42))
	world.wrap_horizontal = true
	world.spawn_cell = Continents.generate(world,world_seed)
	Rivers.generate(world,world_seed)
	for cell: Vector2i in world.cells():
		if not world.walkable(cell): continue
		world.links[cell] = {"id":"local_%d_%d" % [cell.x,cell.y],"label":"%s region %d, %d" % [world.biomes[cell],cell.x,cell.y],"biome":world.biomes[cell],"kind":"Local","parent":"global","return_cell":cell}
	maps[world.id] = world
func resolve(link: Dictionary):
	if maps.has(link.id): return maps[link.id]
	var local: bool = link.kind == "Local"
	var region_rng := RandomNumberGenerator.new()
	region_rng.seed = world_seed+link.id.hash()
	var half_height: int = region_rng.randi_range(10,15)
	var map = HexMap.new(link.id,link.label,"Local" if local else "POI",Vector2i(half_height*3,half_height*2) if local else Vector2i(18,14))
	map.region_biome = link.get("biome","")
	map.links[Vector2i(1,3)] = {"id":link.parent,"label":"Return to parent map","kind":"Return","arrival":link.return_cell}
	if local:
		for entry: Array in [[Vector2i(4,2),"Dungeon"],[Vector2i(3,4),"Town"],[Vector2i(5,4),"Tower"]]:
			map.links[entry[0]] = {"id":map.id+"_"+entry[1],"label":entry[1],"kind":entry[1],"parent":map.id,"return_cell":entry[0]}
		Water.generate(map,int((world_seed+map.id.hash()) % 2147483647))
		LocalPois.generate(map,int((str(world_seed)+":"+map.id+":pois").hash()))
		LocalTerrain.generate(map,int((world_seed+map.id.hash()) % 2147483647))
		Rivers.generate(map,int((world_seed+map.id.hash()) % 2147483647))
	else:
		for cell: Vector2i in map.cells():
			if cell.x == 0 or cell.y == 0 or cell.x == map.dimensions.x-1 or cell.y == map.dimensions.y-1: map.walls.append(cell)
		map.walls.append(Vector2i(4,3))
		map.walls.append(Vector2i(4,4))
	maps[map.id] = map
	return map
