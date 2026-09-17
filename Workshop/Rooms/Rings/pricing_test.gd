extends SceneTree
const Rings = preload("res://Production/Actors/rings.gd")
const Items = preload("res://Production/Actors/items.gd")
const Shops = preload("res://Production/World/village_shops.gd")
const Inspect = preload("res://Production/Actors/item_inspection.gd")
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; push_error("Workshop/Rooms/Rings/pricing_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 for greater: bool in [false,true]:
  var ring: Dictionary = Rings.make(Items.identity(),"STR",greater)
  check(Shops.retail_price(ring) == (250 if greater else 50),"retail")
  check(Shops.sale_price(ring) == (25 if greater else 5),"10 percent resale")
  check(Shops.stock_price({"item":ring,"price":10}) == Shops.retail_price(ring),"legacy offer updated")
 for family: String in Rings.ACTIONS:
  var ring: Dictionary = Rings.make(Items.identity(),family,true)
  check(not Shops.buyable(ring) and not Shops.sellable(ring),"untradeable "+family)
  var text: String = Inspect.tooltip(ring)
  check(text.contains("Cannot be bought or sold") and not text.contains("gold"),"no displayed gold price")
 check(Shops.sale_price({"kind":"armor","base_rank":2}) == 5,"ordinary gear keeps half resale")
 var world := Sim.new(152)
 var player: Dictionary = world.Actors.create([3,3,3,3,3,3])
 world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
 world.start_in_town()
 var map = world.maps.maps[player.map_id]
 var cell: Vector2i = player.pos
 for candidate: Vector2i in map.shops:
  if map.shops[candidate].id == "general_goods": cell = candidate
 for candidate: Vector2i in map.neighbors(cell):
  if map.walkable(candidate) and world.actor_at(map.id,candidate).is_empty(): player.pos = candidate; break
 player.gold = 1000
 var ring: Dictionary = Rings.make(Items.identity(),"STR")
 map.shops[cell].stock.append({"item":ring,"price":10})
 check(world.buy(player,cell,ring.item_id).ok and player.gold == 950,"buy uses current quote")
 check(world.sell(player,cell,ring.item_id).ok and player.gold == 955,"sell pays 5")
 var action: Dictionary = Rings.make(Items.identity(),"attack_action",true)
 map.shops[cell].stock.append({"item":action,"price":50})
 check(not world.buy(player,cell,action.item_id).ok and player.gold == 955,"even stale action stock cannot be bought")
 map.shops[cell].stock.pop_back()
 Grid.place_auto(player.bag,action)
 check(not world.sell(player,cell,action.item_id).ok and player.gold == 955,"action sale rejected without mutation")
 check(Sim.validate_snapshot(world.snapshot()).is_empty(),"commerce leaves valid persistent state")
 print("Ring pricing: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
