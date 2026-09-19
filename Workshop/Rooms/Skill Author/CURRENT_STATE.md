# Skill Author
Updated: 2026-09-16
Checkpoint: [Skill Board]+[Interface]+[Authoring]

Inspector skill drafting, revision-safe .tres/JSON Library exports and F6 footprint painting remain available. Schema 2 adds Required Chain Length and Adjacent Skill Tags (family names), and exports deterministic board definitions. Footprint reference is radius four. Legacy experimental fields are retained as stored notes and hidden from Inspector.

Root Test On Skill Board plus Companion Drafts runs a shared-evaluator placement sandbox in F6. It uses `Production/Actors/skill_board.gd` and `Production/UI/skill_board_view.gd`; Production never reads Workshop. Test layouts are disposable; draft definitions are saved via the Inspector's Save New Revision button. Full workflow: [README.md](README.md). Authoritative board rules: [Skill Board current state](../Skill%20Board/CURRENT_STATE.md).

Existing 54-check author suite passes for shape presets, validation, revision preservation, schema export and deep-copy resource load. Additional shared board and F5 integration tests are in Skill Board Room. No free-text effect execution or attack-animation authoring has been added. Human editing acceptance pending.

## Separate shapes and damage text — 2026-09-18

Draft → Skill Board Footprint controls board occupancy only. Draft → Attack Pattern → Attack Cells stores independent axial targets, with the actor at (0,0) facing right toward (1,0). Damage Calculation is multiline design text, not executable code. Empty patterns are allowed for passive/WIP ideas; targets may be disconnected.

Select Shape Painter → Paint Layer in the Inspector to choose which shape Add/Remove edits. In F6 painter mode, use the Board footprint / Attack pattern buttons before clicking hexes. Board Test continues to use only the board footprint. Board rotation does not rotate attack data. JSON schema 3 exports `attack_pattern`, `attack_facing` and `damage_calculation` separately from `board_definition.footprint`.

Cleaving Strike `Library/axe_cleave_r002.tres` corrects the board footprint to one hex and retains its three attack targets and original notes. Damage remains unspecified. Load that revision via Load Existing Draft → Load Copy for Editing. Revision 1 is preserved. Pattern edit/export/round-trip checks passed (`tests/pattern_test.gd`). No gameplay effect or Production change was made.
