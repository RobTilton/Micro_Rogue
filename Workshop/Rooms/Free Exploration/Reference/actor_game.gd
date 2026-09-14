extends "res://Production/UI/game_ui.gd"
const Simulation = preload("res://Production/Actors/actor_world.gd")
const Brain = preload("res://Production/Actors/enemy_brain.gd")
const ActorView = preload("res://Production/UI/actor_view.gd")
var simulation: RefCounted
var brain: RefCounted = Brain.new()
var selected_actor_id: int = -1
var selected_shop_cell: Vector2i = Vector2i(-1,-1)

func _make_board() -> Control:
	return ActorView.new()

func _make_simulation(seed_value: int) -> RefCounted:
	return Simulation.new(seed_value)

func _start_run() -> void:
	simulation = _make_simulation(randi_range(1,2147480000))
	simulation.difficulty = difficulty
	map_world = simulation.maps
	player = Actors.create(dice_slots.slice(6,12))
	for slot: String in Grid.EQUIPMENT: player[slot] = {}
	player.bag = []
	player.gold = 100
	simulation.add_actor(player,"global",map_world.maps.global.spawn_cell,"player","player")
	simulation.advance_to_player(brain)
	cooldowns = player.clock
	messages.clear()
	mode = "move"
	selected_actor_id = -1
	_sync()
	_note("Explore regions and POIs. Enemies can collect equipment and follow an observed exit. End Turn also waits outside combat.")
	_arena_ui()

func _sync() -> void:
	if simulation == null: return
	active_map = map_world.maps[player.map_id]
	loot = simulation.ground[player.map_id]
	actions = player.actions
	pending_weapon = player.pending
	retreat_available = player.retreat
	battle = simulation.engaged(player)
	enemy = {"pos":Vector2i(-1,-1),"hp":0}
	for candidate: Dictionary in simulation.hostiles(player):
		if enemy.hp <= 0 or candidate.id == selected_actor_id: enemy = candidate
	if enemy.hp > 0: selected_actor_id = enemy.id
	else: selected_actor_id = -1

func _refresh() -> void:
	if simulation == null: return
	if frame_ready and board.map_data.id != player.map_id:
		_sync()
		_arena_ui()
		return
	_sync()
	super._refresh()
	if not frame_ready or not drag.payload.is_empty(): return
	var visible_actors: Array[Dictionary] = [player]
	for actor: Dictionary in simulation.on_map(player.map_id):
		if actor.id != player.id and simulation.can_see(player,actor.pos): visible_actors.append(actor)
	board.trade_route = map_world.records.global.constraints.get("starter_route",[]) if active_map.layer == "Global" else []
	board.route_labels = {}
	if board.trade_route.size() >= 2:
		var towns: Array = map_world.records.global.constraints.get("route_towns",[])
		if towns.size() == 2:
			board.route_labels[board.trade_route.front()] = map_world.records[towns[0]].label
			board.route_labels[board.trade_route.back()] = map_world.records[towns[1]].label
	board.show_actors(visible_actors,selected_actor_id)
	for event: Dictionary in simulation.motion_events:
		if event.map_id != player.map_id: continue
		var visible: bool = simulation.can_see(player,event.from)
		for cell: Vector2i in event.route:
			if not simulation.can_see(player,cell): visible = false
		if visible: board.animate_motion(event)
	simulation.motion_events.clear()
	if is_instance_valid(minimap):
		minimap.trade_route = board.trade_route
		minimap.update_map(active_map,player.pos,visible_actors)
	board.visible_props = []
	for cell: Vector2i in active_map.props:
		if simulation.can_see(player,cell): board.visible_props.append(cell)
	board.loot_cells = []
	for entry: Dictionary in loot:
		if simulation.can_see(player,entry.pos) and entry.pos not in board.loot_cells: board.loot_cells.append(entry.pos)
	if mode == "lunge": board.highlights = simulation.paths(player,player.stats.DEX).keys() if _skill_available("Lunge") else []
	board.queue_redraw()
	hud.gold.text = "Gold\n"+str(player.get("gold",0))
	hud.state.text += "\n"+preload("res://Production/World/world_clock.gd").label(simulation.world_hours)
	hud.buttons["End Turn"].disabled = player.hp <= 0
	hud.buttons["End Turn"].text = "End Turn" if battle and Combat.remaining(player.actions) > 0 else "Wait"
	hud.state.tooltip_text = "World threshold %d. DEX + effects = %.2f speed. Momentum carries over; each extra grant adds one free action." % [simulation.turn_threshold,simulation.Momentum.speed(player)]
	hud.state.text += "\nMomentum %.2f / %d · Speed %.2f" % [player.get("momentum",0.0),simulation.turn_threshold,simulation.Momentum.speed(player)]
	preview_label.text = "Move to %s · %d hexes · %s" % [preview_destination,preview_path.size(),"1 movement action" if battle else "advances one world turn"]

func _process(_delta: float) -> void:
	# Actor Foundation uses world turns, including pursuit outside combat.
	pass

func _flush_events() -> void:
	for message: String in simulation.events: _note(message)
	simulation.events.clear()

func _finish(result: Dictionary, advance_outside: bool = true) -> void:
	_note(result.reason)
	if result.ok and advance_outside and not battle and Combat.available(player.actions,"move") == 0:
		simulation.advance_to_player(brain)
	if player.retreat: mode = "retreat"
	_flush_events()
	_refresh()

func _end_turn() -> void:
	if simulation == null or player.hp <= 0: return
	simulation.cancel(player)
	_cancel_preview(false)
	simulation.advance_to_player(brain)
	mode = "retreat" if player.retreat else "move"
	_flush_events()
	_refresh()

func _blocked() -> Array:
	return simulation.blocked(player) if simulation != null else []

func _movement_paths() -> Dictionary:
	return simulation.paths(player) if simulation != null else {}

func _confirm_move() -> void:
	if mode != "move" or preview_path.is_empty(): _cancel_preview(); return
	var outcome: Dictionary = simulation.move(player,preview_destination,preview_path)
	_cancel_preview(false)
	_finish(outcome)

func _board_intent(cell: Vector2i, bypass: bool) -> void:
	if cell == player.pos: return
	if player.hp <= 0: return
	if mode == "move" and player.pending.is_empty() and active_map.shops.has(cell):
		_open_shop(cell)
		return
	var target: Dictionary = simulation.actor_at(player.map_id,cell,player.id)
	if not target.is_empty() and simulation.can_see(player,cell): selected_actor_id = target.id
	if not player.pending.is_empty() or mode == "attack":
		if not target.is_empty(): _finish(simulation.attack(player,target.id),false)
		mode = "move" if player.pending.is_empty() else "lunge: optional attack"
		_refresh()
		return
	if mode == "lunge":
		_finish(simulation.lunge(player,cell),false)
		if not player.pending.is_empty(): mode = "lunge: optional attack"
		_refresh()
		return
	if mode == "retreat":
		_finish(simulation.retreat(player,cell),false)
		if not player.retreat: mode = "move"
		_refresh()
		return
	if not target.is_empty():
		_refresh()
		return
	if not bypass and simulation.can_see(player,cell):
		for entry: Dictionary in loot:
			if entry.pos == cell: _open_tile_choices(cell); return
	_request_movement(cell,bypass)

func _command(name: String) -> void:
	if simulation == null: return
	if name == "Cancel": simulation.cancel(player)
	super._command(name)

func _skill_available(skill: String) -> bool:
	return simulation != null and simulation.skill_available(player,skill)

func _next_weapon() -> Dictionary:
	return simulation.next_weapon(player) if simulation != null else {}

func _riposte() -> void:
	_finish(simulation.riposte(player),false)

func _drink_potion(item_id: int) -> void:
	_finish(simulation.drink(player,item_id))

func _can_transfer(source: Dictionary, target: Dictionary) -> bool:
	return simulation.transfer(player,source,target,true).ok

func _transfer(source: Dictionary, target: Dictionary) -> void:
	var rearrange: bool = source.get("zone") == "bag" and target.get("zone") == "bag"
	_finish(simulation.transfer(player,source,target),not rearrange)

func _inventory_allowed() -> bool:
	return simulation != null and simulation.ready(player) and Combat.available(player.actions,"activation") > 0

func _enter_map() -> void:
	var outcome: Dictionary = simulation.interact(player,{"kind":"entrance"})
	if not outcome.ok: _finish(outcome,false); return
	mode = "move"
	_cancel_preview(false)
	# Travel spends the existing budget; it cannot refill momentum/free actions.
	if Combat.remaining(player.actions) == 0: simulation.advance_to_player(brain)
	_flush_events()
	_sync()
	_arena_ui()

func _save_map() -> void:
	pass # Actor registry and map ground are already authoritative persistent state.

func _check_death() -> void:
	if simulation == null: return
	for actor: Dictionary in simulation.actors.values():
		if actor.id != player.id: simulation.resolve_death(actor,player)
	_refresh()

func _spawn_enemy() -> void:
	if simulation == null or active_map.layer != "POI": return
	var cell: Vector2i = simulation.arrival_cell(active_map,Vector2i(6,3))
	if cell == Vector2i(-1,-1): _note("No space for another test enemy."); return
	simulation.add_actor(Actors.create(Actors.dice(),true),active_map.id,cell,"enemy")
	_refresh()

func _skills_panel(parent: Node) -> void:
	Parts.label(parent,"Spend a point: +1 stat",20)
	for stat: String in Actors.STATS:
		Parts.button(parent,"+1 "+stat,_raise_stat.bind(stat),player.points > 0 and player.hp > 0)
	Parts.label(parent,"Sword Mastery · points %d" % player.points,20)
	for skill: String in ["Lunge","Riposte","Show-Off"]:
		var previous: String = "" if skill == "Lunge" else "Lunge" if skill == "Riposte" else "Riposte"
		Parts.button(parent,("✓ " if skill in player.skills else "Learn · ")+skill,func(): _finish(simulation.learn(player,skill),false),player.hp > 0 and player.points > 0 and skill not in player.skills and (previous.is_empty() or previous in player.skills))
	_wrap(parent,"Lunge: DEX path, optional attack +1.5 STR; 4 turns. Riposte: defense and counter, optional retreat; 2 turns. Show-Off: two sword attacks. These rules also apply to enemies.",450)

func _map_transition_button(parent: Node) -> void:
	if active_map != null and active_map.links.has(player.pos):
		Parts.button(parent,active_map.links[player.pos].label,_enter_map,player.hp > 0)
		_wrap(parent,"Travel costs activation and advances a turn. Enemies that see you leave may follow.")

func _look_panel(parent: Node) -> void:
	if not simulation.can_see(player,inspected_cell):
		Parts.label(parent,"That location is out of sight.")
		return
	super._look_panel(parent)

func _activate_panel(parent: Node) -> void:
	_map_transition_button(parent)
	for crossing: Dictionary in simulation.border_options(player):
		Parts.button(parent,"Cross "+["east","northeast","northwest","west","southwest","southeast"][crossing.side]+" · 6 hours",_cross_border.bind(crossing.side))
	for npc: Dictionary in simulation.on_map(player.map_id):
		if npc.get("role","") != "crier" or active_map.distance(player.pos,npc.pos) > 1 or not simulation.can_see(player,npc.pos): continue
		Parts.label(parent,"Town Crier · Local bounties",20)
		for quest: Dictionary in simulation.town_quests(player).values():
			_wrap(parent,quest.title,360)
			_quest_direction(parent,quest.target)
			if quest.get("tutorial",false): _wrap(parent,quest.get("effects","Follow the gold trade route. Remove its hostile boss to reduce pressure and improve both towns prosperity."),360)
			var text: String = "Accept bounty" if quest.status == "available" else "Check bounty" if quest.status == "accepted" else "Claim reward" if quest.status == "claim reward" else "Reward claimed"
			Parts.button(parent,text+" · "+_quest_reward_text(quest),_crier_quest.bind(quest.target),quest.status != "rewarded")
	for cell: Vector2i in active_map.shops:
		if simulation.inspect_shop(player,cell).ok:
			Parts.button(parent,active_map.shops[cell].name,_open_shop.bind(cell))
	for cell: Vector2i in active_map.props:
		var prop: Dictionary = active_map.props[cell]
		if prop.kind in ["rug","rubble"] or active_map.distance(player.pos,cell) > 1 or not simulation.can_see(player,cell): continue
		if prop.opened: Parts.label(parent,prop.name+" · searched")
		else: Parts.button(parent,"Search "+prop.name,_search_prop.bind(cell))
	Parts.label(parent,"Equipped belt",20)
	for potion: Dictionary in player.belt.get("contents",[]):
		Parts.button(parent,"Use Lesser Health",_drink_potion.bind(potion.item_id),_inventory_allowed())
	Parts.button(parent,"Backpack",func(): _toggle_panel("Inventory",200))
	Parts.label(parent,"Nearby visible items",20)
	for entry: Dictionary in loot:
		if active_map.distance(player.pos,entry.pos) <= 1 and simulation.can_see(player,entry.pos):
			Parts.button(parent,"Take "+entry.item.name,func(): _transfer({"zone":"ground","id":entry.item.item_id},{"zone":"pickup"}))

func _inventory_panel(parent: Node) -> void:
	if player.main.get("hands","") == "versatile":
		Parts.button(parent,"Grip: "+player.get("grip","one")+" hand(s) · Change",func(): _finish(simulation.change_grip(player),false),player.off.is_empty() and Combat.available(player.actions,"activation") > 0)
	super._inventory_panel(parent)

func _open_shop(cell: Vector2i) -> void:
	var result: Dictionary = simulation.inspect_shop(player,cell)
	if not result.ok:
		_note("Move next to the shop first.")
		_refresh()
		return
	selected_shop_cell = cell
	_cancel_preview()
	_toggle_panel("Shop",200)

func _shop_panel(parent: Node) -> void:
	var result: Dictionary = simulation.inspect_shop(player,selected_shop_cell)
	if not result.ok:
		Parts.label(parent,"Approach a shop to interact.")
		return
	var shop: Dictionary = result.shop
	Parts.label(parent,shop.name,22)
	if shop.closed:
		_wrap(parent,"Closed.")
	elif shop.id == "inn":
		Parts.button(parent,"Rest · 1 gold · 1 block (6 hours)",_rest_inn,player.get("gold",0) >= 1)
		_wrap(parent,"Recover up to "+str(2*player.stats.CON)+" HP. No ration required.")
	else:
		Parts.label(parent,"Gold: "+str(player.get("gold",0))+" · Prosperity: "+str(shop.get("prosperity",0)))
		for entry: Dictionary in shop.get("stock",[]):
			Parts.button(parent,entry.item.name+" · "+str(entry.price)+" gold",_buy_item.bind(entry.item.item_id),player.get("gold",0) >= entry.price)
		if shop.get("stock",[]).is_empty(): Parts.label(parent,"No stock available.")

func _search_prop(cell: Vector2i) -> void:
	_finish(simulation.interact(player,{"kind":"search","cell":cell}),false)

func _rest_inn() -> void:
	_finish(simulation.rest_at_inn(player,selected_shop_cell),false)

func _buy_item(item_id: int) -> void:
	_finish(simulation.buy(player,selected_shop_cell,item_id),false)

func _crier_quest(target_id: String) -> void:
	_finish(simulation.quest_action(player,target_id),false)

var context_popup: PopupMenu
var context_actions: Array[Callable] = []
var minimap: Control
func _arena_ui() -> void:
	super._arena_ui()
	board.context_requested.connect(_show_context)
	board.double_clicked.connect(_double_hex)
	context_popup = PopupMenu.new()
	board.add_child(context_popup)
	context_popup.id_pressed.connect(func(id: int):
		if id >= 0 and id < context_actions.size(): context_actions[id].call())
	host.z_index = 20
	minimap = preload("res://Production/UI/mini_map.gd").new()
	minimap.z_index = 10
	board.add_child(minimap)
	minimap.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_left = -202
	minimap.offset_right = -12
	minimap.offset_top = 12
	minimap.offset_bottom = 162
	minimap.cell_selected.connect(board.focus_cell)
	_refresh()

func _double_hex(cell: Vector2i) -> void:
	if cell == player.pos and active_map.links.has(cell): _enter_map()

func _context_action(text: String, action: Callable) -> void:
	context_popup.add_item(text,context_actions.size())
	context_actions.append(action)

func _show_context(cell: Vector2i) -> void:
	if not frame_ready or player.hp <= 0 or not drag.payload.is_empty(): return
	context_popup.clear()
	context_actions.clear()
	_context_action("Focus on player",board.focus_player)
	for crossing: Dictionary in simulation.border_options(player):
		_context_action("Cross "+["east","northeast","northwest","west","southwest","southeast"][crossing.side]+" · 6 hours",_cross_border.bind(crossing.side))
	if cell == player.pos:
		for panel: String in ["Character","Inventory","Skills","Quests"]:
			_context_action(panel,_toggle_panel.bind(panel,160))
		_context_action("Interact / nearby loot",_command.bind("Activate"))
		_context_action("Wait / end turn",_command.bind("End Turn"))
		if active_map.links.has(cell): _context_action(active_map.links[cell].label,_enter_map)
	else:
		_context_action("Move here",_board_intent.bind(cell,true))
	if simulation.can_see(player,cell):
		_context_action("Information",_open_tile_choices.bind(cell))
		if active_map.shops.has(cell): _context_action("Visit "+active_map.shops[cell].name,_open_shop.bind(cell))
		if active_map.props.has(cell) and active_map.props[cell].kind not in ["rug","rubble"] and not active_map.props[cell].opened:
			_context_action("Search "+active_map.props[cell].name,_search_prop.bind(cell))
		var target: Dictionary = simulation.actor_at(player.map_id,cell,player.id)
		if not target.is_empty():
			if simulation.hostile(player,target): _context_action("Attack "+target.name,_mouse_attack.bind(target.id))
			elif target.get("role","") == "crier": _context_action("Talk to town crier",_command.bind("Activate"))
		for entry: Dictionary in loot:
			if entry.pos == cell: _context_action("Take "+entry.item.name,_transfer.bind({"zone":"ground","id":entry.item.item_id},{"zone":"pickup"}))
	var point: Vector2i = Vector2i(get_viewport().get_mouse_position()) if get_window().is_embedding_subwindows() else DisplayServer.mouse_get_position()
	context_popup.popup(Rect2i(point,Vector2i.ZERO))

func _mouse_attack(target_id: int) -> void:
	_finish(simulation.attack(player,target_id),false)

func _quests_panel(parent: Node) -> void:
	var count: int = 0
	for record: Dictionary in map_world.records.values():
		var entries: Array = record.constraints.get("quests",{}).values()
		entries.sort_custom(func(a: Dictionary,b: Dictionary): return a.get("tutorial",false) and not b.get("tutorial",false))
		for quest: Dictionary in entries:
			count += 1
			var status: String = quest.status
			var boss_id: int = map_world.records[quest.target].constraints.get("boss_id",-1)
			if status != "rewarded" and simulation.actors.has(boss_id) and simulation.actors[boss_id].hp <= 0: status = "Return to the crier"
			_wrap(parent,quest.title,360)
			_quest_direction(parent,quest.target)
			if quest.get("tutorial",false): _wrap(parent,quest.get("effects","Follow the gold trade route. Remove its hostile boss to reduce pressure and improve both towns prosperity."),360)
			Parts.label(parent,record.label+" · "+status+" · "+_quest_reward_text(quest),16)
	if count == 0: Parts.label(parent,"Speak to a town crier to find local bounties.")

func _raise_stat(stat: String) -> void:
	_finish(simulation.spend_stat(player,stat),false)

func _cross_border(side: int) -> void:
	_finish(simulation.cross_border(player,side),false)

func _quest_reward_text(quest: Dictionary) -> String:
	return str(quest.skill_reward)+" skill point" if quest.get("skill_reward",0) > 0 else str(quest.reward)+" gold"

func _quest_direction(parent: Node, target_id: String) -> void:
	var destination: Dictionary = simulation.quest_destination(player,target_id)
	var row := HBoxContainer.new()
	parent.add_child(row)
	var preview = preload("res://Production/UI/quest_hex.gd").new()
	preview.biome = destination.biome
	row.add_child(preview)
	Parts.label(row,destination.arrow+" "+str(destination.cell)+" · "+destination.biome,18)
	_wrap(parent,destination.scope+" · POI entrance on Local: "+str(destination.local_cell),360)
