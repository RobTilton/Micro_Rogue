# World Time and Frontier
Updated: 2026-09-14
Checkpoint: [World Time and Frontier]+[Validation]+[Production adoption]

F5 runs this Production implementation. Human playtest acceptance is pending. Existing saves are preserved; generate a new world to receive the guaranteed starter route and two towns. Existing initialized locations retain their layouts and contents.

## Starter route and tutorial
New world generation creates two named towns connected by a traversable route, shown in gold on the Global map and minimap. The starting crier offers the route tutorial first: defeat the boss in the indicated route Dungeon, then return to claim exactly one skill point. Boss death removes that POI hostility source immediately. Claiming the tutorial raises both endpoint towns' prosperity by one and reports the before/after values. Other hostility sources can remain. Rewards cannot be claimed twice. Outside the guaranteed endpoints, new Local maps have a seeded 20% town chance.

## Time and travel
The persisted clock uses twelve 30-day months, four six-hour blocks per day: Morning, Noon, Evening, Midnight. The display uses Month_01.day_01.1 and the block name. Every successful player Global-border crossing costs exactly six hours. Global movement is limited to one adjacent route edge or an explicitly registered one-use event step. Global lunge/retreat cannot bypass travel rules.

For ordinary exploration, walk to a dry Local boundary and use Activate or the contextual Cross direction action. Arrival is on the opposite dry edge of the adjacent Local. Failed crossings spend no action or time. Entering/exiting a location within the same Global hex adds no border charge. NPC pursuit can follow Local borders without repeatedly advancing shared time. No duration is assigned yet to ordinary local steps, combat turns, or resting.

## Encounters and progression
New Locals contain seeded chests and scouts. Visible Local enemies trigger a persistent radius-six outdoor hex arena using the encounter biome; water biomes receive dry shoreline combat ground. The same actor identities transfer, and the exit returns to the encounter cell. Other unseen actors remain in the Local.

Monsters initially spawn near player level, then age independently: each full day since birth adds one fifth of a level, granting a level and point every five days. Existing monsters no longer rescale to the player. Allocated stats, equipment, missing health and dead state survive scaling. Players can spend one advancement point for +1 to a selected stat in Skills. Skill-less monsters spend points on stats through the shared actor system.

Rival families fight spatially when active. Once per day, each occupied offscreen map can resolve one hostile pair using a deterministic coin roll weighted by stats and equipment; deaths use the existing corpse and kill-XP pipeline. This is a bounded first pass, not a full population simulation. Unspawned maps are not populated merely to simulate fights. Families still use placeholder art and equipment rules.

Shop stock persists until the weekly 168-hour boundary, when initialized towns replace unsold stock using current prosperity. Purchased items remain owned. Inn service is now implemented by [Living Frontier](<../Living Frontier/CURRENT_STATE.md>), which also adds timed population and quest directions. Boats, a general road network and further economy work remain deferred.

## Validation
Final headless Frontier run: **66 checks, zero failures**, including valid save restoration. Frontier integration covers calendar rollover, route-only movement, six-hour charges, Local dry arrivals, arenas and return links, aging, stat spending, offscreen determinism, weekly stock, tutorial rewards/prosperity, event permits and save restoration. A 12-seed route sweep passed; all worlds had both route towns and 11 sampled other regions had no town. Mouse Play regression: 26 checks passed. Town Market regression: 32 checks passed. Rendered route, minimap, calendar and tutorial journal were inspected in tests/frontier_gameplay.png. Tests use isolated saves. No player-save reset or Git commit was performed.
