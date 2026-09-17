extends SceneTree
const Rings = preload("res://Production/Actors/rings.gd")
const Actors = preload("res://Production/Actors/actors.gd")
const Items = preload("res://Production/Actors/items.gd")
const Rules = preload("res://Production/Actors/equipment_rules.gd")
const Combat = preload("res://Production/Actors/combat.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
const Momentum = preload("res://Production/Actors/momentum.gd")
const Sight = preload("res://Production/Actors/perception.gd")
const Brain = preload("res://Production/Actors/enemy_brain.gd")
const Inspection = preload("res://Production/Actors/item_inspection.gd")
const Shops = preload("res://Production/World/village_shops.gd")
const Sim = preload("res://Production/Persistence/persistent_actor_world.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures += 1; push_error("Workshop/Rooms/Rings/ring_test.gd: "+message)
func _initialize() -> void: call_deferred("run")
func actor() -> Dictionary:
 var a: Dictionary = Actors.create([3,3,3,3,3,3])
 Rules.initialize(a)
 for slot: String in Grid.EQUIPMENT: a[slot] = {}
 a.actions = Combat.allowance(a)
 return a
func equip(a: Dictionary, family: String, greater: bool = false, slot: String = "ring_1", battle: bool = false) -> Dictionary:
 var item: Dictionary = Rings.make(Items.identity(),family,greater)
 Grid.place_auto(a.bag,item)
 return Grid.transfer(a,[],a.actions,battle,{"zone":"bag","id":item.item_id},{"zone":"equipment","slot":slot})
func unequip(a: Dictionary, slot: String = "ring_1", battle: bool = false) -> Dictionary:
 return Grid.transfer(a,[],a.actions,battle,{"zone":"equipment","slot":slot,"id":a[slot].item_id},{"zone":"bag"})
func run() -> void:
 for family: String in Rings.FAMILIES:
  for greater: bool in [false,true]:
   if family in Rings.ACTIONS and not greater: continue
   var a: Dictionary = actor()
   var item: Dictionary = Rings.make(Items.identity(),family,greater)
   check(Rings.valid(item) and Sim._item_structure(item),"valid "+item.name)
   check(equip(a,family,greater).ok,"equip "+item.name)
   check(Rings.bonus(a,family) == Rings.amount(family,greater),"effect "+item.name)
   check(Inspection.tooltip(a.ring_1).contains("+%d" % Rings.amount(family,greater)),"tooltip "+item.name)
   check(unequip(a).ok and Rings.bonus(a,family) == 0 and a.stats == {"CON":3,"STR":3,"DEX":3,"INT":3,"WIS":3,"WIL":3},"removes without base-stat mutation "+item.name)
 var a: Dictionary = actor()
 for slot: String in Rings.SLOTS: check(equip(a,"STR",false,slot).ok,"stack in "+slot)
 check(Rings.stat(a,"STR") == 11 and a.stats.STR == 3,"eight stacked stat rings")
 check(Rules.stat_bonus(a,{"category":"swords","hands":"one"}) == 11,"physical weapon reads effective STR")
 check(Brain.upgrade_slot(a,Rings.make(Items.identity(),"STR",true)) in Rings.SLOTS,"humanoid upgrades ring")
 a.humanoid = false
 check(Rings.stat(a,"STR") == 3 and Brain.upgrade_slot(a,Rings.make(Items.identity(),"STR")) == "","nonhumanoid receives no gear benefit")
 a = actor()
 equip(a,"WIL",true)
 check(a.max_hp == 15 and a.hp == 9 and Combat.defense(a,"magical") == 5,"WIL raises capacity and defense without healing")
 a.hp = 15
 unequip(a)
 check(a.hp == 9 and a.max_hp == 9,"removing WIL clamps HP")
 equip(a,"WIL",true)
 check(a.hp == 9 and a.max_hp == 15,"re-equipping cannot refill HP")
 equip(a,"CON",true,"ring_2")
 equip(a,"healing",true,"ring_3")
 a.hp = 1
 check(Combat.heal(a) == 8 and Rings.healing(a,2) == 13,"CON and specialized healing combine once per event")
 equip(a,"physical_defense",true,"ring_4")
 equip(a,"magical_defense",true,"ring_5")
 check(Combat.defense(a,"physical") == 8 and Combat.defense(a,"magical") == 8,"specialized armor adds to matching defense")
 a = actor()
 equip(a,"INT",true)
 equip(a,"physical_damage",true,"ring_2")
 equip(a,"magical_damage",false,"ring_3")
 var physical: Dictionary = {"kind":"weapon","category":"swords","die":1,"bonus":0,"damage_type":"physical"}
 var magical: Dictionary = {"kind":"weapon","category":"staffs","die":1,"bonus":0,"damage_type":"magical"}
 check(Combat.weapon_damage(a,physical) == 7 and Combat.weapon_damage(a,magical) == 7,"damage channel and INT specialization")
 a = actor()
 equip(a,"DEX",true)
 equip(a,"movement",true,"ring_2")
 equip(a,"momentum",true,"ring_3")
 equip(a,"WIS",true,"ring_4")
 equip(a,"sight",true,"ring_5")
 check(Rings.movement(a) == 11 and Momentum.speed(a) == 8 and Sight.radius(a) == 12,"movement, momentum and sight remain separate")
 check(Momentum.grants(a,3) == 2 and a.momentum == 2,"momentum accrual retains remainder")
 a = actor()
 equip(a,"attack_action",true)
 equip(a,"move_action",true,"ring_2")
 equip(a,"free_action",true,"ring_3")
 check(Combat.allowance(a).attack == 2 and Combat.allowance(a).move == 2 and Combat.allowance(a).free == 1,"action rings change turn allowance")
 check(a.actions.attack == 1 and a.actions.move == 1 and a.actions.free == 0,"equipping cannot grant current-turn actions")
 a.actions = Combat.allowance(a)
 check(unequip(a,"ring_1",true).ok and a.actions.attack == 1,"removing attack ring removes extra allowance")
 check(Shops.retail_price(a.ring_2) == 50 and Shops.sale_price(a.ring_2) == 25 and Shops.sellable(a.ring_2),"ring commerce")
 var invalid: Dictionary = Rings.make(Items.identity(),"attack_action",true)
 invalid.greater = false
 check(not Rings.valid(invalid) and not Sim._item_structure(invalid),"reject lesser action ring")
 # Meaningful distribution sample, including actual loot path and potion supplies.
 var rng := RandomNumberGenerator.new()
 rng.seed = 49281
 var paired: int = 0
 var greater_count: int = 0
 var action_count: int = 0
 for index: int in range(100000):
  var ring: Dictionary = Rings.generate(index+1,rng)
  if ring.family in Rings.ACTIONS: action_count += 1
  else:
   paired += 1
   if ring.greater: greater_count += 1
 check(greater_count > paired*0.008 and greater_count < paired*0.012 and action_count > 100 and action_count < 260,"paired 99/1 and rare actions")
 var loot_rings: int = 0
 for index: int in range(5000):
  var drop: Dictionary = Items.loot({"max_material_tier":3},rng)
  if drop.item.kind == "ring": loot_rings += 1
 check(loot_rings > 180 and loot_rings < 320,"5 percent random loot rings")
 check(Items.loot({},rng,true).item.kind == "potion","guaranteed supply loot stays potion")
 # Real world persistence, rest, turns, NPC death and old-save compatibility.
 var world := Sim.new(152)
 var player: Dictionary = actor()
 world.add_actor(player,"global",world.maps.maps.global.spawn_cell,"player","player")
 world.start_in_town()
 equip(player,"WIL",true)
 equip(player,"healing",true,"ring_2")
 equip(player,"free_action",true,"ring_3")
 world.begin_turn(player)
 check(player.actions.free == 1,"begin_turn preserves action-ring free allowance")
 player.hp = 1
 player.gold = 50
 var inn_cell: Vector2i = player.pos
 for cell: Vector2i in world.maps.maps[player.map_id].shops:
  if world.maps.maps[player.map_id].shops[cell].id == "inn": inn_cell = cell
 for cell: Vector2i in world.maps.maps[player.map_id].neighbors(inn_cell):
  if world.maps.maps[player.map_id].walkable(cell) and world.actor_at(player.map_id,cell).is_empty(): player.pos = cell; break
 var inn_result: Dictionary = world.rest_at_inn(player,inn_cell)
 check(inn_result.ok and player.hp == 10,"inn applies specialized healing once")
 var saved: Dictionary = world.save_game("res://Workshop/Rooms/Rings/tests/saves/")
 check(saved.ok,"ring world save")
 var loaded := Sim.new(153)
 check(loaded.load_game(world.last_save).ok,"ring world load")
 var restored: Dictionary = loaded.actors[loaded.player_id]
 check(restored.ring_1 == player.ring_1 and restored.max_hp == player.max_hp and Rings.stat(restored,"WIL") == 5,"ring identity and effects survive reload exactly once")
 var npc: Dictionary = {}
 for candidate: Dictionary in world.on_map(player.map_id):
  if candidate.id != player.id: npc = candidate; break
 equip(npc,"WIL",true)
 var ring_id: int = npc.ring_1.item_id
 npc.faction = "enemy"
 npc.hp = 0
 world.resolve_death(npc,player)
 var dropped: bool = false
 for entry: Dictionary in world.ground[player.map_id]:
  if entry.item.item_id == ring_id: dropped = true
 for prop: Dictionary in world.maps.maps[player.map_id].props.values():
  for item: Dictionary in prop.contents:
   if item.item_id == ring_id: dropped = true
 check(dropped and npc.ring_hp_bonus == 0,"death drops rings and clears temporary HP capacity")
 check(Sim.validate_snapshot(world.snapshot()).is_empty(),"world remains valid after ring wearer death")
 print("Rings: %d checks, %d failures; paired greater %d/%d, actions %d, loot rings %d/5000" % [checks,failures,greater_count,paired,action_count,loot_rings])
 quit(1 if failures else 0)
