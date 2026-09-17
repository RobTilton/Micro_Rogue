extends SceneTree
const Board = preload("res://Production/Actors/skill_board.gd")
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Skill Board/integration_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/Skill Board/tests/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,3,3,3,3,3,3]
	game._start_run()
	var world = game.simulation
	var player: Dictionary = game.player
	check(player.skill_board.origins.is_empty(),"new player starts without origins")
	check(world.can_rearrange_skills(player),"peaceful starting town allows rearrangement")
	check(world.learn(player,"Lunge").ok,"learn in production")
	check(world.place_skill_origin(player,"Martial",Vector2i(-1,0)).ok,"choose permanent origin")
	check(world.place_skill(player,"Lunge",Vector2i(1,0)).ok,"place across wildcard center")
	check(Board.active(player,"Lunge"),"runtime placement activates")
	player.points = 2
	check(world.learn(player,"Riposte").ok,"learn second")
	check(world.place_skill(player,"Riposte",Vector2i(2,0)).ok and Board.active(player,"Riposte"),"connected second skill")
	check(world.learn(player,"Show-Off").ok,"learn third")
	check(world.place_skill(player,"Show-Off",Vector2i(3,0)).ok and Board.active(player,"Show-Off"),"connected third skill")
	game._toggle_panel("Skills",160)
	await process_frame
	check(game.host.panel_name == "Skills" and game.host.content.get_child_count() >= 5,"Skills sidebar opens board and controls")
	check(game._automatic_checkpoint(),"board autosaves")
	var restored = Sim.new(44)
	check(restored.load_game(game.journal.path).ok,"board snapshot reloads")
	var saved_player: Dictionary = restored.actors[restored.player_id]
	check(saved_player.skill_board == player.skill_board and Board.active(saved_player,"Show-Off"),"positions origins activation survive save/load")
	var original: Dictionary = player.skill_board.duplicate(true)
	check(not world.place_skill_origin(player,"Martial",Vector2i(4,0)).ok and player.skill_board == original,"town cannot move origin")
	check(world.remove_board_skill(player,"Riposte").ok and not Board.active(player,"Show-Off"),"removing supporting skill recalculates dependent activation")
	check(world.place_skill(player,"Riposte",Vector2i(2,0)).ok and Board.active(player,"Show-Off"),"replacing support restores activation")
	check(world.clear_skill_placements(player).ok and player.skill_board.origins == original.origins and player.skills.size() == 3,"town clear preserves origins and learned skills")
	player.main = preload("res://Production/Actors/items.gd").make("sword")
	player.off = preload("res://Production/Actors/items.gd").make("sword")
	check(Sim.validate_snapshot(world.snapshot()).is_empty(),"inactive Show-Off keeps carried offhand and save valid")
	player.erase("skill_board")
	check(Sim.validate_snapshot(world.snapshot()).is_empty(),"legacy learned skills with gear and no board remain loadable")
	# Restore visual layout, preserving the independent test save.
	player.skill_board = original
	game._refresh()
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Skill Board/board.png")
	print("Skill Board integration: %d checks, %d failures" % [checks,failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
