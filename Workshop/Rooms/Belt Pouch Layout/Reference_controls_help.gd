extends RefCounted
const Parts = preload("res://Production/UI/ui_parts.gd")
const SECTIONS: Array = [
	["Finding the Global map", "Leave your town or POI through its Return exit. On the Local map, use Return to Global. The location button directly below the minimap opens Map and lists exit coordinates. Walk onto an exit, then double-left-click your character, or select the named transition in Map / Activate. From a deeper floor, return through its parent locations first. There is currently no anywhere-on-demand Global overview button."],
	["Movement and exploration", "Left-click a walkable hex to choose a move. With Confirm ordinary movement enabled, approve it with the move confirmation button. Shift-click a map hex bypasses confirmation; Options can disable confirmation entirely. Drag with left or middle mouse to pan. Scroll the mouse wheel to zoom. Click the minimap to move the camera; right-click the map and choose Focus on player to recenter."],
	["Travel between regions", "Ordinary exploration crosses adjacent Local-map edges: reach a dry edge and use a Cross direction option in Activate or the right-click menu. Every Global border crossed advances six hours. Movement on the Global layer is restricted to adjacent trade-route or special-event steps. Water requires future boat support."],
	["Context menus and combat", "Right-click your character for Character, Inventory, Skills, Quests and nearby interactions. Right-click an enemy for Attack, or select an attack/skill through the bottom action controls. Right-click nearby objects to find their available actions. Use Activate for nearby shops, containers, transitions and potions. End Turn / Wait lets time in the turn system advance. Equipment and interactions cost actions during combat; ordinary exploration actions are free."],
	["Inventory and belts", "Drag items between backpack, equipment, belt pouches and available loot targets. Shift-left-click backpack equipment to equip it; Shift-left-click worn gear to unequip it. Right-click a carried belt and choose Empty belt to move all potions to the backpack. It refuses if they will not all fit. During an item drag, R or right-click rotates the item."],
	["Shops, healing and quests", "Buy or sell using the shop buttons. Ctrl-click the purchase/sale action bypasses its confirmation. General Goods sells health potions and rations. Use potions from Activate or inventory. Camp consumes one ration; an inn costs one gold. Both recover 2×CON HP and advance six hours. Open Quests from the sidebar or your character context menu for objectives and direction hints."],
	["Panels and saving", "Escape cancels a movement preview, closes the current panel, or cancels targeting when no panel is open. Use panel close / Back buttons with the mouse. Sidebar numbers are labels, not implemented keyboard shortcuts. World progress saves automatically. Death starts a new adventurer in the same world; New World / Regenerate replaces the world."]
]
static func build(parent: Node) -> void:
	for section: Array in SECTIONS:
		Parts.label(parent,section[0],20)
		var body: Label = Parts.label(parent,section[1],16)
		body.custom_minimum_size.x = 300
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
