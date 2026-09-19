# Creature Advancement
Updated: 2026-09-18

Non-humanoids receive two advancement points per level; humanoids retain one. Shared Actors.level_point_reward supplies XP level-ups, daily-aging level gains, and newly spawned higher-level enemies. Existing non-skill creatures spend points through the existing lowest-stat-first logic. No new skill or equipment access; no retroactive recalculation of existing levels. Quest rewards unchanged.

Four XP/reward checks passed and the persistent world compiled cleanly. Spawn/aging call sites use the same helper. Prior sources retained here. Balance remains a playtest question.
