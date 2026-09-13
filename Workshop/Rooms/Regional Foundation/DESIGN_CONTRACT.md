# Regional Foundation — Design Contract
Updated: 2026-09-12
Checkpoint: [Regional Foundation]+[Delivery]+[Contract]

Baseline intent comes from the three imported documents in Workshop's root:

- Micro_Rogue_Regional_Resolution_Local_World_Simulation_Architecture.md
- Micro_Rogue_Hostility_Civilization_Suppression_Trade_Routes.md
- Micro_Rogue_Addendum_Hostility_Civilization_Suppression_Trade_Routes.md

Rob's subsequent conversation explicitly refines those documents for this implementation:

1. Local radius is **20**, replacing the document's radius 15 and current randomized rectangular sizes. Total is 1261 cells; diameter 41. The footprint prepares six edges for future travel, which is not included now.
2. A hostile POI has one pressure strength with decay of one per Global hex. The plague-nest exception and independent influence range are discarded. Strength 5 projects 5/4/3/2/1/0 at distance 0/1/2/3/4/5.
3. New POIs may be established through later generation or events. Their pressure updates established regions. Previously existing physical facts persist; revisiting never rerolls contents.
4. Global regional state is authoritative. Loaded maps apply changed revisions immediately; saved/unloaded maps check Global on re-entry and update cached regional values.
5. Generation uses a bounded placement pass, then publishes its results, avoiding recursive pressure/spawn feedback. Actual future hostility-sensitive content rules remain undefined.
6. Fresh worlds in the Room adopt these rules. Preserve existing saves instead of deleting them. There is no implicit Production migration or promotion.
7. Roads displaying trade, breakage communicating world changes, road-based fast travel and restricting unvisited Global travel are future thoughts only.

Implementation scope does not include town shopping/100 gold, suppression stacking, prosperity math, factions, road generation, trade thresholds, monster-family tiers, quests, neighbor bleed or geological events. The shared player/enemy actor capability system remains in force.
