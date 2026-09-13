# World Foundation
Updated: 2026-09-12
Checkpoint: [World Foundation]+[Validation]+[Integration]

**Accepted and promoted (2026-09-12):** Rob accepted the working game and authorized promotion. **F5 now runs [Production/main.tscn](../../../Production/main.tscn)** with independent resources and user-data saves. This Room is retained development source; its F6 behavior and source-era evidence below are preserved. See [promotion evidence](../Production%20Promotion/CURRENT_STATE.md).


Run [main.tscn](main.tscn) with **F6**. This composes Actor Foundation with the architecture in [Hierarchical_World_Gen.md](../../Design/Hierarchical_World_Gen.md).

Choose **Generate new world** to create and automatically persist the Global layout before character creation. **Continue world** resumes the latest valid checkpoint, including unfinished character creation and its original dice roll.

The scene generates Global first, resolves Local maps on entry, and creates template interiors and their descendants only when needed. Try **Town → Well → Underground**, **Dungeon → Floor 2**, or **Tower → Upper Tower**. Return restores the same parent location, including after unloading or restarting.

Progress saves automatically after successful actions, turns, travel, POI creation and character setup changes. A normal window close also checkpoints. **Options → Save an extra snapshot** is an optional additional backup. **Unload inactive maps** releases inactive live map objects. The map panel's **Discover another dungeon** demonstrates an event requesting a new persistent POI; the same request API works at any non-Global depth.

New worlds use varied, warped landmass fields instead of the old fixed diagonal-lobe silhouette. [Six generated examples](tests/topology_variants.png) show the new shapes. Existing saves preserve their layouts. The [User Had a Thought file](../../Design/USER_HAD_A_THOUGHT.md) holds Rob's volcano/earthquake idea; those mechanics are not implemented.

- [Current state and limits](CURRENT_STATE.md)
- [How generation works](GENERATION.md)
- [Handoff and playtest](HANDOFF.md)
- [DOTS](DOTS.md)

Existing UI Foundation and Actor Foundation scenes remain available. The accepted runtime has now been promoted independently; no Git commit was made. Water and equipment-changing sprites are outside this pass.
