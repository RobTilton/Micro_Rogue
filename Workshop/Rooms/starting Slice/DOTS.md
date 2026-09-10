# starting Slice — DOTS
Updated: 2026-09-09

## Room Contract

- Room: starting Slice
- Outcome: Accepted modular splash, character creation, hex combat, skills, inventory, cooldowns, XP and loot proof; adopted into Production with a documented Workshop split.
- Scope: Production runtime, root Godot launcher, Workshop tests/design/docs and necessary reference updates. Preserve standalone splash and source content. No Git commits or deletion.
- Acceptance: Rob's gameplay acceptance; relocated code retains behavior, runtime references stay inside Production, tests/startup pass, current documents synchronized.
- Authority: Initial gameplay alignment received “Confirmed. Execute.” Inventory/cooldown follow-ups were directly requested. Rob subsequently reported “everything so far works” and requested moving the slice to Production and documenting the split.
- Baseline: Accepted uncommitted slice formerly in root gameplay/ and tests/. Production initially empty. Git checkpoint unknown; none created.

## Current Traversal

- Last completed checkpoint: [starting Slice]+[Delivery]+[ProductionPromotion]
- Active/interrupted checkpoint: none
- Next eligible action: none for this Room; new scoped iteration from the adopted Production baseline.
- Human acceptance: Gameplay proof accepted by Rob; relocation validated automatically. No claim of a second post-move visual acceptance.
- Git checkpoint: Human-controlled; none created.

## Mandatory Box List

| Checkpoint | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| [starting Slice]+[Splash]+[Prototype] | Isolated splash | none | Works with visual confirmation | complete | Retained Splash/; Rob confirmed |
| [starting Slice]+[Gameplay]+[Implementation] | Modular playable slice | Splash Prototype | Implementation and headless checks pass | complete | Adopted Production/Gameplay/; 2,027 rule checks and flow test |
| [starting Slice]+[Gameplay]+[InventoryCooldowns] | Ground ownership, belt removal and cooldowns | Gameplay Implementation | Focused checks and updated state | complete | Adopted Production code; 37 regression checks |
| [starting Slice]+[Gameplay]+[Playtest] | Human visual and gameplay validation | Gameplay InventoryCooldowns | Rob accepts proof/slice | complete | Rob: “everything so far works”; screenshots and promotion request |
| [starting Slice]+[Delivery]+[ProductionPromotion] | Runtime adoption and ownership split | Gameplay Playtest | Reference closure, relocated tests/startup and docs pass | complete | 24 preserved files; 11 internal runtime refs; 2,064 checks, flow/startup pass |

## Current References And Disposition

- [Current state](CURRENT_STATE.md): final paths, preservation evidence and Room disposition.
- [Production system contract](../../AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/MICRO_ROGUE_SLICE.md): runtime ownership, controls, rules and limits.
- [Provisional project design](../../Design/Micro_Adventure_Roguelike_Design_Doc_v0.1.md): unchanged content, relocated into Workshop.
- Runtime adopted into Production; tests moved to Workshop/Tests/StartingSlice; root launcher/setup retained. Original splash prototype retained in Room. No duplicate active runtime in Workshop.
- Defense and progression remain slice balance, not a finished game. Future maps, affixes, spells and Wisdom cooldown scaling remain deferred.
- No remaining agent implementation work for this Room. No source content discarded or Git checkpoint created.
