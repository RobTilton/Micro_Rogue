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
	_sync()
	super._refresh()
	if not frame_ready or not drag.payload.is_empty(): return
	var visible_actors: Array[Dictionary] = [player]
	for actor: Dictionary in simulation.on_map(player.map_id):
		if actor.id != player.id and simulation.can_see(player,actor.pos): visible_actors.append(actor)
	board.show_actors(visible_actors,selected_actor_id)
	board.visible_props = []
	for cell: Vector2i in active_map.props:
		if simulation.can_see(player,cell): board.visible_props.append(cell)
	board.loot_cells = []
	for entry: Dictionary in loot:
		if simulation.can_see(player,entry.pos) and entry.pos not in board.loot_cells: board.loot_cells.append(entry.pos)
	if mode == "lunge": board.highlights = simulation.paths(player,player.stats.DEX).keys() if _skill_available("Lunge") else []
	board.queue_redraw()
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
		Parts.button(parent,"Rest unavailable",func(): pass,false)
		_wrap(parent,"Inn services are not available yet.")
	else:
		Parts.button(parent,"Trading unavailable",func(): pass,false)
		_wrap(parent,"Shop services are not available yet.")

func _search_prop(cell: Vector2i) -> void:
	_finish(simulation.interact(player,{"kind":"search","cell":cell}),false)
