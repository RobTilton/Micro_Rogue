# Warning Cleanup
Updated: 2026-09-14
Checkpoint: [Warning Cleanup]+[Validation]+[Explicit Rounding]

Live Production integer divisions now explicitly truncate using int(expression / floating divisor). Calendar periods, aging increments, gold, shop tiers and tile/atlas indices retain their existing integer values. No global warning suppression or gameplay balance change. Original sources retained under Reference/.

Regional Release's preserved Production_main.tscn no longer declares the live Production scene UID. Its original bytes are retained as Reference/Production_main.tscn.original; live scene identity remains unchanged.

Validation: warning_audit.gd loads the runtime with integer-division warnings treated as errors; passed. Adventure Loop 51 checks passed, including calendar/Camp, gold, generation, replacement-character persistence and exact save/load. Headless Godot 4.4.1 editor scan passed without the duplicate UID warning. Human editor session may retain old debugger entries until cleared/restarted. This verifies the reported integer-division class, not every disabled warning category or historical Workshop script.

Production baseline refreshed. No player save changes, commit or deleted artifacts. Human acceptance pending.
