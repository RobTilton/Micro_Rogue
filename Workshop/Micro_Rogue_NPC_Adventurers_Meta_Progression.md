# MICRO ROGUE --- NPC ADVENTURERS & LIVING META-PROGRESSION

## Core Thesis

**You are not special. Until you are.**

The player is not the only adventurer in the world.

NPC adventurers exist inside the same simulation, use the same
fundamental rules, pursue the same kinds of opportunities, fight the
same enemies, enter the same POIs, acquire and sell equipment, accept
quests, succeed, fail, retreat, and die.

The player's characters begin as another participant in that world.

What makes a character exceptional is not that the game declares them
the protagonist. It is what they survive, accomplish, change, and leave
behind.

This system connects the two halves of Micro Rogue's intended
simulation:

1.  **The world changes around the player.**
2.  **The player's actions change the world.**

NPC adventurers make those two directions meet.

------------------------------------------------------------------------

# NPC ADVENTURERS

## Basic World Loop

An NPC adventurer may perform a simple adventuring loop:

`Enter Civilization -> Resupply / Trade -> Check Town Crier -> Accept Goal -> Travel -> Enter POI -> Fight / Explore -> Loot -> Return`

The important rule is that these actions should interact with existing
systems rather than being purely decorative simulations.

An adventurer entering town can physically visit existing services.

Example:

1.  Adventurer enters town.
2.  Adventurer walks to the blacksmith.
3.  A short pause represents buying, selling, repairing, or changing
    equipment.
4.  The blacksmith's inventory changes based on the transaction.
5.  Adventurer walks to the Town Crier.
6.  Adventurer accepts an available quest.
7.  Adventurer leaves town and travels toward the quest location.

The player may simply observe this.

Or follow them.

------------------------------------------------------------------------

# TOWN CRIER INTEGRATION

The Town Crier already acts as a source of quests generated from
conditions in the world.

NPC adventurers should use that same system.

Quests gain an additional field:

**Accepted By**

Example:

> **Clear the Eastern Ruins**\
> Accepted By: Elara Stonehand

Multiple adventurers may potentially be associated with a quest if the
final quest rules permit it.

The Accepted By list gives the player visibility into the simulation
without exposing an abstract AI management interface.

The player can see that another adventurer has taken an interest in the
same world problem.

They can then:

-   Ignore it.
-   Race them to the objective.
-   Follow them.
-   Encounter them along the road.
-   Watch them enter the POI.
-   Fight beside them.
-   Arrive after them.
-   Discover that they failed.

The quest is a world problem, not a reservation made for the player.

------------------------------------------------------------------------

# ADVENTURERS CHANGE THE WORLD

NPC adventurers can resolve the same kinds of hostile conditions the
player can.

If an NPC adventurer clears a hostile POI:

-   The POI is actually cleared.
-   Local hostility may change.
-   Civilization may benefit.
-   Trade-route viability may improve.
-   Loot has actually been removed from the location.
-   The adventurer may return carrying that loot.

If the adventurer sells recovered equipment to a blacksmith, that
equipment may appear in the blacksmith's inventory.

The player may therefore encounter an item whose history can be traced
through the simulation:

`Dungeon -> NPC Adventurer -> Blacksmith -> Player`

No scripted event is required.

------------------------------------------------------------------------

# FAILURE, DEATH, AND ENVIRONMENTAL STORYTELLING

NPC adventurers can fail.

If an adventurer dies inside a dungeon, their body may remain there
according to normal persistence rules.

Their equipment remains subject to the same world interactions as other
equipment.

An enemy may loot the corpse.

Example:

1.  Elara Stonehand accepts a quest.
2.  Elara enters a goblin-controlled dungeon.
3.  Elara dies.
4.  A goblin loots her Masterwork sword.
5.  The goblin survives.
6.  The player enters the dungeon later.
7.  The player encounters a strangely well-equipped goblin.
8.  The player kills it and recovers the sword.
9.  Deeper inside, the player finds Elara's corpse missing that weapon.

The game did not author an environmental-storytelling scene.

**The simulation produced one.**

------------------------------------------------------------------------

# LOADED VS. UNLOADED SIMULATION

NPC adventurers do not necessarily need full combat simulation while far
outside the player's loaded area.

When unloaded, their actions may be resolved through a cheaper
simulation appropriate to world-scale processing.

When they enter a loaded Local Map with the player, they become ordinary
actors and use the normal game systems.

The important invariant is:

**The loaded and unloaded representations describe the same adventurer
and preserve meaningful consequences.**

------------------------------------------------------------------------

# RETIRING PLAYER CHARACTERS

## Retirement Is an Alternative Ending to a Run

Death should not be the only way a character's run ends.

A sufficiently established character may choose to retire.

Retirement ends player control of that character, but does not remove
the character from the world.

Conceptually:

`Player Character -> Persistent NPC Adventurer`

The retired character retains, as appropriate:

-   Name
-   Level
-   Stats
-   Skills
-   Equipment
-   Build
-   History
-   Relationships to relevant world locations
-   Other persistent character state

The simulation then assigns NPC behavior rather than player control.

------------------------------------------------------------------------

# RETIRED ADVENTURER BEHAVIOR

A retired adventurer should generally become attached to the
civilization or region where they retire.

Rather than continuing to roam the entire world aggressively, retired
characters may prioritize **local POIs and local threats**.

This turns retirement into a form of organic regional stabilization.

Example:

> **Gronk "The World Shaker" McSmashy**\
> Level 18\
> Retired in Ambervale

A hostile POI develops near Ambervale.

The Town Crier creates a quest.

Gronk may accept it.

Gronk physically travels to the POI.

Gronk attempts to clear it.

If successful, local hostility is reduced through the same mechanisms
available to any other adventurer.

The player has not purchased:

`+37 Regional Defense`

The player has left **Gronk** there.

Gronk's contribution to the region is whatever Gronk is actually capable
of doing.

------------------------------------------------------------------------

# RETIREMENT IS NOT IMMUNITY

Retired characters remain part of the world.

They are not immortal trophies.

They can encounter danger.

They can fight.

They can potentially fail.

They can potentially die.

If the civilization where a retired character lives is raided, the
retired character may participate because they are physically present
and capable of fighting.

A retired level-18 warrior does not become decorative scenery simply
because the player is no longer controlling them.

If foolish mortals raid Gronk's town:

**Woe unto thee.**

------------------------------------------------------------------------

# SYSTEMIC REUNIONS

One of the primary emotional opportunities created by retirement is the
possibility of encountering a former player character during a future
run.

This should not require a scripted rescue system.

Example:

1.  Gronk retires in a region.
2.  A future player character begins another life in the same persistent
    world.
3.  Much later, a dragon enters Gronk's region.
4.  The current level-14 character engages the dragon.
5.  Gronk independently responds to the regional threat.
6.  Gronk travels toward the dragon.
7.  The player's battle lasts long enough for Gronk to reach the loaded
    Local Map.
8.  Gronk appears at the edge of the hex board.
9.  Gronk enters initiative.

No rule should say:

`IF PlayerLosingToDragon THEN SpawnGronk`

The emotional value comes specifically from the fact that Gronk arrived
for understandable systemic reasons.

The player recognizes him because **they used to be him.**

That creates an emotional event authored jointly by the player and
simulation rather than by a scripted sequence.

If Gronk survives and helps kill the dragon, the player has a reunion
story.

If Gronk dies fighting beside the new character, the player has lost a
piece of their own world history.

Both outcomes matter because the stakes were created through previous
play.

------------------------------------------------------------------------

# META-PROGRESSION

## The World Is the Meta Layer

Micro Rogue's primary meta-progression is not intended to be:

`Die -> Earn Account Currency -> Purchase Permanent Character Bonus`

Instead:

**Characters are temporary. Their consequences are persistent.**

A character may:

-   Clear hostile POIs.
-   Protect civilization.
-   Enable safer regions.
-   Help establish trade routes.
-   Increase prosperity.
-   Change access to goods.
-   Alter regional hostility.
-   Leave equipment circulating through the economy.
-   Permanently modify geography through extraordinary events.
-   Retire and remain physically present in the world.

Future characters inherit none of the previous character's raw stats
merely because that character existed.

They inherit **the world those characters helped create.**

------------------------------------------------------------------------

# PLAYER-CREATED SAFE REGIONS

Across multiple lives, a player may intentionally cultivate a region
they enjoy.

They can:

1.  Clear hostile POIs.
2.  Reduce hostility.
3.  Protect settlements.
4.  Improve conditions for trade routes.
5.  Increase prosperity.
6.  Allow civilization suppression to expand.
7.  Retire powerful characters into the region.
8.  Let those retired adventurers continue handling local threats.

Over time, a dangerous frontier can become a relatively stable pocket of
civilization.

This is not a menu upgrade.

It is a section of the actual world that became safer because of
accumulated actions.

The player has **carved out a place in the world.**

------------------------------------------------------------------------

# THE WORLD CAN PUSH BACK

Meta-progression is not intended to make the world permanently solved.

Existing and planned world-mutation systems can still create:

-   Earthquakes
-   Volcanoes
-   Demonic rifts
-   Hostile incursions
-   Dragon movement
-   Biome mutation
-   Civilization loss
-   Trade-route disruption
-   Other consequences of the War of the Gods

A region cultivated across several lives may later face a new threat.

The player may defend it.

NPC adventurers may defend it.

Retired characters may defend it.

Or the region may change.

Persistence means the player's accomplishments matter.

It does not mean they are untouchable.

------------------------------------------------------------------------

# WORLD-SCALE PLAYER CONSEQUENCES

At extraordinary levels of power, player actions may become large enough
to interact with the same world-mutation machinery normally used by
natural disasters, divine events, demonic incursions, and other
world-scale forces.

Example concept:

A warrior empowered by a God-Touched item performs an extraordinarily
powerful Earthquake.

The combat event exceeds normal local scale.

The game quietly reports:

> **The world moves in response.**

Later, when the player returns to the surface, nearby geography may have
changed.

Another example:

A mage produces an absurd Blizzard.

The resulting world event may remap nearby terrain into Frozen Wastes.

That terrain change may then affect:

-   Hostility
-   Travel
-   Civilization suppression
-   Trade-route viability
-   Prosperity
-   Future POIs
-   Future characters

The player did not select "Destroy Trade Route."

They cast a Blizzard powerful enough to change the land.

The world simulation handled the consequences.

------------------------------------------------------------------------

# THE GOD-TOUCHED CONNECTION

God-Touched equipment represents fringe contact with the larger War of
the Gods.

In Micro Rogue, that war touches the player's world indirectly.

In MAC-ROGUE, the conflict is intended to become much more central.

God-Touched items provide a bridge between those scales.

A normal character lives inside the world's rules.

An extraordinary character may accumulate enough divine influence and
personal power that the world itself must respond to their actions.

This supports the intended progression fantasy:

**Early Game:**\
The world happens to you.

**Mid Game:**\
You learn to manipulate the world.

**Extraordinary Runs:**\
The world must react to you.

**Death or Retirement:**\
The world continues without you.

------------------------------------------------------------------------

# "YOU ARE NOT SPECIAL. UNTIL YOU ARE."

NPC adventurers reinforce one of Micro Rogue's core themes.

At the beginning, the player is not the chosen hero.

Other adventurers:

-   Accept quests.
-   Buy equipment.
-   Explore.
-   Kill monsters.
-   Find loot.
-   Clear dungeons.
-   Die.
-   Become stronger.
-   Affect civilization.

The player is another adventurer operating in the same world.

There is no need for the simulation to reserve history for them.

But eventually, through survival, accumulated skill, extraordinary
equipment, world-changing actions, and persistent consequences, a player
character may become something the ordinary simulation can no longer
treat as ordinary.

They may become a regional hero.

They may become a retired protector.

They may become the reason a kingdom survived.

They may become the reason a forest no longer exists.

They may become the reason future characters inherit a prosperous trade
network.

They may become powerful enough that:

> **The world moves in response.**

The game does not need to declare them special.

**The history of the world demonstrates that they became special.**

------------------------------------------------------------------------

# DESIGN INVARIANTS

## NPC Adventurers Are Participants, Not Decorations

NPC adventurers should use existing world systems wherever practical.

Their actions should produce real state changes.

## Quests Are World Problems

A quest exists because something in the world requires attention.

The player is not guaranteed exclusive ownership of that problem.

## Retired Characters Remain Characters

Retirement changes control and priorities.

It should not erase the character into an abstract bonus.

## Persistent Characters Can Still Die

Retirement does not grant plot armor.

## Meta-Progression Lives Primarily in the World

The player's greatest persistent reward is the accumulated history and
state of the world.

## Systems Should Produce Stories

Prefer interactions where independent systems create memorable events
over bespoke scripts that imitate those events.

## Do Not Script Systemic Reunions

If a retired character appears during a crisis, it should ideally be
because their normal behavior caused them to respond and travel there.

## The Player Is Not Initially Unique

NPCs should demonstrate that adventuring is something people in this
world actually do.

## Exceptional Power Is Earned Through Play

The player becomes exceptional when their actual capabilities and
consequences exceed ordinary actors.

## The World Remembers

When a character dies or retires, meaningful consequences of their
existence remain.

------------------------------------------------------------------------

# CORE META-PROGRESSION LOOP

`New Character`

↓

`Adventure in Existing Persistent World`

↓

`Interact With Towns / NPC Adventurers / POIs / Trade / Hostility`

↓

`Solve Problems, Create Problems, Gain Power`

↓

`Change Local and Global World State`

↓

`Die OR Retire`

↓

`Character's Consequences Remain`

↓

`Retired Characters May Continue Acting as NPC Adventurers`

↓

`World Continues Simulating`

↓

`New Character Enters a World Containing Previous History`

↓

**Repeat**

The result should eventually be a world where generated geography,
simulation history, NPC history, and the player's own history become
difficult to separate.

That is not incidental flavor.

**That is Micro Rogue's meta-progression.**
