# Interior Scenery and Container Loot
Updated: 2026-09-13
Checkpoint: [Interior Scenery]+[Validation]+[Closeout]

Production now places 2–3 seeded props per eligible cavern or dense room on initial population. Cave choices: bones, corpse, chest, rubble. Dungeon/tower choices: chest, crate, barrel, bones, rug. Entry rooms and room centers stay clear; props avoid entrance links by two hexes. Props are walkable, non-occluding first-pass overlays, so movement and room connectivity remain unchanged.

`Production/World/interior_props.gd` owns placement and metadata validation. `HexMap.props` stores kind, name, opened, contents and room_id by hex. MapState persists props optionally for old-save compatibility; PersistentActorWorld validates item identity across containers, inventory and ground. No backfill or reroll of already initialized rooms.

Shared actor interaction `search` requires a ready actor, activation, visibility and distance at most one hex. It moves fixed contents onto ground once, clears the container and marks it searched. Regular pickup handles inventory capacity and equipment. UI Activate lists nearby searchable objects and Take actions. Sight-filtered temporary symbols distinguish storage, remains and decoration; searched props become muted. Idle enemies approach visible containers without inspecting sealed contents and search through the same action API; existing AI evaluates released loot.

Enemy death moves actual possessions into a corpse when its hex has neither another prop nor an entrance; otherwise existing loose-drop behavior preserves accessibility. Death and search are idempotent. Player death behavior is unchanged. Geography revision changes on population, corpse creation and search so autosave captures container state.

Art: `Workshop/Chad-Casso/POI_Overlay_Scenery.png` and `_02.png` remain intact as reference sheets. Their names are harmless; no renaming required. They have painted backgrounds, not transparent ready-to-place sprites. Runtime currently uses simple code-drawn symbols. Transparent individual props/atlas regions and final visual art adoption remain future work. No new container-breaking combat, locks, traps, gold economy, solid-obstacle scenery or corpse decay.

Validation: Production dungeon/tower suite passed 334 checks; focused scenery scene test passed 29 checks, including entrance clearance, search contents, repeat refusal, exact save/load, actual corpse equipment, repeat death and enemy shared search. Counts of scenery checks depend on generated cave size. Tests and isolated saves retained in tests; original runtime files/baseline preserved in Reference. Human visual acceptance pending.
