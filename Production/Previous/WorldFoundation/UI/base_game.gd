extends Control
const Cooldowns = preload("res://Production/Previous/WorldFoundation/Actors/cooldowns.gd")
const SKILL_COOLDOWNS: Dictionary = {"Lunge": 4, "Riposte": 2}
const Actors = preload("res://Production/Previous/WorldFoundation/Actors/actors.gd")
const Combat = preload("res://Production/Previous/WorldFoundation/Actors/combat.gd")
const Inventory = preload("res://Production/Previous/WorldFoundation/Actors/inventory.gd")
const Board = preload("res://Production/Previous/WorldFoundation/UI/hex_board.gd")
const DieSlot = preload("res://Production/Previous/WorldFoundation/UI/die_slot.gd")
const SplashArt = preload("res://Production/Previous/WorldFoundation/UI/splash_art.gd")
var cooldowns: RefCounted = Cooldowns.new()
var arena_active: bool = false
var lunge_button: Button
var riposte_button: Button
var root: VBoxContainer
var player: Dictionary = {}
var enemy: Dictionary = {}
var actions: Dictionary = {}
var loot: Array = []
var difficulty: int = 0
var dice_slots: Array = []
var picked_slot: int = -1
var die_buttons: Dictionary = {}
var mode: String = "move"
var battle: bool = true
var messages: Array[String] = []
var board: Control
var side: VBoxContainer
var status: Label
var log_label: Label
var pending_weapon: Dictionary = {}
var retreat_available: bool = false
var round_number: int = 1

func _ready() -> void:
	_show_splash()

func _process(delta: float) -> void:
	if arena_active and not battle and player.hp > 0 and cooldowns.advance_outside(delta): _refresh()

func _clear() -> void:
	arena_active = false
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	root = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_top = 18
	root.offset_right = -24
	root.offset_bottom = -18
	root.add_theme_constant_override("separation", 10)
	add_child(root)

func _label(parent: Node, value: String, size: int = 18) -> Label:
	var label: Label = Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label

func _button(parent: Node, title: String, callback: Callable, enabled: bool = true) -> Button:
	var button: Button = Button.new()
	button.text = title
	button.disabled = not enabled
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _show_splash() -> void:
	_clear()
	var art_space: Control = Control.new()
	art_space.custom_minimum_size = Vector2(960, 540)
	root.add_child(art_space)
	var art: Node2D = SplashArt.new()
	art.scale = Vector2(2,2)
	art.position.x = 125
	art_space.add_child(art)
	_button(root, "Begin adventure", _new_character)
	_label(root, "STARTING SLICE  /  Character creation · Hex combat · Equipment · Skills", 16)

func _new_character() -> void:
	dice_slots = Actors.dice()
	for index: int in range(6): dice_slots.append(0)
	picked_slot = -1
	_creation_ui()

func _creation_ui() -> void:
	_clear()
	die_buttons.clear()
	_label(root, "ONE ROLL. YOUR ADVENTURER.", 32)
	_label(root, "Drag dice into stats, or click a die then a stat. Swap freely before confirming.")
	_label(root, "Six d6 · No rerolls · WIL × 3 maximum HP · CON powers healing events", 16)
	for group: int in range(2):
		var row: HBoxContainer = HBoxContainer.new()
		root.add_child(row)
		for index: int in range(6):
			var slot: int = index + group * 6
			var button: Button = DieSlot.new()
			die_buttons[slot] = button
			button.slot_index = slot
			button.die_value = dice_slots[slot]
			button.custom_minimum_size = Vector2(180, 95)
			button.text = ("DIE %d" % (index + 1) if group == 0 else Actors.STATS[index]) + "\n" + (str(dice_slots[slot]) if dice_slots[slot] else "—")
			button.transferred.connect(func(source: int, target: int): _swap_dice.call_deferred(source, target))
			button.pressed.connect(func():
				if picked_slot < 0:
					picked_slot = slot
					button.modulate = Color("d99245")
				else: _swap_dice(picked_slot, slot))
			row.add_child(button)
	_button(root, "Randomly assign this roll", func():
		var values: Array = []
		for value: int in dice_slots:
			if value > 0: values.append(value)
		values.shuffle()
		dice_slots = [0,0,0,0,0,0] + values
		_creation_ui())
	var options: OptionButton = OptionButton.new()
	for title: String in ["Normal — round in your favor", "Hard — round all damage up", "True Rogue — round against you"]: options.add_item(title)
	options.selected = difficulty
	options.item_selected.connect(func(index: int): difficulty = index)
	root.add_child(options)
	var assigned: bool = true
	for index: int in range(6,12):
		if dice_slots[index] == 0: assigned = false
	_button(root, "Confirm character and enter world", _start_run, assigned)

func _swap_dice(source: int, target: int) -> void:
	var value: int = dice_slots[source]
	dice_slots[source] = dice_slots[target]
	dice_slots[target] = value
	picked_slot = -1
	_creation_ui()
	var destination: Button = die_buttons[target]
	destination.modulate.a = 0.25
	create_tween().tween_property(destination, "modulate:a", 1.0, 0.35)

func _start_run() -> void:
	player = Actors.create(dice_slots.slice(6,12))
	cooldowns = Cooldowns.new()
	messages.clear()
	round_number = 1
	loot = []
	_spawn_enemy()

func _spawn_enemy() -> void:
	cooldowns.enter_combat()
	enemy = Actors.create(Actors.dice(), true)
	enemy.pos = Vector2i(5,3)
	player.pos = Vector2i(1,3)
	player.riposte = false
	battle = true
	retreat_available = false
	pending_weapon = {}
	actions = Combat.allowance(player)
	mode = "move"
	_note("Encounter %d. You act first. Choose a skill with your starting point." % round_number)
	_arena_ui()

func _arena_ui() -> void:
	_clear()
	arena_active = true
	_label(root, "MICRO ROGUE  /  STARTING SLICE", 26)
	status = _label(root, "", 18)
	var layout: HBoxContainer = HBoxContainer.new()
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(layout)
	var left: VBoxContainer = VBoxContainer.new()
	layout.add_child(left)
	board = Board.new()
	board.custom_minimum_size = Vector2(630, 410)
	board.selected.connect(_cell_selected)
	left.add_child(board)
	var controls: HBoxContainer = HBoxContainer.new()
	left.add_child(controls)
	_button(controls, "Move", func(): mode = "move"; _refresh())
	_button(controls, "Attack", func(): mode = "attack"; _refresh())
	lunge_button = _button(controls, "Lunge", func():
		if "Lunge" in player.skills: mode = "lunge"
		_refresh())
	riposte_button = _button(controls, "Riposte", _riposte)
	_button(controls, "End turn", _end_turn)
	var extras: HBoxContainer = HBoxContainer.new()
	left.add_child(extras)
	_button(extras, "Drink Lesser Health", _drink)
	_button(extras, "Skip lunge attack / retreat", func():
		pending_weapon = {}
		retreat_available = false
		mode = "move"
		_refresh())
	log_label = _label(left, "", 16)
	log_label.custom_minimum_size.x = 620
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size.x = 565
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	side = VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(side)
	_refresh()

func _note(value: String) -> void:
	messages.append(value)
	if messages.size() > 7: messages.pop_front()

func _refresh() -> void:
	status.text = "HP %d/%d   Level %d · XP %d/%d · Points %d   |   Attack %d · Move %d · Activation %d   |   %s" % [player.hp,player.max_hp,player.level,player.xp,player.required_xp,player.points,actions.attack,actions.move,actions.activation,mode.to_upper()]
	board.player_cell = player.pos
	board.enemy_cell = enemy.pos
	board.enemy_alive = enemy.hp > 0
	board.loot_cells = []
	for entry: Dictionary in loot:
		if entry.pos not in board.loot_cells: board.loot_cells.append(entry.pos)
	lunge_button.text = "Lunge" if cooldowns.ready("Lunge") else "Lunge [%d]" % cooldowns.ticks("Lunge")
	lunge_button.disabled = not _skill_available("Lunge")
	riposte_button.text = "Riposte" if cooldowns.ready("Riposte") else "Riposte [%d]" % cooldowns.ticks("Riposte")
	riposte_button.disabled = not _skill_available("Riposte")
	board.highlights = []
	if player.hp > 0:
		if mode == "move" and (not battle or actions.move > 0): board.highlights = _reachable(3 + player.stats.DEX).keys()
		elif mode == "retreat": board.highlights = _reachable(ceili(player.stats.DEX * 0.5)).keys()
		elif mode == "lunge" and _skill_available("Lunge"):
			for direction: Vector2i in Combat.DIRECTIONS:
				for step: int in range(1, ceili(player.stats.DEX * 0.5 + 1) + 1):
					var cell: Vector2i = player.pos + direction * step
					if not Board.inside(cell) or (enemy.hp > 0 and cell == enemy.pos): break
					board.highlights.append(cell)
	board.queue_redraw()
	log_label.text = "\n".join(messages)
	for child: Node in side.get_children():
		side.remove_child(child)
		child.queue_free()
	_label(side, "YOU  " + str(player.stats), 15)
	_label(side, "ENEMY  HP %d/%d · Level %d" % [enemy.hp, enemy.max_hp, enemy.level])
	_label(side, str(enemy.stats), 15)
	_label(side, "Martial Weapons / Sword Mastery")
	for skill: String in ["Lunge", "Riposte", "Show-Off"]:
		var previous: String = "" if skill == "Lunge" else ("Lunge" if skill == "Riposte" else "Riposte")
		_button(side, ("✓ " if skill in player.skills else "Unlock · 1 point · ") + skill, func():
			player.skills.append(skill)
			player.points -= 1
			_refresh(), player.hp > 0 and player.points > 0 and skill not in player.skills and (previous == "" or previous in player.skills))
	_label(side, "Lunge: straight travel up to %d; optional attack +1.5 STR.\nRiposte: +DEX Defense; next attack triggers counter.\nShow-Off: two swords grant main/offhand attacks.\nStance Mastery — TBD" % ceili(player.stats.DEX * 0.5 + 1), 14)
	var inventory_enabled: bool = _inventory_allowed()
	for slot: String in ["main", "off", "armor", "belt"]:
		var equipped: Dictionary = player[slot]
		_label(side, slot.capitalize() + ": " + equipped.get("name", "Empty") + (" [1d%d %+d]" % [equipped.die, equipped.bonus] if not equipped.is_empty() and slot != "belt" else ""), 15)
		if not equipped.is_empty(): _button(side, "Drop " + slot, _drop_item.bind(slot), inventory_enabled)
	_label(side, "Belt: %d/%d potions" % [player.belt.get("contents", []).size(),player.belt.get("capacity", 0)], 16)
	if not player.belt.get("contents", []).is_empty():
		_button(side, "Remove potion → backpack", _remove_potion.bind(-1), inventory_enabled)
	_label(side, "BACKPACK — equip / stock / remove / drop: activation", 14)
	for index: int in range(player.bag.size()):
		var item: Dictionary = player.bag[index]
		var suffix: String = " (%d potions)" % item.contents.size() if item.kind == "belt" else ""
		_button(side, item.name + suffix + " · Equip / stock", _equip.bind(index), inventory_enabled)
		_button(side, "Drop " + item.name, _drop_item.bind("bag", index), inventory_enabled)
		if item.kind == "belt":
			if item.contents.size() < item.capacity:
				_button(side, "Stock this backpack belt", _stock_belt.bind(index), inventory_enabled)
			if not item.contents.is_empty():
				_button(side, "Remove potion → backpack", _remove_potion.bind(index), inventory_enabled)
	if not loot.is_empty():
		_label(side, "GROUND LOOT — move adjacent to collect", 14)
		for index: int in range(loot.size()):
			var entry: Dictionary = loot[index]
			_button(side, "Take " + entry.item.name + " at " + str(entry.pos), _take.bind(index), player.hp > 0 and Combat.distance(player.pos, entry.pos) <= 1)
	if not battle and player.hp > 0:
		_button(side, "Next test encounter (retain gear and ground loot)", func(): round_number += 1; _spawn_enemy())
	if player.hp <= 0:
		_label(side, "YOUR ADVENTURE ENDS", 24)
		_button(side, "Create a new adventurer", _new_character)

func _reachable(limit: int) -> Dictionary:
	var visited: Dictionary = {player.pos: 0}
	var frontier: Array = [player.pos]
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if visited[current] >= limit: continue
		for direction: Vector2i in Combat.DIRECTIONS:
			var next: Vector2i = current + direction
			if not Board.inside(next) or visited.has(next) or (enemy.hp > 0 and next == enemy.pos): continue
			visited[next] = visited[current] + 1
			frontier.append(next)
	visited.erase(player.pos)
	return visited

func _cell_selected(cell: Vector2i) -> void:
	if player.hp <= 0: return
	if not pending_weapon.is_empty():
		if cell == enemy.pos and enemy.hp > 0 and Combat.distance(player.pos, enemy.pos) <= Combat.attack_range(player):
			var weapon: Dictionary = pending_weapon
			pending_weapon = {}
			_strike(weapon, true)
			mode = "move"
		_refresh()
		return
	if mode == "retreat":
		if cell in _reachable(ceili(player.stats.DEX * 0.5)):
			player.pos = cell
			retreat_available = false
			mode = "move"
	elif mode == "move" and (not battle or actions.move > 0):
		if cell in _reachable(3 + player.stats.DEX):
			player.pos = cell
			if battle: actions.move -= 1
	elif mode == "attack" and battle and actions.attack > 0 and not _next_weapon().is_empty():
		if cell == enemy.pos and Combat.distance(player.pos, enemy.pos) <= Combat.attack_range(player): _strike(_spend_attack(), false)
	elif mode == "lunge" and _skill_available("Lunge"):
		if cell in board.highlights:
			pending_weapon = _spend_attack()
			cooldowns.start("Lunge", SKILL_COOLDOWNS.Lunge)
			player.pos = cell
			mode = "lunge: optional attack"
			_note("Lunge moved you. Click an adjacent enemy to attack, or skip.")
	_refresh()

func _spend_attack() -> Dictionary:
	var weapon: Dictionary = player.main if actions.used_attacks == 0 else player.off
	actions.used_attacks += 1
	actions.attack -= 1
	return weapon

func _strike(weapon: Dictionary, lunge: bool) -> void:
	var damage: int = Combat.attack(player, enemy, weapon, lunge, true, difficulty)
	_note("Your %s deals %d damage." % ["Lunge" if lunge else "attack", damage])
	_check_death()

func _riposte() -> void:
	if not _skill_available("Riposte"): return
	cooldowns.start("Riposte", SKILL_COOLDOWNS.get("Riposte", 0))
	player["counter_weapon"] = _spend_attack()
	player.riposte = true
	_note("Riposte: +DEX Defense until the next attack or your next turn.")
	_refresh()

func _drink() -> void:
	if player.hp <= 0 or (battle and actions.activation <= 0) or player.belt.get("contents", []).is_empty() or not pending_weapon.is_empty(): return
	if battle: actions.activation -= 1
	player.belt.contents.pop_back()
	_note("Lesser Health restores %d HP." % Combat.heal(player))
	_refresh()

func _end_turn() -> void:
	if not battle or player.hp <= 0: return
	cooldowns.end_turn()
	pending_weapon = {}
	retreat_available = false
	if enemy.hp <= enemy.max_hp * 0.5 and not enemy.belt.contents.is_empty():
		enemy.belt.contents.pop_back()
		_note("Enemy drinks Lesser Health: +%d HP." % Combat.heal(enemy))
	var route: Array = _enemy_route()
	for step: int in range(mini(3 + enemy.stats.DEX,route.size())):
		if Combat.distance(enemy.pos,player.pos) <= 1: break
		enemy.pos = route[step]
	if Combat.distance(enemy.pos,player.pos) <= 1:
		var counter: bool = player.riposte
		var damage: int = Combat.attack(enemy,player,enemy.main,false,false,difficulty)
		player.riposte = false
		_note("Enemy attacks for %d damage." % damage)
		if counter and player.hp > 0 and Combat.distance(player.pos,enemy.pos) <= Combat.attack_range(player):
			var retaliation: int = Combat.attack(player,enemy,player.counter_weapon,false,true,difficulty)
			_note("Riposte counters for %d damage." % retaliation)
			if retaliation > 0:
				retreat_available = true
				_note("Choose optional Riposte movement, or skip it.")
	player.riposte = false
	actions = Combat.allowance(player)
	mode = "retreat" if retreat_available else "move"
	_check_death()
	_refresh()

func _check_death() -> void:
	if enemy.hp <= 0 and battle:
		battle = false
		for item: Dictionary in Inventory.possessions(enemy):
			loot.append({"item": item, "pos": enemy.pos})
		Actors.award_xp(player, enemy.level)
		_note("Enemy defeated. +%d XP. Its remaining possessions are on the ground." % enemy.level)
	if player.hp <= 0:
		battle = false
		_note("You died. Play, survive, learn, and try again.")

func _equip(index: int) -> void:
	if not _inventory_allowed(): return
	var before: int = Combat.allowance(player).attack
	if Inventory.equip(player,index):
		if battle: actions.activation -= 1
		var after: int = Combat.allowance(player).attack
		# Equipment cannot replenish spent attacks by repeated swapping.
		if after < before: actions.attack = mini(actions.attack, maxi(0,after - actions.used_attacks))
		_note("Equipment changed. Extra offhand allowance applies next turn.")
	_refresh()

func _stock_belt(index: int) -> void:
	if not _inventory_allowed(): return
	var belt: Dictionary = player.bag[index]
	if belt.contents.size() >= belt.capacity: return
	for potion_index: int in range(player.bag.size()):
		if player.bag[potion_index].kind == "potion":
			belt.contents.append(player.bag[potion_index])
			player.bag.remove_at(potion_index)
			if battle: actions.activation -= 1
			_refresh()
			return
	if not player.belt.get("contents", []).is_empty():
		belt.contents.append(player.belt.contents.pop_back())
		if battle: actions.activation -= 1
	_refresh()

func _take(index: int) -> void:
	if player.hp <= 0 or not pending_weapon.is_empty() or Combat.distance(player.pos,loot[index].pos) > 1: return
	if battle and not Combat.loot_cost(actions): return
	Inventory.receive(player,loot[index].item)
	loot.remove_at(index)
	_refresh()

func _next_weapon() -> Dictionary:
	return player.main if actions.used_attacks == 0 else player.off

func _skill_available(skill: String) -> bool:
	return player.hp > 0 and battle and actions.attack > 0 and skill in player.skills and cooldowns.ready(skill) and not _next_weapon().is_empty() and pending_weapon.is_empty() and not retreat_available

func _inventory_allowed() -> bool:
	return player.hp > 0 and (not battle or actions.activation > 0) and pending_weapon.is_empty()

func _drop_item(slot: String, index: int = -1) -> void:
	if not _inventory_allowed(): return
	var item: Dictionary = Inventory.drop(player, slot, index)
	if item.is_empty(): return
	if battle: actions.activation -= 1
	loot.append({"item": item, "pos": player.pos})
	if slot in ["main", "off"]:
		player.riposte = false
		actions.attack = mini(actions.attack, maxi(0, Combat.allowance(player).attack - actions.used_attacks))
	_note("Dropped %s at your feet." % item.name)
	_refresh()

func _remove_potion(belt_index: int) -> void:
	if not _inventory_allowed(): return
	var belt: Dictionary = player.belt if belt_index == -1 else player.bag[belt_index]
	if Inventory.remove_potion(player, belt):
		if battle: actions.activation -= 1
		_note("Moved Lesser Health from belt to backpack.")
	_refresh()

func _enemy_route() -> Array:
	var route: Array = []
	var current: Vector2i = enemy.pos
	for step: int in range(3 + enemy.stats.DEX):
		if Combat.distance(current,player.pos) <= 1: break
		var best: Vector2i = current
		for direction: Vector2i in Combat.DIRECTIONS:
			var next: Vector2i = current + direction
			if Board.inside(next) and next != player.pos and Combat.distance(next,player.pos) < Combat.distance(best,player.pos): best = next
		current = best
		route.append(current)
	return route
