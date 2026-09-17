# Movement Flow
Updated: 2026-09-17
Checkpoint: [Movement Flow]+[Validation]+[Integration]

## Current behavior
F5 remains the production entry point. Ordinary player movement now commits one adjacent hex and renders its 0.25-second slide before committing the next. A new confirmed destination replaces the remaining route from the committed cell; the edge currently being crossed finishes smoothly. There is no accumulating player animation queue. Cancel discards the remaining route/task without refunding an already-spent action.

Combat detection cancels travel and pending approach actions, announces COMBAT STARTED and pauses queued sprite movement for 0.65 seconds. Current step presentation then finishes; the old destination does not resume. Existing turn/action controls determine subsequent combat actions. NPC turn calculation remains the existing synchronous turn model, with its recorded visible motion presented after the pause. No realtime combat conversion.

The player motion event is always rendered even if the previous location has left the current fog view. NPC motion retains only its final contiguous visible segment, avoiding hidden-path disclosure and whole-route animation rejection. Newly revealed sprites initialize directly at their map cell instead of appearing at screen origin for a frame.

Right-click shop/search/pickup/attack/crier/entrance tasks plan an approach, wait for visible movement to finish, revalidate their target, and execute using the existing legality/action rules. They do not automatically end turns or grant actions. A route that cannot reach the task within the available combat movement is refused. Moving targets cause replanning; blocked next steps seek a new route. New destinations, combat, missing/dead/out-of-map targets, and Cancel discard previous intent. Camp and border crossing wait for current visible movement when selected in flight. Terrain costs and six-hour adjacent Global route/event travel are retained.

Local encounter entry is deferred until the animated step finishes. Merely spotting an unaware enemy does not force an arena; actual hostile detection/engagement is required. A valid enemy that detects the player can trigger the encounter even when player sight is shorter.

## Ownership
- `Production/World/movement_preview.gd`: targeted cost-aware A* route reconstruction for requested destinations/interaction approach cells; original bounded paths remain for NPC policy and move highlights.
- `Production/Actors/actor_world.gd`: `walk_step`, `walk_units`, `stop_walk`; one combat movement charge per allowance, per-hex cost accounting, atomic blocked-step refusal and detection interruption. Existing direct movement remains for NPCs/special movement.
- `Production/Persistence/persistent_actor_world.gd`: Global edge/time hooks and deferred Local encounter completion.
- `Production/UI/actor_game.gd`: transient goal/route/task controller, animation pacing, combat banner and contextual dispatch.
- `Production/UI/actor_view.gd`: interpolation, pause, visible sprite initialization.
- `Production/UI/world_game.gd`: entry fade guard and reset of transient intent on save loading. New character creation resets it too.
- Controls guide updated in `Production/UI/controls_help.gd`.

Positions/actions continue to checkpoint through the existing successful-action autosave path. Queued intent and remaining partial-route allowance are transient; loading restores the committed position without executing a stale task or refunding spent actions. No player world was reset.

## User hotfix and talk handling
Rob's `travel_task.duplicate()` before clearing travel was retained. Current source at receipt is preserved as Reference/actor_game_user_duplicate_fix.gd.txt. Cancellation now replaces the pending dictionary rather than clearing shared storage. Empty/cancelled dispatch returns safely. Talking rechecks crier identity, life, map, sight and reach, and opens/refreshes the bounty panel idempotently.

Fresh-world end-to-end tests reproduce successful talk completion, repeat clicks and stale/cancelled requests. The reported dictionary crash's exact stack was unavailable, so no separate unidentified crash cause is asserted beyond these corrected paths.

## Validation
- movement_test.gd: 31 checks passed: adjacent paths, range limits, detection, action credit/cancellation, blocked steps, interpolation/pause, first-frame position and six-hour Global restrictions.
- integration_test.gd: 22 checks passed against actual Production main, with isolated test saves: crier/repeat/cancel, route replacement, shop/search/pickup, combat banner, approach attack, entrance fade, detection-gated arena, checkpoint and load clearing transient intent.
- combat_pause.png rendered and visually inspected after fixing sprite initialization. No script errors in final runs. Tracked edited code passes git diff --check.

Human playtest acceptance pending. Keep tests, screenshot, isolated saves and original-source references. No commits or unrelated cleanup. Ring/amulet work remains untouched.
