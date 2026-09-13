# Loot Foundation — Current State
Updated: 2026-09-13
Checkpoint: [Loot Foundation]+[Validation]+[Delivery]

This document describes the original standalone Workshop construction module and its original integration boundaries. Its Production successor is now adopted in [Equipment Integration](<../Equipment Integration/CURRENT_STATE.md>), which owns active combat values, slot weighting, runtime wiring and validation. The standalone generator and its historical test evidence below are retained.

## Files and ownership

- [ITEM_CATALOG.md](ITEM_CATALOG.md): all supplied tables and deferred design intent.
- [data/catalog.json](data/catalog.json): 40 materials, six qualities, 160 supplied bases and one derived Belt base. Stable IDs separate names from references; rank preserves supplied order.
- [domain/loot_generator.gd](domain/loot_generator.gd): catalog validation, compatible selection and record construction.
- [tests/loot_test.gd](tests/loot_test.gd): executable contract checks.
- Reference retains exact legacy Production item/inventory source copies from task entry. Those files document compatibility gaps; they are not live dependencies.

## Calling the module

```gdscript
const Loot = preload("res://Workshop/Rooms/Loot Foundation/domain/loot_generator.gd")
var loot = Loot.new()
var rng = RandomNumberGenerator.new()
rng.seed = 12345
var result = loot.generate(rng, {
    "item_id": 1001,
    "category": "swords",
    "min_base_rank": 1,
    "max_base_rank": 3,
    "min_material_tier": 1,
    "max_material_tier": 2
})
if result.ok:
    var item = result.item
```

The caller owns unique item IDs, RNG and source progression. The generator never advances a global ID counter. Repeating the same seed and request sequence reproduces records. Failed requests consume no randomness and produce no item. `item_id` is required; optional filters are `base_id`, `category`, `material_family`, `material_id`, `min_base_rank`, `max_base_rank`, `min_material_tier`, `max_material_tier`. Unknown fields and incompatible/empty selections refuse with an origin-qualified error.

Selection is uniform among eligible base types, then uniform among their eligible materials. This is a test default, not a hostility/player-level progression formula. Unfiltered selection weights categories by their number of bases. A future loot-source policy should supply filters or choose bases explicitly; it must not silently treat this default as balanced drop tables. Quality uses the exact shared 20/40/20/15/4/1 distribution independently of selection.

Outputs contain schema_version, caller item_id, base_id/name/rank, category, kind, slot, a single material record, material_tier, quality metadata and separate empty prefix/suffix arrays. Name formatting is literal Quality + Material + Base Name. Material-bearing base names are intentionally preserved, so some combinations repeat material wording; naming grammar can change without changing IDs. Records are independent dictionaries and support Godot variant serialization. No damage/defense, roll-percentile, numeric rarity or stat multiplier is fabricated. Belt capacity alone is resolved: Trash 1, otherwise 2.

## Extensions

`Loot.new(custom_catalog)` validates and copies a caller-provided catalog. New categories and base entries do not require a generation branch. To introduce rings, register a ring slot, jewelry category with allowed material families, and ranked bases. The test demonstrates generating a gem ring using only those data additions; the shipped catalog does not contain invented ring types. Production still needs ring equipment slots and rules when that module is approved.

Each string in catalog `affix_layers` creates a separate empty array in generated records. Prefixes and suffixes are reserved today; the test adds an implicit layer without editing the generator. No affix roll, affix effect application or arbitrary affix injection is implemented. The future affix pass can consume and enrich these records after base/material/quality construction. Gems are available in the material registry for that future content but ordinary equipment cannot randomly receive them through unsupported component rules.

## Validation and next integration

Godot 4.4.1 headless: 690 checks passed. Coverage includes exact quality boundaries/counts; same-seed reproducibility; all 161 bases; independent material tiers; belt behavior; invalid requests leaving RNG unchanged; malformed catalogs; output isolation; variant serialization; and data-only rings/new affix layers. No rendered UI behavior is claimed for this data module.

Production adoption is the next separate step. Its existing item generator has five qualities and combat expects legacy `die`, `bonus` and sword-specific kinds. Equipment currently supports main, off, body and belt only. These records must not be sent directly into that runtime: define a stat adapter, preserve old item interpretation, add slot/weapon support, and connect the generator to loot sources before adoption. Class loadouts, hostility/level scaling, tier overlap balance, multi-material assembly and functional affixes remain deferred. No save reset, Production edit or Git commit was made.
