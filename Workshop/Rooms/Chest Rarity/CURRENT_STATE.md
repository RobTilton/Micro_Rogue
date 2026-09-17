# Chest Rarity
Updated: 2026-09-17
Checkpoint: [Chest Rarity]+[Validation]+[Delivery]

Read `Workshop/Micro_Rogue_Rings_And_Amulets.md` fully. Rings tune existing systems; amulets introduce rule changes. The document's standard amulet target is 0.05% from Rare Chests. User explicitly specified chest mix: 75% normal, 25% rare. This Room implements chest classification. Rings have since been delivered in [Rings](../Rings/CURRENT_STATE.md); amulets remain pending.

`Production/World/chest_rarity.gd` owns roll intervals: 1–75 normal, 76–100 rare. Each chest uses an independent seed derived from its location seed and cell; assignment does not consume loot/gold/population RNG. This is a per-chest probability, not a fixed quota for each map. `chest_rarity` is serialized in the existing prop dictionary, and the name becomes Normal Chest / Rare Chest (or Normal/Rare Wild Chest). Existing chest sprites remain shared.

Persistent world's `_seed_prop_gold` classifies all newly populated Town, Local and interior props. `_balance_chest_gold` also ensures classification on old loaded/re-entered maps, including lazy restored maps. Already-tagged chests never reroll. Existing contents, item IDs, gold and opened state are preserved. Rare classification does not yet grant better gear or extra gold. Rings use the shared random-loot table independently of chest rarity; rare-chest amulets remain deferred. Interior prop validation accepts absent tags for legacy saves and rejects invalid explicit classifications.

Evidence: chest_test.gd passes 48 checks covering exact 75/25 roll intervals, deterministic assignment, idempotence, preserved state, malformed data, all generation branches, and world save/load including lazy map restoration. Independent seeded sample: 597 rare out of 2,499 chests (23.89%, a sample rather than a quota). Edited tracked code passes git diff --check. Isolated test saves and source references retained. No player-save reset or commits. Human acceptance pending.
