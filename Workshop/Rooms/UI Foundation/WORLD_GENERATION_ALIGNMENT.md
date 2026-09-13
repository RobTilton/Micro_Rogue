# Hierarchical World Generation — Alignment Review
Updated: 2026-09-11
Checkpoint: [UI Foundation]+[Documentation]+[HierarchyAlignment]

**World Foundation update (2026-09-11):** The hierarchy architecture is now implemented in the separate [World Foundation scene](../World%20Foundation/README.md). See its [generation reference](../World%20Foundation/GENERATION.md) and [validation](../World%20Foundation/CURRENT_STATE.md). Descriptions below of missing hierarchy features apply to the earlier UI/Actor generator, not the new scene.

Implementation baseline/evidence: existing UI Foundation generators plus the accepted Actor Foundation runtime; imported design fully read and named code owners inspected on 2026-09-11. Documentation assessment only; no generation changes or fresh runtime tests.

## Finding

**The current game follows the first part of the hierarchy, but does not yet implement the full architecture.** Global geography is built first; Local maps and POI interiors are created lazily and retained during a run. Detailed parent constraints, data-driven POI templates, recursive floors/submaps and saved-state loading/unloading are missing.

Keep the core rule in [Hierarchical_World_Gen.md](../../Design/Hierarchical_World_Gen.md): parent establishes constraints; child resolves playable detail; generated results become authoritative. A cleaner implementation can reduce special cases without changing that design. No rewrite of its intent is recommended, and the imported document is preserved unchanged.

The document lists roads, factions, quest types and many POI examples as possible content. Their absence is not itself a violation requiring every example to be built now. The architectural requirement is that the common location/constraint/template model can support such content without a different fundamental system for each type.

## Current Alignment

| Design rule | Current state | Evidence / consequence |
|---|---|---|
| Global generated first | Implemented | `map_world._init()` creates Global, continents, biomes and rivers immediately. |
| Local generated on first need | Implemented for current travel | Global links are descriptors; `resolve()` creates a Local only if its ID is absent. Actor travel uses `ensure_map()`. |
| Parent defines constraints | Partial | Local receives parent identity, biome and return location. It does not receive Global river/boundary geometry, geographic tags or connection contracts. |
| Child resolves parent geography | Partial | Local water/terrain/rivers are seeded independently. A Global river does not constrain its Local counterpart; adjacent Local coastlines/rivers need not match. |
| POIs are persistent template instances | Partial | Three stable Local links are retained, but every region has exactly Dungeon/Town/Tower; there is no reusable POI template record or per-type generation rule data. |
| Floors/submaps generated lazily and recursively | Not implemented | Every non-Local unresolved destination becomes the same 18×14 POI template. Those interiors expose only Return, not deeper child descriptors. |
| Generated state authoritative | Implemented during a run | Cached map objects and the actor registry retain mutations. Revisits do not reroll existing maps/encounters. |
| Hierarchical persistent addresses | Partial | IDs embed Local coordinates and a type suffix. Adequate for one Town/Dungeon/Tower per Local in one run; no explicit world/parent/local-instance address model. |
| Exists-but-unloaded distinct from not-generated | Not implemented | Map dictionary presence currently drives generation. There is no saved record catalogue or unload/load path. |
| Quest/event-created POIs | Not implemented | There is no request-to-place/template-instantiation boundary. This is a planned extension, not a quest system already present. |
| Actor pursuit across hierarchy | Working at current depths | Actor IDs transfer through generic entrance links, retaining gear/state. Recursive generation must preserve this boundary rather than rebuilding NPCs on entry. |

## Concrete Code Gaps

### One resolver is still specialized to two cases

[map_world.gd](Prototype/domain/map_world.gd) `resolve()` returns a cached map by ID; otherwise `kind == Local` creates a Local and everything else creates a POI rectangle. A future Floor/TownWell/DeepForest descriptor therefore has no distinct template resolution. The code does not currently create recursive child links.

A Return link identifies a destination and arrival coordinate; it is not a complete recipe for rebuilding that destination. It works because its parent map is still cached. Removing a map from the cache and later resolving it through Return would enter the creation path with an incomplete descriptor. **Do not add unloading by merely erasing cached maps.** Load/generate decisions must come from an authoritative location record, not the particular travel link used to reach it.

### Parent geography is not handed down

Global links currently include ID, label, biome, parent and return cell. They do not carry river connections. [river_generator.gd](Prototype/domain/river_generator.gd) independently selects Local outlets, including region boundaries. [local_water.gd](Prototype/domain/local_water.gd) independently chooses Local coast orientation.

The document's example of a river entering/exiting a Global cell is conceptual. Current rivers lie on **shared hex edges and vertices**. The implementation must explicitly translate that representation into child boundary constraints; inventing independent entrance points for each child would introduce mismatches. A canonical parent edge/vertex identity should own shared boundary information. Variable Local dimensions then map agreed boundary positions into their own hex coordinates. Decide that mapping before changing river routing.

### POI identity, placement and generation are intertwined

Local generation first installs three fixed-type links, water generation may relocate them or reserve the island Tower, and final spacing moves them across dry land. This works for the current three destinations, but is not a template system. When templates specify terrain/river restrictions, complete the relevant geography first and then resolve placement against it. Preserve the lake-island intent as a reserved feature/anchor rather than requiring water generation to mutate a specific POI's link.

A POI instance ID should remain stable if its entrance is moved. Multiple instances of the same template need different IDs; type names such as `Town` are not instance identities. A template can instantiate the current fixed rectangle initially—introducing template ownership does not require a complete dungeon generator in the same change.

### Runtime persistence has multiple owners

[Actor Foundation actor_world.gd](../Actor%20Foundation/domain/actor_world.gd) owns live actors, per-map ground and initialization flags. UI Foundation's MapWorld owns map geometry/links; its older `states` dictionary belongs to the earlier single-enemy scene and is not the active actor scene's save model.

A future location record must preserve geometry/links, ground, actor location/identity and population-initialization state coherently. Actor clocks currently contain RefCounted objects; serialize their numeric state explicitly instead of attempting to dump runtime dictionaries unchanged. Losing an initialization flag could duplicate residents; losing actor placement could duplicate a pursuer across maps. Unloading a view, saving a location and deciding which actors get turns are separate operations.

## Proposed Small Common Model

This is a proposed implementation shape, not existing classes or approved code changes.

| Record / service | Minimum responsibility |
|---|---|
| World record | Unique world ID, root seed, schema/generator versions and location catalogue. A seed is reproducibility input, not sufficient identity for two separate saves using the same seed. |
| Location record | Stable ID/address, parent ID, role, template ID, generation seed, parent constraints, generation state and reference to resolved state. POI instance IDs remain independent of display labels and entrance coordinates. |
| Entrance link | Source location/cell → target location/entrance. Navigation references a target record; it does not contain or choose that target's generation algorithm. |
| Template | Placement restrictions, layout/population rules and declarations for child locations. Initially wrap current Local and fixed-POI generators; add template variety incrementally. |
| Location resolver/store | `ensure_location(id)`: use active state if present; load previously generated state if unloaded; otherwise generate from the location record, validate constraints, then register the result. |

A location record can represent a POI before its first playable map is resolved. Its first interior can be a child location (for example `entry`) when that distinction is useful; do not require an extra empty playable floor merely to fit a diagram. Every playable submap uses the same location/entrance relationship, at any depth. Global cell metadata can stay inside the Global map; it need not become its own loaded scene.

Example stable address: `world/<world-id>/global/12,7/local/poi/<instance-id>/entry/child/<instance-id>`. This is illustrative; exact serialization belongs to the implementation contract. Use explicit structured identity and a documented seed derivation, with separate streams for terrain, placement and initial population. Runtime activity must not consume another location's generation randomness.

Track two separate facts:

- **Generation:** declared but unresolved, or generated with authoritative state.
- **Residency/activity:** loaded, unloaded, and eligible for simulation. Unloaded does not mean never generated; loaded does not mean every NPC must act.

Resolved data wins over seeds/templates on revisits. Store schema/generator version information so code changes do not silently regenerate visited places. Prototype save snapshots are a sensible first persistence implementation; streaming/chunk timeout policy can come later.

## Recommended Implementation Order

1. **Location identity and resolver:** introduce the catalogue and shared resolution boundary around the existing generators. Preserve current map sizes, POI spacing, actor identities and existing action/travel behavior. Initially all state may remain in memory, explicitly labeled as such.
2. **Template instances and recursion:** replace type-suffix assumptions with stable POI instance IDs and small templates. Add a two-level Dungeon plus a Town→Well child as proofs of the same recursive mechanism. Spawn initial occupants from the resolved template once, not from the incoming link's `kind`.
3. **Parent geography contracts:** define canonical shared boundary information and hand it into Local generation. Prove one Global/Local river connection and matching adjacent Local boundaries before expanding roads or geographic tags.
4. **Durable state:** save/load the catalogue and resolved location/actor/ground state together. Prove unload/reload and application restart with a relocated pursuer, defeated enemy, collected item and existing child maps. Do not build an eviction scheduler before correct reload exists.
5. **External POI requests:** expose one request-to-place boundary for later events/quests. Validate placement and reserve a stable instance ID; create its playable children only on need. A rejected request must leave the existing world unchanged.

These are bounded stages, not a request to implement every content example at once. Ordering can put durable storage before the geographic proof if reliable saves become the immediate priority; identity/resolution must come first either way.

## Required Acceptance Evidence For Future Work

- Revisiting a location never rerolls its resolved map or repopulates a defeated encounter.
- Two POIs of one template have distinct identities and persistent states.
- Entering a deeper floor creates only that floor, not all siblings or descendants.
- A Town→Well→Underground map uses the same resolver as Dungeon→Floor2.
- A previously generated target reached through Return reloads from its own record.
- Different visit orders preserve the same generated geography/initial population for the same descriptors and seed policy.
- Parent river constraints and neighboring child boundary endpoints agree in data and a composed visual proof.
- Saving, unloading and loading preserve actor identity, HP, inventory, cooldowns, ground ownership and population flags without duplication.
- A pursuer can cross a recursive entrance through the same legal action service, once per world turn.

## Disposition

Read all 672 lines of the imported design. Compared active MapWorld, Local water/terrain/POI placement, Global/Local river routing and ActorWorld resolution/initialization/travel/scheduling. No runtime behavior changed or new tests executed for this assessment. Imported design preserved. Current actor gameplay acceptance is recorded separately; it does not imply acceptance of missing hierarchy features or water art.

Next proposed implementation boundary is stage 1, then the small recursive proofs. This review supplies the concrete gaps and preservation contract for that alignment; it does not claim the game already follows the full hierarchy.
