# Regional Foundation — Current State
Updated: 2026-09-12
Checkpoint: [Regional Foundation]+[Persistence]+[Validation]

Adoption: Rob approved this generation and requested Production promotion with edge entry, a hex start menu and one-save regeneration. [Regional Release](../Regional%20Release/CURRENT_STATE.md) records the delivered successor. The behavior described below is the preserved source Room, not the current F5 release.


## Rapid Shape

A Workshop candidate for fixed hexagonal Locals and persisted regional hostility. F6 entry: `main.tscn` in this Room. Production remains the accepted F5 game and has not been modified. SOURCE_BASELINE.json identifies the imported Production scripts; shared Production artwork is read-only. No user Git checkpoint supplied.

New worlds declare Global geography and Local addresses first. Every Global hex has biome/base hostility and regional facts. A radius-two bubble (19 hexes at the starting location) is marked regionally resolved without constructing Local terrain. Player Global movement and Local generation extend this bubble. Settlement distributions, regional factions and advance POI population are not invented: actual POI facts are published when established.

## Geometry

Every newly generated Local uses radius 20, diameter 41 and exactly 1261 playable axial cells. Coordinates occupy a 41×41 bounding box centered at (20,20); excluded corners are not tiles, walls or navigation targets. Interior maps and Global retain their existing geometry. Return to Global is at Local center. Local size randomization is removed; terrain and POI positions remain seeded.

`World/hex_map.gd` owns membership and enumeration. `geographic_contracts.gd` maps six actual sides to inherited neighbor boundary contracts; full sides contain 21 cells and share corners. Surface sampling excludes shared corner cells so two contracts cannot overwrite a corner. Parent river ports connect to the appropriate side. No automatic edge crossing or neighboring terrain bleed is implemented.

## Regional truth and synchronization

`World/regional_state.gd` operates on Global-owned `records.global.regional`: hex records plus POI source records. Each hex holds biome, base hostility, current hostility, contributing source IDs/values, known POIs, resolution flag and revision. Local/interior `regional_values` are read-only-by-contract cached copies with `regional_revision` identifying the applied Global revision.

Source contribution = max(0, strength − wrapped Global hex distance). Sources stack additively; no tier/range separation or secondary decay logic. Source strength is a nonnegative integer; zero removes its pressure, preserving the POI record and physical location. Biome values follow the imported addendum; runtime Sea/Swamp/Wasteland names map to its plural labels, Salt Marsh uses Marsh's 2, and impassable Ice Wall contributes 0. Civilization suppression remains unimplemented pending its stacking/strength rules.

The existing generic Dungeon and Tower each default to strength 1; other templates default to 0. These are explicit placeholder assignments, not monster-family definitions. Descendant floors do not automatically add duplicate regional sources.

`location_world.gd` publishes a finite Local generation pass before recalculating pressure. `constraints.generation_region` records the inputs used by that pass. New sources can affect already-established regions; existing terrain, towns, actors and equipment are never rerolled. Live Local/interior caches synchronize immediately. Unloaded maps remain unloaded and reconcile when `ensure_location` restores them. The same Global source remains authoritative throughout.

Public event boundaries:

- `request_poi(parent_id, template, requested_cell, label, hostility = -1)` validates and stages unresolved parents atomically; -1 uses the template placeholder default. Successful commit preserves existing live map object identity.
- `set_poi_hostility(poi_id, strength)` changes/removes pressure using an existing POI's Local ancestry. Repeating the same strength is a no-op. It does not delete a POI or declare its occupants dead.
- `resolve_regions(global_cell)` resolves the nearby data bubble without terrain generation.
- `sync_region(location_id)` / `sync_loaded_regions()` reconcile cached regional values without population changes.

POI lifecycle events must explicitly report that a threat is neutralized; automatic “last enemy means cleared” semantics are not defined. Future prosperity, trade, spawn and quest consumers can read these facts, but this delivery does not implement their formulas or replace current populations based on hostility.

## Persistence

This Room uses `user://regional_foundation/` for automatic journals, extra snapshots and map archives. It does not read, reset or overwrite Production's `user://worlds/`. Generate a new world here. Generator version 3 saves belong to this candidate; previous Production saves retain their original geometry and loader in Production.

Snapshots and journals serialize `regional_hexes` and `regional_sources` separately from location records, enabling per-hex journal deltas. Regional revision changes do not force geography recapture. Cached map values are captured when their applied revision changes. Save validation verifies source ancestry, exact distance contributions, geometry membership and current caches; stale unloaded caches are permitted and reconciled on entry. Revision/source mutations persist through the existing action checkpoint path; external event callers must checkpoint after their completed transaction, as existing event UI does.

## Validation and remaining work

Geometry checks cover all 11 playable biomes across three seeds, six sides, inherited rivers/surface profiles and east–west wrap. Regional checks cover late sources, strength changes, removal, no-op changes, atomic failed events, actor/equipment preservation, unloaded re-entry and journal persistence. Rendered gameplay and a full-map overview have been inspected. Focused autosave checks cover interrupted tails, exact restart and small movement deltas (827 bytes in the measured frontier movement; timing is machine-dependent).

Implementation validation is complete: geometry 96,399; regional/persistence 12,112; actors 134; autosave 17; rendered UI 19 checks, all passing. Separate-process journal restoration matches exactly. DOTS records the detailed evidence and pending human playtest. Tests and images remain in `tests/`; source errors caught during development were fixed and the affected checks rerun. No test fixture is installed in normal player Continue storage.

Pending: Rob's F6 playtest and any later explicit Production adoption. Excluded: road/trade mechanics, Global travel restrictions, edge crossing, prosperity formulas, suppression, quests, monster families, starting-town economy, neighbor bleed and geological events. Road/fast-travel thought recorded in Workshop/Design/USER_HAD_A_THOUGHT.md.

Preservation audit note: Production/main.tscn already had UID annotations and blank-line formatting at Room entry. Its normalized text matches the locked scene hash exactly; all other 138 Production resource hashes match without normalization. The historical strict audit reports this metadata difference. This Room does not rewrite Production or its baseline manifest.

Human feedback: Rob reports “the hex map shapes look solid.” Geometry appearance is accepted; this does not establish full gameplay/persistence acceptance or authorize Production promotion. Right-click contextual menu remains unimplemented and outside this Room’s delivered scope.
