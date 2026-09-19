extends SceneTree
const Author = preload("res://Workshop/Rooms/Skill Author/Tool/skill_author.gd")
func _initialize() -> void:
 var author = Author.new()
 author.draft = load("res://Workshop/Rooms/Skill Author/Library/axe_cleave_r001.tres").duplicate(true)
 author.draft.attack_cells = author.draft.footprint()
 author.draft.shape = "Single hex"
 author.draft.rotation_steps = 0
 author.draft.custom_cells.clear()
 author.draft.custom_cells.append(Vector2i.ZERO)
 assert(author.draft.footprint() == [Vector2i.ZERO])
 assert(author.draft.attack_cells.size() == 3)
 author.paint_layer = "Attack pattern"
 author.cell_to_edit = Vector2i(3,0)
 author.add_cell()
 assert(author.draft.footprint() == [Vector2i.ZERO])
 author.remove_cell()
 assert(author.draft.attack_cells.size() == 3)
 author.draft.damage_calculation = "Test formula"
 assert(author.draft.as_data().damage_calculation == "Test formula")
 author.draft.damage_calculation = ""
 var saved = author.save_revision(Author.LIBRARY)
 assert(saved.ok)
 var restored = load(saved.resource)
 assert(restored.attack_cells == author.draft.attack_cells)
 assert(restored.board_definition().footprint == [Vector2i.ZERO])
 print("Pattern separation checks passed; corrected draft: ",saved.resource)
 author.free()
 quit()
