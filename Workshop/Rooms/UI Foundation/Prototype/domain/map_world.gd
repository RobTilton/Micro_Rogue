extends RefCounted
const HexMap = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/hex_map.gd")
const Biomes = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/biome_generator.gd")
const Water = preload("res://Workshop/Rooms/UI Foundation/Prototype/domain/local_water.gd")
var world_seed: int
var maps: Dictionary = {}
var states: Dictionary = {}
func _init(seed_value: int = 1729) -> void:
	world_seed = seed_value
	var world = HexMap.new("global","The Marches","Global",Vector2i(24,18))
	Biomes.generate(world,world_seed)
	for cell: Vector2i in world.cells():
		world.links[cell] = {"id":"local_%d_%d" % [cell.x,cell.y],"label":"%s region %d, %d" % [world.biomes[cell],cell.x,cell.y],"biome":world.biomes[cell],"kind":"Local","parent":"global","return_cell":cell}
	maps[world.id] = world
func resolve(link: Dictionary):
	if maps.has(link.id): return maps[link.id]
	var local: bool = link.kind == "Local"
	var map = HexMap.new(link.id,link.label,"Local" if local else "POI",Vector2i(14,12) if local else Vector2i(18,14))
	map.region_biome = link.get("biome","")
	map.links[Vector2i(1,3)] = {"id":link.parent,"label":"Return to parent map","kind":"Return","arrival":link.return_cell}
	if local:
		for entry: Array in [[Vector2i(4,2),"Dungeon"],[Vector2i(3,4),"Town"],[Vector2i(5,4),"Tower"]]:
			map.links[entry[0]] = {"id":map.id+"_"+entry[1],"label":entry[1],"kind":entry[1],"parent":map.id,"return_cell":entry[0]}
		Water.generate(map,int((world_seed+map.id.hash()) % 2147483647))
	else:
		for cell: Vector2i in map.cells():
			if cell.x == 0 or cell.y == 0 or cell.x == map.dimensions.x-1 or cell.y == map.dimensions.y-1: map.walls.append(cell)
		map.walls.append(Vector2i(4,3))
		map.walls.append(Vector2i(4,4))
	maps[map.id] = map
	return map
