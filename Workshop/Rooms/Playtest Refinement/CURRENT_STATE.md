# Playtest Refinement
Updated: 2026-09-15
Checkpoint: [Playtest Refinement]+[Validation]+[Integration]

Live entry remains Production/main.tscn (F5). Implements Workshop/Playtest_Findings.md with direct user clarifications. Human playtest acceptance remains pending; no save reset or commit.

## Sight, detection and discovery
Production/Actors/perception.gd owns sight: max(0, sight_base + floor(WIS/2) + sum(sight_effects)). New actors start with sight_base=7 and empty source-keyed effects. ActorWorld.set_sight_effect(actor,source,integer) changes/removes an additive modifier (zero removes). All actor perception uses this calculation and existing wall/shop line-of-sight blocking. Character and inventory display effective hex radius. Equipment/skills may use named sources later; this pass adds no new affixes.

A hostile seeing the player engages combat immediately, even when the player cannot see it. Merely spotting a shorter-sighted hostile does not engage the player. Attacking engages both participants. Exploration movement truncates at the first detected hex and pays a combat move. Lunge shares the boundary and pays its attack; approaching NPCs also stop at initial player detection. Pursuit refers to the particular target rather than unrelated background fights. Momentum remains unchanged: first threshold grants normal actions, subsequent thresholds add free actions.

map_knowledge.gd observes only current sight and builds a separate presentation map. Unknown cells are hidden; remembered cells dim. Remembered terrain, links, shops, props and ground-loot markers update only when visible. Container contents are never copied into memory. Live actors are shown only in current sight. The world view, minimap and Map entrance list consume observed information; route segments require both endpoints discovered. Player camera state remains on the actual map.

ActorWorld.discovered_maps persists through snapshots/journals and character replacement. Old saves begin with empty discovery, then reveal current sight; old exploration cannot be reconstructed. Source world geometry remains intact. NPC explored_cells is separate actor-owned information, not shared player discovery.

## Combat and economy
All physical weapons use STR; two-handed melee uses floor(1.5*STR). Bows use STR with no two-hand bonus. Staffs remain INT. Weapon material/quality bonuses retain the earlier doubled values. Shared inspected item tooltips calculate baseline price and eligible sell value using village_shops; supplies use their actual baseline prices (potion 2, ration 1). Distant appearance-only tooltips do not reveal appraised prices.

Quality weights total 1000: Trash 200, Common 409, Exceptional 200, Masterwork 150, Mythic 40, God-Touched 1. Existing item validation ignores obsolete probability metadata while retaining semantic identity/property checks; existing item power is unchanged.

Items.loot adds a 20% health-potion branch. Equipment-specific construction and shop categories still use Items.generate. Newly populated rooms use seeded ordinary, boss, armory, storeroom and camp roles. Boss rooms have three container opportunities; ordinary rooms have a 15% chance of one. Other designated rooms have one. Storerooms supply potions; camps offer rations/belts/potions. Loose room drops fall from 65% to 10%, with a boss-room drop. Existing populated layouts/contents are not deleted or reshuffled.

Gold comes from chests and actual monster deaths. New chest gold is floor(1d3*3*hostility/4); version-2 chests halve again once, version-1 chests quarter once. New monster gold is floor((1+hostility d3)/2); older monsters halve their coin purse at death once. Non-chest scenery gold is removed on map reconciliation; actual death corpses retain their coins. No player wallet or quest reward change. Actual death corpses now carry an explicit marker; existing named death corpses remain recognized.

Quests sidebar shows accepted quests, including completed objectives awaiting a crier claim. Available and rewarded quests are excluded.

## NPC exploration
EnemyBrain prioritizes visible enemies over ground/container investigation. After three idle world rounds, an enemy seeks a known reachable frontier adjacent to unseen cells; it uses existing legal movement. Memory persists per actor/map. Fallback seeks a more distant remembered frontier. This is basic exploration, not door interaction or strategic inter-map roaming. Boss starting-quality floor remains undecided; current starting loadouts stay intact.

## Evidence and remaining work
39 focused checks cover WIS/effects, detection boundary, walls, fog/chest memory, replacement discovery, STR scaling, exact rarity distribution, old quality metadata, consumable drops, accepted quests, generated loot validation and idle exploration. Integration suite covers 63 checks including layout seed sweeps, creation, recovery, save roundtrip, persistent death, controls/minimap and permitted gold sources. Original historical regression produced two expected failures for the superseded gold formula; the Room copy updates only those gold expectations and adds this pass's checks.

Rendered fog.png inspected: current cave bright, remembered cave dim, unknown terrain hidden, minimap masked. Tests and isolated saves retained under this Room. Original modified files retained under Reference. Crowded-POI timing has not been profiled; no performance improvement claim. Player visual/balance acceptance pending.
