extends RefCounted
const Variation = preload("res://Workshop/Rooms/Regional Release/UI/terrain_variation.gd")
## Explicit approved samples; no road or modern-sheet regions are included.
const SHEETS: Array[String] = ["res://Production/Assets/Terrain/Local_Map_Wasteland_DO_NOT_USE_THE_ROADS.png","res://Production/Assets/Terrain/Local_Map_Wasteland_02.png"]
const SAMPLES: Array[Vector3] = [Vector3(0,96,268),Vector3(0,1440,268),Vector3(0,1436,902),Vector3(1,97,267),Vector3(1,1445,267),Vector3(1,465,100)]
static func sample(cell: Vector2i, map_id: String) -> Vector3:
	return SAMPLES[Variation.index(cell,map_id,SAMPLES.size())]
