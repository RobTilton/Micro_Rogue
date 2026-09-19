extends SceneTree
const World = preload("res://Production/Persistence/adventurer_world.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var world = World.new(152)
 var actor = world.Actors.create([3,3,3,3,3,3])
 world.add_actor(actor,"global",world.maps.maps.global.spawn_cell,"player","player")
 world.start_in_town()
 var journal = world.Journal.new()
 for index in range(4):
  world.ledger().steps = index
  var start = Time.get_ticks_usec()
  var snapshot = world.snapshot(journal.previous)
  if not journal.previous.is_empty():
   assert(journal.previous.records.global.constraints.adventurers.steps == index-1)
   assert(is_same(snapshot.states,journal.previous.states))
  assert(snapshot.records.global.constraints.adventurers.steps == index)
  var captured = Time.get_ticks_usec()
  var result = journal.checkpoint(snapshot,"res://Workshop/Rooms/Living Adventurers/Tests/movement_profile/")
  assert(result.ok)
  print("snapshot ms=",(captured-start)/1000.0," save ms=",(Time.get_ticks_usec()-captured)/1000.0)
 quit()
