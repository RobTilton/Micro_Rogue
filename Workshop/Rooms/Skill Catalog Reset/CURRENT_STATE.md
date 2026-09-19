# Skill Catalog Reset
Updated: 2026-09-18

User requested catalog location and removal of current gameplay skills. Live SkillBoard.DEFINITIONS is empty. Lunge, Riposte and Show-Off definitions remain only as legacy migration metadata, and their guarded implementation is retained. NPC learning reads the empty catalog. Lunge/Riposte HUD buttons are hidden; the Skills board remains available with an empty-catalog message and stat spending.

Loading saves clears placeholder learned skills, board placements/origins, skill cooldowns, pending ability and riposte state; refunds one point per removed learned skill. Repeat loads of migrated data do not repeat refunds. Actual user saves were not edited during this task; migration takes effect on next Continue. Authored drafts, tool, basic attacks and equipment remain available.

Library: Workshop/Rooms/Skill Author/Library. Runtime catalog: Production/Actors/skill_board.gd. Four catalog/refund checks and Production compile passed. Legacy metadata should be separated from new catalog validation/migration when authored skills are adopted. Prior sources retained here.
