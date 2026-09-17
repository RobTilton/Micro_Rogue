# MICRO ROGUE — RINGS & AMULETS

## Design Philosophy

Jewelry is divided into two fundamentally different equipment systems:

* **Rings tune existing systems.**
* **Amulets break, replace, or introduce rules.**

Micro Rogue uses simple numbers with direct effects. Jewelry should follow the same philosophy: short descriptions, immediately understandable effects, and complexity produced by interactions with other systems rather than complicated item text.

---

# RINGS

## Ring Philosophy

Rings are tuning points for the player's stats, defenses, damage, and other existing systems.

Most rings have two tiers:

* **Lesser**
* **Greater**

For rings that have both versions:

* **Lesser Ring:** 99% of Lesser/Greater ring drops.
* **Greater Ring:** 1% of Lesser/Greater ring drops.

Greater specialized rings deliberately outperform the equivalent Greater stat ring **within their specific subsystem**, because the specialized ring sacrifices the other benefits provided by the governing stat.

### General Pattern

**Stat Rings**

* Lesser: `+1 Stat`
* Greater: `+2 Stat`

**Specialized System Rings**

* Lesser: `+1`
* Greater: `+3`

**Greater-Only Action Rings**

* No Lesser version.
* Modify the player's action economy directly.

---

## Stat Rings

### Ring of Constitution

**Lesser:**
`+1 CON`

**Greater:**
`+2 CON`

### Ring of Strength

**Lesser:**
`+1 STR`

**Greater:**
`+2 STR`

### Ring of Dexterity

**Lesser:**
`+1 DEX`

**Greater:**
`+2 DEX`

### Ring of Intelligence

**Lesser:**
`+1 INT`

**Greater:**
`+2 INT`

### Ring of Wisdom

**Lesser:**
`+1 WIS`

**Greater:**
`+2 WIS`

### Ring of Will

**Lesser:**
`+1 WIL`

**Greater:**
`+2 WIL`

---

# SPECIALIZED SYSTEM RINGS

These rings improve only one specific system.

Their Greater versions provide `+3` because a Greater stat ring provides `+2` to the governing stat while also providing that stat's other benefits.

Specialization therefore provides a stronger individual effect at the cost of versatility.

## Physical Damage

**Lesser:**
`+1 Physical Damage`

**Greater:**
`+3 Physical Damage`

## Magical Damage

**Lesser:**
`+1 Magical Damage`

**Greater:**
`+3 Magical Damage`

## Eagle's Eye

**Lesser:**
`+1 View Range`

**Greater:**
`+3 View Range`

## Movement Speed

**Lesser:**
`+1 Movement Speed`

**Greater:**
`+3 Movement Speed`

## Momentum

**Lesser:**
`+1 Momentum`

**Greater:**
`+3 Momentum`

## Healing

Increases health restored by healing/rest events.

**Lesser:**
`+1 HP Restored`

**Greater:**
`+3 HP Restored`

## Physical Armor

**Lesser:**
`+1 Physical Armor`

**Greater:**
`+3 Physical Armor`

## Magical Armor

**Lesser:**
`+1 Magical Armor`

**Greater:**
`+3 Magical Armor`

---

# GREATER-ONLY ACTION RINGS

These rings do not have Lesser versions.

Their effects modify the player's action economy rather than providing ordinary numerical tuning.

## Attack Action Ring

`+1 Attack Action`

## Movement Action Ring

`+1 Movement Action`

## Free Action Ring

`+1 Free Action`

---

# AMULETS

## Amulet Philosophy

Amulets are extraordinarily rare items that change how the game works for the wearer.

They should produce:

> "Oh... fuck."

moments.

Amulets should generally **change a rule, introduce a rule, remove a restriction, or enable behavior that normally does not exist.**

They should not merely behave like stronger rings.

The player has:

`2 Amulet Slots`

### Standard Amulet Drop Rate

Standard amulets are intended to be approximately:

`0.05% chance from a Rare Chest`

Exact balance may change during testing.

---

# STANDARD AMULETS

## Lowest Armor

The player's attacks use the lower of the target's Physical Armor or Magical Armor when determining damage reduction.

`Effective Armor = MIN(Physical Armor, Magical Armor)`

This applies regardless of the attack's normal damage type.

---

## Adjacency Breaker

Reduce the adjacency requirements of **all skills by 1**.

Example:

`Requires 3 Adjacent Nodes → Requires 2`

This changes the geometry and construction possibilities of the player's skill honeycomb.

---

## Critical Strike

`Your attacks can critically strike.`

Critical strikes are otherwise unavailable to the player.

---

## Dodge

`Dodge Chance = DEX + WIS`

The resulting value maps directly to percentage chance.

Example:

`6 DEX + 6 WIS = 12% Dodge Chance`

Dodge is otherwise unavailable to the player.

---

## Double Consumables

`Your consumables have 2 charges each.`

The effect applies to consumables used through the player's normal consumable/belt systems.

---

## Double Backpack

`Your backpack space is doubled.`

---

## Structure Escape

`You may instantly return to the entrance of any structure you are inside.`

This returns the player to the structure entrance rather than civilization or another safe location.

---

## Clone

Once per day:

`Create a clone of yourself.`

The clone:

* Has `1 HP`.
* Lasts `1 Round`.
* Otherwise functions as a clone of the player.

Exact edge-case interactions are intentionally left for implementation and playtesting.

---

# TOUCHED-BY-THE-GODS AMULETS

Touched-by-the-Gods Amulets exist above standard amulets.

They do not merely change a rule.

They provide an attribute increase so far beyond ordinary jewelry that the character's build can fundamentally change around the item.

### Intended Rarity

Approximately:

`0.001% of Amulet Drops`

These items are not expected progression.

They are run-defining events.

---

## Touched-by-the-Gods — Constitution

`+10 CON`

## Touched-by-the-Gods — Strength

Example:

**Amulet of Titanicous's Strength**

`+10 STR`

## Touched-by-the-Gods — Dexterity

`+10 DEX`

## Touched-by-the-Gods — Intelligence

`+10 INT`

## Touched-by-the-Gods — Wisdom

`+10 WIS`

## Touched-by-the-Gods — Will

`+10 WIL`

---

# DESIGN INVARIANTS

### Rings Tune Systems

Rings should primarily provide small, direct numerical changes to systems that already exist.

### Specialized Rings Beat Stats Locally

A Greater specialized ring should outperform `+2` to its governing stat **for that specific effect**, while the stat ring retains the advantage of affecting multiple systems.

Default specialized progression:

`+1 Lesser / +3 Greater`

### Amulets Change Rules

Standard amulets should generally not be designed as larger numerical rings.

A good amulet causes the player to reconsider how existing systems can be used.

### New Mechanics May Exist Exclusively Through Amulets

Mechanics such as:

* Critical strikes
* Dodge

do not need to exist as baseline player mechanics.

An amulet may introduce the mechanic.

### God-Touched Items May Break the Normal Power Scale

Touched-by-the-Gods Amulets are intentionally extreme.

A `+10` stat increase may completely redirect an existing build.

This is desirable.

If an extremely rare God-Touched item creates an absurd interaction through legitimate system composition, the player should generally be allowed to enjoy the run.

### Simple Effects, Compounding Systems

Jewelry descriptions should remain short.

The depth should come from interactions between:

* Stats
* Skills
* Equipment
* Weapons
* Spells
* Belts
* Consumables
* Actions
* World systems
* Altars
* Wells
* Other persistent character changes

The game should not need to explicitly author every resulting build.

Players should be able to discover combinations that emerge naturally from the systems.
