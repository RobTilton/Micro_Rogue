# Movement Flow DOTS
Updated: 2026-09-17
Checkpoint: [Movement Flow]+[Validation]+[Integration]

## Authority and starting state
User authorized visible combat interruption before movement, continuous route replacement, elimination of queued visual teleporting, and approach-and-execute contextual actions. Later explicitly requested continuation, supplied the task dictionary duplicate fix, and reported a talk crash without an exact stack. Scope: Production movement/simulation/presentation, focused validation and documentation. Preserve action economy, detection, current world and unrelated work. Original sources retained in Reference; the user-patched actor_game source additionally retained as actor_game_user_duplicate_fix.gd.txt. Git checkpoint unknown; existing workspace work retained.

## Boxes
- [Movement Flow]+[Runtime]+[Stepping]: complete. Targeted A*, one-hex authoritative player movement, retained combat range credit, deferred Local encounter, Global route/time hooks. 31 focused checks passed.
- [Movement Flow]+[UI]+[Intent]: complete for agent delivery; depends on Stepping. Destination replacement, visible combat pause/banner, task revalidation, safe dictionary ownership, crier panel, sprite initialization and reset on load/new character. Final native Godot screenshot inspected.
- [Movement Flow]+[Validation]+[Integration]: complete for agent delivery; depends on both. 22 real-game integration checks passed with isolated saves; final git diff --check clean. Current state, controls, Production README, Rooms index and affected baseline hashes synchronized.

Last completed: [Movement Flow]+[Validation]+[Integration]. No active implementation Box. Next: human F5 playtest. Delivery complete; human acceptance/adoption remains pending.

## Limits and disposition
Runtime NPC turn calculation remains synchronous; animation is presentation, not a realtime combat scheduler. Queued approach cannot auto-end turns to finish an unreachable task. An in-progress hex finishes before a new route turns; its remainder is replaced. The exact separately reported talk stack was unavailable; corrected ownership/cancel/stale-target paths are covered by tests, not a claim to have inspected that unavailable stack. No player-save reset, commits or unrelated cleanup. Retain tests, screenshot, isolated tests/ saves, and source backups in this Room.
