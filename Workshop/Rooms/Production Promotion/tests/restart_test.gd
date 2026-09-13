extends SceneTree
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Brain = preload("res://Production/Actors/enemy_brain.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Production Promotion/tests/restart_test.gd: "+message)
func _initialize() -> void:
	var path: String = FileAccess.get_file_as_string("res://Workshop/Rooms/Production Promotion/tests/restart_path.txt")
	var sim = Sim.new(1)
	check(sim.load_game(path).ok,"separate process reads full snapshot")
	var player: Dictionary = sim.actors[sim.player_id]
	check(not player.pending.is_empty() and player.clock.ticks("Lunge") == 4,"pending action and cooldown survive restart")
	sim.cancel(player)
	var dungeon_id: String = player.map_id
	var local_id: String = sim.maps.records[dungeon_id].parent
	var enemy: Dictionary = sim.on_map(dungeon_id).filter(func(a): return a.id != player.id)[0]
	player.hp = 999
	player.max_hp = 999
	player.pos = Vector2i(1,3)
	enemy.pos = Vector2i(3,3)
	enemy.points = 0
	enemy.belt.contents = []
	var enemy_id: int = enemy.id
	check(sim.unload_location(local_id).ok,"restart can unload parent")
	sim.begin_turn(player)
	check(sim.travel(player).ok and player.map_id == local_id,"restart Return restores parent")
	check(not enemy.trail.is_empty(),"observer records exit")
	var saved: Dictionary = sim.save_game("res://Workshop/Rooms/Production Promotion/tests/saves/")
	check(saved.ok,"save active pursuit")
	check(sim.load_game(saved.path).ok,"restore active pursuit")
	player = sim.actors[sim.player_id]
	sim.advance(Brain.new())
	check(sim.actors[enemy_id].map_id == player.map_id and sim.actors[enemy_id].pos != player.pos,"restored pursuer follows through saved entrance")
	enemy = sim.actors[enemy_id]
	enemy.hp = 0
	sim.resolve_death(enemy,player)
	var drops: int = sim.ground[local_id].size()
	saved = sim.save_game("res://Workshop/Rooms/Production Promotion/tests/saves/")
	check(saved.ok and sim.load_game(saved.path).ok,"death and loot roundtrip")
	sim.resolve_death(sim.actors[enemy_id],sim.actors[sim.player_id])
	check(sim.ground[local_id].size() == drops and sim.actors[enemy_id].dropped,"death does not duplicate loot after reload")
	var floor_id: String = dungeon_id+"/floor_2"
	sim.ensure_map({"id":floor_id})
	player = sim.actors[sim.player_id]
	player.map_id = floor_id
	player.pos = Vector2i(1,3)
	var follower: Dictionary = sim.on_map(floor_id).filter(func(a): return a.id != player.id)[0]
	follower.pos = Vector2i(3,3)
	follower.points = 0
	follower.belt.contents = []
	sim.begin_turn(player)
	check(sim.unload_location(dungeon_id).ok,"nested pursuit parent unload")
	check(sim.travel(player).ok and player.map_id == dungeon_id,"recursive floor Return")
	sim.advance(Brain.new())
	check(follower.map_id == dungeon_id and follower.pos != player.pos,"pursuer traverses recursive floor entrance")
	check(Sim.validate_snapshot(sim.snapshot()).is_empty(),"restored world remains valid")
	print("World restart/pursuit: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
