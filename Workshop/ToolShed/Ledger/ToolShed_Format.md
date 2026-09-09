# ToolShed Format
Updated: 2026-09-09

## Purpose and structure
ToolShed stores reusable, evidenced knowledge and workflows. Rooms are the working surfaces; ToolShed is durable storage after a capability proves useful. A small rule can be worth keeping when it prevents rediscovery.

```text
ToolShed/
  Ledger/
    ToolShed_Format.md
    ToolShed_Parts_Catalog.md
    Completed_Tool_Builds_Catalog.md
  StorageUnits/<ToolName>/
    ToolReadme.md
    <implementation or rule>
  Completed_Tool_Builds/<BuildName>/
    BuildReadme.md
    <composed implementation>
```

## Catalog schema
Parts/rules go in [ToolShed_Parts_Catalog.md](ToolShed_Parts_Catalog.md); composed builds go in [Completed_Tool_Builds_Catalog.md](Completed_Tool_Builds_Catalog.md). Keep entries concise and searchable.

```text
Name: Stable reusable name.
Status: Proven | Experimental | Archived
Kind: Tool | Script | Reusable Rule | Scene Utility | Format Contract | Completed Tool Build
StorageUnit / BuildUnit: Current directory relative to the project root.
Authority: Current README or contract.
Keywords: Object types, actions, APIs, problem and common user wording.
Summary: One-sentence capability.
UseWhen: Appropriate task and conditions.
DoNotUseWhen: Unsupported or inappropriate cases.
KeyRules: Essential invariants and limitations.
```

Choose one status and one location field. Proven means supported within the documented validation scope, not universally safe. Experimental identifies remaining uncertainty; Archived is retained and not the current implementation. No entries exist in this template.

## Part README schema
Use title/date and, where applicable, the provenance checkpoint from [Documentation Format](../../Documentation_Format_README.md). Include:

- Purpose, status and keywords.
- Proven In: resolvable evidence and its scope.
- Reusable Capability and Required Assumptions.
- Key Rules and Usage Shape: inputs, invocation, output and mutation boundary.
- Known Boundaries: unsupported cases, failures and required human checks.
- Source References and Future Notes, when applicable.

## Build README schema
Include purpose/status, entry point, ordered workflow, inputs/outputs, component dependencies, ownership/mutation rules, validation, limitations and current source references. Identify the reusable parts it composes. Use a build for a whole problem-solving workflow; use a storage unit for one part or rule.

## Naming and references
Use short action/capability names that make sense outside a Room. Room-specific context belongs in evidence and source references. Include useful search keywords. Link current resolvable artifacts rather than stale construction paths; omit nonexistent references. A README never grants execution, deletion, Git or Production authority.
