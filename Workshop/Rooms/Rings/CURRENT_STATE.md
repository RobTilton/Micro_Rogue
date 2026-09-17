# Rings — Current State
Updated: 2026-09-17
Checkpoint: [Rings]+[Validation]+[Delivery]

## Rapid shape

F5 Production includes all 31 ring variants from [the supplied design](../../Micro_Rogue_Rings_And_Amulets.md): six paired stat families, eight paired system families, and three Greater-only action rings. Eight independent humanoid ring slots allow duplicate stacking. Amulets remain deferred; the jeweler stays closed.

## Runtime contracts

- `Production/Actors/rings.gd` owns ring definitions, generation, validation, derived stat/bonus access and descriptions. Rings occupy one backpack cell and use placeholder drawn ring icons.
- Actor `stats` remain permanent values. Consumers use derived values for combat, sight, normal movement, momentum, healing and displayed stats. WIL adds three maximum HP per point; equipping never heals, removing clamps current HP. `ring_hp_bonus` tracks only the removable maximum-HP contribution and is validated on load.
- Movement rings add normal movement hexes; Momentum rings add momentum each world tick. Stat DEX still affects both existing systems. Healing rings add once per potion, inn or camp event, after CON multiplication.
- Action rings modify the next earned turn allowance, including Free Action alongside extra momentum grants. Equipping never refills current actions. Removing action bonuses reduces unspent allowance. Movement credit cannot grow by swapping rings mid-walk.
- Shared equipment rules enforce humanoid-only use. NPC upgrade selection recognizes ring slots and stronger ring bonuses; equipment drops into the normal corpse/ground loot flow on death. NPC ring scoring is a simple numeric placeholder, not a class-specific optimizer.
- Inventory supports shift-click to the next empty slot (first slot replacement when full), explicit drag/drop into any slot, shift-click removal, inspection, selling and merchant resale. Low-magic prices: Lesser 50 gold (sell 5), paired Greater 250 (sell 25). Greater-only action rings cannot be bought or sold and display no gold price. Existing saved shop offers are quoted using current ring prices; their stored items are preserved. Ordinary equipment resale remains 50%. Prosperity affects stock quantity/tier, not prices; no prosperity/hostility price modifiers currently exist.
- Existing saves accept absent ring slots. Loading initializes them without rerolling items or rewriting base stats. New ring instances persist with identity, family and grade.

## Loot policy

`Items.loot` rolls 5% rings before its ordinary non-equipment/equipment branch. Guaranteed supplies remain potions. This reaches newly generated Local chests, POI containers and loose POI loot; existing contents are unchanged. No world reset is needed. Ordinary equipment-only generation and shop restocking remain unchanged.

Paired families are uniformly selected and retain an exact 99% Lesser / 1% Greater grade roll. Action rings have a separate 1%-gated roll with 3/17 selection, approximately 0.176% of ring drops, equally divided between the three action families. This provisional choice keeps actions rare without altering the paired-family grade ratio. Chest rarity remains the separate 75% Normal / 25% Rare system.

## Validation and limits

- `ring_test.gd`: 190 checks passed: every variant, eight-slot stacking, stat isolation, healing/HP, movement/momentum/sight, channel damage/defense, action allowance, NPC upgrade eligibility, pricing, rejection of malformed rings, real inn healing, world save/load and corpse drops. Distribution sample: 1,009 Greater / 99,829 paired; 171 action rings / 100,000 rings; 266 rings / 5,000 loot rolls.
- `integration_test.gd`: 8 checks passed through the real F5 scene, isolated saves: shift-click, explicit eighth-slot transfer, all eight UI targets, effective stats, autosave and legacy absent slots. `inventory.png` visually inspected; ring slots and backpack icons fit the existing paperdoll.
- Existing regressions: Chest Rarity 48, Movement Flow 31, Skill Board 40 checks passed. Total: 317 passing checks.
- Ring illustrations remain simple placeholders. No amulet mechanics or new skill effects were added. Human playtest acceptance remains pending.

Original touched files are retained under `Reference/`; tests and isolated saves stay in this Room. No user world was reset and no Git commit was created.

## Ring pricing correction

Checkpoint: [Rings]+[Economy]+[Pricing]. `pricing_test.gd` passes 18 checks covering both grades, 10% resale, all three untradeable action families, hidden monetary tooltips, stale shop offers, real buy/sell refusal and valid persistent state. Shop UI script compile check passed. Initial integration evidence above precedes this pricing correction.

Drop-rate audit (unchanged): standard `Items.loot` is 5% rings, 19% health potions, 76% equipment. Guaranteed supplies return potions. Camp props can choose rations first; village stock/containers use equipment generation directly. Monster deaths release actual possessions rather than rolling this table. Equipment quality weights sum to 1,000: Trash 15%, Common 51%, Exceptional 25%, Masterwork 8%, Mythic 0.9%, God-Touched 0.1%. Conditional ring odds remain as documented above; approximately 4.9413% of ordinary loot rolls are Lesser rings, 0.04991% paired Greater, and 0.008824% Greater-only action rings. The pricing correction did not change loot rates. Equipment quality weights were subsequently updated by user request; the item-type and ring-grade rates remain unchanged.

Quality tuning checkpoint: [Rings]+[Economy]+[QualityWeights]. Production catalog weights are 150/510/250/80/9/1 out of 1,000, verified after writing and totaling exactly 100%. Applies to new equipment rolls; existing items retain their qualities.
