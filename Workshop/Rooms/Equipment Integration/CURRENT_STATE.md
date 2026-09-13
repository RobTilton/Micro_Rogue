# Equipment Integration — Current State
Updated: 2026-09-13
Checkpoint: [Equipment Integration]+[Validation]+[Delivery]

Production F5 now uses generated material/quality equipment and the agreed Physical/Magical combat rules. The original Loot Foundation remains a standalone construction reference; Production owns its own catalog/generator and has no Workshop runtime dependency. [RULES.md](RULES.md) records all 56 weapon dice, stat scaling, armor formulas and handedness assignments.

## Runtime ownership

- `Production/Actors/loot_catalog.json` and `loot_generator.gd`: 161 base definitions, materials, six weighted qualities, deterministic filtered construction and empty affix layers.
- `equipment_rules.gd`: resolved fixed stats, armor slot weighting, stat bonus, handedness and compatibility. No combat rolls occur while inspecting defense.
- `items.gd`: Production ID allocation and generation adapter. `Items.generate(filters, rng)` returns the normal `{ok, item}` or error result. Source code may filter base/category/material tier independently. Resolved records retain legacy die/bonus fields for consumers and add explicit Physical/Magical values, damage type, range, hands, slot and rules_version. IDs increment only on successful construction.
- `combat.gd`: shared attack roll, archetype bonus and matching fixed defense. Zero damage is valid; no miss check or difficulty-dependent rounding. Existing skill cooldowns and momentum action costs remain.
- `grid_inventory.gd`, `inventory.gd`, `actor_world.gd`: main/off/chest/head/arms/legs/belt ownership. Equipping a two-handed weapon stows the offhand if the bag has room, atomically; otherwise nothing moves or spends. Shields cannot be equipped alongside two-handed grips. Versatile grip change costs one activation and requires an empty offhand.
- `enemy_brain.gd`: evaluates fixed armor contributions and weapon stats, accounts for losing the offhand when considering a two-handed upgrade, and uses the shared inventory and ranged attack service. This remains basic AI, not an optimized build planner.
- `UI/game_ui.gd`, `actor_game.gd`, item inspection/art: seven equipment targets in a three-column layout, grip control, exact item defenses/damage/scaling, character defense totals and six quality colors. New weapon families use generic symbols where art is unavailable.
- `Persistence/persistent_actor_world.gd`: saves generated records, new slots and grip; validates resolved stats before loading. Existing compatible saves gain empty slots without rerolling their gear.

## Playable entry points and defaults

New player/NPC starting equipment uses the generator. The current starter policy keeps a Shortsword, shield, one body armor and belt, with material tier 1–3 and the same quality weights for both factions. Head/arms/legs start empty. Belts retain the existing 5% per-pouch chance of a potion during starter generation. This deliberately does not invent class/prosperity/hostility progression.

Each newly populated location receives one seeded loose generated item, material tier 1–3, drawn from the full catalog. Its placement and properties persist; visiting an already initialized location does not reroll or add it. Existing populated maps are not repopulated. NPC possessions drop as their actual items on death, including any armor accessories they acquired. Containers and shops are not implemented.

Full armor values receive quality first, then slot weighting: chest 100%, helmet and shield 50%, arms and legs 25%, nearest-integer rounding with halves up. Shield pre-slot values are provisionally balanced (tier + 2 to both, plus quality). This provisional shield baseline is the remaining balance assumption; the slot weights are Rob’s explicit correction.

Bows use Physical and staffs Magical damage, range 5, the existing terrain sight ray and no ammunition costs, as explicitly approved. Melee range remains 1. No new line-of-fire actor obstruction or spell system is claimed.

## Save compatibility and boundaries

Generated items use rules_version 1 with exact resolved-stat validation. Legacy items retain their dictionaries, IDs, names, rarity and dice. Legacy weapons keep their old base damage; legacy armor’s former die + bonus becomes fixed defense in both channels (legacy shields contribute half, rounded). Old generated-equipment semantics are never guessed from a name. This is a compatibility interpretation, not a reroll into new catalog entries. Old accessories did not exist and therefore load empty. No player save is reset.

Affix layers remain empty, with ring/category construction extension points inherited from Loot Foundation. Functional rings still need slot rules and content; affix effects need their own resolver/versioned save rules. No suffix effects, Titanic Strength, Thickskin, tomes, class identity, level/hostility loot formula or balance target for competing two tiers higher was invented.

## Evidence and disposition

- Equipment formula suite: 193 checks passed, including all 161 generated bases, supplied damage examples, family rounding, slot contributions, mixed defense, stat scaling and zero damage.
- Shared action suite: 12 checks passed for atomic two-hand transfers, accessory slots, ranged attacks and terrain obstruction, grip switching and exact enemy drops.
- Rendered Production suite: 14 checks passed for startup, accessories, Local entry, persistent loose loot without duplication, exact journal roundtrip, legacy migration, malformed-save refusal and inventory construction. Screenshot retained in tests/inventory.png and inspected.
- Existing momentum action suite: 28 checks passed. Existing Production momentum integration: 13 checks passed during adoption.

Test saves live only in the owning test Rooms. Changed-source originals and the prior manifest remain in Reference. Production/BASELINE.json records this adoption. No Git commit or unrelated cleanup. Human balance/playtest acceptance remains pending.
