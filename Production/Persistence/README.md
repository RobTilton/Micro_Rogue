# Persistence
Updated: 2026-09-14
Checkpoint: [Regional Release]+[Delivery]+[Promotion]

`persistent_actor_world.gd` composes shared actor capabilities with location resolution and validated snapshots. `map_state.gd` includes hex geometry and regional cache revisions. `autosave_journal.gd` stores checksummed compressed deltas. Regional hex/source collections are journaled separately from geography.

`world_slot.gd` enforces one active world save. A complete replacement must exist before obsolete files are removed from owned autosave/snapshot folders. New World and Regenerate World replace previous progress; regeneration uses a different seed and fresh character setup. Continue begins a self-contained journal at its next checkpoint, then removes the predecessor. The UI offers no extra snapshot. At 32 MiB, the journal rotates into a full current-state checkpoint; the slot removes the previous journal only after successful publication.

Storage root: **user://worlds/**. `autosaves/` contains the active journal; `archives/` contains unloaded maps for the current world. Obsolete same-location archives are replaced after a successful write; previous-world archives are pruned when the active world changes. `preferences.cfg` contains movement preferences independently of the world. The legacy snapshots folder remains a cleanup/read boundary, not a player backup feature.

Creation, successful actions, turns, travel, event POIs and normal close checkpoint automatically. Truncated tails recover the last completed transaction in the current journal. Failed replacement writes leave the old save available. Removal errors are reported and may temporarily leave old files present.

Current generator version is 3. Version-one/two metadata can inform World Data/Regenerate, but Continue does not silently convert rectangular saved geography. Workshop candidates use independent namespaces and are not automatically imported. Full transactions retain the existing 64 MiB supported limit; this is not a fully indexed arbitrarily large disk-streaming store.

Momentum adoption preserves generator 3/schema 1. Snapshots persist turn_threshold and per-actor momentum, speed_effects and actions.free. Missing fields on compatible older saves default to 3/zero/empty/zero; invalid fields reject loading atomically.

Equipment Integration preserves current generator/schema compatibility: optional head/arms/legs/grip migrate to empty/one on older saves. Generated rules_version 1 items are validated against the adopted catalog and resolved stats. Legacy item dictionaries remain unchanged and receive the documented fixed-defense interpretation. Newly populated locations get one persistent seeded loose item; existing initialized maps are not repopulated.

Cave topology persists as optional map cave_layout; older non-cave maps default empty. Generated Cave records require valid topology. Cave room populations use independent room seeds and initialize once. Cave arrivals use their recorded entry cavern; returns retain the parent entrance.

Dense Dungeon/Tower generation (2026-09-13): packed hex-cell rooms, cyclic single-door connections, persisted per-room content and a player-revealed tower return ladder. Existing saved layouts retained. See `Workshop/Rooms/Dungeon Foundation/CURRENT_STATE.md` for scope and validation.

Interior scenery (2026-09-13): new caves/dungeons/towers get persistent walkable props and fixed container loot. Shared search exposes contents for pickup; enemy corpses retain possessions. Temporary symbols pending transparent art. Details: `Workshop/Rooms/Interior Scenery/CURRENT_STATE.md`.

Town Market (2026-09-13): new radius-three towns with perimeter shops, persistent seeded stock and containers; shared purchases, new characters empty-equipped with 100 gold. Provisional prosperity and no restocking yet. See `Workshop/Rooms/Town Market/CURRENT_STATE.md`.

Town Life (2026-09-13): named-town starts, three allied NPCs, crier boss bounties, persistent hostility-based gold and player-relative monster levels. Rules and provisional formulas: `Workshop/Rooms/Town Life/CURRENT_STATE.md`.

Mouse Play (2026-09-13): contextual mouse actions, self double-click travel, wheel zoom with saved camera state, actor slides, Quests rail and minimap. Controls and evidence: `Workshop/Rooms/Mouse Play/CURRENT_STATE.md`.

World Time and Frontier (2026-09-13): adopted calendar, six-hour border travel, Local-edge exploration, starter trade route with two towns and a one-skill-point crier tutorial, sparse towns, outdoor encounters, independent monster aging, faction combat, stat spending and weekly stock. Authoritative scope and limits: `Workshop/Rooms/World Time and Frontier/CURRENT_STATE.md`. This supersedes earlier statements deferring these features or retaining player-relative monster scaling.

Living Frontier (2026-09-14): 1-gold inn recovery (2 × CON, one six-hour block), quest bearing/terrain hex, seven-day cleared-Local replenishment and monthly survivor occupation of visited cleared POIs. Supersedes prior inn-service deferral. Rules and validation: `Workshop/Rooms/Living Frontier/CURRENT_STATE.md`.

Free Exploration (2026-09-14): action budgets now apply during combat; safe shopping, inventory and exploration need no end-turn prompts. Shop stock has inspection tooltips. Gold and six-hour time costs remain. See `Workshop/Rooms/Free Exploration/CURRENT_STATE.md`.

Shop Sales (2026-09-14): backpack gear sells for half retail rounded down into the receiving merchant stock. Buy/sell confirmations support Ctrl bypass. New characters start with 50 gold; existing balances preserved. See `Workshop/Rooms/Shop Sales/CURRENT_STATE.md`.
