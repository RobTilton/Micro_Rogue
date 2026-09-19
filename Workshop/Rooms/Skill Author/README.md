# Skill Author — Quick Start
Updated: 2026-09-16
Checkpoint: [Skill Board]+[Interface]+[Authoring]

Open `res://Workshop/Rooms/Skill Author/Tool/SkillAuthor.tscn`, select **SkillAuthor**, switch to **2D**, expand **Draft** in the Inspector. No plugin required. F5 runs Production; F6 runs this tool.

1. Enter **Display Name**, lowercase **Skill ID**, **Skill Bucket** (the skill family), and **Skill Kind**. Use Custom plus Custom Bucket for other families.
2. Under **Footprint**, choose a preset or custom connected cells. Most skills use Single hex. Rotation Steps previews six orientations. Root **Cell To Edit** and **Add/Remove Hex at q,r** edit custom shapes. The reference grid is now radius four. Footprint means board occupancy, not attack coverage.
3. Enter unlock prerequisites and point cost. Unresolved design can still go in notes.
4. Under **Origin and Chain**, set **Required Chain Length**. Zero adds no chain-length requirement. Origin counts one; the skill itself is excluded; each other distinct skill counts once regardless of footprint. The wildcard center adds one. A valid path must reach the same-family origin without reusing any hex.
5. Click root **Add Adjacency Rule**, expand Draft → Adjacency → Adjacency Rules → its resource. Set **Minimum** and **Adjacent Skill Tags** (family names). Each matching neighbor hex counts once; a large neighboring skill may supply several. Any listed family matches that rule. Separate mandatory rules must all pass. Empty family list defaults to the draft's own family. Optional-bonus rules remain authored ideas, not activation gates.
6. Write **Effect Description** and optional notes. Click root **Save New Revision**. Status reports the paths.

Files go into `Library/`: matching `skill_id_r001.tres` (editable resource) and `.json` (readable review/export). Each save increments revision and preserves previous files. Saving the scene alone does not export a Library skill. To revise, choose its .tres in **Load Path**, then **Load Copy for Editing**. Save before using New Blank Skill.

## Test several skills on the board
After naming and saving your draft, enable root **Board Test → Test On Skill Board**. Add other saved .tres resources to **Companion Drafts**. Save the scene to pass Inspector changes into the F6 run, then press **F6**.

Select a family origin button and click a free hex. Select a skill button and click its position. Rotate changes the footprint; Remove Selected returns it to the test pool. Green means active; red means unmet requirements. The status lists every test skill and its reason. All placed skills contribute their family even when inactive. Center is free for every family. There are at most three permanent origins; **Reset Sandbox** intentionally starts an entirely fresh test board.

Sandbox arrangements are disposable and do not save into the character or Library. Edit/save skill definitions in the Inspector, then restart F6 to test changes. Invalid drafts are excluded; missing name/effect and disconnected shapes must be fixed first. Duplicate IDs represent the same skill (the current Draft overrides a companion with the same ID).

Disable Test On Skill Board for the original F6 click-to-paint footprint preview. Click **Save New Revision** inside that preview to retain runtime painting, then load that .tres into the Inspector.

## What this does not do
Effects are still prose for implementation, not executable skills. Attack coverage/animations/projectile settings are separate future fields. The author exports deterministic spatial data for promotion; Production does not automatically import Workshop drafts. Old experimental tag/chain/count selectors are retained in resource legacy notes, not used instead of the settled family/hex/chain rules.

## Separate shapes and damage text — 2026-09-18

Draft → Skill Board Footprint controls board occupancy only. Draft → Attack Pattern → Attack Cells stores independent axial targets, with the actor at (0,0) facing right toward (1,0). Damage Calculation is multiline design text, not executable code. Empty patterns are allowed for passive/WIP ideas; targets may be disconnected.

Select Shape Painter → Paint Layer in the Inspector to choose which shape Add/Remove edits. In F6 painter mode, use the Board footprint / Attack pattern buttons before clicking hexes. Board Test continues to use only the board footprint. Board rotation does not rotate attack data. JSON schema 3 exports `attack_pattern`, `attack_facing` and `damage_calculation` separately from `board_definition.footprint`.

Cleaving Strike `Library/axe_cleave_r002.tres` corrects the board footprint to one hex and retains its three attack targets and original notes. Damage remains unspecified. Load that revision via Load Existing Draft → Load Copy for Editing. Revision 1 is preserved. Pattern edit/export/round-trip checks passed (`tests/pattern_test.gd`). No gameplay effect or Production change was made.
