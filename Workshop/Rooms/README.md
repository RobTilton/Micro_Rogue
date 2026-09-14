# Rooms
Updated: 2026-09-14

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

[Cave Foundation](<Cave Foundation/CURRENT_STATE.md>) owns the adopted Cave room/passage generator, one-room dead-end invariant and persistent per-room contents.

- [Dungeon Foundation](Dungeon%20Foundation/CURRENT_STATE.md): dense dungeon/tower rooms and persisted hidden return ladder; implemented, visual acceptance pending.

- [Interior Scenery](Interior%20Scenery/CURRENT_STATE.md): seeded props, shared container searches and corpse loot; verified, visual playtest pending.

- [Town Market](Town%20Market/CURRENT_STATE.md): compact hex towns, persistent shops and purchases, empty-equipped 100-gold starts; verified, human acceptance pending.

- [Town Life](Town%20Life/CURRENT_STATE.md): named-town startup, NPCs, boss bounties, level bands and persistent gold; verified, human acceptance pending.

- [Mouse Play](Mouse%20Play/CURRENT_STATE.md): contextual controls, camera/minimap, movement feedback and quest journal; verified, human acceptance pending.

World Time and Frontier (2026-09-13): adopted calendar, six-hour border travel, Local-edge exploration, starter trade route with two towns and a one-skill-point crier tutorial, sparse towns, outdoor encounters, independent monster aging, faction combat, stat spending and weekly stock. Authoritative scope and limits: `Workshop/Rooms/World Time and Frontier/CURRENT_STATE.md`. This supersedes earlier statements deferring these features or retaining player-relative monster scaling.

Living Frontier (2026-09-14): 1-gold inn recovery (2 × CON, one six-hour block), quest bearing/terrain hex, seven-day cleared-Local replenishment and monthly survivor occupation of visited cleared POIs. Supersedes prior inn-service deferral. Rules and validation: `Workshop/Rooms/Living Frontier/CURRENT_STATE.md`.

Free Exploration (2026-09-14): action budgets now apply during combat; safe shopping, inventory and exploration need no end-turn prompts. Shop stock has inspection tooltips. Gold and six-hour time costs remain. See `Workshop/Rooms/Free Exploration/CURRENT_STATE.md`.

Shop Sales (2026-09-14): backpack gear sells for half retail rounded down into the receiving merchant stock. Buy/sell confirmations support Ctrl bypass. New characters start with 50 gold; existing balances preserved. See `Workshop/Rooms/Shop Sales/CURRENT_STATE.md`.

Weapon Bonus Balance (2026-09-14): weapon material/quality damage modifiers doubled, including existing generated gear through compatible runtime resolution. Armor/HP/base dice/stat scaling unchanged. See `Workshop/Rooms/Weapon Bonus Balance/CURRENT_STATE.md`.

Skill Author (2026-09-14): Workshop-only Godot inspector scene for skill ideas, polyhex shapes, buckets, unlock/chain/adjacency requirements and effect prose. Revision-safe .tres/JSON Library. Start: `Workshop/Rooms/Skill Author/README.md`. Production is unchanged.
