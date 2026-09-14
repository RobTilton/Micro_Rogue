extends RefCounted
## Templates own layout, population, placement, and lazy child declarations.
const DEFINITIONS: Dictionary = {
	"Cave": {"role":"POI","population":0,"layout":"cave","allowed":[],"children":[]},
	"Local": {"role":"Local","population":0,"layout":"terrain","allowed":[],"children":[]},
	"Dungeon": {"role":"POI","population":1,"layout":"ruin","allowed":[],"children":[{"slot":"floor_2","template":"DungeonFloor","label":"Dungeon Floor 2"}]},
	"DungeonFloor": {"role":"Submap","population":1,"layout":"ruin","allowed":[],"children":[]},
	"Town": {"role":"POI","population":0,"layout":"town","allowed":[],"children":[{"slot":"well","template":"Well","label":"Town Well"}]},
	"Well": {"role":"Submap","population":0,"layout":"well","allowed":[],"children":[{"slot":"underground","template":"Underground","label":"Underground Ruin"}]},
	"Underground": {"role":"Submap","population":1,"layout":"ruin","allowed":[],"children":[]},
	"Tower": {"role":"POI","population":1,"layout":"tower","allowed":[],"children":[{"slot":"upper","template":"TowerFloor","label":"Upper Tower"}]},
	"TowerFloor": {"role":"Submap","population":1,"layout":"tower","allowed":[],"children":[]},
	"Shrine": {"role":"POI","population":0,"layout":"shrine","allowed":["Plains","Forest","Hills","Marsh"],"children":[]}
}
static func get_template(id: String) -> Dictionary:
	return DEFINITIONS.get(id,{})
