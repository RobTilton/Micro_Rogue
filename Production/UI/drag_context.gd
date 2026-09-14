extends RefCounted
signal changed
var payload: Dictionary = {}
var preview_label: Label
func begin(item: Dictionary, source: Dictionary, control: Control) -> Dictionary:
	payload = {"inventory_drag":true,"item":item.duplicate(true),"source":source.duplicate(true),"rotated":item.get("rotated",false)}
	preview_label = Label.new()
	preview_label.add_theme_color_override("font_color",Color("ffe2a8"))
	control.set_drag_preview(preview_label)
	update_preview()
	changed.emit()
	return payload
func rotate() -> void:
	if payload.is_empty(): return
	payload.rotated = not payload.rotated
	update_preview()
	changed.emit()
func update_preview() -> void:
	if is_instance_valid(preview_label): preview_label.text = payload.item.name + (" ↻" if payload.rotated else "") + "\nRight-click or R: rotate · release to place"
func finish() -> void:
	payload = {}
	changed.emit()
