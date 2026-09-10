# starting Slice — Current State
Updated: 2026-09-10
Checkpoint: [starting Slice]+[Delivery]+[ProductionPromotion]
Implementation baseline: accepted runtime promoted to Production; no Git commit created.

## Rapid Shape

Room complete. Rob reported “everything so far works,” accepted the proof/slice and explicitly authorized Production promotion. The adopted runtime is now Production/; no gameplay remains at repository root and runtime no longer imports Workshop resources.

## Locations And Ownership

- Root `project.godot` is the only project. F5 launches the newer Workshop UI. Open Production/Gameplay/main.tscn and press F6 for this promoted slice.
- `Production/Gameplay/`: adopted scenes and game systems, with their original UID sidecars.
- `Production/Splash/splash_art.gd`: adopted art, independent of the retained prototype.
- `Workshop/Tests/StartingSlice/`: rule, gameplay-flow and inventory/cooldown tests against Production.
- `Workshop/Design/Micro_Adventure_Roguelike_Design_Doc_v0.1.md`: unchanged provisional project design, relocated from root.
- This Room's `Splash/`: retained prototype scene in the shared project, not a Production dependency.
- [Production system contract](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/MICRO_ROGUE_SLICE.md): authoritative architecture, controls, implemented rules, validation and limitations.

## Validation And Disposition

24 relocated files verified against pre-move SHA-256 values, allowing only necessary reference changes. All 11 Production resource references resolve within Production. Adopted splash art matches the retained original byte-for-byte. 2,027 rule checks, 37 inventory/cooldown checks, full flow test and root startup smoke test passed after relocation on Godot 4.4.1.

Initial startup encountered a stale Godot UID pointing to the old main script; the scene now resolves its explicit Production path and passes startup. Rob's human acceptance applies to the gameplay before relocation; migration has automated validation, not a claimed second visual acceptance.

Source moves were authorized, no content was discarded, and no Git checkpoint was created. The pre-move manifest and validation engine remain under /tmp as recorded in the system contract. Runtime outputs are adopted; prototype and tests remain in Workshop. Future iteration starts from this Production baseline in a newly scoped Room. Defense balance remains intentionally unchanged.
