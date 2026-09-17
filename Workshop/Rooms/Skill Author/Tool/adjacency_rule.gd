@tool
extends Resource
## An authored condition, not an implemented gameplay effect.
@export_enum("Mandatory","Optional bonus") var requirement: String = "Mandatory"
@export_range(0,30) var minimum: int = 1
@export_storage var count_by: String = "Distinct neighboring cells"
@export_storage var skill_bucket: String = "Any"
@export_storage var required_tags: PackedStringArray = []
## Skill family names. Each neighboring hex counts once if it matches any listed family.
@export var adjacent_skill_tags: PackedStringArray = []
@export_storage var specific_skill_ids: PackedStringArray = []
@export_multiline var bonus_or_notes: String = ""
func as_data() -> Dictionary:
	return {"requirement":requirement,"minimum":minimum,"count_by":count_by,"skill_bucket":skill_bucket,"adjacent_skill_tags":Array(adjacent_skill_tags),"required_tags":Array(required_tags),"specific_skill_ids":Array(specific_skill_ids),"bonus_or_notes":bonus_or_notes}
