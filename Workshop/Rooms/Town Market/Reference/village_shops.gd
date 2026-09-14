extends RefCounted
const DEFINITIONS = [
	{"id":"inn","name":"Inn","roof":0,"closed":false},
	{"id":"blacksmith","name":"Blacksmith","roof":1,"closed":false},
	{"id":"leatherworker","name":"Leatherworker","roof":2,"closed":false},
	{"id":"tailor","name":"Tailor","roof":3,"closed":false},
	{"id":"general_goods","name":"General Goods","roof":4,"closed":false},
	{"id":"jeweler","name":"Jeweler","roof":5,"closed":true}
]
const CELLS = [Vector2i(4,5),Vector2i(7,5),Vector2i(10,5),Vector2i(4,9),Vector2i(7,9),Vector2i(10,9)]
static func populate(map) -> void:
	for index: int in range(DEFINITIONS.size()): map.shops[CELLS[index]] = DEFINITIONS[index].duplicate(true)
