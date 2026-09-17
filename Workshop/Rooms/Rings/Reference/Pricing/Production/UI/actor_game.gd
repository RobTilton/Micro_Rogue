extends "res://Production/UI/game_ui.gd"
const Simulation = preload("res://Production/Actors/actor_world.gd")
const Brain = preload("res://Production/Actors/enemy_brain.gd")
const ActorView = preload("res://Production/UI/actor_view.gd")
const SkillBoard = preload("res://Production/Actors/skill_board.gd")
const SkillBoardView = preload("res://Production/UI/skill_board_view.gd")
var board_selection: String = ""
var board_origin: String = ""
var board_rotation: int = 0
var simulation: RefCounted
var brain: RefCounted = Brain.new()
var selected_actor_id: int = -1
var travel_goal = null
var travel_route: Array = []
var travel_task: Dictionary = {}
var travel_map: String = ""
var travel_inflight: bool = false
var combat_pause: float = 0.0
var combat_known: bool = false
var combat_banner: Label
var selected_shop_cell: Vector2i = Vector2i(-1,-1)

func _make_board() -> Control:
	return ActorView.new()

func _make_simulation(seed_value: int) -> RefCounted:
	return Simulation.new(seed_value)

func _start_run() -> void:
	_stop_travel()
	travel_inflight = false
	combat_pause = 0.0
	combat_known = false
	simulation = _make_simulation(randi_range(1,2147480000))
	simulation.difficulty = difficulty
	map_world = simulation.maps
	player = Actors.create(dice_slots.slice(6,12))
	for slot: String in Grid.EQUIPMENT: player[slot] = {}
	player.bag = []
	player.gold = 50
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
	simulation.refresh_action_mode(player)
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
	var observation: Dictionary = preload("res://Production/Actors/map_knowledge.gd").observe(simulation,player)
	board.source_map = active_map
	board.map_data = observation.map
	board.fog_enabled = true
	board.fog_known = observation.known
	board.fog_visible = observation.visible
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
		if event.actor_id == player.id:
			board.animate_motion(event)
		else:
			# Reveal only the final contiguous visible segment, rather than dropping the whole animation.
			var visible_route: Array = []
			var visible_from = null
			for cell: Vector2i in [event.from]+event.route:
				if simulation.can_see(player,cell):
					if visible_from == null: visible_from = cell
					else: visible_route.append(cell)
				else: visible_from = null; visible_route.clear()
			if visible_from != null and not visible_route.is_empty():
				board.animate_motion({"actor_id":event.actor_id,"from":visible_from,"route":visible_route})
	simulation.motion_events.clear()
	if battle and not combat_known: _announce_combat()
	combat_known = battle
	for event: Dictionary in simulation.attack_events:
		if event.map_id == player.map_id and simulation.can_see(player,event.from) and simulation.can_see(player,event.to): board.animate_attack(event)
	simulation.attack_events.clear()
	if is_instance_valid(minimap):
		minimap.trade_route = board.trade_route
		minimap.fog_enabled = true
		minimap.fog_known = observation.known
		minimap.fog_visible = observation.visible
		minimap.update_map(observation.map,player.pos,visible_actors)
	board.interior_template = simulation.maps.records.get(active_map.id,{}).get("template","") if simulation.maps.get("records") is Dictionary else ""
	board.visible_props = observation.map.props.keys()
	board.loot_cells = []
	board.item_tooltips = {}
	for entry: Dictionary in loot:
		if simulation.can_see(player,entry.pos):
			if entry.pos not in board.loot_cells: board.loot_cells.append(entry.pos)
			var description: String = preload("res://Production/Actors/item_inspection.gd").tooltip(entry.item,active_map.distance(player.pos,entry.pos) <= 1)
			board.item_tooltips[entry.pos] = board.item_tooltips.get(entry.pos,"")+("\n\n" if board.item_tooltips.has(entry.pos) else "")+description
	for cell: Vector2i in observation.known:
		if not observation.visible.has(cell) and observation.known[cell].get("loot",false): board.loot_cells.append(cell)
	for cell: Vector2i in board.visible_props:
		if not observation.visible.has(cell): continue
		var prop: Dictionary = active_map.props[cell]
		var text: String = prop.get("name","Scenery")
		if prop.kind not in ["rug","rubble"]: text += " · searched" if prop.get("opened",false) else " · search to reveal contents"
		board.item_tooltips[cell] = text+("\n\n"+board.item_tooltips[cell] if board.item_tooltips.has(cell) else "")
	if mode == "lunge": board.highlights = simulation.paths(player,Rings.stat(player,"DEX")).keys() if _skill_available("Lunge") else []
	board.queue_redraw()
	hud.gold.text = "Gold\n"+str(player.get("gold",0))
	hud.state.text += "\n"+preload("res://Production/World/world_clock.gd").label(simulation.world_hours)
	hud.buttons["End Turn"].disabled = player.hp <= 0
	hud.buttons["End Turn"].text = "End Turn" if battle and Combat.remaining(player.actions) > 0 else "Wait"
	if player.hp <= 0:
		hud.buttons["End Turn"].disabled = false
		hud.buttons["End Turn"].text = "New adventurer"
	hud.state.tooltip_text = "World threshold %d. DEX + effects = %.2f speed. Momentum carries over; each extra grant adds one free action." % [simulation.turn_threshold,simulation.Momentum.speed(player)]
	if battle:
		hud.state.text += "\nMomentum %.2f / %d · Speed %.2f" % [player.get("momentum",0.0),simulation.turn_threshold,simulation.Momentum.speed(player)]
	else:
		hud.state.text = "Exploration · actions are free\n"+preload("res://Production/World/world_clock.gd").label(simulation.world_hours)
		hud.state.tooltip_text = "Turn budgets apply during combat. Gold costs and travel/rest time still apply."
	preview_label.text = "Move to %s · %d hexes · %s" % [preview_destination,preview_path.size(),"1 movement action" if battle else "free exploration"]

func _process(delta: float) -> void:
	if simulation == null or not frame_ready or player.is_empty(): return
	if combat_pause > 0.0:
		combat_pause = maxf(0.0,combat_pause-delta)
		board.motion_paused = combat_pause > 0.0
		if combat_pause == 0.0 and is_instance_valid(combat_banner): combat_banner.hide()
		return
	if "travel_transition_active" in self and get("travel_transition_active"): return
	if board.motion_busy(): return
	if travel_inflight:
		travel_inflight = false
		if travel_goal == null and travel_task.is_empty(): simulation.stop_walk(player)
		var previous_map: String = player.map_id
		simulation.complete_walk_step(player)
		if player.map_id != previous_map:
			_stop_travel()
			_finish({"ok":true,"reason":"Entered encounter."},false)
			return
	if player.hp <= 0 or (not travel_map.is_empty() and player.map_id != travel_map): _stop_travel(); return
	if travel_goal == null and travel_task.is_empty(): return
	if not travel_task.is_empty():
		var target: Dictionary = _travel_task_target()
		if target.is_empty(): _stop_travel(); _note("That task is no longer available."); return
		if active_map.distance(player.pos,target.cell) <= target.reach and simulation.can_see(player,target.cell):
			var task: Dictionary = travel_task.duplicate()
			_stop_travel()
			_execute_travel_task(task)
			return
		if travel_goal != target.cell or travel_route.is_empty():
			travel_goal = target.cell
			travel_route = _route_for(target.cell,target.reach)
	if travel_route.is_empty():
		_stop_travel()
		return
	if not active_map.walkable(travel_route[0]) or not simulation.actor_at(player.map_id,travel_route[0],player.id).is_empty():
		travel_route = _route_for(travel_goal,travel_task.get("reach",0))
		if travel_route.is_empty(): _stop_travel(); _note("The route is blocked."); return
	var next: Vector2i = travel_route.pop_front()
	var outcome: Dictionary = simulation.walk_step(player,next)
	if not outcome.ok:
		_stop_travel()
		_finish(outcome,false)
		return
	travel_inflight = true
	if travel_route.is_empty() and travel_task.is_empty(): travel_goal = null
	else: outcome.reason = ""
	_finish(outcome,false)

func _movement_busy() -> bool:
	return combat_pause > 0.0 or (frame_ready and board.motion_busy())

func _stop_travel() -> void:
	travel_goal = null
	travel_route.clear()
	travel_task = {}
	travel_map = ""
	if simulation != null and player.has("id"): simulation.stop_walk(player)

func _announce_combat() -> void:
	_stop_travel()
	_cancel_preview(false)
	combat_pause = 0.65
	board.motion_paused = true
	_note("Combat started. Travel stopped.")
	if not is_instance_valid(combat_banner):
		combat_banner = Label.new()
		combat_banner.text = "COMBAT STARTED"
		combat_banner.add_theme_font_size_override("font_size",28)
		combat_banner.add_theme_color_override("font_color",Color("ffcb9c"))
		combat_banner.add_theme_stylebox_override("normal",Parts.style(Color("351c1c")))
		combat_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		combat_banner.z_index = 100
		board.add_child(combat_banner)
	combat_banner.position = Vector2(maxf(8,board.size.x*0.5-140),24)
	combat_banner.show()

func _route_for(cell: Vector2i, reach: int = 0) -> Array:
	var goals: Array = []
	if reach == 0: goals.append(cell)
	else:
		for candidate: Vector2i in active_map.cells():
			if active_map.distance(candidate,cell) <= reach and active_map.walkable(candidate) and simulation.Sight.visible(active_map,candidate,cell,simulation.Sight.radius(player)): goals.append(candidate)
	var budget: int = simulation.walk_units(player) if simulation.engaged(player) else -1
	return Paths.route_to(player.pos,goals,simulation.blocked(player),active_map,budget)

func _queue_travel(cell: Vector2i, task: Dictionary = {}) -> void:
	if combat_pause > 0.0: return
	var reach: int = task.get("reach",0)
	var route: Array = _route_for(cell,reach)
	if route.is_empty() and active_map.distance(player.pos,cell) > reach:
		_stop_travel()
		_note("No reachable route within the available movement.")
		return
	travel_goal = cell
	travel_route = route
	travel_task = task
	travel_map = player.map_id
	_cancel_preview(false)

func _approach_task(task: Dictionary) -> void:
	if player.hp <= 0 or combat_pause > 0.0: return
	travel_task = task.duplicate()
	var target: Dictionary = _travel_task_target()
	if target.is_empty(): _stop_travel(); _note("That task is no longer available."); return
	travel_task.reach = target.reach
	_queue_travel(target.cell,travel_task.duplicate())

func _travel_task_target() -> Dictionary:
	var task: Dictionary = travel_task
	var cell: Vector2i = task.get("cell",player.pos)
	var reach: int = 1
	match task.get("kind",""):
		"shop":
			if not active_map.shops.has(cell): return {}
		"search":
			if not active_map.props.has(cell) or active_map.props[cell].opened: return {}
		"camp": reach = 0
		"border":
			var valid_side: bool = false
			for option: Dictionary in simulation.border_options(player):
				if option.side == task.side: valid_side = true
			if not valid_side: return {}
			reach = 0
		"entrance":
			if not active_map.links.has(cell): return {}
			reach = 0
		"attack", "crier":
			var target: Dictionary = simulation.actors.get(task.get("actor_id",-1),{})
			if target.is_empty() or target.hp <= 0 or target.map_id != player.map_id: return {}
			cell = target.pos
			if task.kind == "attack": reach = Combat.attack_range(player)
		"take":
			var found: bool = false
			for entry: Dictionary in simulation.ground[player.map_id]:
				if entry.item.item_id == task.item_id: cell = entry.pos; found = true; break
			if not found: return {}
		_: return {}
	if task.kind in ["attack","crier"] and not simulation.can_see(player,cell): return {}
	return {"cell":cell,"reach":reach}

func _execute_travel_task(task: Dictionary) -> void:
	match task.get("kind",""):
		"shop": _open_shop(task.cell)
		"search": _search_prop(task.cell)
		"entrance": _enter_map()
		"border": _cross_border(task.side)
		"camp": _camp()
		"attack": _mouse_attack(task.actor_id)
		"crier": _talk_to_crier(task.actor_id)
		"take": _transfer({"zone":"ground","id":task.item_id},{"zone":"pickup"})
		_: _note("That task was cancelled.")

func _talk_to_crier(actor_id: int) -> void:
	var npc: Dictionary = simulation.actors.get(actor_id,{})
	if npc.is_empty() or npc.get("role","") != "crier" or npc.hp <= 0 or npc.map_id != player.map_id or active_map.distance(player.pos,npc.pos) > 1 or not simulation.can_see(player,npc.pos):
		_note("The town crier is no longer within reach.")
		return
	if host.panel_name != "Activate": _toggle_panel("Activate",280)
	else: _refresh()

func _flush_events() -> void:
	simulation.finish_hearing()
	for message: String in simulation.events: _note(message)
	simulation.events.clear()

func _finish(result: Dictionary, advance_outside: bool = true) -> void:
	if not result.reason.is_empty(): _note(result.reason)
	if result.ok and advance_outside and not battle and Combat.available(player.actions,"move") == 0:
		simulation.advance_to_player(brain)
	if player.retreat: mode = "retreat"
	_flush_events()
	_refresh()

func _end_turn() -> void:
	if _movement_busy(): return
	_stop_travel()
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

func _request_movement(cell: Vector2i, bypass: bool = false) -> void:
	if player.hp <= 0 or mode != "move" or not player.pending.is_empty() or combat_pause > 0.0: return
	if player.map_id == "global" and active_map.distance(player.pos,cell) != 1:
		_note("Global travel requires an adjacent trade-route step.")
		return
	if battle and not simulation.walks.has(player.id) and Combat.available(player.actions,"move") <= 0: _note("No movement action remains."); return
	var route: Array = _route_for(cell)
	if route.is_empty(): return
	preview_destination = cell
	preview_path = route
	if bypass or not confirm_movement: _confirm_move()
	else: _refresh()

func _confirm_move() -> void:
	if mode != "move" or preview_path.is_empty(): _cancel_preview(); return
	_queue_travel(preview_destination)


func _board_intent(cell: Vector2i, bypass: bool) -> void:
	if combat_pause > 0.0: return
	if cell == player.pos: _stop_travel(); return
	if player.hp <= 0: return
	if mode == "move" and player.pending.is_empty() and active_map.shops.has(cell):
		_approach_task({"kind":"shop","cell":cell})
		return
	var target: Dictionary = simulation.actor_at(player.map_id,cell,player.id)
	if not target.is_empty() and simulation.can_see(player,cell): selected_actor_id = target.id
	if _movement_busy() and mode != "move": return
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
	if name == "Cancel": _stop_travel()
	elif name in ["Attack","Lunge","Riposte","End Turn","Activate","Wait"] and _movement_busy(): return
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
	if _movement_busy(): return
	_stop_travel()
	var outcome: Dictionary = simulation.interact(player,{"kind":"entrance"})
	if not outcome.ok: _finish(outcome,false); return
	mode = "move"
	_cancel_preview(false)
	# Travel spends the existing budget; it cannot refill momentum/free actions.
	simulation.refresh_action_mode(player)
	if simulation.engaged(player) and Combat.remaining(player.actions) == 0: simulation.advance_to_player(brain)
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
	SkillBoard.ensure(player)
	Parts.label(parent,"Skill board · points %d · origins %d/3" % [player.points,player.skill_board.origins.size()],20)
	_wrap(parent,"Learn → place a permanent family origin → place skills. Green: active. Red: requirements unmet. Inactive pieces still support other skills. Move/remove placed skills in town outside combat.",760)
	var layout := HBoxContainer.new()
	parent.add_child(layout)
	var view := SkillBoardView.new()
	view.actor = player
	view.selected = board_selection
	view.footprint_rotation = board_rotation
	view.hex_clicked.connect(_skill_hex_clicked)
	layout.add_child(view)
	var tools := VBoxContainer.new()
	layout.add_child(tools)
	tools.custom_minimum_size.x = 280
	_wrap(tools,"Placing origin: "+board_origin+" (permanent)" if not board_origin.is_empty() else "Selected: "+board_selection if not board_selection.is_empty() else "Select a learned skill or an unlocked origin below.",280)
	var controls := VBoxContainer.new()
	tools.add_child(controls)
	Parts.button(controls,"Rotate",func(): board_rotation = (board_rotation+1)%6; _refresh(),not board_selection.is_empty())
	Parts.button(controls,"Remove selected",func(): _finish(simulation.remove_board_skill(player,board_selection),false),simulation.can_rearrange_skills(player) and player.skill_board.placements.has(board_selection))
	Parts.button(controls,"Clear movable skills",func(): _finish(simulation.clear_skill_placements(player),false),simulation.can_rearrange_skills(player))
	for family: String in SkillBoard.families(player):
		if not player.skill_board.origins.has(family):
			Parts.button(tools,"Place permanent "+family+" origin",func(): board_origin = family; board_selection = ""; _refresh())
	var states: Dictionary = SkillBoard.evaluate(player)
	for skill: String in SkillBoard.DEFINITIONS:
		if skill in player.skills:
			Parts.button(tools,skill+" · "+("Active" if states[skill].active else "Inactive"),func(): board_selection = skill; board_origin = ""; board_rotation = 0; _refresh())
			_wrap(tools,states[skill].reason,280)
		else:
			Parts.button(tools,"Learn · 1 point · "+skill,func(): _finish(simulation.learn(player,skill),false),player.hp > 0 and player.points > 0)
	Parts.label(parent,"Spend a point: +1 stat",20)
	var stats := HBoxContainer.new()
	parent.add_child(stats)
	for stat: String in Actors.STATS: Parts.button(stats,"+1 "+stat,_raise_stat.bind(stat),player.points > 0 and player.hp > 0)

func _skill_hex_clicked(cell: Vector2i) -> void:
	if not board_origin.is_empty():
		var family: String = board_origin
		var confirmation := ConfirmationDialog.new()
		confirmation.title = "Permanent family origin"
		confirmation.dialog_text = "Place the %s origin at (%d, %d)? This position cannot change, even during a town respec." % [family,cell.x,cell.y]
		add_child(confirmation)
		confirmation.confirmed.connect(func():
			_finish(simulation.place_skill_origin(player,family,cell),false)
			if player.skill_board.origins.has(family): board_origin = ""
			confirmation.queue_free()
			_refresh())
		confirmation.canceled.connect(confirmation.queue_free)
		confirmation.popup_centered()
	elif not board_selection.is_empty():
		_finish(simulation.place_skill(player,board_selection,cell,board_rotation),false)
	else:
		var entry: Dictionary = SkillBoard.occupied(player.skill_board).get(cell,{})
		if SkillBoard.DEFINITIONS.has(entry.get("id","")): board_selection = entry.id; _refresh()

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
			Parts.button(parent,active_map.shops[cell].name,_approach_task.bind({"kind":"shop","cell":cell}))
	for cell: Vector2i in active_map.props:
		var prop: Dictionary = active_map.props[cell]
		if prop.kind in ["rug","rubble"] or active_map.distance(player.pos,cell) > 1 or not simulation.can_see(player,cell): continue
		if prop.opened: Parts.label(parent,prop.name+" · searched")
		else: Parts.button(parent,"Search "+prop.name,_approach_task.bind({"kind":"search","cell":cell}))
	Parts.button(parent,"Camp · 1 ration · 1 block",_camp,player.hp > 0 and not simulation.engaged(player) and player.map_id != "global")
	Parts.label(parent,"Carried health potions",20)
	for potion: Dictionary in player.belt.get("contents",[])+player.bag:
		if potion.get("kind") != "potion": continue
		var use: Button = Parts.button(parent,"Use Lesser Health",_drink_potion.bind(potion.item_id),_inventory_allowed())
		use.tooltip_text = preload("res://Production/Actors/item_inspection.gd").tooltip(potion)
	Parts.button(parent,"Backpack",func(): _toggle_panel("Inventory",200))
	Parts.label(parent,"Nearby visible items",20)
	for entry: Dictionary in loot:
		if active_map.distance(player.pos,entry.pos) <= 1 and simulation.can_see(player,entry.pos):
			var take: Button = Parts.button(parent,"Take "+entry.item.name,func(): _transfer({"zone":"ground","id":entry.item.item_id},{"zone":"pickup"}))
			take.tooltip_text = preload("res://Production/Actors/item_inspection.gd").tooltip(entry.item)

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
		_wrap(parent,"Recover up to "+str(Rings.healing(player,2))+" HP. No ration required.")
	else:
		Parts.label(parent,"Gold: "+str(player.get("gold",0))+" · Prosperity: "+str(shop.get("prosperity",0)))
		for entry: Dictionary in shop.get("stock",[]):
			var buy_button: Button = Parts.button(parent,entry.item.name+" · "+str(entry.price)+" gold",_buy_item.bind(entry.item.item_id),player.get("gold",0) >= entry.price)
			var description: Dictionary = preload("res://Production/Actors/item_inspection.gd").describe(entry.item,true)
			buy_button.tooltip_text = description.title+"\n"+description.details+"\nPrice: "+str(entry.price)+" gold"
		if shop.get("stock",[]).is_empty(): Parts.label(parent,"No stock available.")
		Parts.label(parent,"Sell backpack gear",20)
		_wrap(parent,"Unequip gear to sell it. Empty loaded belts first. Ctrl-click buys or sells without confirmation.")
		for item: Dictionary in player.bag:
			if not preload("res://Production/World/village_shops.gd").sellable(item): continue
			var price: int = preload("res://Production/World/village_shops.gd").sale_price(item)
			var button: Button = Parts.button(parent,"Sell "+item.name+" · "+str(price)+" gold",_sell_item.bind(item.item_id))
			var description: Dictionary = preload("res://Production/Actors/item_inspection.gd").describe(item,true)
			button.tooltip_text = description.title+"\n"+description.details+"\nSell for: "+str(price)+" gold"

func _search_prop(cell: Vector2i) -> void:
	_finish(simulation.interact(player,{"kind":"search","cell":cell}),false)

func _camp() -> void:
	if _movement_busy(): _approach_task({"kind":"camp","cell":player.pos}); return
	_stop_travel()
	_finish(simulation.camp(player),false)

func _rest_inn() -> void:
	_finish(simulation.rest_at_inn(player,selected_shop_cell),false)

func _buy_item(item_id: int) -> void:
	_request_trade("buy",item_id)

func _sell_item(item_id: int) -> void:
	_request_trade("sell",item_id)

var trade_confirmation: ConfirmationDialog
var pending_trade: Dictionary = {}

func _request_trade(kind: String, item_id: int) -> void:
	var access: Dictionary = simulation.inspect_shop(player,selected_shop_cell)
	if not access.ok or access.shop.closed or access.shop.id == "inn": return
	var item: Dictionary = {}
	var price: int = 0
	if kind == "buy":
		for entry: Dictionary in access.shop.stock:
			if entry.item.item_id == item_id: item = entry.item; price = entry.price; break
	else:
		for candidate: Dictionary in player.bag:
			if candidate.item_id == item_id: item = candidate; break
		if not preload("res://Production/World/village_shops.gd").sellable(item): return
		price = preload("res://Production/World/village_shops.gd").sale_price(item)
	if item.is_empty(): return
	pending_trade = {"kind":kind,"item_id":item_id,"price":price,"map_id":player.map_id,"cell":selected_shop_cell}
	if Input.is_key_pressed(KEY_CTRL):
		_confirm_trade()
		return
	if not is_instance_valid(trade_confirmation):
		trade_confirmation = ConfirmationDialog.new()
		add_child(trade_confirmation)
		trade_confirmation.confirmed.connect(_confirm_trade)
		trade_confirmation.canceled.connect(func(): pending_trade = {})
	trade_confirmation.title = "Confirm purchase" if kind == "buy" else "Confirm sale"
	trade_confirmation.dialog_text = ("Buy " if kind == "buy" else "Sell ")+item.name+" for "+str(price)+" gold?"
	trade_confirmation.get_ok_button().text = "Buy" if kind == "buy" else "Sell"
	trade_confirmation.popup_centered()

func _confirm_trade() -> void:
	var request: Dictionary = pending_trade
	pending_trade = {}
	if request.is_empty(): return
	if player.map_id != request.map_id:
		_finish({"ok":false,"reason":"The shop is no longer in reach."},false)
		return
	var access: Dictionary = simulation.inspect_shop(player,request.cell)
	if not access.ok: _finish(access,false); return
	var price: int = -1
	if request.kind == "buy":
		for entry: Dictionary in access.shop.get("stock",[]):
			if entry.item.item_id == request.item_id: price = entry.price; break
	else:
		for item: Dictionary in player.bag:
			if item.item_id == request.item_id: price = preload("res://Production/World/village_shops.gd").sale_price(item); break
	if price != request.price:
		_finish({"ok":false,"reason":"That offer changed. Select the item again."},false)
		return
	_finish(simulation.buy(player,request.cell,request.item_id) if request.kind == "buy" else simulation.sell(player,request.cell,request.item_id),false)

func _crier_quest(target_id: String) -> void:
	_finish(simulation.quest_action(player,target_id),false)

var context_popup: PopupMenu
var context_actions: Array[Callable] = []
var minimap: Control
func _arena_ui() -> void:
	combat_banner = null
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
	rail.add_child(minimap)
	rail.move_child(minimap,0)
	minimap.custom_minimum_size = Vector2(166,110)
	rail.map_button.custom_minimum_size.y = 62
	minimap.cell_selected.connect(board.focus_cell)
	_refresh()

func _double_hex(cell: Vector2i) -> void:
	if cell == player.pos and active_map.links.has(cell): _approach_task({"kind":"entrance","cell":cell})

func _context_action(text: String, action: Callable) -> void:
	context_popup.add_item(text,context_actions.size())
	context_actions.append(action)

func _show_context(cell: Vector2i) -> void:
	if not frame_ready or player.hp <= 0 or not drag.payload.is_empty(): return
	context_popup.clear()
	context_actions.clear()
	_context_action("Focus on player",board.focus_player)
	if cell == player.pos and player.hp > 0 and not simulation.engaged(player) and player.map_id != "global": _context_action("Camp · 1 ration · 1 block",_camp)
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
		if cell != player.pos and active_map.links.has(cell): _context_action(active_map.links[cell].label,_approach_task.bind({"kind":"entrance","cell":cell}))
		if active_map.shops.has(cell): _context_action("Visit "+active_map.shops[cell].name,_approach_task.bind({"kind":"shop","cell":cell}))
		if active_map.props.has(cell) and active_map.props[cell].kind not in ["rug","rubble"] and not active_map.props[cell].opened:
			_context_action("Search "+active_map.props[cell].name,_approach_task.bind({"kind":"search","cell":cell}))
		var target: Dictionary = simulation.actor_at(player.map_id,cell,player.id)
		if not target.is_empty():
			if simulation.hostile(player,target): _context_action("Attack "+target.name,_approach_task.bind({"kind":"attack","actor_id":target.id}))
			elif target.get("role","") == "crier": _context_action("Talk to town crier",_approach_task.bind({"kind":"crier","actor_id":target.id}))
		for entry: Dictionary in loot:
			if entry.pos == cell:
				_context_action("Take "+entry.item.name,_approach_task.bind({"kind":"take","item_id":entry.item.item_id}))
				context_popup.set_item_tooltip(context_popup.item_count-1,preload("res://Production/Actors/item_inspection.gd").tooltip(entry.item))
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
			if quest.status != "accepted": continue
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
	if _movement_busy(): _approach_task({"kind":"border","cell":player.pos,"side":side}); return
	_stop_travel()
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

func _inventory_time_label() -> String:
	return preload("res://Production/World/world_clock.gd").label(simulation.world_hours) if simulation != null else ""
