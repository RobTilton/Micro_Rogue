extends SceneTree
const Items = preload("res://Production/Actors/items.gd")
const Grid = preload("res://Production/Actors/grid_inventory.gd")
func _initialize() -> void:
	var checks: int = 0
	for tier: int in range(1,9):
		for index: int in range(6):
			var result: Dictionary = Items.generate({"category":"belts","min_material_tier":tier,"max_material_tier":tier})
			assert(result.ok)
			var belt: Dictionary = result.item
			# Generate until the desired quality is reached, retaining the owning generator's derived fields.
			while belt.quality.id != Items.generator.catalog.qualities[index].id:
				belt = Items.generate({"category":"belts","min_material_tier":tier,"max_material_tier":tier}).item
			assert(belt.capacity == clampi(tier+1+Items.BONUS[index],1,14))
			assert(Items.valid_generated(belt))
			var potion: Dictionary = Items.potion()
			potion.pouch = 0
			belt.contents = [potion]
			var identity: int = belt.item_id
			belt.erase("belt_capacity_version")
			belt.capacity = 1 if index == 0 else 2
			var saved: Dictionary = {"actors":[{"belt":belt}],"states":{"shop_stock":[belt.duplicate(true)]}}
			Items.upgrade_belts(saved)
			Items.upgrade_belts(saved)
			assert(belt.capacity == clampi(tier+1+Items.BONUS[index],1,14))
			assert(belt.item_id == identity and belt.contents[0] == potion and belt.contents[0].pouch == 0)
			assert(saved.states.shop_stock[0].capacity == belt.capacity)
			assert(Items.valid_generated(belt))
			belt.contents.clear()
			var actor: Dictionary = {"belt":belt,"bag":[]}
			for pouch: int in range(belt.capacity):
				assert(Grid._put_belt(actor,Items.potion(),{"belt_id":belt.item_id}))
			assert(not Grid._put_belt(actor,Items.potion(),{"belt_id":belt.item_id}))
			assert(belt.contents.size() == belt.capacity)
			checks += 1
	print("Belt Progression: %d tier/quality combinations passed; migration preserves contents and identity." % checks)
	quit()
