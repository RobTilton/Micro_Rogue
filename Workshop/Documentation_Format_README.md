# MCA Documentation Format
Updated: 2026-09-09

## Purpose and authority

This is the standalone writing guide for MCA documents. Use it directly rather than deriving conventions from an older project's documents. It explains the existing [shared operating contract](AI_AGENTS_README/SHARED/.AGENTS.md) and [Room/documentation contract](AI_AGENTS_README/SHARED/MCA_ROOM_AND_DOCUMENTATION_CONTRACT.md); those contracts own authority and completion rules. This guide adds no execution gates.

Documents provide current intent, ownership, interfaces, evidence and the next valid action. Implementation establishes actual behavior. Report and reconcile differences; do not silently treat an outdated description as runtime truth.

## Common header

Every newly created or updated active MCA document starts with a descriptive title and `Updated: YYYY-MM-DD` immediately below it. Use the actual edit date. A date alone is not evidence that behavior was revalidated.

Task and system state documents also identify their applicable checkpoint and implementation baseline near the top. Shared contracts, general READMEs and indexes need no invented Room checkpoint. In blank templates, placeholders are explicitly unfilled and grant no authority.

```markdown
# Descriptive Document Title
Updated: YYYY-MM-DD
Checkpoint: [RoomName]+[TableName]+[BoxName]
Implementation baseline/evidence: <known revision, files or evidence; unknown if unavailable>
```

A checkpoint is a traversal identity, not a Git commit. Keep names stable. Distinguish a known commit from uncommitted changes and from an unknown baseline.

## Document types and locations

| Document | Location | Required purpose/content |
|---|---|---|
| AGENTS.md | Project root | Short startup routing into the shared contract, applicable primer and task context. |
| Shared contract / primer | Workshop/AI_AGENTS_README | Operating authority / collaboration context; do not duplicate project state here. |
| DOTS.md | Each execution Room | Outcome, scope, authority evidence, baseline, Box/dependency table, traversal, unresolved state and disposition. |
| CurrentState.md | Owning Room | Current result, paths, behavior, component contracts, evidence, limits and next work. |
| Handoff.md | Owning Room, for mid-execution transfer | Authority, exact checkpoint/status, implementation, evidence and next eligible action; receiver validation. |
| System description | AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI | Durable architecture and component/preservation contracts. |
| Shader description | AI_Facing_Documentation/SHADER_LIBRARY_FOR_AI | Material/shader ownership, inputs, outputs, coordinate/value contracts, dependencies and validation. |
| Workflow reference | AI_AGENTS_README/SHARED/Workflow_References | A specific trigger, reusable lesson, assumptions and failure boundaries; no independent authority. |
| ToolReadme.md / BuildReadme.md | ToolShed storage unit / completed build | Reusable capability, use, inputs/outputs, assumptions, proof and limits. |
| Catalog | ToolShed/Ledger | Concise discovery entries that link the current tool owner. |
| Audit/evidence report | Owning Room or Workshop/_Audits | Scope, method, observations, findings, uncertainty and reproducible evidence. |

Use the established [ToolShed schema](ToolShed/Ledger/ToolShed_Format.md) for tool READMEs and catalog fields. These example filenames are defaults; preserve an established current-state filename rather than renaming it merely for style.

## Current-state and system-document structure

Use the [current-state template](AI_AGENTS_README/SHARED/Templates/CURRENT_STATE_TEMPLATE.md). Include the sections that apply, in this order:

1. **Rapid Shape:** purpose, readiness, end-to-end flow and the main ownership rule. Put facts that change the next action first.
2. **Current Locations And Structure:** exact current files, entry points, component hierarchy or document chain. Identify the authoritative owner.
3. **Entry Points And Flow:** how the work/system starts and the ordered behavior that produces its result.
4. **Component Contracts:** each relevant component's job, inputs, outputs/API, owner, mutation boundary, required values/order and guarantees. Explain why an invariant matters.
5. **Required Outside Data:** actual dependencies, assets, configuration and authoritative references. Distinguish required inputs from optional aids.
6. **Validation And Current Limits:** checks actually run, results, scope, unverified behavior, human acceptance status and next required work.

Omit sections that do not apply; do not fill them with speculative architecture. Keep the document useful to someone who has not read the conversation. Reference an authoritative inventory rather than maintaining another volatile copy.

A coupled system description must additionally identify every relevant owner, coordinate/value/ordering contract, what each contributes, consequences of independent changes, and required composed validation. Use the `FRAGILE_` filename prefix only when that coupling is a material preservation boundary. Follow the [fragile-system reference](AI_AGENTS_README/SHARED/Workflow_References/when_working_with_fragile_system_documentation.md).

## DOTS format

Create DOTS before implementation in a new execution Room. Use the [DOTS template](AI_AGENTS_README/SHARED/Templates/DOTS_TEMPLATE.md). It must contain:

- Room outcome, scope and prohibited territory.
- Observable acceptance criteria and actual Alignment/Execute evidence.
- Known starting baseline; explicitly unknown when unavailable.
- Unique Box checkpoints and their responsibilities, dependencies, completion conditions, status, outputs and evidence.
- Last completed checkpoint, active/interrupted checkpoint and next eligible action.
- Human acceptance, Git checkpoint status, unresolved issues and retained-output disposition.

```markdown
| Checkpoint: [Room]+[Table]+[Box] | Responsibility | Depends on | Completion condition | Status | Outputs / evidence |
|---|---|---|---|---|---|
| <unique identity> | <bounded responsibility> | <identities or none> | <observable outcome and checks> | planned | <actual paths/results> |
```

Supported statuses:

| Status | Meaning |
|---|---|
| planned | Identified but not started. |
| active | Work is underway. |
| awaiting_validation | Implementation/checkpoint awaits a required check or human judgment. |
| complete | Its stated completion condition and required checks are met; affected state references are synchronized. |
| blocked | A concrete required dependency or decision is unavailable; identify it and the next enabling condition. |
| superseded | This Box is no longer required in the current plan; preserve the applicable replacement/reference. |

Never equate implementation completion with human acceptance or Production adoption. Dependencies must be explicit; list order alone is not a dependency. A failed Box does not erase independent completed results. Do not recycle checkpoint names for different responsibilities.

## Handoff format

Use the [Astra handoff template](AI_AGENTS_README/SHARED/Templates/ASTRA_HANDOFF_TEMPLATE.md) when transferring ongoing work. Include:

- DOTS and current-state links with matching checkpoint/status fields.
- Approved goal, authority evidence, boundaries and remaining acceptance criteria.
- Known implementation baseline, relevant uncommitted work and exact outputs.
- Executed checks/results, unknowns and unresolved dependencies.
- Next eligible action and its stopping condition.
- Receiving-agent validation of paths, authority, status agreement and relevant implementation evidence.

Do not mark a transfer valid merely because a handoff file exists. Do not infer human acceptance or missing authorization. Recovery reads are allowed; dependent writes still require the established scope.

## Evidence and uncertainty

State what was tested and what that test establishes. Include conditions such as input/seed, version or environment when they affect reproducibility. Link the actual log/report/artifact when available. Report meaningful failures and their current disposition; do not substitute the final pass count for the entire development history.

Use precise distinctions: observed, inferred, proposed, unverified and accepted. For example, a data-layout check does not establish a full application run; a screenshot does not prove movement behavior. Record human acceptance only when it was actually given, and retain its scope.

Do not invent timestamps, commits, output paths, validation, approval or prior actions. Keep unknowns explicit. Do not describe an optional future improvement as a present blocker.

## Writing and linking conventions

Use plain, concrete language. Prefer current behavior and constraints to conversational history. Use paragraphs for connected explanations, numbered lists for ordered actions, and tables for parallel contracts or states. Keep each document proportional to its task.

Link current authoritative files with relative Markdown links so the project can move. Make inline paths exact. Do not hard-code a developer's local drive, machine name or home directory into reusable documents. Distinguish a placeholder path from an existing artifact. Remove stale claims and repair references when the implementation changes within the approved scope.

Do not repeat policies in every document or use an old investigation transcript as a current contract. Preserve history separately when required, with a pointer to the current owner. Historical material is not normal init context.

## Update and closeout points

At each completed Box, synchronize DOTS and every affected current-state reference together. Update the date when editing, not as a substitute for verification. If synchronization is interrupted, leave the checkpoint incomplete until the records agree.

At Table/Room closeout, reconcile composed behavior, remaining limits, acceptance and output disposition: retained in Room, promoted to ToolShed, or explicitly adopted into Production. Identify the next eligible action, or state that no agent implementation work remains. Documentation closeout grants no file-deletion, commit, reset or Production authority.

Before handing off a document, verify its referenced paths, consistency with DOTS, honest evidence scope, unresolved acceptance and the clarity of the next action. The reader should not need an older project or the chat transcript to discover the format.
