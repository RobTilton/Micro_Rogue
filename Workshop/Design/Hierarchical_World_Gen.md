# Micro Rogue — Hierarchical World Generation Architecture

## Purpose

Micro Rogue's world generation is organized as a hierarchy of independently generated and persistent map layers.

The core principle is:

> **A parent layer establishes constraints. A child layer resolves those constraints into playable space.**

Lower layers are generated only when needed. Once generated, their resolved state is associated with their location in the hierarchy and can persist independently of whether that map is currently loaded.

This allows Micro Rogue to represent a large world without generating the entire playable world at New Game.

---

# Generation Hierarchy

```text
World
└── Global Map
    └── Global Cell
        └── Local Map
            └── POI
                └── Floor / Submap
                    └── Floor / Submap
                        └── ...
```

Every generated location therefore has an address derived from its ancestry.

Example:

```text
World[Seed]
└── GlobalCell[12,-7]
    └── LocalMap
        └── POI[RuinedKeep_02]
            └── Floor[3]
```

Conceptually:

```text
WorldSeed
    -> GlobalCell
        -> LocalMap
            -> POI
                -> Floor
```

This address gives generated content a stable identity.

---

# Layer 0 — Global Map

The Global Map is generated first when a new world/save is created.

It establishes the large-scale geography of the world.

Possible responsibilities include:

* Global hex/cell coordinates
* Biomes
* Rivers
* Roads
* Mountains
* Major terrain features
* Major landmarks
* Regions
* Broad faction or territory information
* Seeds/references used by child generators

A Global Cell does **not** need to contain its complete playable Local Map when the world is created.

Instead, it stores the information required to eventually generate that Local Map.

Conceptually:

```text
GlobalCell
{
    world_position
    biome
    terrain_tags
    connections
    local_seed
    local_map_generated
}
```

Example Global Cell information:

```text
Biome: Forest

River:
    enters NW edge
    exits SE edge

Road:
    enters W edge

Tags:
    ruins
```

The Global Map determines **what geographically exists**.

The Local Map determines what actually walking through that location looks like.

---

# Layer 1 — Local Map

A Local Map represents the playable map contained within a Global Cell.

Local Maps are generated **upon first entry into that Global Cell's actual playable map layer**.

Conceptually:

```text
EnterGlobalCell(world_position)

if LocalMap exists:
    LoadLocalMap(world_position)
else:
    GenerateLocalMap(GlobalCell)
    SaveLocalMap(world_position)
```

The Local Map generator receives constraints from its parent Global Cell.

For example:

```text
Global Cell:
    Forest
    River enters NW
    River exits SE
    Road enters W
    Ruins tag
```

The Local Map generator resolves those facts into an actual playable environment.

Its job is effectively:

> Generate a playable forest map satisfying these geographic constraints.

Once generated, the Local Map becomes the authoritative version of that location.

Returning to the Global Cell loads that existing map rather than generating a new one.

---

# Layer 2 — POI

Points of Interest exist inside Local Maps.

Examples include:

* Towns
* Cities
* Castles
* Forts
* Ruins
* Towers
* Caves
* Mines
* Shrines
* Merchant locations
* Dungeon entrances
* Overgrown forests
* Wells
* Quest locations

Each POI is created from a **POI Template**.

The template contains a small set of generation rules describing how that POI should be constructed.

The template does **not** need to contain the final generated layout.

Conceptually:

```text
POITemplate
{
    generation_rules
    placement_rules
    allowed_terrain
    entrances
    child_map_rules
}
```

When instantiated:

```text
GeneratePOI(
    world_position,
    local_position,
    poi_template
)
```

The template's rules are resolved into a concrete POI layout.

Once generated, that resolved POI belongs to that location.

It persists there permanently unless some future world-management system explicitly removes or expires it.

---

# Natural / World POIs

Some POIs may be generated during Local Map creation.

Examples:

```text
Cave
Shrine
Ruined Tower
Merchant Hut
Abandoned Mine
Village
```

These become ordinary persistent features of that Local Map.

---

# Event / Quest Generated POIs

POIs may also be created after initial world generation.

For example:

```text
QuestGenerated(
    world_position,
    local_position,
    POITemplate(quest.template.get())
)
```

The quest system should not directly generate terrain.

Instead, it requests a POI satisfying some requirements.

Conceptually:

```text
Quest System:
    "I require POI type X
     satisfying constraints Y."
```

The POI system resolves placement and generation.

Once created, the POI becomes part of the world.

It is no longer merely "quest content."

It is now **a place in the world that the quest caused to exist.**

Future quests, NPCs, encounters, or exploration systems may therefore reference the same location.

---

# Layer 3+ — Floors and Submaps

A POI may contain additional playable map layers.

These are referred to conceptually as Floors/Submaps regardless of whether they represent literal vertical floors.

Examples:

```text
Dungeon
    Floor 1
    Floor 2
    Floor 3

Tower
    Floor 1
    Floor 2
    Roof

Castle
    Main Layout
    Dungeon Floor 1
    Dungeon Floor 2

Town
    Town Layout
    Well
        Underground Floor 1

Overgrown Forest
    Outer Forest
    Deep Forest
    Ancient Grove
```

A "floor" therefore means:

> A child playable map belonging to another generated location.

It does not necessarily imply vertical architecture.

---

# Lazy Floor Generation

Each dungeon/tower/fort/ruin/forest/etc. floor is generated **only upon first entry**.

Example:

```text
Player enters Dungeon Floor 1

if Floor 1 exists:
    Load Floor 1
else:
    Generate Floor 1
    Save Floor 1
```

Later:

```text
Player enters Dungeon Floor 2

if Floor 2 exists:
    Load Floor 2
else:
    Generate Floor 2
    Save Floor 2
```

There is no requirement to generate an entire dungeon when the player enters its entrance.

Only the currently required layer needs to exist.

---

# Recursive Generation

The hierarchy is recursive.

Any generated map may either terminate or expose another child map.

For example:

```text
Global Cell
└── Local Map
    └── Town
        └── Well
            └── Underground Ruin
                └── Ancient Dungeon
                    └── Floor 1
```

The architecture does not need separate fundamental systems for:

* towns
* castles
* dungeons
* towers
* caves
* forests

They are variations of the same relationship:

```text
Parent Location
    -> Child Location
```

A Town may simply have no additional generated floors.

A Castle may have a persistent single-floor surface layout while containing a dungeon entrance.

A well inside a Town may expose an underground map.

An Overgrown Forest may use successive child maps to represent increasingly deep wilderness.

---

# Persistent Addressing

Generated content persists because it has an address through the hierarchy.

Example:

```text
World[Seed]
/
GlobalCell[12,-7]
/
LocalMap
/
POI[RuinedKeep_02]
/
Floor[3]
```

That address identifies the resolved generated state.

Therefore:

```text
Generate Once
    ↓
Associate Result With Address
    ↓
Save
    ↓
Unload When Necessary
    ↓
Return Later
    ↓
Load Existing Result
```

Generation state and loaded state are separate concepts.

A location may:

```text
Exist + Loaded
Exist + Unloaded
Not Yet Exist
```

This allows future chunk timeout / unloading systems without destroying world persistence.

A Local Map or dungeon floor can disappear from active memory while its generated state remains associated with its address.

---

# Generation Order

High-level generation order:

```text
1. New Game
      ↓
2. Generate Global Map
      ↓
3. Player explores Global Map
      ↓
4. Player enters Global Cell
      ↓
5. Generate Local Map if necessary
      ↓
6. Generate/resolve initial Local POIs
      ↓
7. Save Local Map
      ↓
8. Player enters POI
      ↓
9. Generate first required Floor/Submap if necessary
      ↓
10. Save generated Floor/Submap
      ↓
11. Repeat recursively as deeper locations are entered
```

Event-driven content may enter the hierarchy later:

```text
Quest/Event
    ↓
Request POI
    ↓
Select Global Cell
    ↓
Select Local Position
    ↓
Instantiate POI Template
    ↓
Resolve Generation Rules
    ↓
Assign Persistent Address
    ↓
POI now exists in world
```

---

# Core Architectural Rules

## Rule 1 — Parent Defines Constraints

A parent layer describes facts the child must respect.

Example:

```text
Global:
River crosses this cell NW -> SE.
```

The Local Map generator decides how that river actually appears while preserving that constraint.

---

## Rule 2 — Child Resolves Constraints

The child generator owns the detailed implementation of its playable space.

The parent should not need to generate the child's geometry/layout itself.

---

## Rule 3 — Generate On First Need

Do not generate lower layers until something actually requires them.

```text
Global Map:
    Generated at New Game

Local Map:
    Generated on first entry

POI:
    Generated when initially populated or requested

POI Floor/Submap:
    Generated on first entry
```

---

## Rule 4 — Generated Results Become Authoritative

Templates and seeds describe how something **may be generated**.

Once generation occurs, the resulting location becomes the authoritative state for that address.

Returning to the location loads the existing result.

---

## Rule 5 — Templates Store Rules, Not Necessarily Results

A POI Template should primarily describe generation behavior.

Example:

```text
RuinedFortTemplate
{
    footprint_rules
    wall_rules
    room_rules
    entrance_rules
    encounter_rules
}
```

Instantiation resolves those rules into one particular Ruined Fort.

---

## Rule 6 — Generation Is Recursive

Any playable location may contain another playable location.

The architecture should therefore support:

```text
Location
    -> Child Location
        -> Child Location
            -> ...
```

rather than hardcoding a fixed maximum conceptual depth into the world model.

---

## Rule 7 — Persistence Is Address-Based

Generated content belongs to a hierarchical location.

The important identity is not merely:

```text
Dungeon Floor 3
```

but:

```text
World
-> Global Cell
-> Local Map
-> Specific POI
-> Floor 3
```

This prevents generated locations from losing their identity after unloading.

---

# High-Level Model

The entire Micro Rogue world-generation architecture can therefore be summarized as:

```text
GLOBAL WORLD
Defines geography
        ↓
LOCAL MAP
Resolves geography into playable terrain
        ↓
POI
Resolves a location/template into a persistent place
        ↓
FLOOR / SUBMAP
Resolves deeper playable spaces as they are entered
        ↓
REPEAT AS NECESSARY
```

Or more simply:

> **Generate the world broadly first. Generate detail only when the player reaches it. Give every generated result a persistent hierarchical address.**

This structure supports:

* Large worlds
* Lazy generation
* Persistent exploration
* Procedural dungeons
* Procedural towers
* Procedural ruins
* Procedural forests
* Towns
* Cities
* Castles
* Nested locations
* Quest-created locations
* Future chunk unloading
* Regeneration-independent saves

without requiring the entire playable world to exist at New Game.

---

# Current High-Level Generation Layers

```text
0. Global Map

1. Local Map

2. POI

3+. POI Floors / Child Submaps
```

These layers establish the high-level world-generation architecture.

The individual generation systems for each layer can now be designed independently and **in order**.
