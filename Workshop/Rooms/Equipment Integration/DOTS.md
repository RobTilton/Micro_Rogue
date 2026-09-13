# Equipment Integration — DOTS
Updated: 2026-09-13
Checkpoint: [Equipment Integration]+[Rules]+[Catalog]

Rob authorized implementation of the supplied loot/combat rules. Scope: adopt the Loot Foundation catalog into Production, implement weapon/armor values, fixed matching defense with zero minimum and no miss roll, archetype stat scaling, handedness, shared armor slots, AI/UI/persistence integration. Preserve old item records. No affix effects, Titanic Strength, new skills, class/progression formulas or world reset. Ranged defaults explicitly approved. Rob specified chest 100%, head/shield 50%, arms/legs 25% contributions. Shield pre-slot balanced baseline remains a stated provisional assumption.

Baseline: Production/BASELINE.json and changed-file originals in Reference. No user Git checkpoint. Existing Loot Foundation provides catalog and tested generator.

| Box | Dependency | Acceptance | Status |
|---|---|---|---|
| [Equipment Integration]+[Rules]+[Catalog] | supplied tables | all 56 weapons and armor formulas resolved | complete |
| [Equipment Integration]+[Runtime]+[Equipment] | Catalog | shared combat, slots, hands, UI and persisted loot | complete |
| [Equipment Integration]+[Validation]+[Delivery] | Equipment | formula/action/save tests and current-state documentation | complete |

Human playtest pending. Retain reference files and test artifacts. No deletion or commit.

Last completed: [Equipment Integration]+[Validation]+[Delivery]. Formula tests 193, action tests 12, rendered Production tests 14, momentum tests 28 and existing momentum integration 13 passed. Current rules and boundaries are in RULES.md and CURRENT_STATE.md. Runtime adopted into Production; all references and isolated test saves retained. No active Box; human playtest/balance acceptance pending.
