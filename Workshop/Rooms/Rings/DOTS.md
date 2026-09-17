# Rings
Updated: 2026-09-17

Outcome: implement approved rings in Production: eight shared humanoid slots, loot, UI, persistence and effects. Authorization: user requested rings, confirmed distance/momentum distinctions and provisional loot rules, then asked to continue. Amulets excluded.
Starting state: current working files following Chest Rarity; originals retained under Reference before changes. Existing uncommitted work preserved.
Acceptance: all variants apply/remove, no equip healing/action refill, old/new save compatibility, player UI and NPC use, focused checks.

- [Rings]+[Runtime]+[Integration] — complete. Definitions and 31 variants, derived bonuses, equipment/AI, loot, inventory/commerce and save validation. Evidence: ring_test.gd and integration_test.gd.
- [Rings]+[Validation]+[Delivery] — complete (agent delivery); depends on Integration. 317 checks passed across ring/runtime/UI and focused chest/movement/skill regressions. Inventory screenshot inspected. CURRENT_STATE and Production baseline synchronized.

Last completed: [Rings]+[Economy]+[QualityWeights]. Active checkpoint: none. Next: human F5 playtest. Human acceptance pending. Provisional drop/price policy and placeholder art documented in CURRENT_STATE.md. Retain Reference, tests, isolated saves and inventory.png. No commits or deletions.

- [Rings]+[Economy]+[Pricing] — complete. 18 transaction/policy checks and shop UI compile passed. User correction: Lesser 50/5, paired Greater 250/25, Greater-only untradeable; inspect existing loot probabilities. Preserve pre-change files in Reference/Pricing.

- [Rings]+[Economy]+[QualityWeights] — complete. Saved JSON values and 1,000-weight total verified. User approved equipment quality percentages 15/51/25/8/0.9/0.1; preserve existing items and separate ring rates.
