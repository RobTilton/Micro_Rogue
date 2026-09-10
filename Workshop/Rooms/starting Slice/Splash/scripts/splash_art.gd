extends Node2D
## Self-contained presentation component. No gameplay dependencies or input ownership.

const INK: Color = Color("d5c9a5")
const SHADOW: Color = Color("4d4650")
const GOLD: Color = Color("d99245")
const GLYPHS: Dictionary = {
	"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
	"I": ["111", "010", "010", "010", "010", "010", "111"],
	"C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"O": ["0111110", "1100011", "1000001", "1000001", "1000001", "1100011", "0111110"],
	"o": ["00000", "00000", "01110", "10001", "10001", "10001", "01110"],
	"g": ["00000", "01111", "10001", "10001", "01111", "00001", "01110"],
	"u": ["00000", "00000", "10001", "10001", "10001", "10011", "01101"],
	"e": ["00000", "00000", "01110", "10001", "11111", "10000", "01111"],
}

var elapsed: float = 0.0
var flame_frame: int = 0

func _process(delta: float) -> void:
	elapsed += delta
	var next_frame: int = int(elapsed * 5.0) % 3
	if next_frame != flame_frame:
		flame_frame = next_frame
		queue_redraw()

func _draw() -> void:
	# A 480 x 270 logical canvas; all geometry lands on whole pixels.
	for point: Vector2 in [Vector2(49, 66), Vector2(403, 58), Vector2(112, 202), Vector2(425, 195)]:
		draw_rect(Rect2(point, Vector2(1, 1)), SHADOW)
	_draw_letter("M", Vector2i(37, 100), 7)
	_draw_letter("I", Vector2i(79, 100), 7)
	_draw_letter("C", Vector2i(107, 100), 7)
	_draw_letter("R", Vector2i(149, 100), 7)
	_draw_letter("o", Vector2i(190, 121), 4)
	_draw_letter("g", Vector2i(214, 121), 4)
	_draw_letter("u", Vector2i(238, 121), 4)
	_draw_letter("e", Vector2i(262, 121), 4)
	_draw_letter("O", Vector2i(298, 86), 11)
	_draw_adventurer(Vector2i(329, 137))
	draw_rect(Rect2(149, 181, 182, 1), SHADOW)
	draw_rect(Rect2(237, 178, 5, 5), GOLD)

func _draw_letter(letter: String, origin: Vector2i, pixel_size: int) -> void:
	var rows: Array = GLYPHS[letter]
	for row_index: int in range(rows.size()):
		var row: String = rows[row_index]
		for column_index: int in range(row.length()):
			if row[column_index] == "1":
				var position: Vector2 = Vector2(origin + Vector2i(column_index, row_index) * pixel_size)
				draw_rect(Rect2(position + Vector2(0, 2), Vector2.ONE * pixel_size), SHADOW)
				draw_rect(Rect2(position, Vector2.ONE * pixel_size), INK)

func _draw_adventurer(origin: Vector2i) -> void:
	var base: Vector2 = Vector2(origin)
	# Boots rest on the O's inner bottom edge; the torch is held to the right.
	draw_rect(Rect2(base + Vector2(-2, -9), Vector2(7, 9)), Color("596c70"))
	draw_rect(Rect2(base + Vector2(-1, -14), Vector2(5, 5)), GOLD)
	draw_rect(Rect2(base + Vector2(-2, -16), Vector2(7, 3)), Color("724e40"))
	draw_rect(Rect2(base + Vector2(-2, 0), Vector2(3, 4)), SHADOW)
	draw_rect(Rect2(base + Vector2(3, 0), Vector2(3, 4)), SHADOW)
	draw_rect(Rect2(base + Vector2(4, -8), Vector2(7, 2)), GOLD)
	draw_rect(Rect2(base + Vector2(10, -14), Vector2(2, 9)), Color("724e40"))
	draw_rect(Rect2(base + Vector2(8, -19 - flame_frame), Vector2(6, 6 + flame_frame)), Color("c76b37"))
	draw_rect(Rect2(base + Vector2(10, -18), Vector2(2, 4)), Color("f5d879"))
