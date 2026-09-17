@tool
extends Resource
const Adjacency = preload("res://Workshop/Rooms/Skill Author/Tool/adjacency_rule.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
@export_category("Identity")
## Stable lowercase identifier, e.g. martial_show_off. Leave blank to derive from the name.
@export var skill_id: String = ""
@export var display_name: String = ""
@export_enum("Martial","Mental Mastery","Magic","Monk","Custom") var skill_bucket: String = "Martial"
@export var custom_bucket: String = ""
## Family identity is Skill Bucket; tags are retained as legacy notes only.
@export_storage var tags: PackedStringArray = []
@export_storage var is_origin: bool = false
@export_enum("Active ability","Passive","Neighbor modifier","Origin","Undecided") var skill_kind: String = "Undecided"
@export_category("Footprint")
@export_enum("Single hex","Two hex line","Three hex line","Three hex bend","Three hex triangle","Four hex hook","Seven hex flower","Custom") var shape: String = "Single hex"
@export_range(0,5) var rotation_steps: int = 0
@export var allow_rotation: bool = true
@export var allow_mirror: bool = false
## Axial coordinates. Use the author's Add/Remove Cell buttons if easier than editing this array.
@export var custom_cells: Array[Vector2i] = [Vector2i.ZERO]
@export_category("Unlock Prerequisites")
@export_range(0,100) var skill_point_cost: int = 1
@export var prerequisite_skill_ids: PackedStringArray = []
@export_enum("All listed","Any listed","Undecided") var prerequisite_mode: String = "All listed"
@export_range(0,100) var minimum_points_in_bucket: int = 0
@export_multiline var prerequisite_notes: String = ""
@export_category("Origin and Chain")
@export_storage var requires_origin: bool = true
## Blank means the skill's own bucket origin.
@export_storage var origin_skill_id: String = ""
@export_storage var chain_bucket: String = "Same as skill"
@export_storage var chain_measure: String = "Undecided"
@export_storage var chain_amount: int = 0
@export_storage var chain_tags: PackedStringArray = []
## Minimum distinct skills back to this family origin. Origin counts as 1; self is excluded.
@export_range(0,60) var required_chain_length: int = 0
@export_multiline var chain_notes: String = ""
@export_category("Adjacency")
## Add an element, then choose New Resource of the adjacency-rule type and expand it.
@export var adjacency_rules: Array[Adjacency] = []
@export_multiline var adjacency_notes: String = ""
@export_category("Effect Idea")
## Plain-language intent. This does not execute code or grant a runtime effect.
@export_multiline var effect_description: String = ""
@export_multiline var optional_bonus_description: String = ""
@export_multiline var balance_notes: String = ""
@export_multiline var open_questions: String = ""
func bucket() -> String: return custom_bucket.strip_edges() if skill_bucket == "Custom" else skill_bucket
func identifier() -> String:
	return skill_id.strip_edges() if not skill_id.strip_edges().is_empty() else display_name.to_snake_case().replace(" ","_").replace("-","_")
func footprint() -> Array[Vector2i]:
	var presets: Dictionary = {
		"Single hex":[Vector2i(0,0)],"Two hex line":[Vector2i(0,0),Vector2i(1,0)],
		"Three hex line":[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)],
		"Three hex bend":[Vector2i(0,0),Vector2i(1,0),Vector2i(1,1)],
		"Three hex triangle":[Vector2i(0,0),Vector2i(1,0),Vector2i(0,1)],
		"Four hex hook":[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(2,-1)],
		"Seven hex flower":[Vector2i(0,0),Vector2i(1,0),Vector2i(1,-1),Vector2i(0,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]}
	var result: Array[Vector2i] = []
	for cell: Vector2i in custom_cells if shape == "Custom" else presets.get(shape,[]):
		for step: int in range(rotation_steps): cell = Vector2i(-cell.y,cell.x+cell.y)
		result.append(cell)
	return result
func problems() -> PackedStringArray:
	var errors := PackedStringArray()
	if display_name.strip_edges().is_empty(): errors.append("Give the skill a display name.")
	var regex := RegEx.new()
	regex.compile("^[a-z][a-z0-9_]*$")
	if regex.search(identifier()) == null: errors.append("Skill ID must start with a lowercase letter and use only a-z, 0-9 and underscores.")
	if bucket().is_empty(): errors.append("Enter the custom bucket name.")
	if effect_description.strip_edges().is_empty() and not is_origin: errors.append("Describe what the skill does; WIP wording is fine.")
	var cells: Array[Vector2i] = footprint()
	if cells.is_empty(): errors.append("The footprint needs at least one hex.")
	var unique: Dictionary = {}
	for cell: Vector2i in cells:
		if unique.has(cell): errors.append("The footprint has a duplicate cell."); break
		unique[cell] = true
	if not cells.is_empty():
		var reached: Array[Vector2i] = [cells[0]]
		var index: int = 0
		while index < reached.size():
			for direction: Vector2i in DIRECTIONS:
				var next: Vector2i = reached[index]+direction
				if cells.has(next) and not reached.has(next): reached.append(next)
			index += 1
		if reached.size() != unique.size(): errors.append("Footprint hexes must form one connected piece.")
	for rule in adjacency_rules:
		if rule == null: errors.append("An adjacency entry is empty. Create its rule resource or remove that entry.")
	return errors
func as_data() -> Dictionary:
	var result: Dictionary = {"schema_version":2,"status":"idea_only","legacy_notes":{"tags":Array(tags),"is_origin":is_origin,"requires_origin":requires_origin,"origin_skill_id":origin_skill_id,"chain_bucket":chain_bucket,"chain_measure":chain_measure,"chain_amount":chain_amount,"chain_tags":Array(chain_tags)}}
	for property: Dictionary in get_property_list():
		if not (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) or not (property.usage & PROPERTY_USAGE_EDITOR): continue
		var value = get(property.name)
		if property.name in ["custom_cells","adjacency_rules"]: continue
		result[property.name] = Array(value) if value is PackedStringArray else value
	result.skill_id = identifier()
	result.resolved_bucket = bucket()
	result.footprint = []
	for cell: Vector2i in footprint(): result.footprint.append([cell.x,cell.y])
	result.board_definition = board_definition()
	result.board_definition.footprint = result.footprint.duplicate(true)
	result.adjacency_rules = []
	for rule in adjacency_rules:
		if rule != null: result.adjacency_rules.append(rule.as_data())
	return result

## Executable spatial data only. Free-text effects still require an implementation.
func board_definition() -> Dictionary:
	var rules: Array = []
	for rule in adjacency_rules:
		if rule == null or rule.requirement != "Mandatory": continue
		var families: Array = Array(rule.adjacent_skill_tags)
		if families.is_empty(): families.append(bucket() if rule.skill_bucket == "Any" else rule.skill_bucket)
		rules.append({"count":rule.minimum,"families":families})
	return {"family":bucket(),"footprint":footprint(),"chain":required_chain_length,"adjacency":rules,"cost":skill_point_cost,"prerequisites":Array(prerequisite_skill_ids),"allow_rotation":allow_rotation,"allow_mirror":allow_mirror}
