# Persistence
Updated: 2026-09-13
Checkpoint: [Regional Release]+[Delivery]+[Promotion]

`persistent_actor_world.gd` composes shared actor capabilities with location resolution and validated snapshots. `map_state.gd` includes hex geometry and regional cache revisions. `autosave_journal.gd` stores checksummed compressed deltas. Regional hex/source collections are journaled separately from geography.

`world_slot.gd` enforces one active world save. A complete replacement must exist before obsolete files are removed from owned autosave/snapshot folders. New World and Regenerate World replace previous progress; regeneration uses a different seed and fresh character setup. Continue begins a self-contained journal at its next checkpoint, then removes the predecessor. The UI offers no extra snapshot. At 32 MiB, the journal rotates into a full current-state checkpoint; the slot removes the previous journal only after successful publication.

Storage root: **user://worlds/**. `autosaves/` contains the active journal; `archives/` contains unloaded maps for the current world. Obsolete same-location archives are replaced after a successful write; previous-world archives are pruned when the active world changes. `preferences.cfg` contains movement preferences independently of the world. The legacy snapshots folder remains a cleanup/read boundary, not a player backup feature.

Creation, successful actions, turns, travel, event POIs and normal close checkpoint automatically. Truncated tails recover the last completed transaction in the current journal. Failed replacement writes leave the old save available. Removal errors are reported and may temporarily leave old files present.

Current generator version is 3. Version-one/two metadata can inform World Data/Regenerate, but Continue does not silently convert rectangular saved geography. Workshop candidates use independent namespaces and are not automatically imported. Full transactions retain the existing 64 MiB supported limit; this is not a fully indexed arbitrarily large disk-streaming store.

Momentum adoption preserves generator 3/schema 1. Snapshots persist turn_threshold and per-actor momentum, speed_effects and actions.free. Missing fields on compatible older saves default to 3/zero/empty/zero; invalid fields reject loading atomically.

Equipment Integration preserves current generator/schema compatibility: optional head/arms/legs/grip migrate to empty/one on older saves. Generated rules_version 1 items are validated against the adopted catalog and resolved stats. Legacy item dictionaries remain unchanged and receive the documented fixed-defense interpretation. Newly populated locations get one persistent seeded loose item; existing initialized maps are not repopulated.
