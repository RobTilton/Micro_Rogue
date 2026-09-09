# When Working With FRAGILE System Documentation
Updated: 2026-09-09

Use the filename prefix `FRAGILE_` for an AI-facing system description when the system's correct result depends on multiple tightly coupled values, transforms, assets, coordinate spaces, or runtime owners, and changing one dependency in isolation can silently invalidate the composed behavior.

Example:

```text
FRAGILE_COUPLED_SYSTEM.md
```

The prefix communicates a context requirement. It is not execution authority, a claim that the system is broken, or a permanent prohibition against approved work.

Before auditing, modifying, or documenting a system with a `FRAGILE_` description:

1. Read the complete `FRAGILE_` system document before inspecting isolated implementation details.
2. Recover the full coupling contract, including every named owner, transform, coordinate-space conversion, required value, and source-of-truth file relevant to the task.
3. Verify the applicable contract against live Production because documentation does not outrank current implementation.
4. Treat a proposed change to any coupled owner as a system-level change unless the document explicitly proves that owner is independently variable.
5. Do not modify one dependency in isolation merely because the local edit appears correct.
6. Preserve required validation across the complete composed result, including human visual validation when automated checks cannot prove it.
7. If live evidence conflicts with the documented contract, or a proposed change would invalidate an undocumented dependency, resolve the discrepancy against the approved scope. Continue authorized work; request a decision only when required authority or material design intent is unresolved.

`FRAGILE_` documents should remain context-forward and precise. They must identify:

- the rapid system shape;
- current runtime ownership and wiring;
- the complete coupling contract;
- required transforms, values, coordinate spaces, or ordering;
- what each coupled owner contributes;
- the consequence of changing each owner independently;
- required outside data and live sources of truth;
- validation requirements and known limits.

Do not apply `FRAGILE_` merely because a system is complicated. Use it when the coupling itself is a material preservation boundary that future agents must understand before work begins.
