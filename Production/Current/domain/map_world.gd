extends RefCounted
const HexMap = preload("res://Production/Current/domain/hex_map.gd")
var maps: Dictionary = {}
var states: Dictionary = {}
func _init() -> void:
	var world = HexMap.new("global","The Marches","Global",Vector2i(5,5))
	for cell: Vector2i in world.cells():
		world.links[cell] = {"id":"local_%d_%d" % [cell.x,cell.y],"label":"Explore region %d, %d" % [cell.x,cell.y],"kind":"Local","parent":"global","return_cell":cell}
	maps[world.id] = world
func resolve(link: Dictionary):
	if maps.has(link.id): return maps[link.id]
	var local: bool = link.kind == "Local"
	var map = HexMap.new(link.id,link.label,"Local" if local else "POI",Vector2i(7,6) if local else Vector2i(9,7))
	map.links[Vector2i(1,3)] = {"id":link.parent,"label":"Return to parent map","kind":"Return","arrival":link.return_cell}
	if local:
		for entry: Array in [[Vector2i(4,2),"Dungeon"],[Vector2i(3,4),"Town"],[Vector2i(5,4),"Tower"]]:
			map.links[entry[0]] = {"id":map.id+"_"+entry[1],"label":entry[1],"kind":entry[1],"parent":map.id,"return_cell":entry[0]}
	else:
		for cell: Vector2i in map.cells():
			if cell.x == 0 or cell.y == 0 or cell.x == map.dimensions.x-1 or cell.y == map.dimensions.y-1: map.walls.append(cell)
		map.walls.append(Vector2i(4,3))
		map.walls.append(Vector2i(4,4))
	maps[map.id] = map
	return map
