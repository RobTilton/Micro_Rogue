# Rooms
Updated: 2026-09-09

No project Rooms are included. Create `Workshop/Rooms/<RoomName>/` for a bounded approved outcome. Before implementation, create its DOTS from the [template](../AI_AGENTS_README/SHARED/Templates/DOTS_TEMPLATE.md) and follow the [Room contract](../AI_AGENTS_README/SHARED/MCA_ROOM_AND_DOCUMENTATION_CONTRACT.md).

```text
<RoomName>/
  DOTS.md               Outcome, authority, Boxes, dependencies, traversal
  CurrentState.md       Current behavior, paths, evidence and limits
  <TableName>/          Task-specific isolated working surface
  Handoff.md            When transferring ongoing work to another agent
```

Tables/Boxes are created for the actual task; do not populate dummy completed work. Evidence belongs near its owning task with a clear link from current state. Use [Documentation Format](../Documentation_Format_README.md); synchronize DOTS and affected state references at each completed Box.
