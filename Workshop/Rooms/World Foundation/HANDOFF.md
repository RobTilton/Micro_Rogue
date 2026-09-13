# World Foundation — Handoff
Updated: 2026-09-12
Checkpoint: [World Foundation]+[Validation]+[Integration]

**Accepted and promoted (2026-09-12):** Rob accepted the working game and authorized promotion. **F5 now runs [Production/main.tscn](../../../Production/main.tscn)** with independent resources and user-data saves. This Room is retained development source; its F6 behavior and source-era evidence below are preserved. See [promotion evidence](../Production%20Promotion/CURRENT_STATE.md).

DOTS: [DOTS.md](DOTS.md)

Rob requested implementation of all stages of the hierarchy alignment. This Room delivers those architecture stages on top of the accepted actor system. Read [CURRENT_STATE.md](CURRENT_STATE.md) for evidence and [GENERATION.md](GENERATION.md) for runtime truth. The original imported design is preserved.

## Playtest

1. Open `main.tscn` here and press **F6**. Choose **Generate new world**, assign the adventurer’s dice, and enter a Local region. The Global layout is already durable before dice assignment.
2. Enter Town, then Well, then Underground; or inspect Dungeon Floor 2 and Upper Tower. Return should preserve the exact parent.
3. Use the map panel's **Discover another dungeon**. Its entrance remains through travel and saving; its interior is deferred.
4. Use **Options → Unload inactive maps**, then Return. An enemy that sees an exit can still follow using the shared actor actions.
5. Complete an action, stop the scene without manually saving, run it again and choose **Continue world**. Gear, actor identity, dropped loot and nested location should survive. Also try stopping during dice assignment: Continue should preserve that world and the same roll.
6. Generate several new worlds to judge landmass variety. Earlier saved worlds keep their layouts. Volcano/earthquake ideas are recorded only in `Workshop/Design/USER_HAD_A_THOUGHT.md`.

Source gameplay acceptance is recorded; promoted F5 human verification is separate. No additional approval is needed to finish any already-authorized correction found in this pass; a new content/art direction needs its own user instruction. Production adoption was subsequently authorized and completed in the promotion Room. Preserve the existing scenes and retained snapshots.

## Travel fade — 2026-09-12

Rob requested a short fade to cover the felt Local-generation hitch. World Foundation now fades out for 0.12 seconds, presents an opaque frame before travel/generation, then fades in for 0.12 seconds after the map rebuild. It applies to map entrances/returns; ordinary movement stays immediate. Duplicate travel and input are blocked during the transition. Known invalid travel responds immediately. World UI: 17 checks pass on the OpenGL backend, including opacity at map change, viewport coverage, duplicate-entry blocking and overlay cleanup. Human timing/feel review pending.
