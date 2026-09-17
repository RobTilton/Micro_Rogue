# Skill Board DOTS
Updated: 2026-09-16
Checkpoint: [Skill Board]+[Validation]+[Integration]

## Authority and scope
User explicitly requested implementing the settled board in the game through the side menu, plus authoring support. Outcome: radius-four board, at most three permanent family origins, wildcard center, neighbor-hex requirements and distinct-skill chains; shared player/NPC rules. Production Actors/Persistence/UI and Workshop Skill Author changes authorized. Ring/amulet work excluded. No commits, player-save reset or unrelated changes. Existing modified workspace retained.

Starting evidence: current Skill Author and Production learning/combat paths read directly. Exact touched originals retained under Reference/, including pre-existing uncommitted work. Git checkpoint unknown. Relevant rules in CURRENT_STATE.md; author workflow in ../Skill Author/README.md.

## Boxes
- [Skill Board]+[Runtime]+[Placement]: complete. Shared geometry, immutable origins, atomic footprint placement, active evaluator, learning/combat gating, safe NPC auto-placement and save validation. Focused board_test.gd: 40 checks passed, including mutual activation, multi-hex adjacency, longer paths, distinct-skill counting, combat bonuses, malformed data and legacy missing-board handling.
- [Skill Board]+[Interface]+[Authoring]: complete for agent delivery, dependent on Placement. F5 Skills board, origin confirmation, selectable placements and town controls; schema 2 Inspector fields, radius-four footprint grid and F6 companion-draft sandbox. Existing author suite: 54 checks passed. Game board and author sandbox rendered and visually inspected (board.png, author_board.png). Required scripts compile through these executions; human interaction acceptance remains pending.
- [Skill Board]+[Validation]+[Integration]: complete for agent delivery, dependent on the two implemented Boxes. integration_test.gd: 20 checks passed using actual Production main scene, isolated saves, origin permanence, active chains, town rearrangement, board roundtrip, old-save eligibility and inactive-skill carried-equipment validity. git diff --check passed for edited tracked code. Runtime imports remain Production-only. Baseline and current docs synchronized.

Last completed: [Skill Board]+[Validation]+[Integration]. No active implementation Box. Next: human F5 and author F6 playtest. Delivery complete; human acceptance/adoption pending, not asserted.

## Limits and retained outputs
Runtime catalog is still the three implemented skills; authored effect prose needs later effect implementation/promotion. Attack coverage/animations and jewelry remain out of scope. Exact simple-path search is cached and pruned, but very dense custom cyclic boards can be costly. Town respec rearranges placements without refunding learned points; origins never reset on the same character. Old learned skills are retained but player origins are not auto-chosen.

Retain runtime scripts, Workshop tools, this Room's tests/screenshots/source backups and isolated tests/ saves. Existing unrelated Regional Release duplicate-main UID warning was observed during editor startup, not introduced or fixed here. No blanket project-warning-free claim.
