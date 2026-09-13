extends RefCounted
## Mix coordinate hash through the RNG; string-hash low bits form visible bands.
static func index(cell: Vector2i, map_id: String, count: int, salt: int = 0) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = (map_id+":"+str(cell)+":"+str(salt)).hash()
	return rng.randi_range(0,count-1)
