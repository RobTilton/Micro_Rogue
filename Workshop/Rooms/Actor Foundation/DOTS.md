# Actor Foundation — DOTS
Updated: 2026-09-11
Checkpoint: [Actor Foundation]+[Simulation]+[SharedActions]
Implementation baseline: current UI Foundation Prototype with LocalPoiSpacing; BASELINE.json records input hashes. No user Git checkpoint supplied.

## Room Contract

Rob accepted the sprite/shared-action/persistent-multiple-actor/loot-scavenging/map-pursuit scope (“yes. Perfectly”), then issued “execute”. Build a dedicated Workshop scene using existing UI and generators. Shared player/enemy movement, attacks, learned skills, potion, inventory and entrance rules. Basic sight and remembered exits; turn-based pursuit advances on travel and Local movement/wait. Existing loot/entrances are first world objects. Static supplied-character sprites, not equipment animation. Preserve original sources and Production; no deletion or commit.

## Traversal

Last completed: [Actor Foundation]+[Validation]+[Integration]. Active implementation: none. [Actor Foundation]+[Validation]+[Playtest] awaits Rob. Next: open main.tscn/F6 and review gameplay and sprites. Human acceptance pending.

| Checkpoint | Responsibility | Depends on | Completion condition | Status | Evidence |
|---|---|---|---|---|---|
| [Actor Foundation]+[Simulation]+[SharedActions] | Actor registry, costs and shared legal actions | existing combat/inventory/map contracts | player/enemy parity and refusal tests pass | complete | Current state and passing shared-action/render checks |
| [Actor Foundation]+[Simulation]+[EnemyBrain] | perception, equipment evaluation and remembered pursuit | SharedActions | multiple actors, loot and cross-map pursuit tests pass | complete | 134 simulation checks, including cross-map and equipment cases |
| [Actor Foundation]+[Presentation]+[Sprites] | source-derived static sprites and actor UI | SharedActions | actual render inspected; source files preserved | complete | Source-derived keyed atlas; actual OpenGL render inspected |
| [Actor Foundation]+[Validation]+[Integration] | player controls and composed behavior | SharedActions, EnemyBrain, Sprites | tests pass and current-state docs agree | complete | 17 Actor UI checks; 2,128 existing regression checks; docs synchronized |
| [Actor Foundation]+[Validation]+[Playtest] | Rob's visual/gameplay acceptance | Integration | human acceptance | awaiting_validation | Rob review pending |

All output retained. Earlier maps pause independently in UI Foundation; Actor Foundation explicitly changes actor scheduling for pursuit. No automatic message to Chad-Casso authorized or sent.

[Current state](CURRENT_STATE.md) · [launch guide](README.md) · [handoff](HANDOFF.md). Static keyed sprites are source-derived tool edits, not original pixel-exact cutouts. Initial checkerboard output and pursuit typed-array failure were corrected; final tests and render passed. Retain all output.
