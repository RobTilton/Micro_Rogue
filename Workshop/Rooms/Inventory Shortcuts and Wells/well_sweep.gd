extends SceneTree
const World = preload("res://Production/World/location_world.gd")
func _initialize() -> void:
	var count: int = 0
	var world = World.new(4,false)
	for seed_value: int in range(100):
		world.records.clear()
		world.records["parent"] = {"label":"Town","children":[]}
		world.records["well"] = {"id":"well","label":"Well","children":[],"address":"well","instance":0,"seed":seed_value}
		var map = world._generate_well({"id":"well","label":"Well","parent":"parent","seed":seed_value,"constraints":{"return_cell":Vector2i(3,3)}})
		var queue: Array = [map.spawn_cell]
		var seen: Dictionary = {map.spawn_cell:true}
		while not queue.is_empty():
			for next: Vector2i in map.neighbors(queue.pop_front()):
				if map.walkable(next) and not seen.has(next): seen[next] = true; queue.append(next)
		for cell: Vector2i in map.cells():
			if map.walkable(cell): assert(seen.has(cell))
		for cell: Vector2i in map.links: assert(seen.has(cell))
		if map.links.size() == 2: count += 1
		assert((map.links.size() == 2) == World.well_has_underground(seed_value))
	assert(count > 20 and count < 60)
	print("100 connected well chambers passed; %d deeper entrances (40 percent probability)." % count)
	quit()
