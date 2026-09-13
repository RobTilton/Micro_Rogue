# Micro Rogue — Addendum to Hostility, Civilization Suppression, and Emergent Trade Routes

## Purpose

This document is an addendum to:

**Micro Rogue — Hostility, Civilization Suppression, and Emergent Trade Routes**

It extends the existing Hostility model by defining:

1. Biome Base Hostility
2. Threat-Tier Hostility Projection
3. Shared decay behavior between hostile pressure and civilization suppression
4. How projected Hostility can feed future quest generation

The underlying trade-route, prosperity, and civilization-suppression systems remain unchanged unless explicitly stated here.

---

## Final Global Hex Hostility

The current high-level Hostility equation becomes:

```text
Final Global Hex Hostility
=
Biome Base Hostility
+ Hostile POI / Threat Projection
- Civilization Suppression
```

Each part should remain simple and independently understandable.

---

## Biome Base Hostility

Each biome contributes a baseline Hostility value to the Global Hex.

Current authoritative values:

```text
Plains      0
Hills       1
Mountains   2
Seas        1
Swamps      2
Wastelands  4
Desert      3
Forest      2
Marsh       2
Lakes       1
```

These values represent the inherent danger or difficulty of existing in that biome before local hostile POIs or civilization influence are considered.

Example:

```text
Plains
Base Hostility = 0
```

A peaceful Plains hex with no hostile influence may remain at Hostility 0.

Example:

```text
Wasteland
Base Hostility = 4
```

A Wasteland begins dangerous before any hostile POI is added.

---

## Why Biome Hostility Exists

Biome Hostility gives the world an immediate, simple danger baseline.

The system does not need a complicated environmental danger simulator.

A biome already communicates broad expectations.

Examples:

```text
Plains
Generally safe

Forest
Moderate natural danger

Mountains
Moderate environmental and creature danger

Desert
High baseline danger

Wasteland
Very high baseline danger
```

This baseline can then be modified by the actual world state.

---

## Threat Tiers

Hostile POIs and major hostile entities should have a Threat Tier.

Current conceptual range:

```text
Threat Tier 0
through
Threat Tier 5
```

Conceptual meaning:

```text
Tier 0
Very low-tier fantasy threats

Examples:
Goblins
Slimes
Other minor hostile creatures
```

through:

```text
Tier 5
Major regional threat

Example:
Dragon
```

Exact monster-family assignments are TBD.

Threat Tier should be usable by future Monster Family systems when deciding:

```text
what may spawn

where it may spawn

how dangerous a region should feel

what Hostility pressure a hostile POI projects
```

---

## Hostile Influence Projection

Hostile POIs do not only affect the Global Hex they occupy.

Major hostile POIs may project Hostility into surrounding Global Hexes.

The projection uses the same simple decay language as Civilization Suppression:

> **Influence decays by 1 point per Global Hex ring of distance.**

Example:

```text
Threat Tier 5 source

Source Hex:
+5 Hostility

Distance 1:
+4 Hostility

Distance 2:
+3 Hostility

Distance 3:
+2 Hostility

Distance 4:
+1 Hostility

Distance 5:
No further effect
```

This means a powerful threat can affect an entire region rather than only its own tile.

---

## Symmetry With Civilization Suppression

Civilization and hostile POIs use the same spatial logic.

Civilization says:

```text
I make nearby Global Hexes safer.
```

Hostile POIs say:

```text
I make nearby Global Hexes more dangerous.
```

Conceptually:

```text
Civilization Pressure
        vs
Hostile Pressure
```

Both can use:

```text
Source strength
↓
Distance from source
↓
Decay by 1 per Global Hex ring
```

This keeps the system easy to reason about.

---

## Threat Tier and Influence Range

For the initial system, Threat Tier and Influence Range may default to the same value.

Example:

```text
Dragon

threat_tier = 5

influence_range = 5
```

However, these should remain separate properties in the data model.

Conceptually:

```text
threat_tier
influence_range
```

This allows future content to behave differently without changing the underlying system.

Example:

```text
Plague Nest

threat_tier = 2

influence_range = 5
```

This would represent a threat that is not individually powerful but spreads its influence across a large area.

Another possible example:

```text
Ancient Golem

threat_tier = 5

influence_range = 1
```

This would represent an extremely dangerous but geographically localized threat.

These are examples only.

The current rule is:

> **Threat Tier and Influence Range may initially match, but they should not be hard-coupled architecturally.**

---

## Hostile POIs as Regional Actors

A hostile POI should be capable of influencing the world around it.

Example:

```text
Dragon Lair
Threat Tier: 5
Influence Range: 5
```

This may produce:

```text
Dragon Lair Hex
+5 Hostility

Nearby Ring 1
+4 Hostility

Nearby Ring 2
+3 Hostility

Nearby Ring 3
+2 Hostility

Nearby Ring 4
+1 Hostility
```

A major hostile POI therefore becomes a regional problem.

This allows threats to matter before the player physically enters their exact Local Map.

---

## Interaction With Civilization

Civilization suppression and hostile pressure may oppose one another.

Example:

```text
Forest Base Hostility:        2

Dragon Influence:            +3

Nearby Town Suppression:     -1

Nearby Castle Suppression:   -2
```

Result:

```text
Final Hostility
=
2 + 3 - 1 - 2

Final Hostility = 2
```

The exact stacking behavior of multiple Civilization Suppression sources remains TBD as defined in the parent system document.

The important point is that both positive and negative regional pressure can feed the same Hostility value.

---

## Hostility and Monster Families

Hostility should become an input to the future Monster Family system.

Hostility does not need to decide the exact monster by itself.

Instead, the likely shape is:

```text
Biome
+
Hostility
+
Monster Family eligibility
+
POI type
+
World state
=
Possible monster population
```

Example:

```text
Forest
Hostility 1
```

may support low-level creatures such as:

```text
Slimes
Goblins
Wolves
```

while:

```text
Forest
Hostility 4
```

may support much more dangerous content.

The exact Monster Family rules are not yet defined.

Do not prematurely implement assumptions beyond Hostility being an available input.

---

## Settlement Quest Pressure

Settlements may inspect elevated Hostility and the sources contributing to it.

This provides a natural basis for quest generation.

Example:

```text
Village
Current Hostility: High

Contributing sources:

Biome Base
+
Dragon Influence
+
Goblin Den
-
Village Suppression
```

The settlement can identify that a nearby Dragon is a major contributor.

This may make a quest against that Dragon valid.

Conceptually:

```text
Threat exists
        ↓
Threat projects Hostility
        ↓
Settlement receives elevated Hostility
        ↓
Settlement identifies contributing source
        ↓
Quest becomes valid
```

This preserves the existing Micro Rogue design rule:

> **Generate causes before generating quests about those causes.**

The threat exists first.

The quest is a response to the world state.

---

## Example — Village Under Regional Pressure

World state:

```text
Biome:
Forest

Biome Hostility:
2

Nearby Dragon:
+3 projected Hostility

Goblin Den:
+1 Hostility

Village Suppression:
-1 Hostility
```

Final:

```text
2 + 3 + 1 - 1 = 5 Hostility
```

The village now exists in a highly dangerous region.

Possible outcomes:

```text
More dangerous monster population

Reduced prosperity

Trade-route disruption

More urgent quests

Merchant degradation

Regional instability
```

The village may generate a quest targeting one of the actual hostile sources.

Example:

```text
"Please make the enormous winged problem stop."
```

The exact quest language and generation system remain TBD.

---

## Design Principle

The system should remain simple.

The goal is not to simulate every possible ecological, military, or economic relationship directly.

The goal is to let a small number of understandable values interact reliably.

Current core relationship:

```text
Biome Base Hostility
        +
Hostile Threat Projection
        -
Civilization Suppression
        =
Final Global Hex Hostility
```

That value can then be consumed by other systems.

---

## Current Authoritative Decisions

```text
Every biome has a Base Hostility value.

Current biome values:

Plains      0
Hills       1
Mountains   2
Seas        1
Swamps      2
Wastelands  4
Desert      3
Forest      2
Marsh       2
Lakes       1

Hostile POIs and major hostile entities may have Threat Tiers.

Current conceptual Threat Tier range:
0 through 5.

Major hostile sources may project Hostility into surrounding Global Hexes.

Hostile influence decays by 1 per Global Hex ring of distance.

Hostile influence uses the same decay concept as Civilization Suppression.

Threat Tier and Influence Range may initially default to the same value.

Threat Tier and Influence Range should remain separate data properties.

Hostility may be used as an input by the future Monster Family system.

Settlements may use elevated Hostility and its contributing sources to determine valid quests.

Quests should respond to existing threats rather than create those threats solely because the quest exists.
```

---

## Explicitly TBD

```text
Exact Threat Tier assignments for monster families

Exact hostile POI Threat Tier assignments

Whether all hostile POIs project regional influence

Exact default relationship between Threat Tier and Influence Range

Whether projected Hostility can stack without limit

Hostility minimum and maximum values

How Hostility affects spawn density

How Hostility affects monster tier selection

Monster Family rules

Exact quest thresholds based on Hostility

How settlements choose which hostile source to target first

How Hostility interacts with future world events

How Hostility affects prosperity numerically
```

---

## Relationship to Parent Document

This addendum extends the Hostility portion of:

**Micro Rogue — Hostility, Civilization Suppression, and Emergent Trade Routes**

The parent document continues to define:

```text
Civilization Suppression

Suppression decay

Trade-route eligibility

Trade distance limits

Route pathing

Prosperity interaction

Merchant consequences

Hidden simulation

Emergent adventure
```

This addendum defines additional Hostility inputs and hostile regional projection.

Together, the current high-level model is:

```text
Biome
    ↓
Base Hostility

Hostile POIs
    ↓
Threat Projection

Civilized POIs
    ↓
Suppression

All three
    ↓
Final Global Hex Hostility
    ↓
Trade
Prosperity
Monster Families
Quest Pressure
Regional Danger
    ↓
Player-visible consequences
```

The intended result remains:

> **Simple systems, clear ownership, and complex gameplay emerging from their relationships.**
