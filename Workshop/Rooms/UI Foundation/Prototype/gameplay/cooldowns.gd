extends RefCounted
## Reusable ability clock. IDs can identify skills or future spells.
const OUTSIDE_TICK_SECONDS: float = 3.0
var remaining: Dictionary = {}
var elapsed: Dictionary = {}
func ready(ability: String) -> bool:
	return ticks(ability) == 0
func ticks(ability: String) -> int:
	return remaining.get(ability, 0)
func start(ability: String, end_turn_ticks: int) -> void:
	remaining[ability] = maxi(0, end_turn_ticks)
	elapsed[ability] = 0.0
func end_turn() -> void:
	for ability: String in remaining:
		remaining[ability] = maxi(0, remaining[ability] - 1)
		elapsed[ability] = 0.0
func enter_combat() -> void:
	for ability: String in elapsed: elapsed[ability] = 0.0
func advance_outside(delta: float) -> bool:
	var changed: bool = false
	for ability: String in remaining:
		if remaining[ability] == 0: continue
		elapsed[ability] += delta
		var steps: int = floori(elapsed[ability] / OUTSIDE_TICK_SECONDS)
		if steps > 0:
			remaining[ability] = maxi(0, remaining[ability] - steps)
			elapsed[ability] = fmod(elapsed[ability], OUTSIDE_TICK_SECONDS)
			changed = true
	return changed
