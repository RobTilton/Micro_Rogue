# Actor Foundation — Handoff
Updated: 2026-09-11
Checkpoint: [Actor Foundation]+[Validation]+[Integration]

**World Foundation handoff (2026-09-11):** Hierarchical generation, recursive templates, saves and event POIs now run in [World Foundation](../World%20Foundation/README.md), composed with this accepted actor system. This scene retains its original generator. Map/simulation factory hooks and optional seeded actor/item generation support the new composition; actor 134/UI 17 and shared regression checks pass after those changes.

DOTS: [DOTS.md](DOTS.md)
Implementation baseline/evidence: [BASELINE.json](BASELINE.json) records pre-change UI Foundation sources; new Room scripts/assets are uncommitted. The original actor pass added a board factory hook; later World Foundation composition adds map/simulation factory hooks and optional actor/item RNG inputs.

## State And Authority

Rob accepted the scope for static supplied-character sprites, shared actions, persistent multiple actors, scavenging, perception and turn-based cross-map pursuit, then said “execute”. Implementation, validation and Playtest are complete for this actor pass; Rob reported no gameplay issues and approval on 2026-09-11. No Production promotion, launcher rewrite, deletion or Git checkpoint.

[Current state](CURRENT_STATE.md) describes exact ownership, action rules, timing and limits. [README](README.md) identifies main.tscn/F6. Source generation remains under UI Foundation; this scene uses actor registry/ground arrays instead of its single-enemy snapshots. [Sprite provenance](art/README.md) records tool edits and magenta-key limitation.

## Evidence

134 simulation + 17 Actor UI checks pass. Existing baseline/UI/drag/panel checks: 2,027 + 79 + 8 + 14 pass. Actual OpenGL capture inspected in tests/actor_gameplay.png. No claim of random Local population or equipment-dependent sprite rendering. Rob accepted the current actor pass on 2026-09-11; this does not accept water art or unimplemented features.

## Next Action And Stop

The current actor pass has human acceptance. Review the hierarchy assessment linked from current state before further generation work; preserve shared rule ownership and persistent actor identity. Do not silently add new object types, random spawning or Production adoption.

## Transfer Validation

Prepared by Cody: source and output paths exist, current DOTS and state match, authority is evidenced, tests and capture were executed. A later receiver must check then-current references and changes before dependent execution. BASELINE.json is historical input evidence, not a claim that the edited UI board factory still matches its old hash.

Hierarchy alignment review: [World Generation Alignment](../UI%20Foundation/WORLD_GENERATION_ALIGNMENT.md). This is a design/code assessment, not an implemented generator migration. Equipment-dependent sprites are an explicit stretch goal; static actor sprites satisfy the current pass.
