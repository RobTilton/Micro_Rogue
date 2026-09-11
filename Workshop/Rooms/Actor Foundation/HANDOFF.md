# Actor Foundation — Handoff
Updated: 2026-09-11
Checkpoint: [Actor Foundation]+[Validation]+[Integration]
DOTS: [DOTS.md](DOTS.md)
Implementation baseline/evidence: [BASELINE.json](BASELINE.json) records pre-change UI Foundation sources; new Room scripts/assets are uncommitted. Only inherited code change is the board factory hook.

## State And Authority

Rob accepted the scope for static supplied-character sprites, shared actions, persistent multiple actors, scavenging, perception and turn-based cross-map pursuit, then said “execute”. Implementation and validation Boxes are delivered; Playtest awaits Rob. No Production promotion, launcher rewrite, deletion or Git checkpoint.

[Current state](CURRENT_STATE.md) describes exact ownership, action rules, timing and limits. [README](README.md) identifies main.tscn/F6. Source generation remains under UI Foundation; this scene uses actor registry/ground arrays instead of its single-enemy snapshots. [Sprite provenance](art/README.md) records tool edits and magenta-key limitation.

## Evidence

134 simulation + 17 Actor UI checks pass. Existing baseline/UI/drag/panel checks: 2,027 + 79 + 8 + 14 pass. Actual OpenGL capture inspected in tests/actor_gameplay.png. No claim of random Local population or equipment-dependent sprite rendering. Human visual/gameplay acceptance is pending.

## Next Action And Stop

Rob opens this Room's main.tscn and presses F6; review sprite appearance, selecting different enemies, equipment scavenging and an observed Dungeon-to-Local chase. Fix concrete in-scope feedback while preserving common rule ownership. Do not silently add new object types, random spawning or Production adoption.

## Transfer Validation

Prepared by Cody: source and output paths exist, current DOTS and state match, authority is evidenced, tests and capture were executed. A later receiver must check then-current references and changes before dependent execution. BASELINE.json is historical input evidence, not a claim that the edited UI board factory still matches its old hash.
