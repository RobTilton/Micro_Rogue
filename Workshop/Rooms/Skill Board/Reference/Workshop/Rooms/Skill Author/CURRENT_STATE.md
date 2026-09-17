# Skill Author
Updated: 2026-09-14
Checkpoint: [Skill Author]+[Validation]+[Inspector Authoring]

Workshop-only authoring tool, independent of Production and project/plugin configuration. Open Tool/SkillAuthor.tscn, select SkillAuthor and expand Draft in Godot's Inspector. Detailed controls: [README.md](README.md).

Schema captures identity, tree/bucket and tags; skill kind/origin; preset or custom connected axial footprint, rotation and mirror permission; unlock skill IDs and all/any policy, cost and bucket investment; origin/chain criteria; multiple mandatory/optional adjacency rules with counting interpretation; free-text effects, bonuses, balance notes and open questions. Unresolved WIP semantics can remain Undecided. This is idea capture, not a board evaluator or effect executor.

Tool scripts use native Godot 4.4 @tool and @export_tool_button support. skill_draft.gd and adjacency_rule.gd are resource schemas; skill_author.gd owns preview, custom-shape helpers and persistence. No class registration/plugin setup is required. Optional F6 preview supports clicking hexes and saving the resulting custom shape; editing fields normally happens in the Inspector.

Save creates a deep-copied `.tres` and readable JSON under Library, with an incremented revision suffix. Previous files are never overwritten. Resource loading uses an independent editable copy. Draft validation refuses empty identity/effect (origins may have no effect text), unsafe IDs, missing custom bucket, empty/disconnected/duplicate-cell footprints and null adjacency rules. Referenced prerequisite IDs may remain unresolved for bulk ideation. JSON contains resolved rotated axial cells; resource retains authoring presets/custom coordinates. No arbitrary effect code is run. Output is contained to this Room. Failed secondary JSON exports retain/report the saved resource.

Validation: 54 checks passed: seven shape presets across six rotations, custom connectivity/duplicates, schema export, resource and JSON round-trip, nested adjacency/prerequisites/effects, independent editing, revision preservation, output containment and native Inspector tool-button metadata. Rendered preview inspected at tests/author_preview.png. Godot editor initial scan compiled tool scripts successfully. Existing unrelated duplicate-UID warning for Regional Release reference/main scene observed; no changes made to those files. Human inspector authoring acceptance pending. Test drafts and artifacts retained separately from Library. No Production changes, commits or deletes.
