extends SceneTree
const World = preload("res://Workshop/Rooms/Regional Release/Persistence/persistent_actor_world.gd")
const Actors = preload("res://Workshop/Rooms/Regional Release/Actors/actors.gd")
const Entry = preload("res://Workshop/Rooms/Regional Release/World/local_entry.gd")
const Contracts = preload("res://Workshop/Rooms/Regional Release/World/geographic_contracts.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1; push_error("Workshop/Rooms/Regional Release/tests/entry_test.gd: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(60).timeout.connect(func(): quit(2))
	var world = World.new(1729)
	var global_map = world.maps.maps.global
	var global_cell: Vector2i = global_map.spawn_cell
	var link: Dictionary = global_map.links[global_cell]
	var local = world.ensure_map(link)
	var actor: Dictionary = Actors.create([4,4,4,4,4,4])
	world.add_actor(actor,"global",global_cell,"player")
	check(local.distance(Vector2i(20,20),local.spawn_cell) == 20,"Return is on perimeter")
	check(Entry.dry(local,local.spawn_cell),"Return uses dry terrain")
	for side: int in range(6):
		actor.map_id = "global"; actor.pos = global_cell; actor.global_approach = posmod(side+3,6)
		world.begin_turn(actor)
		var available: Array[Vector2i] = Entry.candidates(local,side)
		var outcome: Dictionary = world.travel(actor)
		check(outcome.ok == not available.is_empty(),"entry viability matches approached side")
		if outcome.ok:
			check(actor.pos in Contracts.boundary_cells(local,side,true),"enters correlated edge")
			check(Entry.dry(local,actor.pos),"never arrives on water")
	actor.map_id = "global"; actor.pos = global_cell; actor.global_approach = 0
	world.begin_turn(actor)
	var side: int = 3
	var backup: Dictionary = local.water_cells.duplicate()
	for cell: Vector2i in Contracts.boundary_cells(local,side,true): local.water_cells[cell] = true
	var before: Dictionary = actor.duplicate(true)
	check(not world.travel(actor).ok and actor == before,"wet side refuses without spending action")
	local.water_cells = backup
	for cell: Vector2i in Entry.candidates(local,side):
		world.add_actor(Actors.create([4,4,4,4,4,4],true),local.id,cell,"enemy")
	check(not world.travel(actor).ok and actor == before,"occupied side refuses without spending action")
	# Shared movement records exact final step, including horizontal wrapping.
	var approach: Dictionary = {"map_id":"global","pos":Vector2i(78,20)}
	world.record_global_approach(approach,[Vector2i(79,20),Vector2i(0,20)])
	check(approach.global_approach == 0,"wrap approach direction")
	for direction: int in range(6):
		approach.pos = global_cell
		world.record_global_approach(approach,[global_map.canonical(global_cell+global_map.DIRECTIONS[direction])])
		check(approach.global_approach == direction,"all six approach directions")
	check(World.validate_snapshot(world.snapshot()).is_empty(),"edge entries persist safely")
	print("Edge entry: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
