# MCA Room And Documentation Contract
Updated: 2026-09-09

## Rapid Shape

Each execution Room has one `DOTS.md`: the mandatory Box list and authoritative traversal record. Current-state references describe the result. Together they establish where work stands and what can happen next. The [shared contract](.AGENTS.md) governs permission.

Flow: establish Room contract and DOTS -> complete bounded Boxes -> synchronize references at each Box -> validate composition at Table/Room closeout -> report for human acceptance and checkpointing.

## Room Entry

For a new Room, establish the approved outcome, scope, prohibited territory, acceptance conditions, starting-state evidence, relevant references, and required dependencies. Use a clean task directory under `Workshop/Rooms/`. Do not populate it with unrelated history or duplicate entire systems without need.

After execution approval, create DOTS before implementation. Internal Box planning and necessary within-scope revisions belong to the agent. Record dependencies explicitly; do not assume list order alone proves a dependency. Keep approved boundaries stable while resolving routine mechanics independently.

## DOTS Contract

Use [the DOTS template](Templates/DOTS_TEMPLATE.md). Record:

- Room identity and approved outcome, scope, exclusions, acceptance, and authorization evidence.
- Starting-state reference: user-supplied Git checkpoint or other exact available evidence. Record unknown values as unknown; never invent a commit.
- Every Table and Box, its unique checkpoint, responsibility, dependencies, completion condition, status, outputs, and validation evidence.
- Last completed checkpoint, any active/interrupted checkpoint, and next eligible Box or terminal state.
- Current unresolved issues, human validation/acceptance status, and retained output disposition.

Checkpoint spelling is `[Room]+[Table]+[Box]`, using stable descriptive identifiers. Do not recycle an identifier for different work. A checkpoint is a traversal identity, not a Git commit; Rob controls Git checkpoints. Multiple independent Boxes may complete, so the full list and dependency state remain authoritative, not just the last-completed field.

Statuses: `planned`, `active`, `awaiting_validation`, `complete`, `blocked`, `superseded`. Use `blocked` for a concrete unavailable dependency or decision; identify it. `superseded` identifies a Box no longer needed in the current plan, without retaining its design history. A failed Box does not erase independently valid completed outputs.

Mark complete only when the Box's stated completion condition is met, its required checks have demonstrably executed, and affected references are synchronized. Pending required human visual validation means `awaiting_validation`, not complete. Keep agent delivery and human adoption separate.

## Current-State Document Format

Every newly created or updated active MCA document has `Updated: YYYY-MM-DD` immediately below its title. This date records the actual edit date, not an assertion that runtime behavior was freshly verified. Keep filenames stable. Do not touch unrelated legacy documents merely to stamp a date or claim migration/validation.

Task/system state documents additionally identify their applicable `Checkpoint: [Room]+[Table]+[Box]` near the top and the known implementation baseline or evidence. Shared policy/index documents may span Rooms and need only their date; record their task linkage in DOTS. Unchanged dependencies retain their existing checkpoint rather than falsely acquiring a new validation date.

Use [the current-state template](Templates/CURRENT_STATE_TEMPLATE.md):

1. Rapid Shape: purpose, flow, ownership rules, and readiness.
2. Current locations and structure: exact files, nodes, wiring, or document chain.
3. Entry points and ordered behavior.
4. Component contracts: job, inputs, outputs, API, ownership, essential values.
5. Required outside data and dependencies.
6. Validation evidence, current limits, and remaining work.

Omit inapplicable sections. Front-load information that changes the correct next action. Preserve current constraints with their consequences; omit abandoned approaches, chronological work logs, and repeated explanations. Link to authoritative inventories instead of duplicating volatile data. Historical snapshots are not normal recovery inputs.

## Synchronization And Closeout

At each completed Box, update affected references and DOTS in the same work batch. These are companion changes for the next human Git checkpoint, not an automated commit. A date alone does not establish agreement. If interrupted between updates, leave the Box incomplete and reconcile the mismatch before claiming a valid transfer.

At Table closeout, validate the composed components and reconcile interface/dependency limits. At Room closeout, record final outputs, acceptance status, integration evidence, and disposition: retain in Room, preserve reusable work in ToolShed, or promote only when explicitly authorized. Closeout never grants deletion or Production authority. Preserve useful independent results even if another Box remains incomplete.

## Astra Handoff Validity

A mid-execution entry requires a current-state handoff, using [the handoff template](Templates/ASTRA_HANDOFF_TEMPLATE.md). It must point to DOTS and establish:

- exact Room/Table/Box identities and matching statuses;
- current authority and its evidence, exclusions, and remaining acceptance criteria;
- implementation baseline, relevant uncommitted work, output paths, and applicable references;
- executed checks and results, unverified claims, and unresolved dependencies;
- the next eligible action and its stopping condition.

The receiving agent verifies that referenced files exist, checkpoint/status fields agree, authority is evidenced, and relevant implementation evidence matches the stated transfer. Use focused permitted reads; do not re-audit every completed component. If material state cannot be established, the handoff is not valid: recover the specific missing evidence or ask for it before dependent execution. Read-only recovery may continue. Do not infer approval or human acceptance from a polished document.

A fresh Room avoids mid-execution transfer but still requires valid input contracts. Neither a handoff nor documentation authorizes access to prohibited territory.
