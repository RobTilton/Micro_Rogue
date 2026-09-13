# Actor Foundation — DOTS
Updated: 2026-09-11
Checkpoint: [Actor Foundation]+[Validation]+[Playtest]
Implementation baseline: current UI Foundation Prototype with LocalPoiSpacing; BASELINE.json records input hashes. No user Git checkpoint supplied.

## Room Contract

Rob accepted the sprite/shared-action/persistent-multiple-actor/loot-scavenging/map-pursuit scope (“yes. Perfectly”), then issued “execute”. Build a dedicated Workshop scene using existing UI and generators. Shared player/enemy movement, attacks, learned skills, potion, inventory and entrance rules. Basic sight and remembered exits; turn-based pursuit advances on travel and Local movement/wait. Existing loot/entrances are first world objects. Static supplied-character sprites, not equipment animation. Preserve original sources and Production; no deletion or commit.

## Traversal

Last completed: [Actor Foundation]+[Validation]+[Playtest]. Active implementation: none. Rob reported “No gameplay issue. love this so far.” on 2026-09-11. Current actor gameplay accepted; water art remains unsatisfactory and is outside this actor pass. Equipment-dependent sprites are explicitly a stretch goal. Next: review hierarchy alignment before new generation implementation.

| Checkpoint | Responsibility | Depends on | Completion condition | Status | Evidence |
|---|---|---|---|---|---|
| [Actor Foundation]+[Simulation]+[SharedActions] | Actor registry, costs and shared legal actions | existing combat/inventory/map contracts | player/enemy parity and refusal tests pass | complete | Current state and passing shared-action/render checks |
| [Actor Foundation]+[Simulation]+[EnemyBrain] | perception, equipment evaluation and remembered pursuit | SharedActions | multiple actors, loot and cross-map pursuit tests pass | complete | 134 simulation checks, including cross-map and equipment cases |
| [Actor Foundation]+[Presentation]+[Sprites] | source-derived static sprites and actor UI | SharedActions | actual render inspected; source files preserved | complete | Source-derived keyed atlas; actual OpenGL render inspected |
| [Actor Foundation]+[Validation]+[Integration] | player controls and composed behavior | SharedActions, EnemyBrain, Sprites | tests pass and current-state docs agree | complete | 17 Actor UI checks; 2,128 existing regression checks; docs synchronized |
| [Actor Foundation]+[Validation]+[Playtest] | Rob's visual/gameplay acceptance | Integration | human acceptance | complete | Rob: “No gameplay issue. love this so far.”; acceptance limited to this delivered actor pass |

All output retained. Earlier maps pause independently in UI Foundation; Actor Foundation explicitly changes actor scheduling for pursuit. No automatic message to Chad-Casso authorized or sent.

[Current state](CURRENT_STATE.md) · [launch guide](README.md) · [handoff](HANDOFF.md). Static keyed sprites are source-derived tool edits, not original pixel-exact cutouts. Initial checkerboard output and pursuit typed-array failure were corrected; final tests and render passed. Retain all output.

## World Foundation composition — 2026-09-11

Rob authorized all hierarchy implementation stages. Delivered in [World Foundation DOTS](../World%20Foundation/DOTS.md); this Room keeps its existing scene and acceptance scope. Shared factory/optional RNG adaptations are covered by the new Room implementation and passing actor/shared regressions. World Foundation playtest remains pending.
