# Skill Board
Updated: 2026-09-16
Checkpoint: [Skill Board]+[Validation]+[Integration]

## Runtime contract
F5 → Skills sidebar opens a radius-four board (61 hexes). Center (0,0) is reserved: wildcard family for adjacency and one chain link, never an origin. New characters have no origins. Learning the first skill in a family unlocks placement of that family's origin. At most three origins; their positions cannot be moved or cleared, including in town. Learning additional families is not forbidden, but cannot exceed the origin placement cap.

Learned, placed, and active are separate states. Every occupied cell supplies its skill family even if that skill is inactive. Mandatory rules are evaluated independently of active states, allowing mutual activation. Multi-hex footprints must fit entirely on empty board cells; moving validates before mutation. Center and origins cannot be covered. Rotation and optional reflection are supported by the evaluator; currently shipped skills use one cell.

Adjacency counts unique boundary hexes outside the evaluated footprint, not distinct neighboring skills or repeated shared edges. A rule matches any listed family; separate mandatory rules must all pass. Center matches every family.

Chain requirements use a simple path of same-family occupied hexes to that family's origin. No hex repeats, the evaluated skill's whole footprint is excluded, distinct skills count once, origin counts one, and center counts one. A longer qualifying path can satisfy the requirement even when a shorter route exists. Different evaluations can reuse the same center, skills, and edges. Exact path search stops upon finding a sufficient path; no arbitrary length cutoff. Reachability/count bounds prune impossible branches, and results cache by board/catalog/learned state. Very large cyclic custom arrangements can still make exact longest-path decisions expensive; current shipped chains require only 1–3 links.

## Entry and controls
Select a learned skill, then click its destination; Rotate changes its orientation. Select an unlocked origin, click a free hex, and confirm the permanent position. Green means active; red means unmet requirements. Hover and the skill list show reasons. First placement is available outside combat. Moving/removing existing pieces or clearing all movable pieces requires town and no combat. This is a placement respec: learned skills and spent points are retained. Origins remain fixed. Stat-point spending remains below the board.

Lunge, Riposte and Show-Off remain the implemented catalog, family Martial, cost one each, existing sequential unlock prerequisites, chain requirements 1/2/3 respectively. Their executable effects remain unchanged apart from requiring board activation. Show-Off attack allowance and Riposte defense/counter also check activation. Learned Show-Off still permits carrying an offhand sword so deactivating the skill does not invalidate saved equipment; using its extra attack requires activation. Humanoid NPCs use the same board evaluator and auto-place outside combat; they never reposition existing origins. Non-humanoids retain stat advancement.

## Ownership and persistence
- `Production/Actors/skill_board.gd`: geometry, spatial definitions, placement, evaluator, validation, deterministic NPC placement.
- `Production/Actors/actor_world.gd`: learning and legal board actions/town/combat boundaries.
- `Production/UI/skill_board_view.gd`: reusable clickable board; `actor_game.gd` supplies Skills panel and origin confirmation.
- `Production/Persistence/persistent_actor_world.gd`: validates board fields; existing actor snapshot/journal copying persists them. Normal successful UI actions checkpoint through `world_game.gd`.
- `Workshop/Rooms/Skill Author/Tool/`: editor author and multi-draft sandbox use the same Production evaluator. Production does not read Workshop.

Older saves without board fields remain valid. Their learned skills/points are retained, with no origin silently chosen for the player; place origins and skills after loading. No world regeneration is required. NPCs initialize their boards when safe. Replacement characters receive fresh blank boards; persistent world data is unchanged.

## Authoring
See [Skill Author instructions](../Skill%20Author/README.md). The tool now exports schema 2 spatial definitions: family, numeric axial footprint, required chain length, mandatory family adjacency, rotation/mirror permissions and unlock metadata. Legacy experimental fields remain stored as legacy notes but are hidden in the Inspector. Explicit `Required Chain Length` is authoritative; old chain amount/measure fields are not silently interpreted. New spell/skill prose does not become executable code. Promotion of authored effects/catalog entries remains a later implementation step, with no automatic Workshop imports or new invented effects.

## Evidence and remaining acceptance
Focused board checks, author save/load checks and real F5 integration checks pass; counts and final runs recorded in DOTS. Real game board and author sandbox screenshots retained in this Room. Validation saves are isolated under tests/; source backups under Reference/. Human playtest acceptance pending. No commits, player-save reset, ring/amulet work or asset generation.
