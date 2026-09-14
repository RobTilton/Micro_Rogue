extends SceneTree
const Inspection = preload("res://Production/Actors/item_inspection.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Item Presentation/tests/presentation_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(90).timeout.connect(func(): quit(2))
	var game = load("res://Production/main.tscn").instantiate()
	var directory: String = "res://Workshop/Rooms/Item Presentation/tests/saves/"
	game.autosave_directory = directory+"autosaves/"
	game.snapshot_directory = directory+"snapshots/"
	game.preferences_path = directory+"preferences.cfg"
	root.add_child(game)
	await game._new_character()
	game.dice_slots = [0,0,0,0,0,0,6,6,6,6,6,6]
	game._start_run()
	var world = game.simulation
	var player: Dictionary = game.player
	var rng := RandomNumberGenerator.new()
	rng.seed = 731
	for category: String in ["staffs","leather_body","leather_head","leather_arms","leather_legs","belts"]:
		var item: Dictionary = world.Items.generate({"category":category,"max_material_tier":2},rng).item
		var slot: String = "main" if category == "staffs" else "belt" if category == "belts" else "armor" if category == "leather_body" else item.slot
		player[slot] = item
	player.grip = "two"
	var potion: Dictionary = world.Items.potion()
	potion.pouch = 0
	player.belt.contents.append(potion)
	var carried: Dictionary = world.Items.make("sword",false,rng)
	world.Grid.place_auto(player.bag,carried)
	var ground_item: Dictionary = world.Items.make("sword",false,rng)
	world.ground[player.map_id].append({"item":ground_item,"pos":player.pos})
	game._sync()
	game._arena_ui()
	game._toggle_panel("Inventory",180)
	await process_frame
	await process_frame
	check(game.current_grid._get_tooltip(Vector2(carried.grid_pos)*52+Vector2(10,10)).contains("damage:"),"backpack hover exposes stats")
	check(game.board.item_tooltips[player.pos].contains("damage:"),"nearby ground hover exposes stats")
	check(not Inspection.tooltip(ground_item,false).contains("damage:"),"distant items conceal exact stats")
	var panel_style = game.root.theme.get_stylebox("panel","TooltipPanel")
	check(panel_style.bg_color.a == 1.0 and panel_style.bg_color.v < 0.1,"tooltip background is opaque dark")
	var targets: Array = []
	collect(game.host.content,targets)
	var equipment: int = 0
	var pouches: int = 0
	for target in targets:
		if target.target.get("zone") == "equipment":
			equipment += 1
			if not target.item.is_empty(): check(target.tooltip_text == Inspection.tooltip(target.item),"equipment hover uses inspection")
		if target.target.get("zone") == "belt": pouches += 1
	check(equipment == 7 and pouches == player.belt.capacity,"all gear slots and equipped pouches are drag targets")
	var source: Dictionary = {"zone":"bag","id":carried.item_id}
	check(world.transfer(player,source,{"zone":"equipment","slot":"main"}).ok,"paper doll retains shared equip path")
	game._refresh()
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://Workshop/Rooms/Item Presentation/tests/paper_doll.png")
	game.queue_free()
	await process_frame
	print("Item Presentation: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
func collect(node: Node, targets: Array) -> void:
	if node is preload("res://Production/UI/item_target.gd"): targets.append(node)
	for child in node.get_children(): collect(child,targets)
