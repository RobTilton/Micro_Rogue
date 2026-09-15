extends RefCounted
const Items = preload("res://Production/Actors/items.gd")
const Contracts = preload("res://Production/World/geographic_contracts.gd")
const DEFINITIONS = [
	{"id":"inn","name":"Inn","roof":0,"closed":false},
	{"id":"blacksmith","name":"Blacksmith","roof":1,"closed":false},
	{"id":"leatherworker","name":"Leatherworker","roof":2,"closed":false},
	{"id":"tailor","name":"Tailor","roof":3,"closed":false},
	{"id":"general_goods","name":"General Goods","roof":4,"closed":false},
	{"id":"jeweler","name":"Jeweler","roof":5,"closed":true}
]
static func populate(map, seed_value: int = 1) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(seed_value,"town-layout")
	var candidates: Array = []
	var center := Vector2i(3,3)
	var directions: Array = preload("res://Production/World/hex_map.gd").DIRECTIONS
	for side: int in range(6):
		var a: Vector2i = directions[side]
		var b: Vector2i = directions[(side+1)%6]
		candidates.append(center+(a*2+b if rng.randi_range(0,1) == 0 else a+b*2))
	for definition: Dictionary in DEFINITIONS:
		var index: int = rng.randi_range(0,candidates.size()-1)
		map.shops[candidates[index]] = definition.duplicate(true)
		candidates.remove_at(index)

static func stock(map, seed_value: int, prosperity_override: int = -1) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = Contracts.seed_for(seed_value,"town-stock")
	var prosperity: int = rng.randi_range(1,6) if prosperity_override < 0 else prosperity_override
	var tier: int = mini(8,1+prosperity/3)
	for shop: Dictionary in map.shops.values():
		# Saved shops are never rerolled by this entry point.
		if shop.has("stock"): continue
		shop.stock = []
		shop.supplies_added = false
		shop.prosperity = prosperity
		if shop.closed or shop.id == "inn": continue
		for index: int in range(maxi(5,prosperity*3)):
			var request: Dictionary = {"max_material_tier":tier,"max_base_rank":tier}
			match shop.id:
				"blacksmith": request.material_family = "metal"
				"leatherworker": request.material_family = "leather"
				"tailor": request.material_family = "cloth"
				"general_goods": request.category = ["belts","bows","staffs"][rng.randi_range(0,2)]
			var drop: Dictionary = Items.generate(request,rng)
			if drop.ok:
				var price: int = retail_price(drop.item)
				shop.stock.append({"item":drop.item,"price":price})
	ensure_supplies(map)
	if not map.props.is_empty(): return
	var candidates: Array = []
	for cell: Vector2i in map.cells():
		if map.walkable(cell) and not map.links.has(cell) and cell != map.spawn_cell and map.distance(cell,Vector2i(3,3)) == 2: candidates.append(cell)
	for index: int in range(mini(3,candidates.size())):
		var choice: int = rng.randi_range(0,candidates.size()-1)
		var cell: Vector2i = candidates[choice]
		candidates.remove_at(choice)
		var contents: Array = []
		for item_index: int in range(rng.randi_range(1,2)):
			var drop: Dictionary = Items.generate({"max_material_tier":tier,"max_base_rank":tier},rng)
			if drop.ok: contents.append(drop.item)
		var kind: String = ["crate","barrel","chest"][index]
		map.props[cell] = {"kind":kind,"name":kind.capitalize(),"opened":false,"contents":contents,"room_id":-1}

static func retail_price(item: Dictionary) -> int:
	return maxi(1,5*int(item.get("base_rank",1))+int(item.get("material_tier",1))-1+int(item.get("quality",{}).get("modifier",0)))

static func sale_price(item: Dictionary) -> int:
	return retail_price(item)/2

static func sellable(item: Dictionary) -> bool:
	return item.get("kind","") in ["weapon","sword","shield","armor","belt"] and (item.get("kind") != "belt" or item.get("contents",[]).is_empty())

static func ensure_supplies(map) -> bool:
	var changed: bool = false
	for shop: Dictionary in map.shops.values():
		if shop.id != "general_goods" or shop.closed or shop.get("supplies_added",false): continue
		for index: int in range(5):
			shop.stock.append({"item":Items.potion(),"price":2})
			shop.stock.append({"item":Items.ration(),"price":1})
		shop.supplies_added = true
		changed = true
	return changed
