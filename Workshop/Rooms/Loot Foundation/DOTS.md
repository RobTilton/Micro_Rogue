# Loot Foundation — DOTS
Updated: 2026-09-12
Checkpoint: [Loot Foundation]+[Catalog]+[Definitions]

Authority: Rob requested capturing the supplied tables, then starting the loot system with easy entry for rings and affix layers. Scope: Workshop catalog, single-material generator, tests and documentation. Production adoption is separate; no changes to existing saves, actor equipment slots or combat. No commit or deletion.

Baseline: Production/Actors/items.gd supplies the legacy item dictionary; Production/Actors/inventory.gd supports main/off/body/belt only. Exact copies are retained in Reference. No user Git checkpoint supplied.

| Box | Depends on | Acceptance | Status |
|---|---|---|---|
| [Loot Foundation]+[Catalog]+[Definitions] | user tables | exact material, quality and 160 base-type entries in readable and machine-readable form | complete |
| [Loot Foundation]+[Generation]+[SingleMaterial] | Definitions | deterministic item rolls, quality weights, belt rule, extension entry points | complete |
| [Loot Foundation]+[Validation]+[Delivery] | SingleMaterial | automated contract checks and current-state handoff | complete |

Unresolved balance formulas are explicitly deferred. Base selection/material selection defaults are test policy, not approved progression. Human acceptance pending. Retain all Room outputs; no Production adoption in this step.

Last completed: [Loot Foundation]+[Validation]+[Delivery]. All three Boxes complete. Validation: 690 Godot headless checks passed; exact catalog counts and extension fixtures included. See CURRENT_STATE.md for API, defaults and Production compatibility boundaries. No active Box; next work is user-directed runtime integration/balancing. Human acceptance pending. All outputs retained in this Room.
