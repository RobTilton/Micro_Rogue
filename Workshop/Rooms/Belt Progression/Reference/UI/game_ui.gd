extends "res://Production/UI/base_game.gd"
const Card = preload("res://Production/UI/item_card.gd")
const Inspection = preload("res://Production/Actors/item_inspection.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Paths = preload("res://Production/World/movement_preview.gd")
const Parts = preload("res://Production/UI/ui_parts.gd")
const Rail = preload("res://Production/UI/navigation_rail.gd")
const Host = preload("res://Production/UI/panel_host.gd")
const Hud = preload("res://Production/UI/bottom_hud.gd")
const World = preload("res://Production/UI/world_view.gd")
const BackpackGrid = preload("res://Production/UI/inventory_grid.gd")
const Target = preload("res://Production/UI/item_target.gd")
const Drag = preload("res://Production/UI/drag_context.gd")
const MapWorld = preload("res://Production/World/map_world.gd")
const Travel = preload("res://Production/World/travel_cost.gd")
var map_world = null
var active_map = null
var drag: RefCounted = Drag.new()
var rail: Control
var panel_placements: Dictionary = {}
var host: Control
var hud: Control
var notice: Label
var preview_row: HBoxContainer
var preview_label: Label
var preview_path: Array = []
var preview_destination: Vector2i = Vector2i(-1,-1)
var confirm_movement: bool = true
var inspection_looting: bool = true
var inspected_cell: Vector2i = Vector2i(-1,-1)
var selected_item: int = -1
var inspected_belt: int = -1
var current_grid: Control
var frame_ready: bool = false

func _clear() -> void:
	_restore_panel_parent()
	frame_ready = false
	inspected_cell = Vector2i(-1,-1)
	preview_path = []
	preview_destination = Vector2i(-1,-1)
	super._clear()

func _arena_ui() -> void:
	_clear()
	arena_active = true
	var theme: Theme = Theme.new()
	theme.default_font_size = 17
	var tooltip_panel := StyleBoxFlat.new()
	tooltip_panel.bg_color = Color("080d12")
	tooltip_panel.border_color = Color("9b927b")
	tooltip_panel.set_border_width_all(1)
	tooltip_panel.content_margin_left = 12
	tooltip_panel.content_margin_right = 12
	tooltip_panel.content_margin_top = 10
	tooltip_panel.content_margin_bottom = 10
	theme.set_stylebox("panel","TooltipPanel",tooltip_panel)
	theme.set_color("font_color","TooltipLabel",Color("f4f0e6"))
	theme.set_font_size("font_size","TooltipLabel",16)
	root.theme = theme
	var top: HBoxContainer = HBoxContainer.new()
	top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top.add_theme_constant_override("separation",14)
	root.add_child(top)
	rail = Rail.new()
	top.add_child(rail)
	rail.panel_requested.connect(_toggle_panel)
	var frame: PanelContainer = PanelContainer.new()
	frame.add_theme_stylebox_override("panel",Parts.style(Color("111a21")))
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(frame)
	var stage: Control = Control.new()
	stage.clip_contents = true
	frame.add_child(stage)
	board = _make_board()
	board.map_data = active_map
	board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.add_child(board)
	board.hex_intent.connect(_board_intent)
	host = Host.new()
	host.theme = theme
	host.placements = panel_placements
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.add_child(host)
	host.closed.connect(func(): _restore_panel_parent(); inspected_belt = -1; _refresh())
	preview_row = HBoxContainer.new()
	root.add_child(preview_row)
	preview_label = Parts.label(preview_row,"",16)
	preview_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Parts.button(preview_row,"Confirm movement",_confirm_move)
	Parts.button(preview_row,"Cancel preview",_cancel_preview)
	notice = Parts.label(root,"",16)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud = Hud.new()
	hud.drag_context = drag
	root.add_child(hud)
	hud.command.connect(_command)
	hud.transfer_requested.connect(_transfer)
	frame_ready = true
	_refresh()

func _make_board() -> Control:
	return World.new()

func _process(delta: float) -> void:
	if arena_active and not battle and player.hp > 0 and cooldowns.advance_outside(delta): _refresh()

func _input(event: InputEvent) -> void:
	if not frame_ready: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and not drag.payload.is_empty():
		drag.rotate()
		if is_instance_valid(current_grid): current_grid.queue_redraw()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and not drag.payload.is_empty():
			drag.rotate()
			if is_instance_valid(current_grid): current_grid.queue_redraw()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			if not drag.payload.is_empty(): return
			if not preview_path.is_empty(): _cancel_preview()
			elif not host.panel_name.is_empty(): host.close()
			else: _command("Cancel")
			get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and not drag.payload.is_empty():
		drag.finish()
		_refresh.call_deferred()

func _restore_panel_parent() -> void:
	if is_instance_valid(host) and is_instance_valid(board) and host.get_parent() == self:
		host.reparent(board.get_parent())
		host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _toggle_panel(name: String, anchor_y: float = 140) -> void:
	if name == "Inventory" and host.panel_name != "Inventory":
		host.reparent(self)
		host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if not host.placements.has("Inventory"): host.placements.Inventory = {"position":Vector2(240,24),"dock_x":0,"dock_y":0}
	elif name != "Inventory": _restore_panel_parent()
	host.toggle(name,anchor_y)
	if name != "Inventory": inspected_belt = -1
	_refresh()

func _command(name: String) -> void:
	if not frame_ready: return
	match name:
		"Attack": _cancel_preview(false); mode = "attack"
		"Lunge":
			if _skill_available("Lunge"): _cancel_preview(false); mode = "lunge"
		"Riposte": _cancel_preview(false); _riposte(); mode = "move"
		"Activate": _toggle_panel("Activate",280)
		"End Turn": _cancel_preview(false); _end_turn()
		"Cancel":
			_cancel_preview(false)
			pending_weapon = {}
			retreat_available = false
			mode = "move"
	_refresh()

func _refresh() -> void:
	if not frame_ready or not drag.payload.is_empty(): return
	board.player_cell = player.pos
	board.enemy_cell = enemy.pos
	board.enemy_alive = enemy.hp > 0
	board.loot_cells = []
	for entry: Dictionary in loot:
		if entry.pos not in board.loot_cells: board.loot_cells.append(entry.pos)
	board.highlights = []
	if player.hp > 0:
		if mode == "move" and (not battle or Combat.available(actions,"move") > 0): board.highlights = _movement_paths().keys()
		elif mode == "retreat": board.highlights = Paths.paths(player.pos,ceili(player.stats.DEX*0.5),_blocked(),active_map).keys()
		elif mode == "lunge" and _skill_available("Lunge"):
			board.highlights = Paths.paths(player.pos,ceili(player.stats.DEX*0.5+1),_blocked(),active_map).keys()
	board.preview_path = preview_path
	board.queue_redraw()
	preview_row.visible = not preview_path.is_empty()
	preview_label.text = "Move to %s · %d hexes · %s" % [preview_destination,preview_path.size(),"1 movement action" if battle else "free roaming"]
	if active_map != null and active_map.layer == "Global":
		preview_label.text = "Move to %s · %d hexes · terrain cost %.1f / %d" % [preview_destination,preview_path.size(),Travel.path_cost(active_map,preview_path),3+player.stats.DEX]
	notice.text = messages.back() if not messages.is_empty() else "Click a hex to preview movement. Shift-click moves immediately."
	if player.hp <= 0: notice.text = "Your adventure ends. Open Character to roll a new adventurer."
	var belt: Dictionary = Grid.belt_by_id(player,inspected_belt)
	if belt.is_empty(): belt = player.belt
	hud.force_belt = host.panel_name == "Activate" or (host.panel_name == "Inventory" and inspected_belt > 0)
	hud.show_state(player,actions,mode,cooldowns,{"Attack":player.hp > 0 and battle and Combat.available(actions,"attack") > 0 and not _next_weapon().is_empty() and pending_weapon.is_empty(),"Lunge":_skill_available("Lunge"),"Riposte":_skill_available("Riposte"),"End Turn":battle and player.hp > 0},belt)
	rail.select(host.panel_name)
	if active_map != null: rail.map_button.text = "⬡\n" + active_map.layer + "\n" + active_map.title
	Parts.clear(host.content)
	match host.panel_name:
		"Map": _map_panel(host.content)
		"Character": _character_panel(host.content)
		"Inventory": _inventory_panel(host.content)
		"Skills": _skills_panel(host.content)
		"Logs": _logs_panel(host.content)
		"Options": _options_panel(host.content)
		"Activate": _activate_panel(host.content)
		"Look": _look_panel(host.content)
		"Tile": _tile_panel(host.content)
		"Shop": _shop_panel(host.content)
		"Quests": _quests_panel(host.content)

func _wrap(parent: Node, text: String, width: float = 300) -> Label:
	var label: Label = Parts.label(parent,text,16)
	label.custom_minimum_size.x = width
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _character_panel(parent: Node) -> void:
	Parts.label(parent,"Level %d · XP %d/%d" % [player.level,player.xp,player.required_xp],22)
	Parts.label(parent,"HP %d / %d" % [player.hp,player.max_hp],20)
	for stat: String in Actors.STATS: Parts.label(parent,"%s     %d" % [stat,player.stats[stat]])
	_wrap(parent,"Physical Defense: %d (CON + equipment)\nMagical Defense: %d (WIL + equipment)\nMatching defense subtracts from damage; minimum 0." % [Combat.defense(player,"physical"),Combat.defense(player,"magical")])
	if not battle and player.hp > 0 and (active_map == null or active_map.layer == "POI"): Parts.button(parent,"Next test encounter",func(): round_number += 1; _spawn_enemy())
	if player.hp <= 0: Parts.button(parent,"Roll a new adventurer",_new_character)

func _skills_panel(parent: Node) -> void:
	Parts.label(parent,"Martial Weapons / Sword Mastery",20)
	Parts.label(parent,"Available points: %d" % player.points)
	for skill: String in ["Lunge","Riposte","Show-Off"]:
		var previous: String = "" if skill == "Lunge" else ("Lunge" if skill == "Riposte" else "Riposte")
		Parts.button(parent,("✓ " if skill in player.skills else "Unlock · 1 point · ")+skill,func():
			player.skills.append(skill)
			player.points -= 1
			_refresh(),player.hp > 0 and player.points > 0 and skill not in player.skills and (previous == "" or previous in player.skills))
		if skill != "Show-Off": Parts.label(parent,"          ↓")
	_wrap(parent,"Lunge: choose a movement path and optional sword attack +1.5 STR. Cooldown 4 ticks.\nRiposte: +DEX Defense and a counter on the next attack. Cooldown 2 ticks.\nShow-Off: main-hand then offhand sword attacks.\nStance Mastery: TBD.",450)

func _logs_panel(parent: Node) -> void:
	_wrap(parent,"\n\n".join(messages),520)

func _options_panel(parent: Node) -> void:
	var toggle: CheckButton = CheckButton.new()
	toggle.text = "Confirm ordinary movement"
	toggle.button_pressed = confirm_movement
	toggle.toggled.connect(func(value: bool): confirm_movement = value; _cancel_preview())
	parent.add_child(toggle)
	_wrap(parent,"Shift-click bypasses confirmation.\nRight-click or R rotates a dragged item.\nEscape closes a panel or cancels targeting.\nDifficulty: " + ["Normal","Hard","True Rogue"][difficulty])

func _inventory_panel(parent: Node) -> void:
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation",16)
	parent.add_child(layout)
	var left := VBoxContainer.new()
	layout.add_child(left)
	Parts.label(left,"Equipment",20)
	var doll = preload("res://Production/UI/paper_doll.gd").new()
	left.add_child(doll)
	var locations: Dictionary = {
		"head":Rect2(161,0,98,58),"armor":Rect2(151,72,118,100),
		"main":Rect2(12,72,100,122),"off":Rect2(304,72,100,122),
		"arms":Rect2(12,213,100,68),"belt":Rect2(151,185,118,38),"legs":Rect2(161,239,98,75)}
	var names: Dictionary = {"head":"Head","armor":"Chest","main":"Main hand","off":"Off hand","arms":"Hands / arms","belt":"Belt","legs":"Legs / feet"}
	for slot: String in Grid.EQUIPMENT:
		var item: Dictionary = player[slot]
		var target: Button = _item_target(doll,item,{"zone":"equipment","slot":slot,"id":item.get("item_id",-1)},{"zone":"equipment","slot":slot},names[slot]+"\n"+item.get("name","Empty"))
		target.position = locations[slot].position
		target.size = locations[slot].size
		target.add_theme_font_size_override("font_size",13)
		target.text = ""
		target.icon = null
		var caption := Label.new()
		caption.text = names[slot]
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.position = Vector2(0,3)
		caption.size.x = target.size.x
		caption.add_theme_font_size_override("font_size",13)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		target.add_child(caption)
		if not item.is_empty():
			var icon = preload("res://Production/UI/item_icon.gd").new()
			icon.item = item
			var side: float = minf(44,target.size.y-24)
			icon.position = Vector2((target.size.x-side)*0.5,22)
			icon.size = Vector2(side,side)
			target.add_child(icon)
		else:
			var empty := Label.new()
			empty.text = "Empty"
			empty.position = Vector2(0,25)
			empty.size.x = target.size.x
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			empty.add_theme_font_size_override("font_size",12)
			empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
			target.add_child(empty)
		target.pressed.connect(func():
			selected_item = item.get("item_id",-1)
			if slot == "belt": inspected_belt = selected_item
			_refresh.call_deferred())
	for index: int in range(8):
		var ring: Button = Parts.button(doll,"○",func(): pass,false)
		ring.position = Vector2(299+(index%4)*27,215+(int(index/4.0))*28)
		ring.size = Vector2(25,26)
		ring.tooltip_text = "Ring %d · future equipment slot" % (index+1)
	for index: int in range(2):
		var necklace: Button = Parts.button(doll,"◇",func(): pass,false)
		necklace.position = Vector2(299+index*38,278)
		necklace.size = Vector2(34,30)
		necklace.tooltip_text = "Necklace %d · future equipment slot" % (index+1)
	Parts.label(left,"Equipped belt pouches",16)
	var pouches := HBoxContainer.new()
	left.add_child(pouches)
	if player.belt.is_empty(): Parts.label(pouches,"No belt equipped",15)
	else:
		for index: int in range(player.belt.capacity):
			var potion: Dictionary = {}
			for content: Dictionary in player.belt.contents:
				if content.pouch == index: potion = content
			var target: Button = _item_target(pouches,potion,{"zone":"belt","belt_id":player.belt.item_id,"id":potion.get("item_id",-1)},{"zone":"belt","belt_id":player.belt.item_id,"pouch":index},str(index+1)+" · "+("Empty" if potion.is_empty() else "HP"))
			target.custom_minimum_size = Vector2(72,38)
	Parts.label(left,"Backpack · drag gear to equip",16)
	current_grid = BackpackGrid.new()
	current_grid.drag_context = drag
	current_grid.items = player.bag
	current_grid.selected_id = selected_item
	current_grid.validator = _can_transfer
	current_grid.transfer_requested.connect(_transfer)
	current_grid.item_selected.connect(_select_item)
	current_grid.selection_completed.connect(func(): _refresh.call_deferred())
	left.add_child(current_grid)
	var drop: Button = _item_target(left,{}, {},{"zone":"ground"},"Drop at feet — drag here")
	drop.custom_minimum_size.y = 34
	var details := VBoxContainer.new()
	details.custom_minimum_size.x = 200
	layout.add_child(details)
	Parts.label(details,"Adventurer · Level %d" % player.level,20)
	Parts.label(details,"HP %d / %d" % [player.hp,player.max_hp])
	for stat: String in Actors.STATS: Parts.label(details,"%s    %d" % [stat,player.stats[stat]])
	_wrap(details,"Physical Defense: %d\nMagical Defense: %d" % [Combat.defense(player,"physical"),Combat.defense(player,"magical")],200)
	if not player.main.is_empty():
		var rules = preload("res://Production/Actors/equipment_rules.gd")
		var flat: int = rules.damage_bonus(player.main)+rules.stat_bonus(player,player.main)+int(player.get("attack_modifier",0))
		_wrap(details,"Main-hand %s damage\n%d–%d · average %.1f\nBefore target defense" % [player.main.get("damage_type","physical"),1+flat,player.main.die+flat,(player.main.die+1)*0.5+flat],200)
	else: Parts.label(details,"Main hand: empty",16)
	Parts.label(details,"Gold: %d" % player.get("gold",0),20)
	_wrap(details,_inventory_time_label(),200)
	_wrap(details,"Ring and necklace slots: coming later.",200)
	var selection: Dictionary = _selected_source()
	if not selection.is_empty():
		var item: Dictionary = Grid.source_item(player,loot,selection)
		_add_item_card(details,item,true,false,200)
		if item.kind == "potion": Parts.button(details,"Drink",_drink_potion.bind(item.item_id),_inventory_allowed())
		if item.kind == "ration" and has_method("_camp"): Parts.button(details,"Camp · 1 ration",Callable(self,"_camp"))
		if item.kind == "belt": Parts.button(details,"Inspect / load belt",func(): inspected_belt = item.item_id; _refresh())
		if selection.zone == "bag": Parts.button(details,"Rotate",func(): _transfer(selection,{"zone":"bag","cell":item.grid_pos,"rotated":not item.get("rotated",false)}))
		Parts.button(details,"Drop at feet",func(): _transfer(selection,{"zone":"ground"}))
	else: _wrap(details,"Hover any item for details. Drag between backpack, equipment and belt pouches.",200)

func _inventory_time_label() -> String:
	return ""

func _item_target(parent: Node, item: Dictionary, source: Dictionary, target: Dictionary, text: String) -> Button:
	var button: Button = Target.new()
	button.drag_context = drag
	button.item = item
	button.source = source
	button.target = target
	button.text = text
	button.clip_text = true
	button.tooltip_text = text
	button.transfer_requested.connect(_transfer)
	parent.add_child(button)
	return button

func _select_item(item_id: int) -> void:
	selected_item = item_id
	var selected: Dictionary = Grid.source_item(player,loot,{"zone":"bag","id":item_id})
	if selected.get("kind") == "belt": inspected_belt = item_id
	# Do not rebuild the grid under a mouse-down that may become a drag.
	current_grid.selected_id = item_id
	current_grid.queue_redraw()

func _selected_source() -> Dictionary:
	if selected_item < 0: return {}
	for item: Dictionary in player.bag:
		if item.item_id == selected_item: return {"zone":"bag","id":selected_item}
	for slot: String in Grid.EQUIPMENT:
		if player[slot].get("item_id",-1) == selected_item: return {"zone":"equipment","slot":slot,"id":selected_item}
	return {}

func _activate_panel(parent: Node) -> void:
	_map_transition_button(parent)
	Parts.label(parent,"Equipped belt",20)
	if player.belt.get("contents",[]).is_empty(): Parts.label(parent,"No usable potions.",16)
	for potion: Dictionary in player.belt.get("contents",[]):
		Parts.button(parent,"Pouch %d · Lesser Health · heal %d" % [potion.pouch+1,player.stats.CON],_drink_potion.bind(potion.item_id),_inventory_allowed())
	Parts.button(parent,"Backpack",func(): _toggle_panel("Inventory",200))
	Parts.label(parent,"Nearby",20)
	var count: int = 0
	for entry: Dictionary in loot:
		if _map_distance(player.pos,entry.pos) <= 1:
			count += 1
			Parts.button(parent,"Take " + entry.item.name,func(): _transfer({"zone":"ground","id":entry.item.item_id},{"zone":"pickup"}))
	if count == 0: Parts.label(parent,"Nothing nearby to activate or collect.",16)

func _drink_potion(item_id: int) -> void:
	if not _inventory_allowed(): return
	for index: int in range(player.belt.get("contents",[]).size()):
		if player.belt.contents[index].item_id == item_id:
			player.belt.contents.remove_at(index)
			if battle: Combat.spend(actions,"activation")
			_note("Lesser Health restores %d HP." % Combat.heal(player))
			_refresh()
			return

func _can_transfer(source: Dictionary, target: Dictionary) -> bool:
	if not pending_weapon.is_empty(): return false
	return Grid.transfer(player,loot,actions,battle,source,target,true,active_map).ok

func _transfer(source: Dictionary, target: Dictionary) -> void:
	if not pending_weapon.is_empty(): _note("Finish or skip the Lunge attack first."); return
	var result: Dictionary = Grid.transfer(player,loot,actions,battle,source,target,false,active_map)
	_note(result.reason)
	if not result.ok: inspected_belt = -1 if Grid.belt_by_id(player,inspected_belt).is_empty() else inspected_belt
	_refresh.call_deferred()

func _blocked() -> Array:
	return [enemy.pos] if enemy.hp > 0 else []

func _movement_paths() -> Dictionary:
	return Paths.paths(player.pos,3+player.stats.DEX,_blocked(),active_map)

func _board_intent(cell: Vector2i, bypass: bool) -> void:
	if player.hp <= 0: return
	if mode != "move" or not pending_weapon.is_empty():
		super._cell_selected(cell)
		if mode == "attack": mode = "move"
		_refresh()
		return
	if not bypass:
		for entry: Dictionary in loot:
			if entry.pos == cell:
				_open_tile_choices(cell)
				return
	_request_movement(cell,bypass)

func _request_movement(cell: Vector2i, bypass: bool = false) -> void:
	if player.hp <= 0 or mode != "move" or not pending_weapon.is_empty(): return
	if battle and Combat.available(actions,"move") <= 0: _note("No movement action remains."); _refresh(); return
	var available: Dictionary = _movement_paths()
	if not available.has(cell): _cancel_preview(); return
	preview_destination = cell
	preview_path = available[cell]
	if bypass or not confirm_movement: _confirm_move()
	else: _refresh()

func _confirm_move() -> void:
	if player.hp <= 0 or mode != "move" or (battle and Combat.available(actions,"move") <= 0): _cancel_preview(); return
	var available: Dictionary = _movement_paths()
	# The exact previewed path must still be valid; do not silently substitute another route.
	if not available.has(preview_destination) or available[preview_destination] != preview_path: _cancel_preview(); return
	player.pos = preview_destination
	if battle: Combat.spend(actions,"move")
	_cancel_preview(false)
	_note("Moved. Click a hex to preview another movement when available.")
	_refresh()

func _cancel_preview(refresh: bool = true) -> void:
	preview_path = []
	preview_destination = Vector2i(-1,-1)
	if refresh: _refresh()

func _open_loot_tile(cell: Vector2i, looting: bool = true) -> void:
	inspection_looting = looting
	inspected_cell = cell
	_cancel_preview(false)
	if host.panel_name != "Look": host.toggle("Look",180)
	_refresh()

func _look_panel(parent: Node) -> void:
	var nearby: bool = _map_distance(player.pos,inspected_cell) <= 1
	host.title.text = ("Loot" if nearby and inspection_looting else "Look") + " · " + str(inspected_cell)
	_wrap(parent,"Within reach: inspect and take individual items." if nearby else "At a distance: visible appearance only. Move within one hex to see stats or take items.",450)
	var found: int = 0
	for entry: Dictionary in loot:
		if entry.pos != inspected_cell: continue
		found += 1
		_add_item_card(parent,entry.item,nearby,true,450)
		if nearby and inspection_looting:
			var source: Dictionary = {"zone":"ground","id":entry.item.item_id}
			var target: Dictionary = {"zone":"pickup"}
			var take: Button = Parts.button(parent,"Take",func(): _transfer(source,target),player.hp > 0)
			take.tooltip_text = preload("res://Production/Actors/item_inspection.gd").tooltip(entry.item)
	if found == 0: Parts.label(parent,"Nothing remains on this tile.")
	if nearby and battle:
		_wrap(parent,"Each item costs activation, then attack actions, then movement. No space or no actions means nothing is taken.",450)
	var destination: Vector2i = inspected_cell
	if _movement_paths().has(destination):
		Parts.button(parent,"Move to this tile…",func():
			host.close()
			_request_movement(destination), player.hp > 0 and (not battle or Combat.available(actions,"move") > 0))

func _add_item_card(parent: Node, item: Dictionary, known: bool, horizontal: bool, width: float) -> void:
	var card: Control = Card.new()
	card.item = item
	card.within_reach = known
	card.horizontal = horizontal
	card.card_width = width
	parent.add_child(card)

func _start_run() -> void:
	player = Actors.create(dice_slots.slice(6,12))
	cooldowns = Cooldowns.new()
	messages.clear()
	round_number = 1
	map_world = MapWorld.new(randi_range(1,2147480000))
	active_map = map_world.maps.global
	player.pos = active_map.spawn_cell
	enemy = {"pos":Vector2i(-1,-1),"hp":0}
	loot = []
	battle = false
	actions = Combat.allowance(player)
	pending_weapon = {}
	retreat_available = false
	mode = "move"
	_note("Global map. Move to a region and open Map to enter it.")
	_arena_ui()

func _save_map() -> void:
	map_world.states[active_map.id] = {"pos":player.pos,"enemy":enemy,"loot":loot,"battle":battle,"actions":actions.duplicate(true),"riposte":player.riposte,"counter_weapon":player.get("counter_weapon",{})}

func _enter_map() -> void:
	if active_map == null or not active_map.links.has(player.pos) or player.hp <= 0: return
	if not pending_weapon.is_empty() or retreat_available:
		_note("Finish or cancel the skill before travelling.")
		_refresh()
		return
	if battle and Combat.available(actions,"activation") <= 0:
		_note("Travelling during combat requires an activation action.")
		_refresh()
		return
	var link: Dictionary = active_map.links[player.pos]
	if battle: Combat.spend(actions,"activation")
	_save_map()
	active_map = map_world.resolve(link)
	if map_world.states.has(active_map.id):
		var state: Dictionary = map_world.states[active_map.id]
		player.pos = state.pos
		enemy = state.enemy
		loot = state.loot
		battle = state.battle
		actions = state.actions.duplicate(true)
		player.riposte = state.riposte
		player.counter_weapon = state.counter_weapon
		actions.attack = mini(actions.attack,maxi(0,Combat.allowance(player).attack-actions.used_attacks))
	else:
		player.pos = link.get("arrival",Vector2i(1,3))
		enemy = {"pos":Vector2i(-1,-1),"hp":0}
		loot = []
		battle = link.kind in ["Dungeon","Tower"]
		if battle:
			enemy = Actors.create(Actors.dice(),true)
			enemy.pos = Vector2i(6,3)
			cooldowns.enter_combat()
		actions = Combat.allowance(player)
		player.riposte = false
	mode = "move"
	pending_weapon = {}
	retreat_available = false
	_note("Entered " + active_map.title + ". Orange hex markers lead to other maps; use Map or Activate while standing on one.")
	_arena_ui()

func _map_transition_button(parent: Node) -> void:
	if active_map == null: return
	if active_map.links.has(player.pos):
		Parts.button(parent,active_map.links[player.pos].label,_enter_map,player.hp > 0)
		if battle: _wrap(parent,"Travel costs activation in combat; the encounter waits in its current state.")

func _map_panel(parent: Node) -> void:
	if active_map == null: return
	Parts.label(parent,active_map.layer+" · "+active_map.title,22)
	Parts.button(parent,"Center on player",func(): board.focus_player())
	_wrap(parent,"Drag the map with left or middle mouse to pan. Click without dragging to act.")
	Parts.label(parent,"World seed: %d" % map_world.world_seed,14)
	if active_map.biomes.has(player.pos): Parts.label(parent,"Biome: " + active_map.biomes[player.pos])
	_wrap(parent,"Position %s · %s. Black hexes are blocked. Orange markers: L region, D dungeon, T town/tower, R return." % [player.pos,("Radius %d · %d cells" % [active_map.hex_radius,active_map.cells().size()]) if active_map.hex_radius > 0 else ("%d × %d hexes" % [active_map.dimensions.x,active_map.dimensions.y])])
	_map_transition_button(parent)
	if active_map.layer == "Global":
		_wrap(parent,"World: 80 wide × 40 playable rows, ice caps north/south, east–west wrap.\nTravel: mountains ×3; hills, swamp, marsh, salt marsh ×2; forest ×1.5; plains, wasteland, desert ×1. Costs apply when entering each hex. Water travel remains provisional; boats are not implemented.")
		return
	for cell: Vector2i in active_map.links:
		Parts.label(parent,"%s · %s" % [cell,active_map.links[cell].label],14)

func _reachable(limit: int) -> Dictionary:
	return Paths.paths(player.pos,limit,_blocked(),active_map)

func _enemy_route() -> Array:
	var paths: Dictionary = Paths.paths(enemy.pos,10000,[player.pos],active_map)
	var best: Array = []
	for cell: Vector2i in paths:
		if Combat.distance(cell,player.pos) == 1 and (best.is_empty() or paths[cell].size() < best.size()): best = paths[cell]
	return best

func _spawn_enemy() -> void:
	if active_map == null:
		super._spawn_enemy()
		return
	if active_map.layer != "POI": return
	cooldowns.enter_combat()
	enemy = Actors.create(Actors.dice(),true)
	enemy.pos = Vector2i(6,3) if player.pos != Vector2i(6,3) else Vector2i(6,2)
	battle = true
	player.riposte = false
	pending_weapon = {}
	retreat_available = false
	actions = Combat.allowance(player)
	mode = "move"
	_arena_ui()

func _open_tile_choices(cell: Vector2i) -> void:
	inspected_cell = cell
	_cancel_preview(false)
	if host.panel_name != "Tile": host.toggle("Tile",180)
	_refresh()

func _tile_panel(parent: Node) -> void:
	var cell: Vector2i = inspected_cell
	host.title.text = "Tile · " + str(cell)
	var nearby: bool = _map_distance(player.pos,cell) <= 1
	Parts.button(parent,"Move",func():
		host.close()
		mode = "move"
		_request_movement(cell),_movement_paths().has(cell) and (not battle or Combat.available(actions,"move") > 0))
	Parts.button(parent,"Loot",func(): _open_loot_tile(cell,true),nearby and player.hp > 0)
	Parts.button(parent,"Look",func(): _open_loot_tile(cell,false))
	if not nearby: _wrap(parent,"Move within one hex to loot. Looking from here reveals appearance only.")
	if active_map != null and active_map.links.has(cell):
		_wrap(parent,"Entrance: " + active_map.links[cell].label)
		if player.pos == cell: _map_transition_button(parent)
		else: _wrap(parent,"Move onto the entrance to use it.")

func _map_distance(a: Vector2i, b: Vector2i) -> int:
	return active_map.distance(a,b) if active_map != null else Combat.distance(a,b)

func _shop_panel(parent: Node) -> void:
	Parts.label(parent,"Shop")

func _quests_panel(parent: Node) -> void:
	Parts.label(parent,"No quests available.")
