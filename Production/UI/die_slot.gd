extends Button
signal transferred(source: int, target: int)
var slot_index: int = 0
var die_value: int = 0
func _get_drag_data(_position: Vector2) -> Variant:
	if die_value == 0: return null
	var preview: Label = Label.new()
	preview.text = str(die_value)
	set_drag_preview(preview)
	return {"die_slot": slot_index}
func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("die_slot")
func _drop_data(_position: Vector2, data: Variant) -> void:
	transferred.emit(data.die_slot, slot_index)
