extends "res://Production/Previous/WorldFoundation/UI/actor_game.gd"
const Persistent = preload("res://Production/Previous/WorldFoundation/Persistence/persistent_actor_world.gd")
const Journal = preload("res://Production/Previous/WorldFoundation/Persistence/autosave_journal.gd")
var autosave_directory: String = Journal.DIRECTORY
var snapshot_directory: String = Persistent.SAVE_DIR
var journal: RefCounted = Journal.new()
var prepared_world: RefCounted
var starting_world: bool = false

func _ready() -> void:
	get_tree().auto_accept_quit = false
	super._ready()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _automatic_checkpoint(): get_tree().quit()
		return
	super._notification(what)

func _new_character() -> void:
	if starting_world: return
	starting_world = true
	_clear()
	Parts.label(root,"Generating world…",28)
	await get_tree().process_frame
	await get_tree().process_frame
	# Global identity and all Local descriptors exist and are durable before character creation.
	prepared_world = Persistent.new(randi_range(1,2147480000))
	simulation = prepared_world
	map_world = simulation.maps
	journal = Journal.new()
	starting_world = false
	if not _automatic_checkpoint(): return
	super._new_character()
	_save_creation()

func _start_run() -> void:
	super._start_run()
	simulation.creation.clear()
	_automatic_checkpoint()

func _swap_dice(source: int, target: int) -> void:
	super._swap_dice(source,target)
	_save_creation()

func _save_creation() -> void:
	if simulation == null or simulation.player_id != 0: return
	simulation.creation = {"dice_slots":dice_slots.duplicate()}
	simulation.difficulty = difficulty
	_automatic_checkpoint()

func _automatic_checkpoint() -> bool:
	if simulation == null: return true
	if simulation.player_id == 0: simulation.difficulty = difficulty
	var snapshot: Dictionary = simulation.snapshot(journal.previous)
	var reason: String = Persistent.validate_snapshot(snapshot) if journal.previous.is_empty() else ""
	var outcome: Dictionary = journal.checkpoint(snapshot,autosave_directory) if reason.is_empty() else {"ok":false,"reason":"Automatic save refused: "+reason}
	if not outcome.ok:
		if frame_ready: _note(outcome.reason); _refresh()
		else: Parts.label(root,outcome.reason)
		return false
	return true

func _finish(outcome: Dictionary, advance_outside: bool = true) -> void:
	super._finish(outcome,advance_outside)
	if outcome.ok: _automatic_checkpoint()

func _end_turn() -> void:
	super._end_turn()
	_automatic_checkpoint()

func _command(command: String) -> void:
	super._command(command)
	if command == "Cancel": _automatic_checkpoint()


func _make_simulation(seed_value: int) -> RefCounted:
	if prepared_world != null:
		var world: RefCounted = prepared_world
		prepared_world = null
		return world
	journal = Journal.new()
	return Persistent.new(seed_value)

func _show_splash() -> void:
	super._show_splash()
	for child: Node in root.get_children():
		if child is Button and child.text == "Begin adventure": child.text = "Generate new world"
	Parts.label(root,"Generate the world first, then create its adventurer. Progress saves automatically.",16)
	Parts.button(root,"Continue world",_load_latest,not _latest_save().is_empty())

func _save_paths() -> Array[String]:
	var candidates: Array[Dictionary] = []
	for directory: String in [snapshot_directory,autosave_directory]:
		if not DirAccess.dir_exists_absolute(directory): continue
		for filename: String in DirAccess.get_files_at(directory):
			if filename.get_extension() not in ["world","journal"]: continue
			var path: String = directory.path_join(filename)
			candidates.append({"path":path,"modified":FileAccess.get_modified_time(path)})
	candidates.sort_custom(func(a: Dictionary,b: Dictionary):
		if a.modified != b.modified: return a.modified > b.modified
		if a.path.get_extension() != b.path.get_extension(): return a.path.get_extension() == "journal"
		return a.path.get_file() > b.path.get_file())
	var paths: Array[String] = []
	for candidate: Dictionary in candidates: paths.append(candidate.path)
	return paths

func _latest_save() -> String:
	var paths: Array[String] = _save_paths()
	return "" if paths.is_empty() else paths[0]

func _load_latest() -> void:
	for path: String in _save_paths():
		if _load_path(path): return

func _load_path(path: String) -> bool:
	var candidate = Persistent.new(1729)
	var outcome: Dictionary = candidate.load_game(path)
	if not outcome.ok:
		if frame_ready: _note(outcome.reason); _refresh()
		else: Parts.label(root,outcome.reason)
		return false
	simulation = candidate
	journal = Journal.new()
	map_world = simulation.maps
	if simulation.player_id == 0:
		prepared_world = simulation
		difficulty = simulation.difficulty
		if simulation.creation.has("dice_slots"):
			dice_slots = simulation.creation.dice_slots.duplicate()
			picked_slot = -1
			_creation_ui()
		else:
			super._new_character()
			_save_creation()
		return true
	prepared_world = null
	player = simulation.actors[simulation.player_id]
	cooldowns = player.clock
	difficulty = simulation.difficulty
	selected_actor_id = -1
	drag.finish()
	mode = "lunge: optional attack" if not player.pending.is_empty() else "retreat" if player.retreat else "move"
	messages.clear()
	_note(outcome.reason)
	_sync()
	_arena_ui()
	return true

func _options_panel(parent: Node) -> void:
	super._options_panel(parent)
	Parts.label(parent,"World progress saves automatically.",16)
	Parts.button(parent,"Save an extra snapshot",_save_world)
	Parts.button(parent,"Continue latest checkpoint",_load_latest,not _latest_save().is_empty())
	Parts.button(parent,"Unload inactive maps",_unload_inactive)

func _save_world() -> void:
	var outcome: Dictionary = simulation.save_game(snapshot_directory)
	_note(outcome.reason)
	_refresh()

func _unload_inactive() -> void:
	var count: int = 0
	for id: String in map_world.maps.keys():
		if id != player.map_id and simulation.unload_location(id).ok: count += 1
	_note("Stored and unloaded %d inactive maps." % count)
	_refresh()

func _map_panel(parent: Node) -> void:
	super._map_panel(parent)
	if player.map_id != "global":
		Parts.button(parent,"Discover another dungeon",_discover_dungeon)

func _discover_dungeon() -> void:
	var outcome: Dictionary = map_world.request_poi(player.map_id,"Dungeon")
	_note(outcome.reason)
	_refresh()
	if outcome.ok: _automatic_checkpoint()

var travel_transition_active: bool = false
var travel_cover: ColorRect

func _input(event: InputEvent) -> void:
	if travel_transition_active or starting_world:
		get_viewport().set_input_as_handled()
		return
	super._input(event)

func _enter_map() -> void:
	if travel_transition_active or simulation == null: return
	# Refused travel should respond immediately without flashing the screen.
	if not simulation.ready(player) or player.actions.activation <= 0 or not active_map.links.has(player.pos):
		super._enter_map()
		return
	travel_transition_active = true
	if not is_instance_valid(travel_cover):
		var layer := CanvasLayer.new()
		layer.layer = 100
		add_child(layer)
		travel_cover = ColorRect.new()
		travel_cover.color = Color(0,0,0,0)
		travel_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		travel_cover.mouse_filter = Control.MOUSE_FILTER_STOP
		layer.add_child(travel_cover)
	travel_cover.show()
	var fade_out: Tween = create_tween()
	fade_out.tween_property(travel_cover,"color:a",1.0,0.12)
	await fade_out.finished
	# Present an opaque frame before synchronous generation can stall rendering.
	await get_tree().process_frame
	await get_tree().process_frame
	super._enter_map()
	_automatic_checkpoint()
	await get_tree().process_frame
	var fade_in: Tween = create_tween()
	fade_in.tween_property(travel_cover,"color:a",0.0,0.12)
	await fade_in.finished
	travel_cover.hide()
	travel_transition_active = false

func _clear() -> void:
	# The inherited scene builder clears all direct children on every map entry.
	var overlay: Node = travel_cover.get_parent() if is_instance_valid(travel_cover) else null
	if overlay != null: remove_child(overlay)
	super._clear()
	if overlay != null:
		add_child(overlay)
		travel_cover.size = get_viewport_rect().size
