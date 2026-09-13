extends SceneTree
const Game = preload("res://Production/UI/game_ui.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Items = preload("res://Production/Actors/items.gd")
const Combat = preload("res://Production/Actors/combat.gd")
var checks: int = 0
var failures: int = 0
func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("res://Workshop/Rooms/Production Promotion/tests/ui_foundation_test.gd: " + description)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1440,900)
	seed(517)
	var actor: Dictionary = Actors.create([3,4,2,1,5,6])
	var ground: Array = []
	var actions: Dictionary = Combat.allowance(actor)
	check(Grid.valid(actor,ground),"Generated inventory valid")
	for kind: String in ["potion","belt","armor","sword","shield"]:
		var expected: Vector2i = {"potion":Vector2i(1,1),"belt":Vector2i(2,1),"armor":Vector2i(2,2),"sword":Vector2i(1,2),"shield":Vector2i(2,2)}[kind]
		check(Grid.footprint({"kind":kind}) == expected,"Footprint " + kind)
	var sword: Dictionary = Items.make("sword")
	check(Grid.place(actor.bag,sword,Vector2i(7,3),false),"Vertical sword at right edge")
	var before: Dictionary = actor.duplicate(true)
	var before_actions: Dictionary = actions.duplicate(true)
	var result: Dictionary = Grid.transfer(actor,ground,actions,true,{"zone":"bag","id":sword.item_id},{"zone":"bag","cell":Vector2i(7,3),"rotated":true})
	check(not result.ok and actor == before and actions == before_actions,"Out-of-bounds rotation refuses atomically")
	result = Grid.transfer(actor,ground,actions,true,{"zone":"bag","id":sword.item_id},{"zone":"bag","cell":Vector2i(6,3),"rotated":true})
	check(result.ok and actor.bag[0].rotated and actions == before_actions,"Valid rotation/rearrangement costs no activation")
	var potion: Dictionary = Items.potion()
	check(not Grid.place(actor.bag,potion,Vector2i(6,3),false),"Occupied cell refuses")
	actor.bag.clear()
	for y: int in range(5):
		for x: int in range(8): check(Grid.place(actor.bag,Items.potion(),Vector2i(x,y),false),"Fill one independent potion per cell")
	check(actor.bag.size() == 40 and Grid.valid(actor,ground),"No stacking, 40 cells")
	var armor: Dictionary = Items.make("armor")
	ground = [{"item":armor,"pos":actor.pos}]
	before = actor.duplicate(true)
	var before_ground: Array = ground.duplicate(true)
	result = Grid.transfer(actor,ground,actions,true,{"zone":"ground","id":armor.item_id},{"zone":"pickup"})
	check(not result.ok and actor == before and ground == before_ground and actions == before_actions,"Full backpack pickup preserves loot and actions")
	actor.bag.clear()
	sword = Items.make("sword")
	Grid.place(actor.bag,sword,Vector2i.ZERO,false)
	for y: int in range(5):
		for x: int in range(8):
			if x == 0 and y < 2: continue
			Grid.place(actor.bag,Items.potion(),Vector2i(x,y),false)
	actor.skills = ["Lunge","Riposte","Show-Off"]
	before = actor.duplicate(true)
	result = Grid.transfer(actor,ground,actions,true,{"zone":"bag","id":sword.item_id},{"zone":"equipment","slot":"off"})
	check(not result.ok and actor == before and actions == before_actions,"Shield cannot fit displaced into narrow sword hole; swap refused")
	actor.bag.clear()
	Grid.place(actor.bag,sword,Vector2i.ZERO,false)
	var shield_id: int = actor.off.item_id
	result = Grid.transfer(actor,ground,actions,true,{"zone":"bag","id":sword.item_id},{"zone":"equipment","slot":"off"})
	check(result.ok and actor.off.item_id == sword.item_id and actor.bag[0].item_id == shield_id and actions.activation == 0,"Successful swap stores displaced shield and spends activation")
	var belt: Dictionary = Items.make("belt")
	belt.contents = []
	potion = Items.potion()
	potion.pouch = 0
	belt.contents.append(potion)
	actor.bag.clear()
	Grid.place(actor.bag,belt,Vector2i.ZERO,false)
	actions.activation = 1
	result = Grid.transfer(actor,ground,actions,true,{"zone":"belt","belt_id":belt.item_id,"id":potion.item_id},{"zone":"bag"})
	check(result.ok and actor.bag.size() == 2 and actions.activation == 0,"Remove backpack belt potion into grid")
	actions.activation = 1
	result = Grid.transfer(actor,ground,actions,true,{"zone":"bag","id":potion.item_id},{"zone":"belt","belt_id":belt.item_id,"pouch":2})
	check(result.ok and actor.bag[0].contents[0].pouch == 2,"Place into exact belt pouch")
	actions.activation = 1
	result = Grid.transfer(actor,ground,actions,true,{"zone":"bag","id":belt.item_id},{"zone":"equipment","slot":"belt"})
	check(result.ok and actor.belt.item_id == belt.item_id and actor.belt.contents[0].item_id == potion.item_id,"Stocked belt equip preserves contents")
	var dropped: Dictionary = actor.belt
	actions.activation = 1
	result = Grid.transfer(actor,ground,actions,true,{"zone":"equipment","slot":"belt","id":dropped.item_id},{"zone":"ground"})
	check(result.ok and actor.belt.is_empty() and ground.back().item.contents[0].item_id == potion.item_id,"Drop belt preserves nested ownership")
	check(Grid.valid(actor,ground),"Final ownership and placement valid")
	var game: Control = load("res://Workshop/Rooms/Production Promotion/tests/ui_fixture.tscn").instantiate()
	root.add_child(game)
	game.dice_slots = [0,0,0,0,0,0,3,4,2,1,5,6]
	game._start_run()
	# These UI regressions retain their original open-arena fixture.
	game.active_map = null
	game._spawn_enemy()
	await process_frame
	await process_frame
	check(game.frame_ready and game.rail.entries.size() == 5,"Wireframe created with rail entries")
	var start: Vector2i = game.player.pos
	game._board_intent(Vector2i(2,3),false)
	check(game.player.pos == start and game.actions.move == 1 and game.preview_path.size() == 1,"Click previews without spending action")
	game._confirm_move()
	check(game.player.pos == Vector2i(2,3) and game.actions.move == 0,"Confirmation commits movement once")
	game.actions.move = 1
	game._board_intent(Vector2i(3,3),true)
	check(game.player.pos == Vector2i(3,3) and game.preview_path.is_empty(),"Shift bypass")
	game.actions.move = 1
	game._board_intent(Vector2i(4,3),false)
	game.enemy.pos = Vector2i(4,3)
	game._confirm_move()
	check(game.player.pos == Vector2i(3,3) and game.actions.move == 1,"Stale movement preview refuses")
	game.enemy.pos = Vector2i(5,3)
	game.confirm_movement = false
	game._board_intent(Vector2i(4,3),false)
	check(game.player.pos == Vector2i(4,3),"Options can disable confirmation")
	for panel: String in ["Character","Inventory","Skills","Logs","Options","Activate"]:
		game._toggle_panel(panel,180)
		await process_frame
		check(game.host.panel_name == panel and game.host.panel.visible,"Open panel " + panel)
	game._toggle_panel("Activate",180)
	check(game.host.panel_name.is_empty(),"Same panel toggles closed")
	game._toggle_panel("Inventory",180)
	game.drag.payload = {"item":Items.potion(),"source":{},"rotated":false}
	game.drag.changed.emit()
	check(game.hud.belt_section.visible,"Potion drag reveals belt tray without closing inventory")
	game.drag.finish()
	game._refresh()
	game.player.skills = ["Lunge","Riposte","Show-Off"]
	game.player.off = Items.make("sword")
	game.actions = Combat.allowance(game.player)
	game.enemy.pos = Vector2i(6,3)
	game.enemy.hp = 1000
	game.enemy.max_hp = 1000
	game._command("Lunge")
	game._board_intent(Vector2i(5,3),false)
	check(game.player.pos == Vector2i(5,3) and game.cooldowns.ticks("Lunge") == 4,"Lunge movement still works")
	game._board_intent(game.enemy.pos,false)
	check(game.pending_weapon.is_empty(),"Optional Lunge attack resolves")
	game._command("Riposte")
	check(game.player.riposte and game.cooldowns.ticks("Riposte") == 2,"Riposte works through HUD")
	game.enemy.main.bonus = -100
	game._command("End Turn")
	check(game.cooldowns.ticks("Lunge") == 3 and game.cooldowns.ticks("Riposte") == 1,"End turn and cooldown mechanics preserved")
	game.enemy.hp = 0
	game._check_death()
	game._refresh()
	check(game.loot.size() == 4 and Grid.valid(game.player,game.loot),"Enemy drops valid actual items")
	game.player.pos = game.enemy.pos
	var loot_id: int = game.loot[0].item.item_id
	game._transfer({"zone":"ground","id":loot_id},{"zone":"pickup"})
	check(game.player.bag.size() == 1 and game.loot.size() == 3,"Context pickup places item in grid")
	game._refresh()
	game.queue_free()
	await process_frame
	print("res://Workshop/Rooms/Production Promotion/tests/ui_foundation_test.gd: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
