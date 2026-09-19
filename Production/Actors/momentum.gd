extends RefCounted
## Speed is independent of movement distance. Effect keys identify their owning source.
const Rings = preload("res://Production/Actors/rings.gd")
const DEFAULT_THRESHOLD: int = 3
static func initialize(actor: Dictionary) -> void:
	if not actor.has("momentum"): actor.momentum = 0.0
	if not actor.has("speed_effects"): actor.speed_effects = {}
	if not actor.actions.has("free"): actor.actions.free = 0
static func speed(actor: Dictionary, threshold: int = DEFAULT_THRESHOLD) -> float:
	var value: float = float(threshold+floori(float(Rings.stat(actor,"DEX"))/2.0)+Rings.bonus(actor,"momentum"))
	for modifier: float in actor.get("speed_effects",{}).values(): value += modifier
	return maxf(0.0,value)
static func grants(actor: Dictionary, threshold: int) -> int:
	initialize(actor)
	actor.momentum += speed(actor,threshold)
	var earned: int = floori(actor.momentum/float(threshold))
	actor.momentum -= earned*threshold
	return earned
static func valid(actor: Dictionary) -> bool:
	var value = actor.get("momentum",0.0)
	if not (value is int or value is float) or not is_finite(float(value)) or value < 0: return false
	if not actor.get("speed_effects",{}) is Dictionary: return false
	for key in actor.get("speed_effects",{}):
		var modifier = actor.speed_effects[key]
		if not key is String or key.is_empty() or not (modifier is int or modifier is float) or not is_finite(float(modifier)): return false
	return true
