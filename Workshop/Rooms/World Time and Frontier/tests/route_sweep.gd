extends SceneTree
const World = preload("res://Production/World/location_world.gd")
var failures: int = 0
func _initialize() -> void:
	var missing_towns: int = 0
	for seed_value: int in range(12):
		var world = World.new(5100+seed_value)
		var rules: Dictionary = world.records.global.constraints
		if rules.starter_route.size() < 3 or rules.route_towns.size() != 2: failures += 1
		for id: String in rules.route_towns:
			if not world.records[id].generated or world.records[id].template != "Town": failures += 1
		for id: String in world.records.keys():
			var record: Dictionary = world.records[id]
			if record.template != "Local" or record.generated: continue
			var local = world.ensure_location(id)
			var has_town: bool = false
			for link: Dictionary in local.links.values():
				if link.kind == "Town": has_town = true
			if not has_town: missing_towns += 1
			break
	if missing_towns == 0: failures += 1
	print("Route sweep: 12 seeds, %d sampled regions without towns, %d failures" % [missing_towns,failures])
	quit(1 if failures else 0)
