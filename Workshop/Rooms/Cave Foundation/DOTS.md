# Cave Foundation — DOTS
Updated: 2026-09-13
Checkpoint: [Cave Foundation]+[Generation]+[Topology]

Rob requested implementing Caves from his diagram: caverns are rooms, passageways connect them, and no dead-end branch extends beyond one room off the main route. Scope: deterministic Cave POI generation, room/corridor metadata, room-owned existing monsters and loose loot, Local discovery, persistence and tests. Dungeon/Tower generation, chests, new enemy classes and artwork are deferred. Production integration authorized. No world reset or commit.

Baseline: Production/BASELINE.json and changed-file originals in Reference. Existing generated locations remain unchanged. Main loop with optional shortcut; zero to two direct side rooms; irregular hex caverns and narrow passages. Source writes need sandbox escalation because lowercase writable path resolves to differently capitalized Windows path.

| Box | Dependency | Acceptance | Status |
|---|---|---|---|
| [Cave Foundation]+[Generation]+[Topology] | user diagram | main loop and side leaves one room deep | complete |
| [Cave Foundation]+[Runtime]+[Persistence] | Topology | caves discoverable, contents durable, old saves compatible | complete |
| [Cave Foundation]+[Validation]+[Delivery] | Persistence | seed sweep and UI/save exercise | complete |

Human playtest pending. Retain originals and isolated test saves.

Last completed: [Cave Foundation]+[Validation]+[Delivery]. 493 topology checks over 40 seeds passed; actual Cave discovery/travel/content/save/re-entry tested in rendered Production. Event discovery follow-up passed 13 checks. Source/geometry and content boundaries recorded in CURRENT_STATE.md. All artifacts retained; human playtest pending.

Closeout: runtime scope and Production independence audited; existing art, combat/equipment and Dungeon/Tower generator code paths preserved. Baseline updated. Equipment/save regression passed 14 checks. No reset or commit.

Final Cave integration run passed 17 checks, including rejection of missing Cave topology. Whole-tree whitespace check reports CRLF/trailing whitespace in the unrelated imported Workshop/Design/Hierarchical_World_Gen.md; that file was not changed by this task.
