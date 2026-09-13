# Micro Rogue — Hostility, Civilization Suppression, and Emergent Trade Routes

## Purpose

Trade routes in Micro Rogue should not be manually placed as decorative world features.

They should **emerge from regional stability**.

Civilized settlements reduce hostility around themselves. Hostile POIs increase hostility. If two civilized POIs can maintain a sufficiently safe corridor between them, a hidden trade route may exist.

The player does not need to see the underlying trade-route simulation directly.

Instead, the player experiences its consequences through:

- merchant inventory quality
- available item tiers
- prosperity
- quest rewards
- caravan activity
- settlement dialogue
- regional safety
- changing world conditions

The desired result is:

> **The simulation changes the world. The world communicates those changes naturally. The player notices and chooses what to do.**

---

## Core Regional Hostility Model

Each Global Hex has a Hostility value.

Conceptually:

```text
base_hostility
+ hostile_POI_pressure
- civilization_suppression
= final_hostility
```

The exact formula is TBD.

The important rule is that Hostility is derived from the actual state of the world rather than assigned as an arbitrary static difficulty rating.

---

## Hostile POI Pressure

Different hostile POIs contribute different amounts of Hostility.

A small threat should not influence the region as strongly as a major military or supernatural presence.

Conceptual examples:

```text
Fungus Spider Nest     +1 Hostility

Goblin Den             +1 or +2 Hostility

Bandit Camp            +2 Hostility

Orc Warband            +3 Hostility

Orc War Camp           +4 Hostility

Necromancer Tower      +5 Hostility

Demonic Fortress       +8 Hostility
```

Exact values are TBD.

The important rule is:

> **Hostile POIs have weighted regional influence.**

An Orc War Camp should matter significantly more than a small monster den.

Multiple hostile POIs may stack their influence.

Example:

```text
Base Hostility:       2

Goblin Den:          +1

Orc War Camp:        +4

Final Before
Civilization:         7
```

---

## Civilization Suppression

Civilized POIs suppress Hostility in the region around them.

The strength and range of this effect depends on settlement type.

Current conceptual ranges:

```text
Village
Suppression Range: 0 Global Hexes

Town
Suppression Range: 1 Global Hex

City
Suppression Range: 2 Global Hexes

Castle
Suppression Range: 3 Global Hexes
```

A Village only affects the Global Hex in which it exists.

Larger settlements project stability into nearby territory.

---

## Suppression Decay

Civilization suppression decreases by **1 point per Global Hex of distance** from the civilized POI.

Conceptual example:

```text
Castle

Center Hex:
-4 Hostility

Distance 1:
-3 Hostility

Distance 2:
-2 Hostility

Distance 3:
-1 Hostility

Distance 4:
No effect
```

Town example:

```text
Town

Center Hex:
-2 Hostility

Distance 1:
-1 Hostility

Distance 2:
No effect
```

City example:

```text
City

Center Hex:
-3 Hostility

Distance 1:
-2 Hostility

Distance 2:
-1 Hostility
```

This gives larger settlements both greater local control and greater regional influence without requiring a complicated formula.

Exact starting suppression values may later change.

The current behavioral rule is:

> **Civilization projects a suppression field that decays by 1 Hostility per Global Hex of distance.**

---

## Overlapping Civilization

Suppression fields may overlap.

Example:

```text
Town A influence
+
City B influence
+
Castle C influence
```

A Global Hex located inside multiple civilized influence fields may receive suppression from more than one source.

Exact stacking rules are TBD.

Possible future approaches include:

```text
Full stacking

Strongest source only

Strongest source + partial secondary influence

Capped stacking
```

Do not lock this behavior until needed.

---

## Final Global Hex Hostility

Conceptually:

```text
Global Hex Hostility
=
Base Regional Hostility
+
Hostile POI Contributions
-
Civilization Suppression
```

Example:

```text
Base Hostility:           2

Orc War Camp:            +4

Nearby Town Suppression: -1

Nearby Castle:           -2

Final Hostility:          3
```

This value becomes an important regional input for future systems.

Possible consumers include:

```text
Trade routes

Prosperity

Quest generation

Merchant quality

Caravan survival

Enemy presence

Settlement growth

Regional danger

Faction expansion

World events
```

---

## Trade Routes

Trade routes are not manually placed.

They emerge when two civilized POIs can maintain a sufficiently safe path between them.

Possible civilized endpoints:

```text
Village

Town

City

Castle

Capital
```

Not every pair of civilized POIs should automatically trade.

The world must support the route.

---

## Trade Distance Limiter

Civilized POIs should only be considered as potential trade partners when they are within a maximum Global Hex distance.

This check happens **before route generation or hostility evaluation**.

Conceptually:

```text
distance = hex_distance(civilization_A, civilization_B)

if distance > MAX_TRADE_DISTANCE:
    reject_pair
```

This acts as both:

- a simulation rule
- a performance guard

The trade system should not search every possible inbound and outbound route between every civilized POI in the world.

Trade is intended to represent relatively local exchange between nearby settlements.

The intended fiction is closer to:

> A traveler spends several days reaching another settlement, discovers what they produce, returns home, and establishes a small relationship between the two communities.

It is **not** intended to represent modern globalized trade networks.

Therefore:

```text
Civilization A
    ↓
Check Hex Distance
    ↓
Too Far?
    YES → Reject immediately
    NO  → Evaluate possible route
```

Only settlements inside `MAX_TRADE_DISTANCE` are eligible for route evaluation.

The exact value of `MAX_TRADE_DISTANCE` is TBD.

---

## Trade Route Candidate

Conceptual process:

```text
Civilized POI A
        ↓
Find another eligible Civilized POI B
        ↓
Check MAX_TRADE_DISTANCE
        ↓
Reject immediately if too far
        ↓
Determine direct shortest path
        ↓
Allow limited detour
        ↓
Measure Hostility along candidate paths
        ↓
If route is safe enough:
    Trade Route exists
```

---

## Route Pathing

Trade routes should not require the absolute shortest route.

A route may take a slightly longer path to avoid danger.

Current concept:

```text
Maximum route length
=
Shortest possible path
+
1 or 2 Global Hexes
```

Exact allowance is TBD.

This allows sensible behavior such as merchants traveling around an Orc War Camp instead of walking directly through it merely because that route is mathematically shortest.

Example:

```text
City A
    |
    |
Orc War Camp
    |
    |
City B
```

Direct route may fail because Hostility is too high.

A nearby alternative:

```text
City A
   \
    Safe Hex
        \
         Safe Hex
             \
              City B
```

may be one Global Hex longer and still support trade.

---

## Trade Route Safety

A candidate route is viable only if its Hostility satisfies a trade threshold.

Possible methods are TBD.

Examples could include:

```text
Every Hex must be below N Hostility
```

or:

```text
Average route Hostility must be below N
AND
no individual Hex may exceed danger threshold M
```

The exact calculation is not currently authoritative.

The authoritative behavioral rule is:

> **A trade route can exist only while a sufficiently safe corridor exists between its civilized endpoints.**

---

## Trade Routes Are Dynamic

Trade routes may appear or disappear as the world changes.

Example:

```text
Town A
    ↓
Safe Corridor
    ↓
City B

Trade Route Active
```

Later:

```text
Orc War Camp appears

        ↓

Regional Hostility rises

        ↓

Safe corridor fails

        ↓

Trade Route becomes inactive
```

This should have downstream consequences.

---

## Trade and Prosperity

Active trade routes may increase settlement Prosperity.

Conceptually:

```text
Active Trade Route
        ↓
Prosperity Bonus
```

Broken routes may reduce Prosperity.

```text
Trade Route Lost
        ↓
Reduced Prosperity
        ↓
Reduced economic quality
```

Exact values are TBD.

---

## Trade and Merchant Quality

Prosperity may influence the quality of merchant inventories.

This should create indirect evidence of world-state changes.

Example:

Before route disruption:

```text
Merchant inventory:

Greater Health Potions

+3 Tier Weapons

Higher quality armor

Rare supplies
```

After route disruption:

```text
Merchant inventory:

Basic Health Potions

+2 Tier Weapons

Lower average item quality

Reduced stock
```

The player should not receive a system message such as:

```text
ORC WARBAND SPAWNED

TRADE ROUTE DISABLED

PROSPERITY -8

MERCHANT QUALITY +3 → +2
```

That information exists for the simulation.

It is not necessarily player-facing.

---

## Communicating World State Through Fiction

NPC dialogue should expose symptoms of simulation changes without explaining the underlying math.

Example merchant dialogue:

> "Nothing's come through from Redhaven in weeks."

That statement may be generated because the trade route to Redhaven has become inactive.

The merchant does not need to say why.

The player may notice other evidence:

```text
Where are the Greater Health Potions?

Why is this sword trash quality?

This merchant hasn't sold garbage like this since I cleared that spider nest.

Didn't he just mention Redhaven?

I haven't been there in a few days.
```

The game has now provided a lead without explicitly creating a quest marker.

---

## Emergent Adventure Example

World state:

```text
Town A

Trade Route:
Town A → Redhaven

Merchant Quality:
High

Regional Hostility:
Low
```

A new Orc Warband establishes itself along the corridor.

Simulation:

```text
Orc Warband appears
        ↓
Hostility rises
        ↓
Trade corridor becomes unsafe
        ↓
Trade Route deactivates
        ↓
Town Prosperity falls
        ↓
Merchant inventory quality falls
```

Player experience:

```text
Player visits merchant.

Greater Health Potions are missing.

Weapon quality is worse than usual.

Merchant says:

"Nothing's come through from Redhaven in weeks."
```

The player thinks:

```text
Wait.

Something changed.

Maybe I should head toward Redhaven.
```

Player travels toward Redhaven.

They discover:

```text
Orc Warband
```

Then:

```text
Shit happens.exe
```

That is intended Micro Rogue gameplay.

No explicit quest was required.

The simulation created a condition.

The condition created visible consequences.

Those consequences created player curiosity.

Player curiosity created an adventure.

---

## Quest Integration

The same world state may also generate explicit quests.

For example:

```text
Trade Route Broken
        ↓
Town recognizes trade disruption
        ↓
Existing Orc Warband is identified as possible cause
        ↓
Quest becomes available
```

Example:

> "The caravans from Redhaven have stopped coming. Scouts haven't returned either."

Possible quest:

```text
Investigate the Redhaven Road
```

The quest still obeys the existing Micro Rogue rule:

> **Generate causes before generating quests about those causes.**

The Orc Warband already exists.

The quest merely points toward the world state.

---

## Hidden Simulation, Visible Consequences

The player should not need access to every simulation value.

Values such as:

```text
Hostility

Suppression

Trade Route viability

Prosperity modifiers

Merchant quality modifiers
```

may remain hidden.

The player instead observes:

```text
Better or worse goods

More or fewer caravans

NPC dialogue

Quest availability

Settlement condition

Enemy activity

Road danger

Regional changes
```

This supports discovery through observation.

---

## System Relationship

The current relationship is:

```text
Civilized POIs
        ↓
Civilization Suppression
        ↓
Global Hex Hostility
        ↑
Hostile POIs
        ↓
Trade Route Viability
        ↓
Prosperity
        ↓
Merchant Quality
Quest Rewards
Settlement Health
        ↓
Player Observation
        ↓
Player Decisions
        ↓
Adventure
```

The strength of the system comes from each individual component remaining relatively simple.

---

## Current Authoritative Decisions

```text
Every Global Hex may have a Hostility value.

Hostile POIs add weighted Hostility.

Different hostile POIs may contribute different amounts.

Civilized POIs suppress Hostility.

Village suppression range = 0.

Town suppression range = 1.

City suppression range = 2.

Castle suppression range = 3.

Civilization suppression decays by 1 per Global Hex of distance.

Trade routes are hidden simulation relationships.

Trade routes connect civilized POIs.

Trade routes have a hard maximum Global Hex distance.

Civilized POI pairs outside MAX_TRADE_DISTANCE are rejected before pathfinding.

Trade routes require sufficiently low Hostility along a viable path.

Trade routes may use a small detour rather than absolute shortest path.

Current conceptual detour allowance:
Shortest Path +1 or +2 Global Hexes.

Trade routes may appear or disappear as regional Hostility changes.

Trade routes may affect Prosperity.

Prosperity may affect merchant inventory quality.

The player should usually discover simulation changes through world consequences rather than exposed numeric values.

World changes should be capable of producing adventures without requiring explicit quests.
```

---

## Explicitly TBD

```text
Base Hostility values

Exact Hostility contribution per hostile POI

Exact civilization suppression strength

Overlapping suppression behavior

Whether Hostility can fall below zero

MAX_TRADE_DISTANCE

Trade Route safety formula

Trade Route detour allowance: +1 or +2

How many simultaneous trade routes a settlement may maintain

Prosperity bonus per active route

Prosperity loss from broken routes

Merchant quality formula

Caravan simulation

Road interaction

Trade route visualization, if any

Quest generation from trade disruption

Settlement growth and decline
```

---

## Design Intent

The goal is not to create a complicated economy simulator.

The goal is to build several simple systems whose relationships naturally produce situations worth investigating.

A player should be capable of noticing:

> "This town feels worse than the last time I was here."

and discovering that there is an actual world-state reason for it.

The desired loop is:

```text
World changes
    ↓
Simulation reacts
    ↓
Settlement changes
    ↓
Player notices
    ↓
Player investigates
    ↓
Adventure happens
```

That emergent chain is a core target for Micro Rogue.
