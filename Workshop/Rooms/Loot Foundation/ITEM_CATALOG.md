# Item Catalog
Updated: 2026-09-12
Checkpoint: [Loot Foundation]+[Catalog]+[Definitions]

User-supplied names and ascending order are preserved below. Base rank, material tier and quality are independent fields. The four armor slots are Body, Head, Arms and Legs; material families are Metal, Leather, Cloth, Wood and Crystal/Gem.

## Materials

| Tier | Metal | Leather | Cloth | Wood | Crystal / Gem |
|---|---|---|---|---|---|
| 1 | Lead | Rawhide | Burlap | Pine | Quartz |
| 2 | Bronze | Leather | Linen | Oak | Amethyst |
| 3 | Iron | Hardened Leather | Wool | Ash | Topaz |
| 4 | Steel | Beast Hide | Cotton | Yew | Opal |
| 5 | Silver | Trollhide | Silk | Ironwood | Sapphire |
| 6 | Mithril | Wyvernhide | Spidersilk | Blackwood | Emerald |
| 7 | Adamant | Drakehide | Runic Silk | Elderwood | Ruby |
| 8 | Orichalcum | Dragonhide | Starweave | Worldwood | Diamond |

## Quality

| Color | Quality | Weight |
|---|---|---|
| Grey | Trash | 20 |
| White | Common | 40 |
| Green | Exceptional | 20 |
| Blue | Masterwork | 15 |
| Purple | Mythic | 4 |
| Orange | Touched by the Gods | 1 |

Weights total 100. The same unmodified distribution applies to all actors and loot sources. No enemy-only quality penalty.

## Weapons, shields and body armor

| Category | Base types, ascending rank 1–8 |
|---|---|
| Swords | Shortsword, Arming Sword, Longsword, Bastard Sword, Greatsword, Falchion, Scimitar, Sabre |
| Spears | Short Spear, Hunting Spear, War Spear, Pike, Partisan, Glaive, Halberd, Lance |
| Maces | Club, Mace, Flanged Mace, Morning Star, Warhammer, Maul, Scepter, Great Maul |
| Daggers | Knife, Dagger, Dirk, Rondel, Stiletto, Kris, Main-Gauche, Assassin Blade |
| Axes | Hatchet, Hand Axe, Battle Axe, Bearded Axe, War Axe, Dane Axe, Greataxe, Executioner Axe |
| Shields | Buckler, Round Shield, Heater Shield, Kite Shield, Tower Shield, Pavise, Warded Shield, Greatshield |
| Plate Armor | Brigandine, Scale Mail, Chainmail, Half Plate, Plate Harness, Full Plate, Gothic Plate, Dreadplate |
| Leather Armor | Rawhide Armor, Treated Leather, Hardened Leather, Studded Leather, Reinforced Leather, Layered Leather, Scalehide Armor, Beastplate |
| Cloth Armor | Cloth Wraps, Padded Robes, Woven Vestments, Enchanted Robes, Runed Vestments, Spellwoven Robes, Arcane Raiment, Astral Vestments |
| Bows | Shortbow, Hunting Bow, Recurve Bow, Longbow, Warbow, Composite Bow, Greatbow, Ranger Bow |
| Staffs | Walking Staff, Quarterstaff, Battlestaff, Mage Staff, Runed Staff, Channeling Staff, Archmage Staff, Grand Staff |

## Leather armor accessories

| Tier | Head | Arms | Legs |
|---|---|---|---|
| 1 | Hide Hood | Hide Bracers | Hide Leggings |
| 2 | Leather Cap | Leather Bracers | Leather Trousers |
| 3 | Hardened Leather Hood | Hardened Vambraces | Hardened Legguards |
| 4 | Studded Leather Helm | Studded Bracers | Studded Leggings |
| 5 | Reinforced Leather Hood | Reinforced Vambraces | Reinforced Legguards |
| 6 | Layered Leather Helm | Layered Bracers | Layered Leggings |
| 7 | Scalehide Hood | Scalehide Vambraces | Scalehide Legguards |
| 8 | Beastplate Helm | Beastplate Bracers | Beastplate Greaves |

## Cloth armor accessories

| Tier | Head | Arms | Legs |
|---|---|---|---|
| 1 | Cloth Hood | Cloth Wraps | Cloth Leggings |
| 2 | Padded Hood | Padded Sleeves | Padded Trousers |
| 3 | Woven Cowl | Woven Sleeves | Woven Leggings |
| 4 | Enchanted Hood | Enchanted Wraps | Enchanted Trousers |
| 5 | Runed Cowl | Runed Sleeves | Runed Leggings |
| 6 | Spellwoven Hood | Spellwoven Wraps | Spellwoven Trousers |
| 7 | Arcane Circlet | Arcane Sleeves | Arcane Leggings |
| 8 | Astral Crown | Astral Wraps | Astral Leggings |

## Plate armor accessories

| Tier | Head | Arms | Legs |
|---|---|---|---|
| 1 | Brigandine Cap | Brigandine Bracers | Brigandine Legguards |
| 2 | Scale Helm | Scale Bracers | Scale Greaves |
| 3 | Chain Coif | Chain Vambraces | Chain Leggings |
| 4 | Half-Plate Helm | Half-Plate Gauntlets | Half-Plate Greaves |
| 5 | Plate Helm | Plate Gauntlets | Plate Greaves |
| 6 | Full Helm | Full Gauntlets | Full Greaves |
| 7 | Gothic Helm | Gothic Gauntlets | Gothic Greaves |
| 8 | Dread Helm | Dread Gauntlets | Dread Greaves |

## Belts

Retain the existing belt concept. Use the Leather material progression above. Capacity is 2 + (material tier - 1) + quality bonus, clamped to 1–14. Bonuses: -1/0/+1/+2/+3/+5 from Trash through Touched by the Gods. No additional named belt base types were supplied.

## Generation boundaries

There are 160 supplied base types, plus a derived generic Belt entry. Initial generation assigns one material and one quality. Base rank is not forced to equal material tier. The catalog does not establish damage, defense, prices or speed bonuses.

Provisional material compatibility for the first generator: metal for swords, spears, daggers, axes and non-Club maces; wood for Club, bows and staffs; metal or wood for shields; matching metal/leather/cloth for armor; leather for belts. These are implementation defaults, editable per category or base. Gems are cataloged but not randomly attached to equipment before focus/component rules exist. Crossbows and standalone focus base types were mentioned but no ordered lists were supplied.

## Deferred design intent

Generated actors should have class identity guiding equipment. Hostility and player level should influence generation; exact formulas are not established. The strongest approximately 20% within a tier should compete roughly two tiers higher, depending on opposing quality. This is a future balance target, not an implemented modifier or an extra roll.

Multi-material example: Bronze blade (tier 2) + Ironwood grip (tier 5) averages 3.5, proposed rounding to 4 normally or 3 on Hard. Component damage contributions and an overall tier multiplier remain WIP. Single-material generation does not apply this averaging.

Rings will enter through a new category, base definitions, materials and slot declaration. No ring names, slot counts or powers have been invented. Prefix and suffix layers are reserved as empty arrays; affix selection, compatibility and stat effects are deferred.

Machine-readable source: [data/catalog.json](data/catalog.json). Runtime consumers must resolve combat stats and equip-slot support before adopting these records into Production.
