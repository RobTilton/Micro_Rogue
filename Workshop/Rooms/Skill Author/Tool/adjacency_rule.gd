@tool
extends Resource
## An authored condition, not an implemented gameplay effect.
@export_enum("Mandatory","Optional bonus") var requirement: String = "Mandatory"
@export_range(0,30) var minimum: int = 1
@export_enum("Distinct neighboring cells","Distinct neighboring skills","Shared edges","Undecided") var count_by: String = "Undecided"
@export var skill_bucket: String = "Any"
@export var required_tags: PackedStringArray = []
@export var specific_skill_ids: PackedStringArray = []
@export_multiline var bonus_or_notes: String = ""
func as_data() -> Dictionary:
	return {"requirement":requirement,"minimum":minimum,"count_by":count_by,"skill_bucket":skill_bucket,"required_tags":Array(required_tags),"specific_skill_ids":Array(specific_skill_ids),"bonus_or_notes":bonus_or_notes}
