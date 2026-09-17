# Playtest Refinement
Updated: 2026-09-15

Outcome: implement Playtest_Findings.md and direct user clarifications in live Production.
Authority: user requested the playtest pass, answered gold/STR/discovery decisions, and requested effect-adjustable WIS sight and immediate hostile detection combat.
Boundary: Production runtime and relevant Workshop documentation/tests. Preserve saves, assets and prior scripts. No commits or save resets. Boss starting quality floor remains TBD.
Starting evidence: Adventure Loop — Controls Help baseline; uncommitted workspace retained.

Boxes (checkpoint prefix [Playtest Refinement]):
- [Rules]+[Economy]: complete; STR, tooltip values, accepted quests, consumables, gold/rarity. Validate formulas/save compatibility.
- [Perception]+[Fog]: awaiting_validation; effect-adjustable WIS sight, world-persistent observed memory, map/minimap visibility, immediate detection combat. Validate LOS, effects, persistence/presentation.
- [Simulation]+[Exploration]: complete; idle exploration/concentrated room loot; depends on Perception. Validate targeting/seeded population.
- [Validation]+[Integration]: awaiting_validation; depends on implementation boxes. Focused/regression checks and baseline/current state.

Last completed: [Playtest Refinement]+[Simulation]+[Exploration]. No active implementation Box. Next: human fog/detection/loot playtest. Awaiting_validation marks human presentation acceptance, not failed automated checks.

Outputs: live Production runtime; CURRENT_STATE.md; refinement_test.gd (39 checks passed); integration_test.gd (63 checks passed); fog_visual.gd and inspected fog.png. Scope-specific whitespace check passed. Regression assertions updated in a retained Room copy for the newly approved gold formula. Original historical tests preserved.

Human acceptance pending. No commits or player-save resets. Reference originals, helper tests and isolated test saves retained. Production/BASELINE.json, Production/README.md and Workshop/TODO.md synchronized. Deferred: boss starting quality floor, richer NPC exploration and performance profiling. See CURRENT_STATE.md for ownership, limits and next steps.
