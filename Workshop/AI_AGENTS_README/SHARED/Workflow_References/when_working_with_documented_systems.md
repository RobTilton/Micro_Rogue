# When Working With Documented Systems
Updated: 2026-09-09

Before auditing, modifying, or documenting a production system, check whether an AI system description exists under:

```text
Workshop/AI_Facing_Documentation/SYSTEMS_DESCRIPTIONS_FOR_AI/
```

or:

```text
Workshop/AI_Facing_Documentation/SHADER_LIBRARY_FOR_AI/
```

These documents are the project's architectural summaries.

Use them to establish current ownership, runtime wiring, source-of-truth files, known constraints, and confirmed behavior before rediscovering the same information from production files.

If documentation conflicts with production, treat production as the current source of truth and report the discrepancy.
