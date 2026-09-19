@tool
extends Node2D
const Board = preload("res://Production/Actors/skill_board.gd")
const BoardView = preload("res://Production/UI/skill_board_view.gd")
const Draft = preload("res://Workshop/Rooms/Skill Author/Tool/skill_draft.gd")
const ROOM: String = "res://Workshop/Rooms/Skill Author/"
const LIBRARY: String = ROOM+"Library/"
@export_category("Skill Author")
## Expand this resource in the Inspector to author the skill.
@export var draft: Draft = Draft.new()
@export_tool_button("Save New Revision", "Save") var save_button: Callable = save_draft
@export_tool_button("New Blank Skill", "New") var new_button: Callable = new_draft
@export_tool_button("Add Adjacency Rule", "Add") var adjacency_button: Callable = add_adjacency_rule
@export_category("Board Test")
## F6 opens a radius-four board sandbox instead of the footprint painter.
@export var test_on_skill_board: bool = false
## Add saved draft resources to test multiple skills together with the current Draft.
@export var companion_drafts: Array[Draft] = []
var test_actor: Dictionary = {"skills":[],"skill_board":Board.blank()}
var test_definitions: Dictionary = {}
var test_selected: String = ""
var test_origin: String = ""
var test_rotation: int = 0
var test_view: Control
var test_status: Label
@export_category("Load Existing Draft")
@export_file("*.tres") var load_path: String = ""
@export_tool_button("Load Copy for Editing", "Load") var load_button: Callable = load_draft
@export_category("Shape Painter")
@export_enum("Skill board footprint","Attack pattern") var paint_layer: String = "Skill board footprint"
@export_category("Custom Shape Helpers")
## Axial q,r. The preview labels every cell. First edit converts the selected preset to Custom.
@export var cell_to_edit: Vector2i = Vector2i.ZERO
@export_tool_button("Add Hex at q,r", "Add") var add_button: Callable = add_cell
@export_tool_button("Remove Hex at q,r", "Remove") var remove_button: Callable = remove_cell
@export_category("Status")
@export_multiline var status: String = "Expand Draft in the Inspector. Save New Revision writes a .tres and readable .json in this Room's Library."
var last_signature: String = ""
var preview_origin := Vector2(520,350)
const RADIUS: float = 32.0
func _ready() -> void:
	set_process(true)
	if not Engine.is_editor_hint() and test_on_skill_board:
		_make_board_test()
		return
	if not Engine.is_editor_hint():
		var buttons := HBoxContainer.new()
		buttons.position = Vector2(24,690)
		add_child(buttons)
		for entry: Array in [["Save New Revision",save_draft],["New Blank Skill",new_draft],["Board footprint",func(): paint_layer = "Skill board footprint"],["Attack pattern",func(): paint_layer = "Attack pattern"]]:
			var button := Button.new()
			button.text = entry[0]
			button.pressed.connect(entry[1])
			buttons.add_child(button)
func _process(_delta: float) -> void:
	var signature: String = str(draft.as_data())+status+paint_layer if draft != null else status
	if signature != last_signature:
		last_signature = signature
		queue_redraw()
func add_adjacency_rule() -> void:
	if draft == null: draft = Draft.new()
	draft.adjacency_rules.append(Draft.Adjacency.new())
	draft.emit_changed()
	status = "Added a rule. Expand Draft → Adjacency → Adjacency Rules to edit it."
	notify_property_list_changed()
func new_draft() -> void:
	draft = Draft.new()
	status = "New blank skill. Previously saved revisions remain in Library."
	notify_property_list_changed()
func load_draft() -> void:
	if not load_path.begins_with(ROOM) or load_path.get_extension() != "tres":
		status = "Choose a Workshop Skill Author .tres draft."
		return
	var loaded = ResourceLoader.load(load_path,"",ResourceLoader.CACHE_MODE_IGNORE)
	if not loaded is Draft:
		status = "That file is not a skill draft."
		return
	draft = loaded.duplicate(true)
	status = "Loaded a copy. Saving creates a new revision; the original stays intact."
	notify_property_list_changed()
func _customize() -> void:
	if draft == null: draft = Draft.new()
	if draft.shape != "Custom" or draft.rotation_steps != 0:
		draft.custom_cells = draft.footprint()
		draft.shape = "Custom"
		draft.rotation_steps = 0
func add_cell() -> void:
	if paint_layer == "Attack pattern":
		if draft == null: draft = Draft.new()
		if cell_to_edit not in draft.attack_cells: draft.attack_cells.append(cell_to_edit)
		draft.emit_changed()
		return
	_customize()
	if not draft.custom_cells.has(cell_to_edit): draft.custom_cells.append(cell_to_edit)
	draft.emit_changed()
func remove_cell() -> void:
	if paint_layer == "Attack pattern":
		if draft != null: draft.attack_cells.erase(cell_to_edit); draft.emit_changed()
		return
	_customize()
	draft.custom_cells.erase(cell_to_edit)
	draft.emit_changed()
func save_draft() -> void:
	var result: Dictionary = save_revision(LIBRARY)
	status = result.message
	notify_property_list_changed()
	if not result.ok: push_warning("Workshop/Rooms/Skill Author/Tool/skill_author.gd: "+status)
func save_revision(directory: String) -> Dictionary:
	if not directory.begins_with(ROOM) or directory.contains(".."):
		return {"ok":false,"message":"Output must remain inside the Skill Author Workshop Room."}
	if draft == null: return {"ok":false,"message":"Create a Draft resource first."}
	var errors: PackedStringArray = draft.problems()
	if not errors.is_empty(): return {"ok":false,"message":"Cannot save yet:\n"+"\n".join(errors)}
	if DirAccess.make_dir_recursive_absolute(directory) != OK: return {"ok":false,"message":"Could not create the draft directory."}
	var revision: int = 1
	var stem: String = directory.path_join(draft.identifier()+"_r%03d" % revision)
	while FileAccess.file_exists(stem+".tres") or FileAccess.file_exists(stem+".json"):
		revision += 1
		stem = directory.path_join(draft.identifier()+"_r%03d" % revision)
	var saved: Draft = draft.duplicate(true)
	saved.skill_id = draft.identifier()
	var error: Error = ResourceSaver.save(saved,stem+".tres")
	if error != OK: return {"ok":false,"message":"Could not save the resource (error %d)." % error}
	var file := FileAccess.open(stem+".json",FileAccess.WRITE)
	if file == null: return {"ok":false,"message":"Resource saved at "+stem+".tres, but JSON export failed. Resource retained."}
	var data: Dictionary = saved.as_data()
	data.revision = revision
	file.store_string(JSON.stringify(data,"\t")+"\n")
	file.flush()
	if file.get_error() != OK: return {"ok":false,"message":"Resource saved; JSON write failed. Files retained at "+stem}
	return {"ok":true,"message":"Saved revision %d:\n%s.tres\n%s.json" % [revision,stem,stem],"resource":stem+".tres","json":stem+".json","revision":revision}
func center(cell: Vector2i) -> Vector2:
	return preview_origin+Vector2(sqrt(3.0)*(cell.x+cell.y*0.5),1.5*cell.y)*RADIUS
func _draw() -> void:
	if not Engine.is_editor_hint() and test_on_skill_board: return
	var font: Font = ThemeDB.fallback_font
	draw_rect(Rect2(0,0,1080,760),Color("101820"))
	draw_string(font,Vector2(24,40),"WORKSHOP · SKILL AUTHOR",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("eac56d"))
	draw_string(font,Vector2(24,69),"Select SkillAuthor, expand Draft in the Inspector, and edit your idea.",HORIZONTAL_ALIGNMENT_LEFT,-1,17)
	if draft == null: return
	draw_string(font,Vector2(24,103),draft.display_name if not draft.display_name.is_empty() else "Unnamed skill",HORIZONTAL_ALIGNMENT_LEFT,-1,24)
	draw_string(font,Vector2(24,130),draft.bucket()+" · "+draft.skill_kind+" · "+str(draft.footprint().size())+" hexes",HORIZONTAL_ALIGNMENT_LEFT,-1,17)
	var cells: Array[Vector2i] = draft.attack_cells if paint_layer == "Attack pattern" else draft.footprint()
	draw_string(font,Vector2(24,160),paint_layer+" · actor/anchor (0,0) · facing RIGHT →",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("eac56d"))
	var visible: Dictionary = {}
	for cell: Vector2i in Board.cells(): visible[cell] = true
	for cell: Vector2i in cells: visible[cell] = true
	for cell: Vector2i in visible:
		var points := PackedVector2Array()
		for corner: int in range(6): points.append(center(cell)+Vector2.from_angle(deg_to_rad(60*corner-30))*(RADIUS-2))
		var occupied: bool = cells.has(cell)
		draw_colored_polygon(points,Color("426e78") if occupied else Color("1b2933"))
		points.append(points[0])
		draw_polyline(points,Color("eac56d") if occupied else Color("344650"),2 if occupied else 1)
		draw_string(font,center(cell)+Vector2(-18,5),"%d,%d" % [cell.x,cell.y],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE if occupied else Color("6b818b"))
	var errors: PackedStringArray = draft.problems()
	var message: String = "Shape ready · saved ideas do not grant gameplay effects." if errors.is_empty() else " / ".join(errors)
	draw_multiline_string(font,Vector2(24,570),message,HORIZONTAL_ALIGNMENT_LEFT,1020,16,-1,Color("eac56d"))
	draw_multiline_string(font,Vector2(24,615),status,HORIZONTAL_ALIGNMENT_LEFT,1020,14)
	draw_string(font,Vector2(24,744),"Presets and rotation: Inspector. Custom: Add/Remove q,r above. Optional F6: click hexes to paint, then Save.",HORIZONTAL_ALIGNMENT_LEFT,-1,14)
func _unhandled_input(event: InputEvent) -> void:
	if test_on_skill_board or Engine.is_editor_hint() or not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT: return
	var best := Vector2i.ZERO
	var distance: float = INF
	for cell: Vector2i in Board.cells():
		var candidate: float = center(cell).distance_to(event.position)
		if candidate < distance: distance = candidate; best = cell
	if distance > RADIUS: return
	cell_to_edit = best
	if draft != null and (draft.attack_cells if paint_layer == "Attack pattern" else draft.footprint()).has(best): remove_cell()
	else: add_cell()

func _test_button(parent: Node, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)

func _make_board_test() -> void:
	var panel := HBoxContainer.new()
	panel.position = Vector2(20,20)
	add_child(panel)
	test_view = BoardView.new()
	panel.add_child(test_view)
	var controls := VBoxContainer.new()
	panel.add_child(controls)
	var entries: Array = companion_drafts.duplicate()
	entries.append(draft)
	for entry in entries:
		if entry == null or not entry.problems().is_empty(): continue
		var id: String = entry.identifier()
		test_definitions[id] = entry.board_definition()
		if id not in test_actor.skills: test_actor.skills.append(id)
	test_view.actor = test_actor
	test_view.definitions = test_definitions
	for family: String in Board.families(test_actor,test_definitions):
		_test_button(controls,"Origin: "+family,func(): test_origin = family; test_selected = ""; _test_refresh())
	for id: String in test_definitions:
		_test_button(controls,id,func(): test_selected = id; test_origin = ""; _test_refresh())
	_test_button(controls,"Rotate footprint",func(): test_rotation = (test_rotation+1)%6; _test_refresh())
	_test_button(controls,"Remove selected",func(): test_actor.skill_board.placements.erase(test_selected); _test_refresh())
	_test_button(controls,"Reset sandbox",func(): test_actor.skill_board = Board.blank(); _test_refresh())
	test_status = Label.new()
	controls.add_child(test_status)
	test_view.hex_clicked.connect(func(cell: Vector2i):
		var reason: String = Board.place_origin(test_actor,test_origin,cell,test_definitions) if not test_origin.is_empty() else Board.place(test_actor,test_selected,cell,test_rotation,false,test_definitions)
		_test_refresh()
		if not reason.is_empty(): test_status.text += "\n"+reason)
	_test_refresh()

func _test_refresh() -> void:
	test_view.selected = test_selected
	test_view.footprint_rotation = test_rotation
	test_view.queue_redraw()
	test_status.text = "Sandbox only; no gameplay effects.\nSelecting: "+(test_origin+" origin" if not test_origin.is_empty() else test_selected)
	for id: String in Board.evaluate(test_actor,test_definitions):
		test_status.text += "\n"+id+": "+Board.evaluate(test_actor,test_definitions)[id].reason
