extends SceneTree
const World = preload("res://Production/World/location_world.gd")
const Dense = preload("res://Production/World/dense_room_generator.gd")
const Caves = preload("res://Production/World/cave_generator.gd")
const Props = preload("res://Production/World/interior_props.gd")
func _initialize() -> void:
	var world = World.new(123,false)
	world.records["parent"] = {"label":"Town Well"}
	var cave_count: int = 0
	for seed_value: int in range(32):
		var record: Dictionary = {"id":"underground","parent":"parent","template":"Underground","seed":seed_value,"label":"Underground Ruin","constraints":{"return_cell":Vector2i(2,2)}}
		var map = world._generate_interior(record)
		var again = world._generate_interior(record)
		assert(map.walls == again.walls and map.spawn_cell == again.spawn_cell)
		assert(map.links[map.spawn_cell].id == "parent")
		if World.underground_is_cave(seed_value):
			cave_count += 1
			assert(Caves.valid(map.cave_layout,map.dimensions,map.walls))
			Props.populate(map,map.cave_layout,"Cave")
		else:
			assert(Dense.valid(map.room_layout,map.dimensions,map.walls))
			assert(map.dimensions.x <= 38 and map.dimensions.y <= 36)
			Props.populate(map,map.room_layout,"Underground")
		assert(not map.props.is_empty())
		var ruin = Dense.generate("ruin","Ruin",seed_value,false,true)
		assert(Dense.valid(ruin.room_layout,ruin.dimensions,ruin.walls))
		assert(ruin.room_layout.rooms.size() >= 6 and ruin.room_layout.rooms.size() <= 9)
	assert(cave_count > 0 and cave_count < 32)
	print("Well Interiors: 32 deterministic wells (%d caves, %d ruins), 32 compact ruins; topology, return links and scenery passed." % [cave_count,32-cave_count])
	quit()
