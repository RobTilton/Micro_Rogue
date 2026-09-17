extends SceneTree
const Author = preload("res://Workshop/Rooms/Skill Author/Tool/skill_author.gd")
const Draft = preload("res://Workshop/Rooms/Skill Author/Tool/skill_draft.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var author := Author.new()
	author.test_on_skill_board = true
	author.draft.display_name = "Cleave"
	author.draft.effect_description = "Test only"
	author.draft.required_chain_length = 2
	var companion := Draft.new()
	companion.display_name = "Support"
	companion.effect_description = "Test only"
	companion.shape = "Three hex bend"
	author.companion_drafts.append(companion)
	root.add_child(author)
	author.Board.place_origin(author.test_actor,"Martial",Vector2i(-1,0),author.test_definitions)
	author.Board.place(author.test_actor,"support",Vector2i(1,0),0,false,author.test_definitions)
	author.Board.place(author.test_actor,"cleave",Vector2i(2,0),0,false,author.test_definitions)
	author._test_refresh()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://Workshop/Rooms/Skill Board/author_board.png")
	quit()
