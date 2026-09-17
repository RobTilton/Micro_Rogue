extends "res://Workshop/Rooms/Playtest Refinement/refinement_test.gd"
const Roster = preload("res://Production/Actors/enemy_roster.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
func run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 913
	var world := World.new()
	var player: Dictionary = Actors.create([3,3,3,3,3,3])
	world.add_actor(player,"global",Vector2i(3,7),"player")
	player.hp = 100000
	player.max_hp = 100000
	check(Roster.catalog.families.size() == 12,"twelve enemy families")
	var total: int = 0
	for family: String in Roster.catalog.families:
		var seen: Dictionary = {}
		for roll_value: int in range(300): seen[Roster.choose_variant(family,rng,100,100).id] = true
		check(seen.size() == Roster.catalog.families[family].variants.size(),"all variants reachable at high pressure")
		for entry: Dictionary in Roster.catalog.families[family].variants:
			total += 1
			check(ResourceLoader.exists(entry.sprite),"sprite exists")
			var actor: Dictionary = Actors.create([3,3,3,3,3,3],true,rng,entry.humanoid)
			Roster.apply(actor,family,entry)
			world.add_actor(actor,"global",Vector2i(4,7),"enemy")
			world.begin_turn(actor)
			check(Roster.valid_actor(actor) and Grid.valid(actor,[]),"variant and inventory valid")
			check(actor.name == entry.name,"spawn preserves variant name")
			check(world.attack(actor,player.id).ok,"every variant has a legal attack")
			if not actor.humanoid:
				for slot: String in Grid.EQUIPMENT: check(actor[slot].is_empty(),"creature has no equipment")
				actor.points = 1
				check(not world.learn(actor,"Lunge").ok,"creature cannot learn humanoid skill")
				actor.skills.append("Lunge")
				check(not world.skill_available(actor,"Lunge"),"old skill cannot bypass anatomy")
				var item: Dictionary = Items.make("sword",true,rng)
				check(not Rules.compatible(actor,item,"main"),"shared equip guard")
				actor.bag.append(item)
				check(not preload("res://Production/Actors/inventory.gd").equip(actor,0),"legacy equip API respects anatomy")
				check(not Grid.transfer(actor,[],actor.actions,false,{"zone":"bag","id":item.item_id},{"zone":"equipment","slot":"main"}).ok,"inventory transfer cannot bypass anatomy")
				check(not world.drink(actor,0).ok,"creature cannot use potion")
			world.actors.erase(actor.id)
	check(total == 42,"forty-two variants")
	check(not Roster.weights(0,1).has("dragons") and Roster.weights(14,1).has("dragons"),"hostility unlocks stronger families")
	check(Roster.weights(0,43).has("dragons"),"player level influences family availability")
	var low: Dictionary = Roster.weights(14,1)
	var high: Dictionary = Roster.weights(25,1)
	check(high.dragons/high.wolves > low.dragons/low.wolves,"higher pressure shifts relative weights toward dragons")
	check(Roster.variant("werebeasts_1").humanoid and not Roster.variant("undead_3").humanoid,"approved werebeast/golem classification")
	var same_a := RandomNumberGenerator.new()
	var same_b := RandomNumberGenerator.new()
	same_a.seed = 99
	same_b.seed = 99
	for index: int in range(20): check(Roster.choose_family(same_a,10,10) == Roster.choose_family(same_b,10,10),"seeded selection deterministic")
	print("Enemy Roster: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
