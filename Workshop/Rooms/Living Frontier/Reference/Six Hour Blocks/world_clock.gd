extends RefCounted
static func parts(hours: int) -> Dictionary:
	var days: int = hours/24
	return {"year":days/360+1,"month":(days/30)%12+1,"day":days%30+1,"hour":hours%24}
static func label(hours: int) -> String:
	var date: Dictionary = parts(hours)
	return "Year_%02d · Month_%02d · day_%02d · %02d:00" % [date.year,date.month,date.day,date.hour]
