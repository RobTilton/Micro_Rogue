# World Foundation — Current State
Updated: 2026-09-12
Checkpoint: [World Foundation]+[Validation]+[Integration]

**Accepted and promoted (2026-09-12):** Rob accepted the working game and authorized promotion. **F5 now runs [Production/main.tscn](../../../Production/main.tscn)** with independent resources and user-data saves. This Room is retained development source; its F6 behavior and source-era evidence below are preserved. See [promotion evidence](../Production%20Promotion/CURRENT_STATE.md).

Implementation baseline: accepted Actor Foundation plus UI Foundation generation; imported hierarchy design reviewed in full. Uncommitted Workshop implementation; no user Git checkpoint supplied.

## Delivered behavior

The new [main.tscn](main.tscn) composes the accepted actor prototype with a location catalogue, common ID resolver, lazy template recursion, parent geographic constraints, automatic checkpoint journals, versioned full-world save/load, explicit map unloading and atomic event POI creation. [GENERATION.md](GENERATION.md) gives the actual sequence, APIs and limits.

| Owner | Responsibility |
|---|---|
| domain/location_world.gd | Location identities, declaration/resolution, generation state, events, map archives |
| domain/topology_generator.gd | Varied new-world land masks, component identity and viable starting land |
| domain/autosave_journal.gd | Compressed append-only checkpoints and incomplete-tail recovery |
| domain/location_templates.gd | Layout, population, placement restrictions and deferred descendants |
| domain/geographic_contracts.gd | Stable seed streams, canonical neighbor profiles, inherited river routes |
| domain/map_state.gd | Map capture, structural validation and reconstruction |
| domain/persistent_actor_world.gd | Actor composition, seeded populations, snapshots and restoration |
| ui/world_game.gd | World-first startup, automatic checkpoints, Continue, travel fade, unload and event controls |

Shared changes are limited to overridable map/simulation factories in Actor Foundation and optional RNG parameters in UI Foundation actor/item creation. Existing callers keep their original behavior. Root launcher, Production, supplied tiles, actor art and imported design are preserved.

## Validation

Godot 4.4.1 Windows through WSL. Current World checks rerun 2026-09-12; inherited actor/shared baseline evidence from 2026-09-11 remains below:

- `tests/world_test.gd`: **58,454 checks, zero failures**. Lazy generation, unload/Return, no repopulation, multiple event instances, atomic unseen-parent rejection, Town/Well/Underground and seven further nesting levels, three seeds of neighbor contracts including wrap, resolved water/river boundaries, visit-order-independent map/population content, corrupt-save refusal, full snapshot equality and lazy restore. Pending weapon and cooldown included in the saved fixture.
- `tests/world_ui_test.gd`: **17 checks, zero failures**. Playable new scene, Local/Town/Well/Underground travel, event control, unload, sprites and restored UI/clock references.
- `tests/restart_test.gd`: **14 checks, zero failures**. A separate Godot process consumes the saved fixture; verifies pursuit/death/drop persistence and recursive entrance traversal.
- `tests/autosave_test.gd`: **16 checks, zero failures**. World saved before character creation, original roll retained, character joins the same Global layout, movement/turn/travel/event checkpoints, incremental state equals full state, interrupted tail recovery and Continue skipping an incomplete first checkpoint. Final measured movement including UI and disk append: 8.153 ms, 713-byte delta (single fixture, not a general performance guarantee).
- `tests/autosave_restart_test.gd`: **8 checks, zero failures**. Separate-process journal load and continued writes; existing generator-one snapshot still loads with identical Global terrain.
- `tests/topology_test.gd`: **2,721 checks, zero failures**, 32 seeds and exact repeat generation. Land-mask area 835–1,677 cells, 3–21 connected landmasses, maximum adjacent-seed land-mask Jaccard overlap 0.521. Every tested spawn has at least 80 connected land cells. Six-seed OpenGL diagnostic capture inspected: `tests/topology_variants.png`.
- Existing Actor Foundation: **134 simulation + 17 UI**, zero failures.
- Existing UI Foundation: **2,027 baseline + 79 UI + 8 drag + 14 floating-panel**, all pass.
- Actual OpenGL 1440×900 Local and Underground captures inspected: `tests/local_gameplay.png`, `tests/underground_gameplay.png`. These show rendered terrain, a nested interior, player/enemy sprites and the inherited HUD. Boundary composition is retained in `tests/boundary_proof.png` and `tests/coast_proof.png`; these depict actual generated data with diagnostic colors rather than tile art.

Tests deliberately position actors at entrances to exercise travel and persistence; they do not claim a full manual adventure playthrough. Rob accepted the source gameplay for promotion. Prior Actor Foundation acceptance remains specific to that pass.

## Limits and retained material

Default templates are small layouts with fixed per-template population counts and seeded stats/equipment. There is no quest engine, roads/factions system, automatic neighbor-edge travel, hydrological simulation, general schema migration or export-ready save storage. Equipment-changing sprites remain a stretch goal; water art is unchanged. See GENERATION.md for the logical rectangular-boundary mapping and memory/storage behavior.

All generated evidence and snapshots are retained. User automatic journals live in `saves/autosaves/`; optional snapshots and per-map unload archives live in `saves/`; validation snapshots and malformed fixtures live in `tests/saves/`. The restart pointer names the fixture written by the world test. No save deletion or Git commit occurred. The later Production promotion is recorded separately in the linked promotion Room.

## Travel fade — 2026-09-12

Rob requested a short fade to cover the felt Local-generation hitch. World Foundation now fades out for 0.12 seconds, presents an opaque frame before travel/generation, then fades in for 0.12 seconds after the map rebuild. It applies to map entrances/returns; ordinary movement stays immediate. Duplicate travel and input are blocked during the transition. Known invalid travel responds immediately. World UI: 17 checks pass on the OpenGL backend, including opacity at map change, viewport coverage, duplicate-entry blocking and overlay cleanup. Human timing/feel review pending.

## Automatic persistence and world-first startup — 2026-09-12

Generate new world now creates and checkpoints Global identity/layout and Local descriptors before character creation. Dice and their assignments are checkpointed too. Continue resumes the same world and original roll; starting the adventurer does not regenerate geography. Gameplay actions, turns, travel and event creation checkpoint automatically. A normal window close also checkpoints, and write failures are shown instead of silently abandoning progress. The manual button is now only an optional extra snapshot.

New-world topology replaces the fixed X-forming diagonal lobes with seeded, rotated and distorted influence fields and variable land coverage. Existing snapshots retain their layouts. The standalone thought file [USER_HAD_A_THOUGHT.md](../../Design/USER_HAD_A_THOUGHT.md) records volcano/earthquake ideas as explicitly **not implemented**.

Journals preserve previous records, recover an incomplete tail and start a new self-contained file on resume. They currently replay sequentially without compaction or pruning. See GENERATION.md for snapshot caching and future mutation-service requirements. Initial compression support and repeated-validation cost were corrected during validation. Earlier manual-save instructions are superseded by this automatic path.
