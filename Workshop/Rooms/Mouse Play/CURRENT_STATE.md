# Mouse Play
Updated: 2026-09-13
Checkpoint: [Mouse Play]+[Validation]+[Closeout]

Production F5 now supports right-click contextual actions, self double-click transitions, wheel zoom, actor movement slides, a Quests rail entry and a clickable minimap. Existing keyboard controls remain available. Existing worlds need no regeneration for these UI features.

Controls: left-click retains movement preview/confirmation (Options can disable confirmation). Drag the map with left or middle mouse. Right-click an actor/hex for relevant actions. Self menu includes Character, Inventory, Skills, Quests, nearby interactions, Wait, current transition and Focus on player. Visible targets expose attack, shop access, container search and loose-item pickup through existing simulation boundaries. Out-of-range actions refuse normally. Double-left-click the player on an entrance triggers travel once; single self click spends no movement. Right-click during inventory drag rotates the item; this takes priority over the map context menu. Inventory's empty-selection sentinel is fixed so naked starts can open Inventory safely.

Wheel zoom clamps to 0.5–2.5, anchors under the pointer and keeps hex picking aligned. Per-map zoom/offset persist; missing legacy zoom defaults to 1. The minimap shows the current map geometry, entrances and shops with player/allied/visible-enemy markers; it introduces no new fog system. Click it to focus the camera on that cell; contextual Focus on player recenters on the player. Floating panels render above it.

ActorWorld emits bounded transient movement events for move, lunge and retreat. ActorView queues grid-coordinate interpolation at 0.25 seconds per hex for players/enemies; pan/zoom remain coherent during the slide. Animation is presentation only: simulation resolves immediately, no turn rules are changed, and input remains available. Hidden paths are not animated; cross-map rebuilds clear presentation and retain existing travel fade. Actor picking resolves rendered actors to their logical positions during animation. Motion queues are not saved.

Quests rail opens persisted bounties across generated towns, with location, reward, status and return-to-crier completion prompts. Accept/claim remains with the crier; the journal does not grant remote rewards.

Files: world_view camera/input; actor_view interpolation; actor_game context/minimap/journal; mini_map.gd rendering/click focus; navigation_rail and game_ui panel routing/drag rotation; ActorWorld transient motion; HexMap/MapState/PersistentActorWorld camera persistence. Source backups and previous manifest retained in Reference.

Validation: final rendered mouse test passed 27 checks without script errors: context entries/inventory action, empty selection, Quests rail, wheel limits/anchor/picking, minimap focus and 37-cell projection, player half/full slide, moving sprite picking, enemy slide, legacy camera migration, exact save/load and single-vs-double-click transition. Town Life regression passed 36 checks. Final screenshot inspected at tests/mouse_gameplay.png. Scoped diff whitespace check passed. Tests use isolated save directories; no player-save reset or Git commit.

Human playtest pending. Remaining polish: final scenery/NPC art, richer minimap styling, and animation pacing based on user feedback. Current map topology is visible on minimap just as the main board has no terrain fog.
