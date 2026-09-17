# Skill Author
Updated: 2026-09-16
Checkpoint: [Skill Board]+[Interface]+[Authoring]

Inspector skill drafting, revision-safe .tres/JSON Library exports and F6 footprint painting remain available. Schema 2 adds Required Chain Length and Adjacent Skill Tags (family names), and exports deterministic board definitions. Footprint reference is radius four. Legacy experimental fields are retained as stored notes and hidden from Inspector.

Root Test On Skill Board plus Companion Drafts runs a shared-evaluator placement sandbox in F6. It uses `Production/Actors/skill_board.gd` and `Production/UI/skill_board_view.gd`; Production never reads Workshop. Test layouts are disposable; draft definitions are saved via the Inspector's Save New Revision button. Full workflow: [README.md](README.md). Authoritative board rules: [Skill Board current state](../Skill%20Board/CURRENT_STATE.md).

Existing 54-check author suite passes for shape presets, validation, revision preservation, schema export and deep-copy resource load. Additional shared board and F5 integration tests are in Skill Board Room. No free-text effect execution or attack-animation authoring has been added. Human editing acceptance pending.
