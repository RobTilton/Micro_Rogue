extends SceneTree
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Living Adventurers/playtest_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(120).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	game.autosave_directory = "res://Workshop/Rooms/Living Adventurers/Tests/identity_ui/autosaves/"
	game.snapshot_directory = "res://Workshop/Rooms/Living Adventurers/Tests/identity_ui/snapshots/"
	game.preferences_path = "res://Workshop/Rooms/Living Adventurers/Tests/identity_ui/preferences.cfg"
	root.add_child(game)
	await game._new_character()
	check(game.rerolls_remaining == 2,"two extra rolls initially")
	game.character_name = "Test Adventurer"
	game._reroll_creation()
	game._reroll_creation()
	var final_roll = game.dice_slots.duplicate()
	game._reroll_creation()
	check(game.rerolls_remaining == 0 and game.dice_slots == final_roll,"third reroll refused")
	check(game.simulation.creation.name == "Test Adventurer" and game.simulation.creation.rerolls_remaining == 0,"creation identity and allowance persisted")
	game._load_path(game.journal.path)
	check(game.rerolls_remaining == 0 and game.character_name == "Test Adventurer","load retains spent rolls and name")
	game.dice_slots = [0,0,0,0,0,0,3,3,3,3,3,3]
	game._start_run()
	check(game.player.name == "Test Adventurer","name applied to actor")
	game.set_process(false)
	game.board.set_process(false)
	check(game.simulation.get_script() == load("res://Production/Persistence/adventurer_world.gd"),"F5 uses Workshop world")
	check(game.player.pos != Vector2i(-1,-1),"player has valid town arrival")
	check(game.simulation.residents(game.simulation.region_of(game.player)).size() == 3,"F5 town contains adventurers")
	var world_id: String = game.simulation.maps.world_id
	var old_id: int = game.player.id
	game._toggle_panel("Character")
	await process_frame
	var retirement_button: bool = false
	for button: Node in game.find_children("*","Button",true,false):
		if button.text == "Retire in this town…": retirement_button = true
	check(retirement_button,"Character panel exposes retirement")
	for frame: int in range(3):
		await process_frame
		game.board._process(0.0)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Living Adventurers/retirement.png")
	game._retire()
	check(game.rerolls_remaining == 2 and game.character_name.is_empty(),"fresh retirement successor gets two rolls and a new name")
	await process_frame
	check(game.prepared_world != null and game.simulation.actors[old_id].retired,"retirement opens next character setup in same world")
	check(game.simulation.maps.world_id == world_id,"retirement does not regenerate geography")
	check(game._automatic_checkpoint(),"pending new character saves")
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	game.set_process(false)
	game.board.set_process(false)
	check(game.player.id != old_id and game.simulation.actors[old_id].hp > 0,"former player survives as NPC")
	check(game.simulation.maps.world_id == world_id,"new character inherits same world")
	game._toggle_panel("Options")
	await process_frame
	for frame: int in range(3):
		await process_frame
		game.board._process(0.0)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Living Adventurers/roster.png")
	var path: String = game.journal.path
	check(game._load_path(path),"Workshop autosave reloads through F5 UI")
	check(game.simulation.actors[old_id].retired,"retiree remains after reload")
	game.queue_free()
	await process_frame
	print("Living Adventurers UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
