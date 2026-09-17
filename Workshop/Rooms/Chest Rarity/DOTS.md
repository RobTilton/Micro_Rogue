# Chest Rarity DOTS
Updated: 2026-09-17
Checkpoint: [Chest Rarity]+[Validation]+[Delivery]

Authority: user requested reading Workshop/Micro_Rogue_Rings_And_Amulets.md and setting chests to 75% normal / 25% rare. Document fully read. Scope: Production persistent chest classification, names, validation, focused tests and docs. Jewelry implementation excluded from this bounded request. Existing contents/gold/opened state and player world preserved. Pre-edit sources in Reference; Git checkpoint unknown.

[Chest Rarity]+[Runtime]+[Classification]: complete. Independent seeded per-chest rarity, names, persisted tag; every live population branch and compatible legacy/lazy-load assignment. Output Production/World/chest_rarity.gd and integration in persistent_actor_world.gd / interior_props.gd.
[Chest Rarity]+[Validation]+[Delivery]: complete; depends on Classification. 48 checks passed, including full save/lazy-reload; exact intervals 75/25; sample 597 rare / 2499. git diff --check passed. Current-state, room index, Production README and affected baseline hashes synchronized.

Last complete: [Chest Rarity]+[Validation]+[Delivery]. No active Box. Human acceptance pending. Next eligible work: jewelry implementation only when requested; source document remains unchanged. Retain tests, isolated saves and backups. No commit, reset or cleanup.
