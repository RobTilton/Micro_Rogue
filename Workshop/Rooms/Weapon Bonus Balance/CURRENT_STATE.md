# Weapon Bonus Balance
Updated: 2026-09-14
Checkpoint: [Weapon Bonus Balance]+[Validation]+[Double Modifiers]

F5 Production weapons now use base die + base flat + 2 × (material tier − 1) + 2 × quality modifier + existing stat bonus. Applies to all weapon categories, Physical and Magical. Trash becomes −2; Common 0; Exceptional +2; Masterwork +4; Mythic +6; God-Touched +10. Material bonuses are 0,2,4,6,8,10,12,14. Base dice/flats, stat scaling, armor, HP, prices and progression are unchanged. Proposed CON/level-up HP changes remain deferred.

Masterwork Steel Longsword: 1d8+10 before stats. T1 Common Shortsword remains 1d6+3 with STR/DEX 3, so the initial zero-damage matchup against 10 defense remains unresolved by this limited change.

New generated weapons carry rules_version 2 and doubled stored bonuses. Existing version-1 generated weapons retain their serialized properties but Rules.damage_bonus applies the missing additional material/quality contribution at runtime. Items.roll, inspection and enemy valuation use that shared effective bonus. Save validation accepts both versions using the appropriate original generation formula. Legacy items without generated material metadata retain their prior bonus. Armor remains version 1. No world reset required.

Modified files: Production/Actors/equipment_rules.gd, items.gd, item_inspection.gd and enemy_brain.gd. Source references and prior baseline retained under Reference/.

Validation: 5,399 checks passed across all weapon bases, eight material tiers and six qualities, plus v1/v2 equivalence, generated-item validation, old-item runtime roll bounds and unchanged armor validation. Frontier integration 73 checks passed including exact valid save restoration. Scoped whitespace check passed. Human playtest acceptance pending. No commit or save reset.
