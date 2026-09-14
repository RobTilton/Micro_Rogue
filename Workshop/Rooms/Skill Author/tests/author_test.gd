extends SceneTree
const Author = preload("res://Workshop/Rooms/Skill Author/Tool/skill_author.gd")
const Draft = preload("res://Workshop/Rooms/Skill Author/Tool/skill_draft.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Skill Author/tests/author_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(45).timeout.connect(func(): quit(2))
	var author = load("res://Workshop/Rooms/Skill Author/Tool/SkillAuthor.tscn").instantiate()
	root.add_child(author)
	check(not author.save_revision(Author.ROOM+"tests/drafts/").ok,"blank skill refused")
	var draft = author.draft
	draft.display_name = "Workshop Test Skill"
	draft.skill_id = "workshop_test_skill"
	draft.effect_description = "Adjacent Martial skills receive -1 cooldown. WIP: decide minimum cooldown later."
	draft.skill_bucket = "Mental Mastery"
	draft.tags = PackedStringArray(["support","cooldown"])
	draft.prerequisite_skill_ids = PackedStringArray(["mental_origin"])
	draft.chain_amount = 5
	draft.chain_measure = "Minimum qualifying cells"
	draft.open_questions = "Should repeated cell contacts stack?"
	author.add_adjacency_rule()
	draft.adjacency_rules[0].requirement = "Optional bonus"
	draft.adjacency_rules[0].minimum = 3
	draft.adjacency_rules[0].skill_bucket = "Martial"
	draft.adjacency_rules[0].bonus_or_notes = "Bonus effect idea."
	for shape: String in ["Single hex","Two hex line","Three hex line","Three hex bend","Three hex triangle","Four hex hook","Seven hex flower"]:
		draft.shape = shape
		for rotation: int in range(6):
			draft.rotation_steps = rotation
			check(draft.problems().is_empty(),"preset remains connected at every rotation")
	draft.shape = "Custom"
	draft.custom_cells.assign([Vector2i.ZERO,Vector2i(3,3)])
	check(not draft.problems().is_empty(),"disconnected footprint refused")
	draft.custom_cells.assign([Vector2i.ZERO,Vector2i.ZERO])
	check(not draft.problems().is_empty(),"duplicate footprint refused")
	draft.shape = "Four hex hook"
	draft.rotation_steps = 2
	var expected: Dictionary = draft.as_data()
	check(expected.effect_description == draft.effect_description and expected.prerequisite_skill_ids == ["mental_origin"] and expected.adjacency_rules[0].minimum == 3,"review data includes effects and requirements")
	check(not author.save_revision("res://Production/").ok,"outside Workshop writes refused")
	var first: Dictionary = author.save_revision(Author.ROOM+"tests/drafts/")
	check(first.ok,"resource and review export saved")
	var bytes: String = FileAccess.get_file_as_string(first.resource)
	var second: Dictionary = author.save_revision(Author.ROOM+"tests/drafts/")
	check(second.ok and second.revision == first.revision+1 and FileAccess.get_file_as_string(first.resource) == bytes,"new revision preserves prior file")
	var exported: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(first.json))
	var decoded_cells: Array[Vector2i] = []
	for pair: Array in exported.footprint: decoded_cells.append(Vector2i(int(pair[0]),int(pair[1])))
	check(decoded_cells == draft.footprint() and exported.effect_description == expected.effect_description and exported.status == "idea_only","JSON review matches draft")
	author.load_path = first.resource
	author.load_draft()
	check(author.draft.as_data() == expected,"resource load retains complete authoring state")
	author.draft.effect_description = "Edited copy"
	var original = ResourceLoader.load(first.resource,"",ResourceLoader.CACHE_MODE_IGNORE)
	check(original.effect_description == expected.effect_description,"editing loaded copy preserves saved original")
	author.draft.effect_description = expected.effect_description
	author.cell_to_edit = Vector2i(0,0)
	author.remove_cell()
	author.add_cell()
	check(author.draft.shape == "Custom" and author.draft.rotation_steps == 0,"shape helpers bake rotation into custom cells")
	var properties: Dictionary = {}
	for property: Dictionary in author.get_property_list(): properties[property.name] = property
	check(properties.save_button.hint == PROPERTY_HINT_TOOL_BUTTON and properties.adjacency_button.hint == PROPERTY_HINT_TOOL_BUTTON,"native inspector tool buttons exported")
	author.status = "TEST PREVIEW · draft saved and reloaded successfully."
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(Author.ROOM+"tests/author_preview.png")
	print("Skill Author: %d checks, %d failures" % [checks,failures])
	author.queue_free()
	await process_frame
	quit(1 if failures else 0)
