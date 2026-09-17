extends SceneTree
const Rarity = preload("res://Production/World/chest_rarity.gd")
const Map = preload("res://Production/World/hex_map.gd")
const State = preload("res://Production/Persistence/map_state.gd")
const Props = preload("res://Production/World/interior_props.gd")
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Chest Rarity/chest_test.gd: "+message)
func chest() -> Dictionary: return {"kind":"chest","name":"Chest","opened":false,"contents":[],"gold":3,"room_id":0}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var counts: Dictionary = {"normal":0,"rare":0}
	for roll: int in range(1,101): counts[Rarity.for_roll(roll)] += 1
	check(counts.normal == 75 and counts.rare == 25,"exact 75/25 roll intervals")
	var map := Map.new("test","Test","POI",Vector2i(50,50))
	for cell: Vector2i in map.cells(): map.props[cell] = chest()
	map.props[Vector2i.ZERO].opened = true
	map.props[Vector2i.ZERO].gold = 0
	map.props[Vector2i(1,0)] = {"kind":"crate","name":"Crate","opened":false,"contents":[],"room_id":-1}
	var original = State.capture(map)
	check(Rarity.ensure(map,152),"classifies old untagged chests")
	var rare: int = 0
	for prop: Dictionary in map.props.values():
		if prop.get("chest_rarity") == "rare": rare += 1
	check(rare > 540 and rare < 710,"seeded sample remains close to expected 25 percent")
	check(not map.props[Vector2i(1,0)].has("chest_rarity"),"non-chests untouched")
	check(map.props[Vector2i.ZERO].opened and map.props[Vector2i.ZERO].gold == 0,"searched chest remains searched")
	check(map.props[Vector2i(2,0)].gold == 3 and map.props[Vector2i(2,0)].contents.is_empty(),"contents and gold preserved")
	check(not Rarity.ensure(map,999),"assigned rarity is permanent even if generation seed changes")
	var repeat = State.restore(original)
	Rarity.ensure(repeat,152)
	check(repeat.props == map.props,"same seed and cells reproduce classifications and names")
	var restored = State.restore(State.capture(map))
	check(restored.props == map.props and Props.valid(restored.props,restored,[],{}),"map roundtrip retains valid rarity data")
	restored.props[Vector2i.ZERO].chest_rarity = "mythic"
	check(not Props.valid(restored.props,restored,[],{}),"invalid chest classifications refused")
	check(Props.valid(original.props,State.restore(original),[],{}),"old untagged saves accepted")
	# Exercise every live chest-generation branch through the real world.
	var world := Sim.new(152)
	var player: Dictionary = world.Actors.create([3,3,3,3,3,3])
	world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
	world.start_in_town()
	var local_id: String = world.maps.records[player.map_id].parent
	for template: String in ["Cave","Dungeon","Tower","Well"]:
		var id: String = local_id+"/rarity_test_"+template.to_lower()
		world.maps.declare(id,local_id,template,"Rarity test "+template,{"return_cell":Vector2i(1,3)})
		var generated = world.ensure_map({"id":id})
		var valid: bool = true
		for prop: Dictionary in generated.props.values():
			if prop.kind == "chest" and prop.get("chest_rarity") not in ["normal","rare"]: valid = false
		check(valid,"classified "+template+" population")
	var total: int = 0
	for id: String in world.initialized:
		for prop: Dictionary in world.maps.maps[id].props.values():
			if prop.kind == "chest":
				total += 1
				check(prop.get("chest_rarity") in ["normal","rare"],"town/local/POI chest classified")
	check(total > 10,"production fixture generated a meaningful chest sample")
	var saved: Dictionary = world.save_game("res://Workshop/Rooms/Chest Rarity/tests/saves/")
	check(saved.ok,"world containing rare chests saves")
	var loaded := Sim.new(153)
	check(loaded.load_game(world.last_save).ok,"world containing rare chests loads")
	for id: String in world.initialized:
		check(loaded.ensure_map({"id":id}).props == world.maps.maps[id].props,"loading cannot reroll chest rarity or contents")
	print("Chest Rarity: %d checks, %d failures; seeded rare count %d/2499" % [checks,failures,rare])
	quit(1 if failures else 0)
