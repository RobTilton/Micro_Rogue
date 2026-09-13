# Momentum Foundation — DOTS
Updated: 2026-09-12
Checkpoint: [Momentum Foundation]+[Actors]+[Scheduler]

Rob accepted persistent per-actor momentum, base action set for the first grant and one flexible action per extra grant. Speed derives from DEX plus effects; threshold is 3 for testing. Implement the shared game action/scheduling path, save compatibility, HUD and tests. No item-generation changes, new items, real-time conversion or commit. Existing Production gameplay is the integration target; preserve changed-file reference copies. One-save lifecycle remains unchanged.

| Box | Dependency | Acceptance | Status |
|---|---|---|---|
| [Momentum Foundation]+[Actors]+[Scheduler] | approved rules | same threshold/remainders/grants/effects for all living actors | complete |
| [Momentum Foundation]+[Actors]+[Actions] | Scheduler | flexible actions usable through all paid action gates, AI and UI | complete |
| [Momentum Foundation]+[Persistence]+[Integration] | Actions | save migration, restart, rendering and capability tests | complete |

Starting baseline: Production/BASELINE.json; no user Git checkpoint. Runtime edits are limited to actor rules, scheduling, dependent UI/persistence and their current-state references. Source baselines preserved under Reference/. Items remain Rob's active design work.

Implementation and headless validation complete: 28 scheduler/action checks and 13 Production/save integration checks pass. See CURRENT_STATE.md for behavior, hooks and limits. Rendered Production integration also passed all 13 checks (OpenGL); human acceptance pending. Baseline audited: changed runtime files stay within Actors/UI/Persistence; item generation, world generation and artwork hashes unchanged; no runtime Workshop dependency.
