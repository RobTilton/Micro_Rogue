extends SceneTree
const Rings = preload("res://Production/Actors/rings.gd")
const Items = preload("res://Production/Actors/items.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; push_error("Workshop/Rooms/Rings/integration_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 create_timer(90).timeout.connect(func(): quit(2))
 var game = load("res://Production/main.tscn").instantiate()
 var directory: String = "res://Workshop/Rooms/Rings/tests/ui/"
 game.autosave_directory = directory+"autosaves/"
 game.snapshot_directory = directory+"snapshots/"
 game.preferences_path = directory+"preferences.cfg"
 root.add_child(game)
 await game._new_character()
 game.dice_slots = [0,0,0,0,0,0,3,3,3,3,3,3]
 game._start_run()
 game.set_process(false)
 var player: Dictionary = game.player
 var ring: Dictionary = Rings.make(Items.identity(),"WIS",true)
 Grid.place_auto(player.bag,ring)
 game._toggle_panel("Inventory")
 await process_frame
 game._quick_equip({"zone":"bag","id":ring.item_id})
 await process_frame
 check(player.ring_1.get("item_id") == ring.item_id,"shift-click equips first free slot")
 check(Rings.stat(player,"WIS") == 5,"UI equipment changes effective stat")
 var ring2: Dictionary = Rings.make(Items.identity(),"physical_damage")
 Grid.place_auto(player.bag,ring2)
 game._quick_equip({"zone":"bag","id":ring2.item_id})
 check(player.ring_2.get("item_id") == ring2.item_id,"shift-click chooses next free ring slot")
 game._quick_equip({"zone":"equipment","slot":"ring_1","id":ring.item_id})
 check(player.ring_1.is_empty() and Rings.stat(player,"WIS") == 3,"shift-click unequips and removes bonus")
 game._transfer({"zone":"bag","id":ring.item_id},{"zone":"equipment","slot":"ring_8"})
 check(player.ring_8.get("item_id") == ring.item_id,"drag/drop can target eighth ring slot")
 await process_frame
 var targets: int = 0
 for node: Node in game.find_children("*","Button",true,false):
  if node.get_script() == load("res://Production/UI/item_target.gd") and node.target.get("slot","") in Rings.SLOTS: targets += 1
 check(targets == 8,"paperdoll exposes eight usable ring targets")
 # Leave multiple rings in the backpack too, exercising its custom draw path.
 Grid.place_auto(player.bag,Rings.make(Items.identity(),"WIL"))
 Grid.place_auto(player.bag,Rings.make(Items.identity(),"free_action",true))
 game._refresh()
 await process_frame
 await process_frame
 check(game._automatic_checkpoint(),"real F5 autosave accepts rings")
 var snapshot: Dictionary = game.simulation.snapshot()
 var old: Dictionary = snapshot.duplicate(true)
 for actor: Dictionary in old.actors.values():
  for slot: String in Rings.SLOTS: actor.erase(slot)
  actor.erase("ring_hp_bonus")
 check(Sim.validate_snapshot(old).is_empty(),"pre-ring actor saves with absent slots remain compatible")
 if DisplayServer.get_name() != "headless":
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://Workshop/Rooms/Rings/inventory.png")
 game.queue_free()
 await process_frame
 print("Ring UI: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
