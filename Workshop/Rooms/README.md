# Rooms
Updated: 2026-09-13

The accepted game now runs with **F5 from Production/main.tscn**. [Regional Release](Regional%20Release/CURRENT_STATE.md) records the verified transfer. The Rooms below remain development/reference surfaces.


Current release: [Regional Release](Regional%20Release/CURRENT_STATE.md), promoted fixed hexagonal Locals, regional hostility, dry edge entry, hex menu and one-save regeneration. [Regional Foundation](Regional%20Foundation/README.md) remains its preserved source. Production is F5.

Earlier Workshop rooms: [World Foundation](World%20Foundation/README.md) for hierarchical generation and saves; [Actor Foundation](Actor%20Foundation/README.md) for the accepted actor prototype; [UI Foundation](UI%20Foundation/README.md) for the earlier interface; [Tile Foundation](Tile%20Foundation/README.md) for art requirements.

Create `Workshop/Rooms/<RoomName>/` for a bounded approved outcome. Before implementation, create its DOTS from the [template](../AI_AGENTS_README/SHARED/Templates/DOTS_TEMPLATE.md) and follow the [Room contract](../AI_AGENTS_README/SHARED/MCA_ROOM_AND_DOCUMENTATION_CONTRACT.md).

```text
<RoomName>/
  DOTS.md               Outcome, authority, Boxes, dependencies, traversal
  CurrentState.md       Current behavior, paths, evidence and limits
  <TableName>/          Task-specific isolated working surface
  Handoff.md            When transferring ongoing work to another agent
```

Tables/Boxes are created for the actual task; do not populate dummy completed work. Evidence belongs near its owning task with a clear link from current state. Use [Documentation Format](../Documentation_Format_README.md); synchronize DOTS and affected state references at each completed Box.

[Momentum Foundation](<Momentum Foundation/CURRENT_STATE.md>) owns the adopted DEX/effect momentum scheduler and flexible action integration.

[Loot Foundation](<Loot Foundation/CURRENT_STATE.md>) captures the full item catalog and tested single-material/quality generator, with ring and affix extension contracts. Workshop only; Production adoption pending.

[Equipment Integration](<Equipment Integration/CURRENT_STATE.md>) is the adopted Production loot/combat implementation, including the final slot contribution correction and ranged defaults.

[Village Foundation](<Village Foundation/CURRENT_STATE.md>) holds the template-based starting-village art request; art delivery and gameplay implementation remain pending.

Village Foundation now includes adopted single-hex roof placeholders, adjacent menus and persistent map data. See its current state for the service implementation boundary.
