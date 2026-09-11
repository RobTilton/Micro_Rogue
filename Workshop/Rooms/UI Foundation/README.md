# UI Foundation Workshop
Updated: 2026-09-11

Working interface and gameplay prototype. Open [Prototype/ui/main.tscn](Prototype/ui/main.tscn) in the root Godot project and press **F6** for the current Workshop iteration. Root F5 is documented as the prior promoted Production entry.

[Current state and controls](CURRENT_STATE.md) · [DOTS](DOTS.md)

Tile artwork, style decisions and subsequent tile planning now start in [Tile Foundation](../Tile%20Foundation/README.md). Live scripts and resource paths remain here.

The prior three Room documents are preserved byte-for-byte under Reference/Before_Tile_Foundation_2026-09-11. They contain obsolete launch/dimension/status statements and are historical reference only. No files were deleted or gameplay changed during organization.

Local destinations now use seeded spacing on dry land, preserving Return and lake-island Towers. Use a new run/new Local region to review. Find entrances on the map; the old fixed Dungeon/Town/Tower coordinates no longer apply. [Validation and details](CURRENT_STATE.md).

Current generation reference: [How the Game Is Generated Now](GAME_GENERATION.md) explains the active Workshop world/Local/POI pipeline, encounter and item randomness, persistence and unimplemented systems. Checkpoint [UI Foundation]+[Documentation]+[GenerationReference] complete; documentation-only inspection, no fresh runtime tests.

The new actor-enabled Workshop iteration is [Actor Foundation/main.tscn](../Actor%20Foundation/main.tscn), also launched with F6. It adds sprites, shared enemy/player actions, multiple persistent actors and map pursuit. This Room’s original scene remains available as the earlier baseline. [Actor controls and limits](../Actor%20Foundation/README.md).
