# Micro Adventure Roguelike — Design Document v0.1

## Status

Early design lock.

This document captures the current game shape only.  
Anything marked **TBD**, **Open**, **Future**, or **Pinned** is not implementation authority.

Primary goal: build a small, system-driven, 2D roguelike/adventure game with procedural replayability.

---

# 1. Core Identity

- 2D grid-based world.
- Hex grid is currently preferred.
- Turn-based combat.
- Free/open roaming outside combat.
- Procedurally generated overworld.
- Procedurally generated POIs.
- Lightweight presentation.
- System interaction matters more than raw content volume.
- No survival-food/water maintenance loop.
- No durability system.

Working title: **TBD**.

---

# 2. World Structure

## 2.1 Overworld

The game world is a generated 2D grid.

Current preference:

- Hex grid.
- Procedural terrain/world generation.
- World contains POIs such as:
  - Towns
  - Caves
  - Forts
  - Graveyards
  - Dungeons
  - Other location types as needed

Movement outside combat is real-time/open-roam style rather than forced turn-by-turn movement.

## 2.2 POI Transition

Stepping into a POI transitions the player into a new local grid map.

Conceptually:

```text
Overworld Grid
    -> POI Entrance
        -> Local POI Grid
```

The local map uses the same fundamental grid/game rules.

This is a scale change, not a separate gameplay system.

---

# 3. Grid

Current preferred grid:

**Hex**

Reasoning:

- Six clean adjacent directions.
- Useful for attack shapes.
- Useful for ranged attacks.
- Useful for melee reach.
- Avoids square-grid diagonal ambiguity.

Final hex orientation and coordinate implementation are **TBD**.

---

# 4. Player Stats

The player has six core stats:

- CON
- STR
- DEX
- INT
- WIS
- WIL

Stats are dynamic and may be modified by:

- Armor
- Weapons
- Rings
- Necklaces
- Potions
- Spells
- Curses
- Other effects

## 4.1 CON — Constitution

Primary role:

- Health regeneration.

CON does **not** define maximum health.

## 4.2 WIL — Willpower

Primary role:

- Maximum health.

WIL belongs conceptually with the magic-side stat triangle even though it governs maximum health.

## 4.3 STR — Strength

Primary role:

- Physical damage.

## 4.4 DEX — Dexterity

Primary roles:

- Additional damage reduction.
- Movement / turn-generation speed.

Base movement generation:

```text
movement_generation = max(DEX + 1, 1)
```

Movement generation must always be at least 1.

## 4.5 INT — Intelligence

Primary role:

- Gates larger / higher-level spells.
- Governs total available magic capacity.

Exact implementation is **TBD**.

## 4.6 WIS — Wisdom

Primary role:

- Magic regeneration.

---

# 5. Character Progression

Core progression:

```text
Experience
    -> Levels
        -> Skill Points
            -> Skill Trees
```

## 5.1 Experience

Experience produces levels.

## 5.2 Levels

Levels produce skill points.

## 5.3 Skill Trees

Skill trees define class identity.

There is no requirement for rigid character classes.

Players may mix and match skill trees.

Example concept:

```text
Sword
Necromancy
Archery
Alchemy
Heavy Armor
etc.
```

A character's effective "class" is whatever combination of trees the player invests in.

Exact trees are **TBD**.

---

# 6. Combat State

## 6.1 Outside Combat

Outside combat:

- Player roams the world freely.
- Movement is not forced into turn-by-turn mode.

## 6.2 Entering Combat

Combat begins when:

1. An enemy sees the player through valid LOS.
2. The player manually presses **TAB** to enter combat mode.

The player may voluntarily enter combat mode before an enemy has detected them.

## 6.3 Line of Sight

LOS is literal line of sight.

Exact LOS algorithm is **TBD**.

---

# 7. Turn Order / Movement Generation

Combat uses a movement-generation clock rather than simple fixed initiative.

Each actor has a movement-generation value.

Base player rule:

```text
movement_generation = max(DEX + 1, 1)
```

At the start of an encounter, determine the highest movement generation among participating actors.

That value becomes the current turn threshold.

Conceptual model:

```text
turn_threshold = highest_actor_movement_generation
```

Actors accumulate movement points.

Conceptually:

```text
movement_meter += movement_generation
```

When an actor reaches the threshold, that actor earns a turn.

Faster actors may earn more turns than slower actors.

Enemy actors may be significantly faster than the player.

## 7.1 Dynamic Recalculation

Movement-related stats are dynamic.

If an actor's speed changes during combat, the encounter movement system must remeasure/recalculate the relevant threshold.

Examples:

- Slow
- Haste
- DEX loss
- DEX gain
- Equipment change
- Spell effect
- Potion effect

The exact rule for preserving/rescaling accumulated movement meter when the threshold changes is **Open / TBD**.

Do not invent this rule without design approval.

---

# 8. Turn Action Economy

A combat turn is action-point based.

Base turn allowance:

- 1 Movement action
- 1 Skill action
- 1 Magic Item / Consumable activation

Conceptually:

```text
TURN
- Move: 1
- Skill: 1
- Activation: 1
```

Exact rules for action ordering, skipping, banking, or gaining additional actions are **TBD**.

---

# 9. Input

## 9.1 Movement

Planned movement inputs:

- Keyboard arrow keys
- Controller analog input
- PC click movement

Exact behavior for click pathing is **TBD**.

## 9.2 Combat Toggle

- TAB manually enters combat-style turn mode.

Exit conditions for manually entered combat mode are **TBD**.

---

# 10. Weapons

Current weapon categories:

- Swords
- Maces
- Spears / Polearms
- Daggers
- Bows
- Throwables

Attack geometry and exact weapon identities are **TBD**.

Hex-based attack patterns are a likely design direction.

Do not assume exact attack shapes yet.

---

# 11. Armor

Armor uses the same general quality structure as weapons.

Exact armor slot layout is **TBD**.

---

# 12. Equipment Quality Structure

Weapons and armor use layered quality.

Each item has:

1. Material Quality Stage
2. +N Enhancement Level
3. Rarity
4. Affixes

## 12.1 Material Stages

Each equipment type has:

- 3 material quality stages.

Exact materials are **TBD**.

## 12.2 Enhancement Levels

Each material stage contains:

- 3 +N levels.

Exact labels and numeric implementation are **TBD**.

## 12.3 Rarity

Items have 1–5 rarity levels.

Each rarity level:

- Allows an additional affix.
- Applies a modifier to item values.

Current rarity value multipliers:

```text
0.85
1.00
1.10
1.30
1.50
```

Exact rarity names are **TBD**.

## 12.4 Affixes

Each rarity step permits another affix to be assigned to the item.

Exact affix pool and generation rules are **TBD**.

---

# 13. Durability

There is no durability system.

This is intentional.

Do not add durability without explicit design change.

---

# 14. Consumables

Consumables are single-use individual items.

No multi-use consumable object is required.

If the player needs more consumables, they obtain more individual consumable items.

Examples may include:

- Potions
- Scrolls
- Throwables
- Other one-use items

Exact consumable list is **TBD**.

---

# 15. Magic Items

Current magic-item categories include:

- Scrolls
- Wands
- Rings
- Necklaces

Traditional roguelike-style curses are intended.

Exact identification rules, spell rules, curse rules, and charge systems are **TBD**.

---

# 16. Inventory

Inventory uses a grid.

Backpack quality determines available inventory space.

Backpack upgrades are found during play.

Conceptually:

```text
Better Backpack
    -> Larger Inventory Grid
```

Exact grid size and item footprint rules are **TBD**.

For Micro scope, do not assume complex multi-cell item shapes unless explicitly added.

---

# 17. Roguelike Meta Progression

Current open question:

Meta knowledge may be the only meaningful progression between runs.

Possible model:

- Player knowledge increases.
- Character power does not permanently increase.

This is not yet locked.

The game may use some limited meta progression if required for the eventual Micro Adventure format.

Status:

**Open / TBD**

---

# 18. Roguelike World Features

Current intended feature family includes traditional roguelike elements such as:

- Curses
- Fountains
- Dungeon POIs
- Scrolls
- Wands
- Rings
- Necklaces
- Potions
- Procedural item variation

Exact mechanics are **TBD**.

---

# 19. World Generation

The world should be procedurally generated with a simple layered data model.

Desired feel:

- Dwarf Fortress-style map generation conceptually.
- Generate broad world fields.
- Tile/render the world from those fields.

Possible world data fields:

```text
Elevation
Moisture
Temperature
Biome
```

These are conceptual, not yet mandatory.

Gameplay world data should be authoritative outside the rendering shader.

A shader may be used to visualize terrain/world data, but the shader should not be the only authoritative source of gameplay-relevant world information.

Exact generation algorithm is **TBD**.

---

# 20. POI Generation

POIs are placed into the generated overworld.

Examples:

- Towns
- Caves
- Forts
- Graveyards
- Dungeons

Entering a POI loads/generates another grid-based map.

Exact POI placement constraints and local-generation algorithms are **TBD**.

---

# 21. Scope Rules

This project is intended to remain small.

Prefer:

- Reusable systems
- Procedural combinations
- Small content pools
- Deterministic/simple rules
- Hardcoded values where useful
- System interaction over content quantity

Avoid unnecessary complexity.

Examples of systems that are currently outside Micro scope:

- Durability
- Food requirements
- Water requirements
- Large survival simulation
- Excessive crafting systems
- Massive handcrafted world content

---

# 22. Pinned Future Ideas

These are explicitly **not part of current Micro scope**.

## Gem Sockets

Potential future equipment system:

- Gem sockets
- Socketable item modifiers

Status:

**PINNED / FUTURE / DO NOT IMPLEMENT NOW**

---

# 23. Current Core Gameplay Loop

```text
Generate World
    ->
Explore Overworld
    ->
Discover POI
    ->
Enter POI
    ->
Explore Local Grid
    ->
Enemy LOS or Manual Combat Toggle
    ->
Turn-Based Combat
    ->
Loot / Experience
    ->
Level
    ->
Skill Point
    ->
Build Character Through Skill Trees + Gear
    ->
Continue Exploring
```

---

# 24. Design Authority Notes for Astra

This document describes the current intended game shape.

When implementing or planning from this document:

1. Do not silently resolve **TBD**, **Open**, **Future**, or **Pinned** items.
2. Do not expand Micro scope merely because a conventional roguelike usually contains a feature.
3. Do not add durability.
4. Do not add food/water survival requirements.
5. Do not convert the skill-tree system into mandatory rigid classes.
6. Do not make combat permanently turn-based outside encounters.
7. Preserve dynamic stat modification.
8. Preserve DEX-driven movement generation and faster-actor extra turns.
9. Preserve the overworld -> POI local-grid structure.
10. Prefer the smallest implementation that proves the system.
11. Treat procedural/system interaction as more important than large content volume.
12. Surface unresolved design questions instead of inventing authority.

---

# 25. Current Open Design Questions

Known unresolved items:

- Final game title.
- Final hex orientation / coordinate representation.
- Exact movement-meter behavior when combat threshold changes.
- Exact action ordering inside a turn.
- Combat-mode exit conditions.
- Exact LOS implementation.
- Exact skill trees.
- Exact spell system.
- INT spell-capacity implementation.
- WIS magic-regeneration implementation.
- Weapon attack geometries.
- Armor slot layout.
- Material names and values.
- Enhancement values.
- Rarity names.
- Affix pools.
- Backpack sizes.
- Inventory item footprints.
- Meta-progression model.
- Curse behavior.
- Wand behavior.
- Scroll behavior.
- Fountain behavior.
- Overworld generation algorithm.
- POI placement algorithm.
- Local POI generation algorithm.

These questions are intentionally unresolved.

---

# End State

This document is the current high-level design authority for the Micro Adventure Roguelike concept.

Version: **0.1**
