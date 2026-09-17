extends SceneTree
const World = preload("res://Production/Actors/actor_world.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Map = preload("res://Production/World/hex_map.gd")
const Paths = preload("res://Production/World/movement_preview.gd")
const View = preload("res://Production/UI/actor_view.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Movement Flow/movement_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var world := World.new(152)
	var map := Map.new("test","Test","POI",Vector2i(16,10))
	world.maps.maps.test = map
	var player: Dictionary = Actors.create([3,3,3,3,3,3])
	world.add_actor(player,"test",Vector2i(1,3),"player","player")
	var foe: Dictionary = Actors.create([3,3,3,3,1,3],true)
	foe.sight_base = 2
	world.add_actor(foe,"test",Vector2i(6,3),"enemy")
	world.begin_turn(player)
	check(not world.engaged(player),"starts outside detection")
	var route: Array = Paths.route_to(player.pos,[Vector2i(12,3)],world.blocked(player),map)
	check(route.size() >= 11,"targeted route reaches distant destination")
	var previous: Vector2i = player.pos
	for cell: Vector2i in route:
		check(map.distance(previous,cell) == 1 and map.walkable(cell) and cell != foe.pos,"route has adjacent unblocked steps")
		previous = cell
	check(Paths.route_to(player.pos,[Vector2i(12,3)],world.blocked(player),map,4).is_empty(),"range-limited route cannot overspend")
	check(world.walk_step(player,Vector2i(2,3)).ok and player.pos == Vector2i(2,3),"step commits one hex")
	check(world.walk_step(player,Vector2i(3,3)).ok,"second safe step")
	var alert: Dictionary = world.walk_step(player,Vector2i(4,3))
	check(alert.ok and alert.combat_started and world.engaged(player),"entry to monster sight announces combat")
	check(not world.walks.has(player.id) and player.actions.move == 0,"detection cancels old route credit and charges movement")
	check(not world.walk_step(player,Vector2i(4,4)).ok,"cannot continue exploration movement after detection")
	world.begin_turn(player)
	var first: Dictionary = world.walk_step(player,Vector2i(4,4))
	check(first.ok and player.actions.move == 0,"first combat step costs one action")
	check(world.walk_step(player,Vector2i(5,4)).ok and player.actions.move == 0,"same movement allowance continues without extra action")
	check(world.walk_units(player) == 8,"remaining allowance tracks traveled distance across retargeting")
	var before: Vector2i = player.pos
	check(not world.walk_step(player,foe.pos).ok and player.pos == before,"occupied next cell refuses atomically")
	world.stop_walk(player)
	check(not world.walk_step(player,Vector2i(4,4)).ok,"cancel cannot refund spent movement")
	# Rendering always interpolates the recorded edge and freezes during the announcement.
	var view := View.new()
	view.map_data = map
	view.zoom = 1.0
	root.add_child(view)
	view.set_process(false)
	view.show_actors([player],player.id)
	check(view.actor_sprites[player.id].position.is_equal_approx(view.center(player.pos)),"newly revealed actor starts on its hex, not screen origin")
	view.animate_motion({"actor_id":player.id,"from":Vector2i(4,4),"route":[Vector2i(5,4)]})
	view.motion_paused = true
	var frozen: Vector2 = view.actor_sprites[player.id].position
	view._process(0.5)
	check(view.actor_sprites[player.id].position == frozen and view.motion_busy(),"combat pause freezes in-flight sprite")
	view.motion_paused = false
	view._process(0.125)
	check(view.actor_sprites[player.id].position.is_equal_approx(view.center(Vector2i(4,4)).lerp(view.center(Vector2i(5,4)),0.5)),"halfway frame interpolates")
	view._process(0.125)
	check(not view.motion_busy() and view.actor_sprites[player.id].position.is_equal_approx(view.center(player.pos)),"sprite arrives at authoritative cell")
	var persistent = preload("res://Production/Persistence/persistent_actor_world.gd").new(152)
	var trade: Array = persistent.maps.records.global.constraints.starter_route
	var traveler: Dictionary = Actors.create([3,3,3,3,3,3])
	persistent.add_actor(traveler,"global",trade[0],"player","player")
	persistent.begin_turn(traveler)
	check(persistent.walk_step(traveler,trade[1]).ok and persistent.world_hours == 6,"animated global trade step charges six hours once")
	check(not persistent.walk_step(traveler,Vector2i(-20,-20)).ok and persistent.world_hours == 6,"invalid global jump cannot advance time")
	print("Movement Flow: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
