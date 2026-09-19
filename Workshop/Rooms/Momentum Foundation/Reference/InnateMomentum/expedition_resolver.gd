extends RefCounted
## No alternate actor copies. Each resolution commits to the persistent actors/items.
const Combat = preload("res://Production/Actors/combat.gd")
const Rules = preload("res://Production/Actors/equipment_rules.gd")
const Momentum = preload("res://Production/Actors/momentum.gd")

static func weapon(actor: Dictionary) -> Dictionary:
	if not actor.main.is_empty(): return actor.main
	if not actor.get("natural_attack",{}).is_empty(): return actor.natural_attack
	return {"kind":"weapon","category":"maces","die":3,"bonus":0,"hands":"one","damage_type":"physical"}

static func expected_damage(source: Dictionary, target: Dictionary) -> float:
	var item: Dictionary = weapon(source)
	var value: float = (float(item.get("die",3))+1.0)/2.0+Rules.damage_bonus(item)+Rules.stat_bonus(source,item)
	value += int(source.get("attack_modifier",0))+Rules.Rings.bonus(source,item.get("damage_type","physical")+"_damage")
	return maxf(0.0,value-Combat.defense(target,item.get("damage_type","physical")))

static func attack_rate(world, actor: Dictionary) -> float:
	var grants: float = Momentum.speed(actor)/float(world.turn_threshold)
	var budget: Dictionary = Combat.allowance(actor)
	return maxf(0.0,minf(1.0,grants)*(budget.attack+budget.free)+maxf(0.0,grants-1.0))

static func use_healing(world, actor: Dictionary) -> int:
	if actor.hp >= actor.max_hp/2.0: return 0
	var consumed: int = 0
	for potion: Dictionary in actor.belt.get("contents",[]).duplicate():
		if actor.hp >= actor.max_hp/2.0: break
		if potion.kind == "potion":
			actor.belt.contents.erase(potion)
			Combat.heal(actor)
			consumed += 1
	for item: Dictionary in actor.bag.duplicate():
		if actor.hp >= actor.max_hp/2.0: break
		if item.kind == "potion":
			actor.bag.erase(item)
			Combat.heal(actor)
			consumed += 1
	if consumed > 0: world.record_event(actor,"healed",{"potions":consumed,"hp":actor.hp})
	return consumed

static func resolve(world, actor: Dictionary, distant: bool) -> void:
	# Never abstract combat in the map the player currently occupies.
	if actor.hp <= 0 or actor.map_id == world.actors[world.player_id].map_id: return
	var foes: Array = world.foes_in(actor.map_id)
	if foes.is_empty():
		world.collect_spoils(actor)
		if actor.map_id == actor.adventure.goal: actor.adventure.phase = "return"
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = world.Contracts.seed_for(world.maps.world_seed,"adventure:%d:%d" % [actor.id,world.ledger().turn])
	var limit: int = mini(64,foes.size()) if distant else 1
	var defeated: int = 0
	for index: int in range(limit):
		if actor.hp <= 0: break
		use_healing(world,actor)
		var target: Dictionary = foes[index]
		if target.hp <= 0: continue
		var outgoing: float = expected_damage(actor,target)*attack_rate(world,actor)
		var incoming: float = 0.0
		# Nearby allies attack together; this is not a guaranteed series of duels.
		for enemy: Dictionary in foes:
			if enemy.hp > 0 and world.maps.maps[actor.map_id].distance(target.pos,enemy.pos) <= 3:
				incoming += expected_damage(enemy,actor)*attack_rate(world,enemy)
		if outgoing <= 0.0:
			actor.adventure.phase = "return"
			world.record_event(actor,"stalemate",{"poi":actor.map_id})
			return
		var exposure: float = incoming*maxf(1.0,target.hp/outgoing)
		var survival: float = 1.0 if exposure <= 0 else clampf(1.5*actor.hp/(actor.hp+exposure),0.02,0.98)
		if rng.randf() > survival:
			var map = world.maps.maps[actor.map_id]
			for cell: Vector2i in map.neighbors(target.pos)+[actor.pos]:
				if map.walkable(cell) and not map.props.has(cell) and not map.links.has(cell) and world.actor_at(map.id,cell,actor.id).is_empty():
					actor.pos = cell
					break
			actor.hp = 0
			world.resolve_death(actor,target)
			world.record_event(actor,"killed",{"poi":actor.map_id,"enemy":target.id,"defeated":defeated})
			return
		actor.hp = maxi(1,actor.hp-roundi(exposure*rng.randf_range(0.35,0.85)))
		target.hp = 0
		world.resolve_death(target,actor)
		defeated += 1
		if actor.hp < actor.max_hp/4.0:
			use_healing(world,actor)
			if actor.hp < actor.max_hp/4.0:
				actor.adventure.phase = "return"
				break
	world.record_event(actor,"expedition" if distant else "encounter",{"poi":actor.map_id,"defeated":defeated,"hp":actor.hp})
	if world.foes_in(actor.map_id).is_empty():
		world.collect_spoils(actor)
		if actor.map_id == actor.adventure.goal: actor.adventure.phase = "return"
