# Equipment and Combat Rules
Updated: 2026-09-13
Checkpoint: [Equipment Integration]+[Rules]+[Catalog]

Active data: `Production/Actors/loot_catalog.json`. Names, base ranks and materials originate in [the full item catalog](<../Loot Foundation/ITEM_CATALOG.md>). This document adds Rob’s weapon/armor formulas and explicitly labels implementation defaults.

## Damage and innate defense

All attacks use Physical or Magical damage. No miss roll, elemental resistances or True damage. Damage taken is max(0, floor(incoming damage − matching defense)). CON adds Physical Defense 1:1; WIL adds Magical Defense 1:1. Normal difficulty no longer changes rounding. Fractional stat bonuses round down consistently. Existing Lunge adds floor(1.5 × STR); Riposte adds DEX to Physical Defense while active. No new skills are invented.

Weapon damage = base die + built-in base flat bonus + (material tier − 1) + quality modifier + archetype stat bonus.

| Archetype | One hand | Two hands |
|---|---|---|
| Daggers | DEX | Not permitted |
| Swords, Spears, Axes | floor((STR + DEX) / 2) | STR + DEX |
| Maces | STR | floor(STR × 1.5) |
| Bows | — | DEX |
| Staffs | — | INT |

| Quality | Modifier | Weight |
|---|---|---|
| Trash | -1 | 20 |
| Common | +0 | 40 |
| Exceptional | +1 | 20 |
| Masterwork | +2 | 15 |
| Mythic | +3 | 4 |
| Touched by the Gods | +5 | 1 |

God-Touched is the user’s later shorthand for Touched by the Gods; the stable quality ID and catalog label are retained. These flat modifiers apply equally to both armor defenses.

## Armor and shield contributions

Full-piece baseline X = material tier + 2 (3 through 10). Leather is X / X. Cloth is round(X × 0.75) Physical / round(X × 1.25) Magical. Plate reverses the skew. First round the family values to integers, then add quality to both, then apply the slot contribution and round again. Defense rounding uses nearest integer with halves up. Each equipped piece contributes independently. Base item rank does not add another armor multiplier.

| Slot | Contribution of the piece’s quality-adjusted values |
|---|---|
| Chest (runtime armor) | 100% |
| Head | 50% |
| Arms (hands) | 25% |
| Legs (feet) | 25% |
| Shield | 50% |

The supplied Arms/Legs slots represent the later hands/feet wording; no separate glove/boot slots were invented. Shield pre-slot values use the provisional balanced Leather baseline plus quality; its contribution is halved per Rob’s correction. Example: tier 6 Masterwork Plate gives 12/8 on chest, 6/4 on head and 3/2 on arms or legs. A tier 6 Masterwork shield gives 5/5.

Belts use Leather material tiers, two base pouches and one pouch for Trash. Other quality/material capacity bonuses remain undefined.

## Weapon bases and proposed sensible handedness

Handedness is an implementation classification, not a new damage formula. Versatile weapons can switch grip through a shared activation action with an empty offhand. Two-handed weapons occupy both hands. Titanic Strength is deferred. Ranged rules approved by Rob: bows Physical, staffs Magical, range 5, existing terrain line of sight, no ammunition cost. Melee range is 1. Actor bodies do not block the existing sight ray.

| Category | Base | Base damage | Hands |
|---|---|---|---|
| Swords | Shortsword | 1d6 | one |
| Swords | Arming Sword | 1d7 | one |
| Swords | Longsword | 1d8 | versatile |
| Swords | Bastard Sword | 1d9 | versatile |
| Swords | Greatsword | 1d10 | two |
| Swords | Falchion | 1d8+2 | one |
| Swords | Scimitar | 1d8+1 | one |
| Swords | Sabre | 1d9+1 | one |
| Spears | Short Spear | 1d6 | versatile |
| Spears | Hunting Spear | 1d7 | versatile |
| Spears | War Spear | 1d8 | versatile |
| Spears | Pike | 1d9 | two |
| Spears | Partisan | 1d9+1 | two |
| Spears | Glaive | 1d10 | two |
| Spears | Halberd | 1d10+1 | two |
| Spears | Lance | 1d12 | one |
| Maces | Club | 1d4 | one |
| Maces | Mace | 1d6 | one |
| Maces | Flanged Mace | 1d7 | one |
| Maces | Morning Star | 1d8 | one |
| Maces | Warhammer | 1d9 | one |
| Maces | Maul | 1d10 | two |
| Maces | Scepter | 1d8+1 | one |
| Maces | Great Maul | 1d12 | two |
| Daggers | Knife | 1d3 | one |
| Daggers | Dagger | 1d4 | one |
| Daggers | Dirk | 1d4+1 | one |
| Daggers | Rondel | 1d5 | one |
| Daggers | Stiletto | 1d5+1 | one |
| Daggers | Kris | 1d6 | one |
| Daggers | Main-Gauche | 1d6+1 | one |
| Daggers | Assassin Blade | 1d8 | one |
| Axes | Hatchet | 1d5 | one |
| Axes | Hand Axe | 1d6 | one |
| Axes | Battle Axe | 1d8 | versatile |
| Axes | Bearded Axe | 1d8+1 | versatile |
| Axes | War Axe | 1d9 | versatile |
| Axes | Dane Axe | 1d10 | two |
| Axes | Greataxe | 1d11 | two |
| Axes | Executioner Axe | 1d12 | two |
| Bows | Shortbow | 1d6 | two |
| Bows | Hunting Bow | 1d7 | two |
| Bows | Recurve Bow | 1d8 | two |
| Bows | Longbow | 1d9 | two |
| Bows | Warbow | 1d10 | two |
| Bows | Composite Bow | 1d10+1 | two |
| Bows | Greatbow | 1d11 | two |
| Bows | Ranger Bow | 1d12 | two |
| Staffs | Walking Staff | 1d4 | two |
| Staffs | Quarterstaff | 1d6 | two |
| Staffs | Battlestaff | 1d7 | two |
| Staffs | Mage Staff | 1d8 | two |
| Staffs | Runed Staff | 1d9 | two |
| Staffs | Channeling Staff | 1d10 | two |
| Staffs | Archmage Staff | 1d11 | two |
| Staffs | Grand Staff | 1d12 | two |

Future affixes may modify damage, defense and stats, or convert damage channel. The arrays exist, but affix rolling/effects, tomes, class-specific loadouts and progression catch-up formulas are not implemented. Flat skill/stat bonuses are intended; no percentage-based progression skills were added.
