extends RefCounted
const BLOCK_NAMES: Array[String] = ["Morning","Noon","Evening","Midnight"]
# Existing saves retain elapsed hours; gameplay and presentation use six-hour blocks.
static func parts(hours: int) -> Dictionary:
	var blocks: int = int(hours/6.0)
	var days: int = int(blocks/4.0)
	var block: int = blocks%4
	return {"year":int(days/360.0)+1,"month":(int(days/30.0))%12+1,"day":days%30+1,"block":block+1,"period":BLOCK_NAMES[block]}
static func label(hours: int) -> String:
	var date: Dictionary = parts(hours)
	return "Month_%02d.day_%02d.%d · %s" % [date.month,date.day,date.block,date.period]
