extends RefCounted
static func label(parent: Node, text: String, font_size: int = 17) -> Label:
	var node: Label = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",font_size)
	parent.add_child(node)
	return node
static func button(parent: Node, text: String, action: Callable, enabled: bool = true) -> Button:
	var node: Button = Button.new()
	node.text = text
	node.disabled = not enabled
	node.pressed.connect(action)
	parent.add_child(node)
	return node
static func clear(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
static func style(fill: Color = Color("19232b")) -> StyleBoxFlat:
	var result: StyleBoxFlat = StyleBoxFlat.new()
	result.bg_color = fill
	result.border_color = Color("786d5f")
	result.set_border_width_all(2)
	result.set_corner_radius_all(0)
	result.anti_aliasing = false
	result.content_margin_left = 12
	result.content_margin_right = 12
	result.content_margin_top = 10
	result.content_margin_bottom = 10
	return result
