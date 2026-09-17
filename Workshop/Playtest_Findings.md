# Micro Rogue — Next Mutation Pass

## 1. Remove DEX Scaling From All Physical Weapons

DEX should no longer contribute directly to weapon damage.

This includes:
- swords
- axes
- maces
- spears
- daggers
- bows
- throwing weapons
- lances
- other physical weapons

Physical weapon damage should scale from STR.

### Reason
DEX already provides major value through action economy.

Current action economy:
- 1 Attack
- 1 Move
- 1 Activate

Every 3 DEX currently grants:
- +1 flexible free action

That free action can be spent on:
- Attack
- Move
- Activate

Therefore DEX already increases potential damage by granting additional attacks.

DEX should not simultaneously:
- increase attack frequency
- increase movement
- increase utility actions
- increase per-hit weapon damage

### Intended Stat Identity

**STR**
- Physical damage
- Determines how hard each physical attack hits

**DEX**
- Tempo
- Movement
- Action economy
- Flexible free actions

A high-STR greatsword user should hit extremely hard.

A somewhat lower-STR, high-DEX greatsword user may hit less hard per swing but potentially swing multiple times.

Both are dangerous for different reasons.

### Weapon Notes
Bows still scale with STR.

Drawing and repeatedly using a powerful bow requires physical strength.

Daggers still scale with STR.

Stabbing through armor, clothing, tissue, etc. still requires physical force.

Spears scale with STR.

Lances are STR-based and this hill will be defended to the death.

---

## 2. Fog of War In All Areas

Fog of war applies everywhere:

- Global Map
- Local Maps
- Towns
- Wilderness
- Dungeons
- Caves
- Towers
- Forts
- Ruins
- Other POIs

The player should only receive information their character could reasonably perceive.

### Base Vision Range

Base view radius:

> 7 hexes

WIS increases view range:

> +1 view radius per 2 WIS

Proposed formula:

`View Radius = 7 + floor(WIS / 2)`

Examples:

- WIS 1 = radius 7
- WIS 2 = radius 8
- WIS 3 = radius 8
- WIS 4 = radius 9
- WIS 5 = radius 9
- WIS 6 = radius 10
- WIS 8 = radius 11

Exact formula can be tuned after playtesting.

### Visibility States

**Unseen**
- Completely hidden.
- Player has no information about terrain, mobs, loot, or interactables.

**Previously Seen**
- Terrain / static structure remains in memory.
- Presented dimmed.
- Dynamic information does not update while outside vision.

**Currently Visible**
- Full current terrain state.
- Current mobs.
- Current loot.
- Current interactables.
- Current environmental state.

### Dynamic Information

Previously observed information is only memory.

Example:

1. Player sees a chest.
2. Player leaves the area.
3. Goblin discovers and loots the chest.
4. Player's remembered map does not update.
5. Player returns and regains line of sight.
6. The changed chest state is revealed.

The same applies to:
- mobs
- corpses
- dropped equipment
- opened containers
- destroyed objects
- other world-state changes

### Minimap

The minimap should obey the same knowledge rules.

It should only reveal:
- discovered terrain
- currently known information

It should not expose:
- unexplored geometry
- current offscreen mob locations
- offscreen loot changes
- hidden POIs before discovery

### WIS Identity

This gives WIS another clear purpose:

> WIS determines how much of the world the character can perceive at once.

Higher WIS means:
- earlier threat detection
- greater exploration awareness
- better ability to see exits / terrain ahead
- better information before committing to movement

This is especially valuable because mobs can:
- wander
- fight
- loot
- equip new gear
- move into previously cleared areas

Fog of war ensures those systems create discovery rather than omniscient information.

---

## 3. Reduce Loot Drop Rates

There is currently too much loot.

Current experience:

> Cannot move roughly five hexes without finding something searchable or lootable.

This reduces:
- excitement
- scarcity
- value perception
- exploration tension

Loot currently feels ubiquitous rather than meaningful.

### Touched by the Gods
Reduce Touched by the Gods frequency dramatically.

Current target:
- roughly 90% reduction from current effective rate

Do not immediately reduce God-Touched power.

The desired reaction is:

> HOLY SHIT. Can I make this work for my build?

Not:

> Oh. Another orange.

God-Touched items can remain extremely strong if they are genuinely rare.

---

## 4. Redistribute Loot Toward Important Locations

Do not simply remove loot uniformly.

Redistribute it.

### Reduce
- random containers everywhere
- constant hallway loot
- excessive minor-room loot
- loot every few hexes

### Increase / Concentrate
- boss rooms
- treasure rooms
- armories
- camps
- storerooms
- guarded areas
- corpses from meaningful encounters
- POI-specific logical locations

### Design Goal
Loot should communicate something about the space.

Examples:

**Boss room**
- boss has accumulated wealth / equipment
- more containers
- greater opportunity for upgrades

**Armory**
- weapons and armor

**Store room**
- supplies / consumables

**Camp**
- food, belts, basic equipment

The player should increasingly think:

> There might be something valuable in there.

rather than:

> There will definitely be three containers somewhere in the next five steps.

---

## 5. Increase Mob Mobility

Mobs currently remain relatively local unless they have a reason to:
- fight
- loot
- pursue something

Add intentional exploration behavior.

### Proposed Priority

1. Fight
2. Loot
3. Explore

### Idle Exploration Rule
If a mob has no meaningful target for approximately 3 simulation rounds:

> Move in a way that increases knowledge of the surrounding environment.

Possible goals:
- doorway
- unexplored adjacent room
- corridor
- tile exposing additional line of sight
- neighboring area outside current known space

This should not be pure random walking.

The mob is seeking information.

### Result
Mobs may naturally:
- leave starting rooms
- encounter other factions
- discover corpses
- discover loot
- upgrade equipment
- find the player
- enter previously cleared spaces

This allows the dungeon simulation to evolve without requiring scripted encounters.

---

## 6. Boss Room Loot / Boss Progression

Bosses should have greater access to loot because their spaces logically contain more resources.

Do not necessarily spawn bosses fully equipped with premium gear.

Instead:

### Boss Baseline
Potentially:
- no Trash starting gear
- Common / Exceptional starting equipment
- exact floor TBD

### Boss Environment
Boss rooms should contain more loot opportunities than ordinary rooms.

Bosses can then use the same existing simulation rules as other mobs:

> find loot -> evaluate loot -> equip upgrades

### Desired Effect

Finding the boss early:
- boss may still have mediocre equipment

Taking too long:
- boss may have searched more containers
- boss may have upgraded
- encounter may become substantially harder

This creates organic difficulty scaling from world time rather than artificial stat inflation.

---

# Overall Goal

The next pass should make the world:

- less loot-saturated
- more dangerous to leave unattended
- more rewarding to explore
- less omniscient
- cleaner in stat identity
- more dependent on emergent mob behavior

Key principle:

> STR determines how hard physical attacks hit.
> DEX determines how often and how flexibly you can act.

And:

> Loot should be something you discover in meaningful places, not fucking confetti.