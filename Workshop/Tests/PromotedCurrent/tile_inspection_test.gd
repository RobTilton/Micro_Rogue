extends SceneTree
const Items = preload("res://Production/Current/gameplay/items.gd")
const Inspection = preload("res://Production/Current/domain/item_inspection.gd")
const Grid = preload("res://Production/Current/domain/grid_inventory.gd")
var checks: int = 0
var failures: int = 0
func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("res://Production/Current/tests/tile_inspection_test.gd: " + description)
func _initialize() -> void:
	call_deferred("run")
func texts(node: Node) -> String:
	var result: String = ""
	if node is Label or node is Button: result += node.text + "\n"
	for child: Node in node.get_children(): result += texts(child)
	return result
func run() -> void:
	root.size = Vector2i(1440,900)
	var sword: Dictionary = Items.make("sword")
	sword.visible_traits = ["Glowing faintly."]
	var far: Dictionary = Inspection.describe(sword,false)
	check(far.title == "Bronze Sword", "Far title reveals material and type, not rarity")
	check(far.details == "Glowing faintly.", "Explicit visible trait is shown")
	check(not far.has("die") and not far.has("rarity") and not far.has("bonus"), "Far snapshot omits hidden fields")
	check(Inspection.describe(sword,true).details.contains("1d4"), "Near weapon stats disclosed")
	var belt: Dictionary = Items.make("belt")
	check(Inspection.describe(belt,false).details.is_empty(), "Far belt hides capacity and contents")
	check(Inspection.describe(belt,true).details.contains("Capacity:"), "Near belt reveals capacity")
	check(Inspection.describe(Items.potion(),false).title == "Glass potion bottle", "Far potion does not reveal effect")
	var game: Control = load("res://Production/Current/ui/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,3,4,2,1,5,6]
	game._start_run()
	# These UI regressions retain their original open-arena fixture.
	game.active_map = null
	game._spawn_enemy()
	game.enemy.pos = Vector2i(6,6)
	var tile: Vector2i = Vector2i(4,3)
	game.loot = [{"item":sword,"pos":tile},{"item":belt,"pos":tile}]
	game._refresh()
	var original: Dictionary = game.actions.duplicate(true)
	var original_position: Vector2i = game.player.pos
	game._board_intent(tile,false)
	game._open_loot_tile(tile)
	check(game.host.panel_name == "Look", "Click distant loot opens Look")
	check(game.preview_path.is_empty() and game.player.pos == original_position and game.actions == original, "Looking never moves or spends actions")
	var content: String = texts(game.host.content)
	check(content.contains("Bronze Sword") and content.contains("Glowing faintly."), "Distant panel renders visible properties")
	check(not content.contains(sword.name) and not content.contains("1d4") and not content.contains("Capacity:") and not content.contains("Take\n"), "Distant UI hides rarity, stats, capacity and pickup controls")
	game._transfer({"zone":"ground","id":sword.item_id},{"zone":"pickup"})
	check(game.loot.size() == 2 and game.actions == original, "Remote pickup is refused at action boundary")
	game.player.pos = Vector2i(3,3)
	game.actions.move = 0
	game._board_intent(tile,false)
	game._open_loot_tile(tile)
	content = texts(game.host.content)
	check(content.contains("1d4") and content.contains("Capacity:") and content.contains("Take\n"), "Adjacent UI shows full item stats and Take even without movement action")
	var count: int = game.loot.size()
	game._transfer({"zone":"ground","id":sword.item_id},{"zone":"pickup"})
	check(game.loot.size() == count-1 and game.player.bag.size() == 1 and game.actions.activation == 0, "Taking one item transfers it and spends activation")
	game._transfer({"zone":"ground","id":belt.item_id},{"zone":"pickup"})
	check(game.loot.is_empty() and game.actions.attack == 0, "Next item spends attack before movement")
	game._refresh()
	check(texts(game.host.content).contains("Nothing remains"), "Empty tile panel reports completion")
	game.player.pos = tile
	var potion: Dictionary = Items.potion()
	game.loot.append({"item":potion,"pos":tile})
	game._board_intent(tile,false)
	game._open_loot_tile(tile)
	check(texts(game.host.content).contains("Restores CON"), "Same-tile inspection is within reach")
	game._transfer({"zone":"ground","id":potion.item_id},{"zone":"pickup"})
	check(game.loot.size() == 1, "No actions means no free pickup")
	game.battle = false
	game._transfer({"zone":"ground","id":potion.item_id},{"zone":"pickup"})
	check(game.loot.is_empty() and Grid.valid(game.player,game.loot), "Outside-combat pickup remains free and valid")
	game.player.pos = original_position
	game.actions.move = 1
	game.loot = [{"item":Items.make("armor"),"pos":tile}]
	game._command("Cancel")
	game.host.close()
	game._board_intent(tile,true)
	check(game.player.pos == tile and game.host.panel_name.is_empty(), "Shift-click retains immediate movement onto loot")
	game.player.pos = original_position
	game.mode = "attack"
	game._board_intent(tile,false)
	check(game.host.panel_name.is_empty(), "Active targeting takes precedence over tile inspection")
	game.mode = "move"
	game._board_intent(Vector2i(2,3),false)
	check(not game.preview_path.is_empty(), "Empty tile still previews movement")
	game._board_intent(tile,false)
	game._open_loot_tile(tile)
	check(game.preview_path.is_empty(), "Opening Look cancels pending movement")
	game.player.pos = original_position
	game._refresh()
	check(not texts(game.host.content).contains("Equipment Defense"), "Range is recalculated whenever panel refreshes")
	game.queue_free()
	await process_frame
	print("res://Production/Current/tests/tile_inspection_test.gd: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
