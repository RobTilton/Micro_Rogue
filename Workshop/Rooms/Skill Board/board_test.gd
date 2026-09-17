extends SceneTree
const Board = preload("res://Production/Actors/skill_board.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const World = preload("res://Production/Actors/actor_world.gd")
const Combat = preload("res://Production/Actors/combat.gd")
const Author = preload("res://Workshop/Rooms/Skill Author/Tool/skill_author.gd")
const Draft = preload("res://Workshop/Rooms/Skill Author/Tool/skill_draft.gd")
const View = preload("res://Production/UI/skill_board_view.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error("Workshop/Rooms/Skill Board/board_test.gd: "+message)
func definition(family: String = "Martial", chain: int = 0, shape: Array = [Vector2i.ZERO], adjacency: Array = []) -> Dictionary:
	return {"family":family,"chain":chain,"footprint":shape,"adjacency":adjacency,"cost":1,"prerequisites":[]}
func actor(skills: Array) -> Dictionary: return {"skills":skills,"skill_board":Board.blank()}
func put(a: Dictionary, id: String, cell: Vector2i, definitions: Dictionary) -> void:
	check(Board.place(a,id,cell,0,false,definitions).is_empty(),"place "+id)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(Board.cells().size() == 61,"radius four has 61 cells")
	var definitions: Dictionary = {"A":definition(),"B":definition(),"C":definition("Magic"),"D":definition("Monk"),"E":definition("Other")}
	var a: Dictionary = actor(definitions.keys())
	check(Board.place_origin(a,"Martial",Vector2i.ZERO,definitions) != "","center reserved")
	check(Board.place_origin(a,"Martial",Vector2i(-2,0),definitions).is_empty(),"first origin")
	var before: Dictionary = a.skill_board.duplicate(true)
	check(Board.place_origin(a,"Martial",Vector2i(2,0),definitions) != "" and a.skill_board == before,"origin immutable and atomic")
	check(Board.place_origin(a,"Magic",Vector2i(1,0),definitions).is_empty(),"second origin")
	check(Board.place_origin(a,"Monk",Vector2i(2,0),definitions).is_empty(),"third origin")
	check(Board.place_origin(a,"Other",Vector2i(3,0),definitions) != "","fourth origin refused")
	check(Board.place(a,"A",Vector2i(5,0),0,false,definitions) != "","out of bounds refused")
	check(Board.place(a,"A",Vector2i.ZERO,0,false,definitions) != "","center cannot be occupied")
	put(a,"A",Vector2i(-1,0),definitions)
	check(Board.valid(a,definitions),"valid placed board")
	var bad: Dictionary = a.duplicate(true)
	bad.skill_board.placements.A.cell = Vector2i.ZERO
	check(not Board.valid(bad,definitions),"save overlap rejected")
	bad = a.duplicate(true); bad.skill_board.origins.Martial = "bad"
	check(not Board.valid(bad,definitions),"malformed coordinates rejected")
	check(Board.valid({"skills":["Lunge"]}),"legacy missing board accepted")
	# Mutual activation independent of active state.
	definitions = {"A":definition("Martial",0,[Vector2i.ZERO],[{"count":1,"families":["Martial"]}]),"B":definition("Martial",0,[Vector2i.ZERO],[{"count":1,"families":["Martial"]}])}
	a = actor(["A","B"])
	Board.place_origin(a,"Martial",Vector2i(-4,0),definitions)
	put(a,"A",Vector2i(2,0),definitions)
	check(not Board.evaluate(a,definitions).A.active,"isolated skill inactive")
	put(a,"B",Vector2i(3,0),definitions)
	check(Board.evaluate(a,definitions).A.active and Board.evaluate(a,definitions).B.active,"inactive skills mutually activate")
	# Three neighbor cells from one large piece, not one skill or shared edges.
	definitions.B.footprint = [Vector2i.ZERO,Vector2i(-1,1),Vector2i(-2,1)]
	definitions.A.adjacency[0].count = 3
	check(Board.evaluate(a,definitions).A.active,"three adjacent hexes from single footprint")
	definitions.A.adjacency[0].count = 4
	check(not Board.evaluate(a,definitions).A.active,"neighbor counted once")
	# Center bridges family chain and adds one link, never an origin.
	definitions = {"A":definition("Magic",2)}
	a = actor(["A"])
	Board.place_origin(a,"Magic",Vector2i(-1,0),definitions)
	put(a,"A",Vector2i(1,0),definitions)
	check(Board.evaluate(a,definitions).A.active,"origin plus wildcard center chain two")
	definitions.A.chain = 3
	check(not Board.evaluate(a,definitions).A.active,"self excluded from chain")
	# Longer route must satisfy despite direct short route.
	var taken: Dictionary = {Vector2i.ZERO:{"id":"target","family":"Martial"},Vector2i(1,0):{"id":"@Martial","family":"Martial"},Vector2i(0,1):{"id":"B","family":"Martial"},Vector2i(1,1):{"id":"C","family":"Martial"}}
	var boundary: Dictionary = {Vector2i(1,0):taken[Vector2i(1,0)],Vector2i(0,1):taken[Vector2i(0,1)]}
	check(Board.chain_satisfied(taken,boundary,"target","Martial",Vector2i(1,0),3),"longer path satisfies even with adjacent origin")
	check(not Board.chain_satisfied(taken,boundary,"target","Martial",Vector2i(1,0),4),"cycles cannot invent links")
	taken[Vector2i(1,1)].id = "B"
	check(not Board.chain_satisfied(taken,boundary,"target","Martial",Vector2i(1,0),3),"large piece counts once for chain")
	# Author emits deterministic spatial data.
	var draft = Draft.new()
	draft.display_name = "Test Skill"
	draft.effect_description = "WIP effect"
	draft.required_chain_length = 4
	var rule = Draft.Adjacency.new()
	rule.minimum = 3
	rule.adjacent_skill_tags = ["Martial","Magic"]
	draft.adjacency_rules.append(rule)
	var data: Dictionary = draft.as_data()
	check(data.board_definition.chain == 4 and data.board_definition.adjacency[0].count == 3,"author exports requirements")
	check(JSON.parse_string(JSON.stringify(data)).board_definition.footprint.size() == 1 and int(JSON.parse_string(JSON.stringify(data)).board_definition.footprint[0][0]) == 0,"JSON footprint numeric arrays")
	# Actual actors: learned is not active, AI uses same rules.
	var world = World.new(152)
	var player: Dictionary = Actors.create([3,3,3,3,3,3])
	world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
	player.points = 3
	check(world.learn(player,"Lunge").ok and not Board.active(player,"Lunge"),"learning requires placement")
	check(world.learn(player,"Riposte").ok and world.learn(player,"Show-Off").ok,"learn existing sequence")
	check(not world.skill_available(player,"Lunge"),"unplaced combat skill unavailable")
	Board.auto_place(player)
	check(Board.active(player,"Lunge") and Board.active(player,"Riposte") and Board.active(player,"Show-Off"),"AI places active same-rules chain")
	check(Board.valid(player),"AI board validates")
	world.begin_turn(player)
	check(world.skill_available(player,"Lunge") and world.skill_available(player,"Riposte"),"placed skills reach shared combat availability")
	player.off = player.main.duplicate(true)
	check(Combat.allowance(player).attack == 2,"active Show-Off grants second attack")
	player.skill_board.placements.erase("Show-Off")
	check(Combat.allowance(player).attack == 1,"unplaced Show-Off does not grant second attack")
	Board.auto_place(player)
	player.riposte = true
	var guarded: int = Combat.defense(player)
	player.skill_board.placements.erase("Riposte")
	check(Combat.defense(player) == guarded-player.stats.DEX,"unplaced Riposte cannot retain its defense bonus")
	player.riposte = false
	player.skill_board.placements.erase("Lunge")
	check(not Board.active(player,"Lunge"),"removal revokes access")
	check(not world.clear_skill_placements(player).ok,"respec outside town refused")
	# Render board and instantiate author, compiling editor/runtime dependencies.
	var view := View.new()
	view.actor = player
	root.add_child(view)
	view.size = Vector2(470,410)
	var author = Author.new()
	author.test_on_skill_board = true
	author.draft = draft
	root.add_child(author)
	check(author.test_definitions.size() == 1,"Workshop sandbox builds current draft")
	await process_frame
	print("Skill Board: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
