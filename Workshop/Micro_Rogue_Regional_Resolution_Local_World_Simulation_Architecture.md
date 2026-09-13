# Micro Rogue — Regional Resolution & Local World Simulation Architecture

## Purpose

Micro Rogue does not treat each Global Hex as an isolated random map.

Instead, each Global Hex participates in a layered world simulation:

1. The Global Map defines the full world topology.
2. Nearby Global Hexes are progressively resolved into meaningful regional state.
3. A playable Local Map is generated only when the player enters that Global Hex.
4. Important Local Map results are reported back upward into the Global Hex.
5. Future neighboring regions can use that resolved information during generation.

The result is a world where nearby regions influence future generation and where the world can develop coherent settlements, threats, trade, quests, and factions without generating every Local Map at New Game.

---

## Core Principle

> **The Global Map exists first. Regional state is resolved around the player. Playable Local Maps are generated only on entry.**

The world therefore has multiple levels of existence.

```text
GLOBAL TOPOLOGY
Entire world exists geometrically
        ↓
REGIONAL RESOLUTION
Nearby Global Hexes gain meaningful world-state data
        ↓
LOCAL MAP GENERATION
The entered Global Hex receives its playable 721-cell map
        ↓
LOCAL RESULTS
Important generated facts are reported back upward
        ↓
GLOBAL STATE
Future regions may use those facts
```

---

## Global Hex States

A Global Hex should conceptually support at least three states.

```text
1. EXISTS

2. REGIONALLY RESOLVED

3. LOCAL MAP GENERATED
```

### State 1 — Exists

The Global Hex exists as part of the already-generated Global Map.

It has basic geographic information such as:

```text
global_coordinate
biome
land / water state
large-scale terrain properties
seed
neighbor relationships
```

Its detailed regional simulation state may not yet exist.

### State 2 — Regionally Resolved

The Global Hex has been given enough world-state information to participate in future generation.

Possible resolved information:

```text
kingdom / faction ownership
distance from capital
civilization pressure
settlement presence
settlement type
prosperity
hostile POI count
regional threats
roads
trade connections
river information
world-event state
regional danger
regional tags
```

A Regionally Resolved hex does not necessarily have its full playable Local Map yet.

### State 3 — Local Map Generated

The player has entered the Global Hex.

Its complete playable Local Map has now been generated and saved.

That Local Map becomes persistent for that Global Hex.

---

## Local Map Physical Contract

Each Global Hex corresponds to exactly one Local Map.

```text
GlobalHex[q,r]
    ↓
LocalMap[q,r]
```

The Local Map is a hexagonal grid.

Current authoritative size:

```text
hex.radius = 15
```

This produces:

```text
Point-to-point diameter: 31 local hexes

15
+
1 center hex
+
15
=
31
```

Total cells:

```text
1 + 3r(r + 1)

r = 15

1 + 3(15)(16)
= 721 local hexes
```

Therefore:

```text
LOCAL MAP

Shape:
Perfect Hexagon

Radius:
15

Point-to-point diameter:
31 cells

Total cells:
721

Generated:
Upon first entry into parent Global Hex

Persistence:
Saved to parent Global Hex address
```

This size is provisional and may be changed later if gameplay proves that a larger or smaller region is preferable.

---

## Why Local Maps Are Large Regions

A Local Map should feel like an actual region rather than a small encounter board.

721 cells provides enough space for meaningful separation between:

```text
towns
villages
monster dens
ruins
forts
caves
shrines
roads
wilderness
dungeons
resource locations
```

The goal is to avoid situations where world logic becomes unbelievable because everything is positioned within a few steps of everything else.

Example problem:

```text
Town
↓
6 hexes away
↓
Goblin Fortress
```

This immediately raises questions such as:

> Why has the town militia never dealt with this?

Larger regional maps allow threats to exist beyond easy local control.

---

## Parent-to-Child Information Flow

The Global Hex should provide meaningful constraints to the Local Map generator.

Possible Global → Local data:

```text
Biome

Kingdom / territory

Distance from capital

Civilization pressure

Settlement expectations

Road presence

River presence

Neighboring regional state

World age

Global event state

Regional danger baseline

Prosperity baseline

Faction influence

Terrain tags
```

The Local Map generator then resolves those abstract facts into physical content.

Example:

```text
GLOBAL HEX

Biome:
Forest

Kingdom:
Kingdom of X

Distance from Capital:
12 Global Hexes

Civilization Pressure:
Medium

Prosperity Baseline:
42

Road:
Present

Threat Level:
Moderate
```

May resolve into:

```text
LOCAL MAP

Small Town

Main Road

Goblin Den

Ruined Watchtower

Forest Wilderness

Merchant Caravan Route
```

---

## Child-to-Parent Information Flow

Generation is not one-directional.

Once the Local Map has been generated, important facts should be reported back to the Global Hex.

Example:

```text
LOCAL MAP GENERATED

Town exists

Goblin Den exists

Ruined Fort exists

2 hostile POIs

Main road crosses region

Merchant route established

Town prosperity = 43
```

The parent Global Hex can then store:

```text
settlement = small_town

hostile_poi_count = 2

regional_threat = moderate

prosperity = 43

trade_route = true

road_connection = true
```

This information becomes available to neighboring regional generation.

---

## Neighbor-Aware Regional Generation

Future Global Hexes should not generate completely independently.

Already resolved neighbors may provide context.

Example:

```text
HEX A

Small Town

Moderate Prosperity

Road exits east

Goblin Activity

Kingdom X
```

When neighboring Hex B is regionally resolved, it can know:

```text
A civilized town exists immediately west.

A road enters from the west.

Goblin activity exists nearby.

The region belongs to Kingdom X.
```

That information can influence what Hex B becomes.

This creates regional continuity without requiring the entire world to be fully simulated at New Game.

---

## Player Starting State

The player begins inside a generated Local Map.

Starting hierarchy:

```text
World
└── Global Map
    └── Starting Global Hex
        └── Local Map
            └── Small Town
                └── Player
```

The player begins as a new adventurer.

Current conceptual starting resources:

```text
Starting Gold:
100

Starting Equipment:
None or minimal

Player must purchase initial equipment.
```

This allows the player to make an immediate build decision.

Example:

```text
Cheap Sword + Armor

Bow + Arrows

Staff + Supplies

Heavy Weapon

Mixed Gear
```

No balance requirement is currently attached to the starting economy.

The immediate goal is simply to make the starting town useful and establish the player's first relationship with the world.

---

## Survival Resource Philosophy

Micro Rogue does not currently require hunger or thirst simulation.

Avoid unnecessary food/water micromanagement.

Possible abstraction:

```text
Rations = Number of available rests
```

A Rest may function as:

```text
Healing

Recovery

Possible ability reset

Possible world-time progression
```

This makes supplies matter without requiring constant food and water maintenance.

---

## Settlements

Settlements are important regional actors.

Possible settlement types:

```text
Hamlet

Village

Town

City

Capital

Fortified Settlement

Castle Settlement
```

A settlement should expose regional information.

Example:

```text
Settlement
{
    type
    kingdom
    prosperity
    reputation
    danger
    quest_pool
    merchant_quality
    local_threats
}
```

---

## Capital Relationship

A town may know:

```text
I belong to Kingdom X.

I am N Global Hexes away from the capital.
```

The capital does not need to be fully designed yet.

The value can exist before all capital mechanics are implemented.

Possible future uses:

```text
prosperity influence

merchant quality

road density

military presence

quest tier

reputation importance

trade route probability

political events
```

---

## Prosperity

Settlements may have a Prosperity value.

Prosperity represents the local economic and social health of the region.

Conceptually:

```text
prosperity = X
```

Possible influences:

```text
Hostile POIs nearby        ↓

Trade routes               ↑

Player clears threats      ↑

Local quests completed     ↑

Major world events         ↑ / ↓

Destroyed infrastructure   ↓

Nearby successful towns    ↑

Regional isolation         ↓
```

The exact formula is TBD.

---

## Prosperity Gameplay Effects

Prosperity may influence:

```text
Quest reward ceiling

Merchant inventory quality

Available equipment tier

Available services

Settlement appearance

Number of merchants

Future settlement growth

Special NPC availability
```

Example:

```text
Low Prosperity Town

Quest Rewards:
10–40 gold

Merchant Gear:
Basic

Rare Items:
Almost none
```

Versus:

```text
High Prosperity Town

Quest Rewards:
100–300 gold

Merchant Gear:
Advanced

Rare Items:
Possible
```

Exact values are TBD.

---

## Hostile POIs

Hostile POIs should exist as part of world generation before quests reference them.

Examples:

```text
Goblin Den

Bandit Camp

Necromancer Tower

Orc Fort

Monster Nest

Demonic Shrine

Ancient Crypt

Dragon Lair
```

These POIs affect regional state.

Possible effects:

```text
prosperity decrease

regional danger increase

quest generation

trade disruption

settlement fear

road danger

faction influence
```

---

## Quest Philosophy

Micro Rogue quests should primarily describe existing world state.

> **The world exists first. Quests interpret it.**

The quest should not normally create a threat merely because the player accepted a mission.

Example:

```text
Goblin Den already exists.

Goblin Champion already exists.

Regional threat data already knows goblins operate nearby.
```

A town can then generate a quest using that world state.

Example:

```text
"I was ambushed by goblins.

My wagon was destroyed and my guards were slain holding back a massive goblin.

Please help me avenge them."
```

Possible response:

```text
<Accept Quest>

Reward:
50 Gold
Kingdom Reputation +2
```

or:

```text
<Ignore Quest>
```

The quest points the player toward an already-existing POI.

---

## Adventurer Quest Identity

The player is an adventurer.

Quest design should emphasize adventuring rather than mundane task simulation.

Preferred quest categories:

```text
Slay monster

Clear dungeon

Destroy hostile camp

Investigate ruin

Recover dangerous artifact

Protect settlement

Hunt named enemy

Explore unknown location

Defend against attack

Stop ritual

Kill dragon
```

Avoid making the primary fantasy:

```text
Fetch 6 cabbages.

Deliver shoes.

Carry mail.

Find lost spoon.
```

The player should generally be solving dangerous regional problems.

---

## Reputation

The player may gain reputation with a kingdom, settlement, faction, or region.

Example:

```text
Kingdom Reputation +2
```

Possible future uses:

```text
Access to better quests

Lower merchant prices

Higher quest rewards

Special equipment

Restricted locations

Faction support

Military assistance

Political access

Unique NPC relationships
```

Exact reputation systems are TBD.

---

## Starting Regional Bubble

The player's starting Local Map should not exist in isolation.

When the world begins, the game should regionally resolve a bubble around the starting Global Hex.

Current concept:

```text
Starting Hex

+

2 Global Hexes outward in every direction
```

For a hex grid, radius 2 contains:

```text
1 + 6 + 12 = 19 Global Hexes
```

Therefore:

```text
Initial Regionally Resolved Area:
19 Global Hexes
```

Only the starting Global Hex necessarily needs its complete Local Map generated immediately.

The surrounding 18 Global Hexes can initially exist only as Regionally Resolved state.

---

## Generation Frontier

As the player explores, the resolved region should expand ahead of them.

Concept:

> When the player comes within 1 Global Hex of the unresolved frontier, resolve the next required Global Hexes.

Example:

```text
RESOLVED RESOLVED RESOLVED

RESOLVED PLAYER   RESOLVED

RESOLVED RESOLVED RESOLVED

        ↓

Player approaches edge.

        ↓

New outer Global Hexes become Regionally Resolved.
```

The goal is for neighboring regional information to exist before the player physically enters that region.

---

## Why Resolve Ahead of the Player

If a Global Hex is only resolved at the instant of entry, it has little context.

By resolving a small frontier ahead of the player:

```text
Neighbor data exists.

Nearby settlements exist conceptually.

Road connections can be known.

Threat relationships can exist.

Kingdom boundaries can continue.

Trade relationships can be established.

Biome transitions can be informed.
```

Then entering the Global Hex only requires generating the actual 721-cell Local Map from already-established regional facts.

---

## Regional Generation Flow

Conceptual flow:

```text
NEW GAME
    ↓
Generate Global Map topology
    ↓
Select Starting Global Hex
    ↓
Resolve radius-2 Global region
    ↓
Generate Starting Local Map
    ↓
Generate Starting Town
    ↓
Spawn Player
    ↓
Player explores
    ↓
Player approaches resolved frontier
    ↓
Resolve additional neighboring Global Hexes
    ↓
Player enters Global Hex
    ↓
Generate Local Map if not already generated
    ↓
Report important generated Local facts back to Global Hex
    ↓
Future regions use updated world state
```

---

## World Simulation Feedback Loop

The architecture creates a feedback loop.

```text
GLOBAL STATE
    ↓
LOCAL GENERATION
    ↓
LOCAL WORLD RESULTS
    ↓
GLOBAL STATE UPDATED
    ↓
FUTURE REGIONAL GENERATION
```

Example:

```text
Global Hex A

Small Town

Prosperity 45

Goblin Threat

Road East
```

Player clears Goblin Den.

Local result:

```text
Goblin Den destroyed
```

Global state becomes:

```text
Hostile POIs:
2 → 1

Regional Danger:
Moderate → Low

Prosperity:
45 → 50
```

Future neighboring regions may then generate using the new state.

---

## Separation of Responsibilities

### Global Map

Owns:

```text
World topology

Global coordinates

Biome

Regional ownership

Resolved regional metadata

Neighbor relationships

World events

High-level settlement/threat information
```

### Local Map

Owns:

```text
721-cell playable terrain

Exact POI positions

Road placement

Exact settlement layout

Monster populations

Local encounters

Exact terrain realization

Persistent local state
```

### POIs

Own:

```text
Specific locations

Generation rules

Occupants

Threats

Loot

Entrances

Child maps / floors
```

### Quest System

Owns:

```text
Interpreting world state

Finding valid existing targets

Generating narrative framing

Assigning rewards

Tracking completion

Applying reputation/economic consequences
```

The Quest System should not own basic world generation.

---

## Important Design Rule

> **Generate causes before generating quests about those causes.**

Example:

Wrong:

```text
Quest generated
    ↓
Create goblins
    ↓
Create goblin camp
```

Preferred:

```text
Goblin Camp exists
    ↓
Regional simulation recognizes threat
    ↓
Quest system creates adventure pointing toward it
```

---

## Current Authoritative Decisions

```text
Global topology exists before play.

Local Maps correspond 1:1 with Global Hexes.

Local Map radius = 15.

Local Map diameter = 31 cells.

Local Map total = 721 cells.

Local Maps generate on first entry.

Generated Local Maps persist.

Regional state may exist before Local Map generation.

Starting region resolves radius 2 around player.

Radius-2 Global bubble = 19 Global Hexes.

Local generation reports important facts back to Global state.

Future regional generation may use neighboring resolved state.

Starting player begins in a small town.

Starting player receives 100 gold.

Player purchases starting equipment.

Hunger/thirst micromanagement is not currently desired.

Rations may represent available rests.

Quests should primarily point toward already-existing world threats.

Prosperity influences regional economy and rewards.

Kingdom reputation may later affect access, prices, quests, and rewards.
```

---

## Explicitly TBD

Do not prematurely implement assumptions for these systems.

```text
Capital placement

Trade route mechanics

Prosperity formula

Exact settlement frequencies

Exact POI counts

Exact POI weights

Quest generation implementation

Kingdom generation

Reputation thresholds

Merchant pricing formulas

Ration mechanics

Rest mechanics

Regional danger formula

Faction ownership logic

Road generation

World event influence
```

These concepts may inform architecture but are not yet implementation contracts.

---

## User Had A Thought — Neighbor Bleed

Future possibility:

> Already-generated neighboring Local Maps or neighboring regional properties may influence shared Local Map edges to create terrain bleed and stronger visual continuity.

Example possibilities:

```text
Forest density crossing borders

Swamp expansion

Mountain continuation

Settlement outskirts

Corruption spread

Burned terrain

Road width continuity

Regional vegetation bleed
```

This is currently an idea only.

**DO NOT IMPLEMENT during the initial Local Layer system.**

---

## High-Level Summary

Micro Rogue's regional world generation should behave like this:

> **The world exists globally before the player reaches it. Nearby regions become increasingly defined as the player approaches. Entering a Global Hex resolves those regional facts into a persistent playable Local Map. The Local Map then reports meaningful results back upward so the world can use what happened there when determining what exists next.**

This creates a procedural world that can develop continuity, settlements, threats, quests, economies, and future history without requiring every playable tile in the world to be generated at New Game.
