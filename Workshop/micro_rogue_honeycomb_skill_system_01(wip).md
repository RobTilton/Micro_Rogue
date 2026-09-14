# Micro Rogue — Honeycomb Skill System

## Core Concept

Micro Rogue uses a two-stage skill system:

1. **Skill Trees = Unlock Space**
   - Players spend skill points inside themed trees such as Martial, Mental Mastery, Magic, Monk, etc.
   - Buying skills unlocks those skills for use.
   - Unlocking a skill does **not** automatically activate it in the player's build.

2. **Honeycomb Board = Build Expression Space**
   - Unlocked skills are represented as pieces that can be transplanted onto a player-owned hex board.
   - Placement, adjacency, chain routing, skill type, and footprint determine whether skills become active.
   - The board is a spatial logic system, not just a visual skill tree.

The result is that skill points determine **what the player owns**, while the honeycomb determines **what the player's current build actually does**.

---

## Board Structure

- The board is a pointy-top hex honeycomb.
- The center hex is a special universal space.
- The center is treated like a wildcard/faceted gem and satisfies:
  - adjacency requirements
  - skill-type requirements
  - chain routing requirements
- The center can participate in valid paths between a skill and its origin.

Conceptually, the center is a **universal routing junction** and a free handshake between otherwise incompatible sections of the board.

---

## Skill Tree Origins

Each skill tree has a unique **Origin Node**.

- When the player buys their first point in a skill tree, that tree's origin becomes available for placement on the honeycomb.
- Example: buying the first Martial point unlocks the Martial Origin piece.
- Every active skill from that tree must be able to trace a valid path back to its tree origin.
- The center wildcard may be part of that route.

Example valid chain:

`Martial Origin -> Martial Skill -> Martial Skill -> CENTER -> Martial Skill -> Show-Off`

The exact intermediate skills do not need to be active unless a specific rule says otherwise. They only need to qualify structurally for the chain.

---

## Placement and Activation Are Separate States

A critical rule of the system:

> **A placed skill does not need to be active in order to contribute to board topology.**

Every placed skill has at least two states:

### Placed
A placed skill:

- occupies board space
- exposes its skill type and tags
- counts for adjacency checks
- can satisfy other skills' adjacency requirements
- can participate in chain routing
- contributes structural value even if its own effect is inactive

### Active
An active skill:

- does everything a placed skill does
- has successfully satisfied its own activation requirements
- grants its gameplay effect

This allows inactive skills to be deliberately used as **infrastructure**.

Example:

Show-Off may fail its own activation requirements, but if another skill requires three adjacent Martial nodes, the inactive Show-Off still counts as a Martial neighbor.

---

## Topology Resolves Before Activation

The board should evaluate structural relationships independently from skill activation.

Recommended conceptual order:

1. Determine which skill pieces are placed.
2. Determine cell ownership, skill types, tags, and occupied spaces.
3. Build adjacency relationships.
4. Build valid chain paths back to tree origins.
5. Evaluate each skill's individual activation requirements.
6. Apply effects from active skills.

This avoids circular dependency problems where Skill A requires Skill B active, Skill B requires Skill C active, and Skill C requires Skill A active.

By default, chains should reason over **placed qualifying pieces**, not only active pieces.

---

## Skill Requirements

A skill may define several independent requirements.

Example:

```text
Show-Off
Skill Type: Martial
Chain Requirement: 5
Adjacent Requirement: 3
Optional Adjacent Requirement: false
```

These are separate checks.

### Chain Requirement
The skill must have a valid path back to the correct skill-tree origin.

Potential attributes include:

- required tree/type
- minimum path length
- maximum path length
- minimum qualifying nodes in path
- exact tags required in path

### Adjacent Requirement
The skill checks the pieces immediately neighboring its occupied cell or cells.

Potential attributes include:

- number of qualifying adjacent cells
- required skill type
- required tags
- required specific skills
- whether the condition is mandatory or optional

### Optional Adjacent Requirement
Some adjacency conditions may not be required for activation but may grant a secondary bonus.

This allows skills to support a baseline function while rewarding more specialized placement.

---

## Multi-Hex Skills / Polyhex Skills

Skills do not need to occupy only one hex.

Powerful or unusual skills may use **polyhex footprints**: connected shapes made of multiple hex cells.

Possible footprints include:

- 2-hex lines
- 3-hex straight pieces
- 3-hex bends
- triangular clusters
- 4+ hex asymmetric shapes
- intentionally awkward late-game shapes

### Core Rule

> A multi-hex skill is one skill entity occupying multiple board cells.

Its gameplay effect activates once, but **every occupied cell participates independently in board topology**.

Each occupied cell can:

- count toward chain routing
- satisfy type-based chain requirements
- contribute adjacency
- create exposed edges
- bridge otherwise disconnected regions
- serve as infrastructure while the skill itself remains inactive

This makes physical footprint a major balance lever.

---

## Shape as Balance

Powerful skills can be balanced through geometry instead of only through numerical prerequisites.

A strong skill may be difficult because it:

- occupies many cells
- has an awkward footprint
- blocks useful board space
- demands difficult routing
- requires specific adjacency on multiple sides
- creates heavy competition around the center

This allows very powerful effects to remain powerful without simply piling on arbitrary stat requirements.

The board itself says:

> "You can have this. Find somewhere to put it."

At the same time, awkward shapes still provide structural upside because every occupied cell contributes to the network.

---

## Show-Off Example

Show-Off is a strong Martial skill and a good candidate for an intentionally obnoxious multi-hex footprint.

Conceptual identity:

- Skill Type: Martial
- Grants dual wielding
- Grants an extra attack / breaks normal action economy
- Has a secondary adjacency bonus allowing use with any Martial weapon
- Requires a Martial chain back to the Martial Origin
- Requires multiple adjacent Martial cells
- Uses an awkward multi-hex / "gobstopper"-like footprint as part of its balance

The player is rewarded with an extremely powerful combat effect, but the skill consumes valuable geometry and may force the entire board to be built around it.

---

## Cross-Tree Infrastructure

Players are encouraged to invest outside their apparent archetype when another tree contains useful board technology.

Example:

A Warrior wants to spam Martial skills more often.

They spend enough points in **Mental Mastery** to reach a skill such as:

```text
Flow State
Skill Type: Mental Mastery
Chain Requirement: 5 Mental Mastery
Effect: Adjacent Skills Have -1 Cooldown
```

The Warrior then:

- routes a Mental Mastery chain to the center
- passes through the center wildcard
- positions Flow State on the Martial side of the board
- surrounds it with the Martial skills they want to spam

The character remains functionally a Warrior, but uses Mental Mastery as **infrastructure**.

This creates cross-tree temptation without forcing traditional hybrid-class identity.

A build can therefore be:

> 95% Martial combat, with a narrow Mental Mastery branch used purely to acquire one extremely valuable board modifier.

---

## Adjacency Modifier Skills

Some skills may modify neighboring skills rather than only affecting the player directly.

Examples:

```text
Adjacent Skills Have -1 Cooldown
```

```text
Adjacent Martial Skills Gain +X Damage
```

```text
Adjacent Spell Skills Cost -1 Mana
```

```text
Skills Adjacent To Two Or More Cells Of This Piece Gain -2 Cooldown
```

Multi-hex modifier skills make edge exposure and footprint orientation strategically important.

A long skill may touch many pieces.
A compact cluster may create dense local bonuses.
A hook-shaped skill may be excellent at wrapping around another important node.

---

## Emergent Build Architecture

The honeycomb is intended to create **build architecture**, not only build selection.

Players should think about:

- what skills they own
- which skills they actually place
- which skills they intend to activate
- which skills are only structural infrastructure
- how chains reach their origins
- how to exploit the center wildcard
- how to maximize adjacency bonuses
- how to fit awkward polyhex skills
- whether a powerful modifier deserves premium central board space
- whether cross-tree investment is worth the routing cost

This means a weak or inactive skill may still be valuable because it is:

- a connector
- a bridge
- a type carrier
- an adjacency provider
- part of a longer chain
- a scaffold for a stronger node

---

## Design Invariants

These rules currently define the identity of the honeycomb system:

1. **Skill Trees unlock pieces; the Honeycomb activates builds.**
2. **Every skill belongs to a tree/type and may carry additional tags.**
3. **Each tree has an Origin Node.**
4. **Active skills must have a valid route back to their relevant origin.**
5. **The center is a universal wildcard for adjacency, type, and routing.**
6. **Placement and activation are separate states.**
7. **Inactive placed skills still contribute topology.**
8. **Adjacency requirements and chain requirements are separate checks.**
9. **Chains use placed qualifying nodes by default, not only active nodes.**
10. **Skills may occupy multiple cells as polyhex pieces.**
11. **A multi-hex skill activates once, while each occupied cell contributes to topology.**
12. **Footprint shape is a legitimate balance mechanism.**
13. **Cross-tree investment should create unexpected build-support opportunities.**
14. **The board should reward spatial engineering rather than simple tree completion.**

---

## Design Goal

The Honeycomb Skill System should create the following player behavior:

> "I unlocked this skill because I want its effect."

Then later:

> "Wait. Even if I don't activate this skill, I can use its shape to bridge these nodes."

Then eventually:

> "If I route Mental Mastery through the center, rotate this ugly three-cell skill, sacrifice this passive, and wrap my Martial cluster around the cooldown node... I can make this completely unreasonable."

That progression from **skill selection -> spatial reasoning -> build engineering** is the core intended fantasy of the system.

