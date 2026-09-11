extends SceneTree
const Items = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/items.gd")
const Actors = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/actors.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("Workshop/Rooms/Actor Foundation/tests/actor_ui_test.gd: " + message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://Workshop/Rooms/Actor Foundation/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	for frame: int in range(3): await process_frame
	check(game.player.sprite == "player" and game.board.actor_sprites.has(game.player.id),"player sprite wired")
	check(not game.hud.buttons["End Turn"].disabled,"wait available outside combat")
	game._enter_map()
	check(game.active_map.layer == "Local","shared travel enters Local")
	var local_id: String = game.active_map.id
	var dungeon_cell := Vector2i.ZERO
	for cell: Vector2i in game.active_map.links:
		if game.active_map.links[cell].kind == "Dungeon": dungeon_cell = cell
	game.player.pos = dungeon_cell
	game._enter_map()
	check(game.active_map.layer == "POI","shared travel enters Dungeon")
	check(game.simulation.on_map(game.player.map_id).size() == 2,"initial enemy registered")
	game.player.hp = 999
	game.player.max_hp = 999
	var first: Dictionary = {}
	for actor: Dictionary in game.simulation.on_map(game.player.map_id):
		if actor.id != game.player.id: first = actor
	first.pos = Vector2i(2,3)
	var second: Dictionary = Actors.create([4,4,4,4,4,4],true)
	second.hp = 999
	second.max_hp = 999
	game.simulation.add_actor(second,game.player.map_id,Vector2i(2,2),"enemy")
	game._refresh()
	check(game.board.actor_sprites.has(first.id) and game.board.actor_sprites.has(second.id),"multiple enemy sprites")
	game.player.skills = ["Lunge","Riposte","Show-Off"]
	game.player.off = Items.make("sword")
	game.simulation.begin_turn(game.player)
	game._command("Attack")
	game._board_intent(second.pos,false)
	check(game.selected_actor_id == second.id and game.player.actions.attack == 1,"click selects and attacks second enemy")
	game._command("Riposte")
	check(game.player.riposte,"UI Riposte reaches shared service")
	game._end_turn()
	check(game.player.actions.move == 1,"player turn restored after NPC phase")
	game._command("Cancel")
	game.player.pos = Vector2i(1,3)
	first.pos = Vector2i(3,3)
	second.pos = Vector2i(5,5)
	game._refresh()
	var enemy_id: int = first.id
	game._enter_map()
	check(game.active_map.id == local_id,"UI travel returns to Local")
	check(game.simulation.actors[enemy_id].map_id == local_id,"observer follows player through UI transition")
	check(game.simulation.actors[enemy_id].pos != game.player.pos,"pursuer does not overlap player")
	game.simulation.actors[enemy_id].hp = 0
	game._check_death()
	var dropped: int = game.loot.size()
	game._check_death()
	check(game.loot.size() == dropped,"UI death processing does not duplicate loot")
	# Move/confirm remains gated through the same service and consumes a world turn.
	for actor: Dictionary in game.simulation.actors.values():
		if actor.id != game.player.id: actor.hp = 0
	game._check_death()
	game.simulation.begin_turn(game.player)
	game._command("Cancel")
	game._refresh()
	var origin: Vector2i = game.player.pos
	var destination: Vector2i = game._movement_paths().keys()[0]
	var tick: int = game.simulation.tick
	game._request_movement(destination)
	check(game.player.pos == origin and not game.preview_path.is_empty(),"movement confirmation retained")
	game._confirm_move()
	check(game.player.pos == destination and game.simulation.tick == tick+1,"outside movement advances world turn")
	game._toggle_panel("Inventory",120)
	check(game.current_grid != null,"inventory remains available")
	game._start_run()
	check(game.simulation.actors.size() == 1 and game.simulation.ground.global.is_empty(),"new run clears actors and drops")
	print("Workshop/Rooms/Actor Foundation/tests/actor_ui_test.gd: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
