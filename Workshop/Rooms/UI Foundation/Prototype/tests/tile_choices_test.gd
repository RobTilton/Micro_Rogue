extends SceneTree
const Items = preload("res://Workshop/Rooms/UI Foundation/Prototype/gameplay/items.gd")
var checks: int = 0
func check(value: bool, description: String) -> void:
	checks += 1
	assert(value,"Prototype/tests/tile_choices_test.gd: "+description)
func button(node: Node, title: String) -> Button:
	if node is Button and node.text == title: return node
	for child: Node in node.get_children():
		var found: Button = button(child,title)
		if found != null: return found
	return null
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://Workshop/Rooms/UI Foundation/Prototype/ui/main.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,4,4,4,4,4,4]
	game._start_run()
	game._enter_map()
	var cell := Vector2i(4,2)
	game.loot.append({"item":Items.potion(),"pos":cell})
	game._board_intent(cell,false)
	check(game.host.panel_name == "Tile","loot entrance opens choices")
	check(button(game.host.content,"Loot").disabled,"remote loot unavailable")
	button(game.host.content,"Look").pressed.emit()
	check(game.host.panel_name == "Look" and button(game.host.content,"Take") == null,"look does not take")
	game._board_intent(cell,false)
	button(game.host.content,"Move").pressed.emit()
	check(game.player.pos != cell and not game.preview_path.is_empty(),"move still confirms")
	game._confirm_move()
	check(game.player.pos == cell,"confirmed move reaches occupied entrance")
	game._board_intent(cell,false)
	check(not button(game.host.content,"Loot").disabled,"nearby loot available")
	check(button(game.host.content,"Dungeon") != null,"entrance available under loot")
	button(game.host.content,"Loot").pressed.emit()
	check(button(game.host.content,"Take") != null,"loot opens pickup")
	game._board_intent(cell,false)
	button(game.host.content,"Dungeon").pressed.emit()
	check(game.active_map.title == "Dungeon","entrance can be used")
	game._enter_map()
	check(game.loot.size() == 1,"travel leaves item intact")
	game.player.pos = Vector2i(1,3)
	game._board_intent(cell,true)
	check(game.player.pos == cell,"shift bypass preserved")
	print("Prototype/tests/tile_choices_test.gd: %d checks passed" % checks)
	quit()
