extends PanelContainer
signal command(name: String)
signal transfer_requested(source: Dictionary, target: Dictionary)
const Parts = preload("res://Production/UI/ui_parts.gd")
const Target = preload("res://Production/UI/item_target.gd")
var drag_context: RefCounted
var hp: Label
var state: Label
var buttons: Dictionary = {}
var belt_section: VBoxContainer
var belt_name: Label
var slots: HBoxContainer
var force_belt: bool = false
func _ready() -> void:
	add_theme_stylebox_override("panel",Parts.style())
	custom_minimum_size.y = 164
	var layout: VBoxContainer = VBoxContainer.new()
	add_child(layout)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation",12)
	layout.add_child(row)
	hp = Parts.label(row,"HP",21)
	hp.custom_minimum_size.x = 115
	var mana: Label = Parts.label(row,"Mana\n—",18)
	mana.custom_minimum_size.x = 70
	mana.tooltip_text = "Magic capacity is not defined yet."
	var middle: VBoxContainer = VBoxContainer.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(middle)
	state = Parts.label(middle,"",15)
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var actions: HBoxContainer = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	middle.add_child(actions)
	for name: String in ["Attack","Lunge","Riposte","Activate","End Turn","Cancel"]:
		buttons[name] = Parts.button(actions,name,func(): command.emit(name))
		buttons[name].custom_minimum_size.y = 38
	Parts.label(row,"Gold\n—",18).tooltip_text = "Currency is not defined yet."
	belt_section = VBoxContainer.new()
	layout.add_child(belt_section)
	belt_name = Parts.label(belt_section,"",14)
	belt_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slots = HBoxContainer.new()
	slots.alignment = BoxContainer.ALIGNMENT_CENTER
	belt_section.add_child(slots)
	drag_context.changed.connect(update_context)
func show_state(actor: Dictionary, actions: Dictionary, mode: String, cooldowns: RefCounted, availability: Dictionary, belt: Dictionary) -> void:
	hp.text = "HP\n%d / %d" % [actor.hp,actor.max_hp]
	state.text = "Attack %d   Movement %d   Activation %d  ·  %s" % [actions.attack,actions.move,actions.activation,mode]
	for name: String in ["Lunge","Riposte"]:
		buttons[name].text = name if cooldowns.ready(name) else "%s [%d]" % [name,cooldowns.ticks(name)]
	for name: String in availability: buttons[name].disabled = not availability[name]
	Parts.clear(slots)
	belt_name.text = ("EQUIPPED · " if belt.get("item_id",-1) == actor.belt.get("item_id",-2) else "BACKPACK BELT · ") + belt.get("name","No belt equipped")
	if not belt.is_empty():
		for index: int in range(belt.capacity):
			var target: Button = Target.new()
			target.drag_context = drag_context
			target.target = {"zone":"belt","belt_id":belt.item_id,"pouch":index}
			target.custom_minimum_size = Vector2(58,40)
			target.text = str(index+1) + " · —"
			for potion: Dictionary in belt.contents:
				if potion.pouch == index:
					target.item = potion
					target.source = {"zone":"belt","belt_id":belt.item_id,"id":potion.item_id}
					target.text = str(index+1) + " · HP"
					target.tooltip_text = "Lesser Health · drag to backpack to remove"
			target.transfer_requested.connect(func(source: Dictionary, destination: Dictionary): transfer_requested.emit(source,destination))
			slots.add_child(target)
	update_context()
func update_context() -> void:
	var dragging_potion: bool = not drag_context.payload.is_empty() and drag_context.payload.item.kind == "potion"
	belt_section.visible = force_belt or dragging_potion
