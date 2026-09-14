# Living Frontier DOTS
Updated: 2026-09-14
Checkpoint: [Living Frontier]+[Validation]+[Recovery and Repopulation]
Authorization: user requested 1-gold inn recovery, quest direction/global tile display, weekly cleared-Local spawns and monthly survivor occupation of old POIs. Production scope: persistent simulation and quest/shop UI. Starting baseline: World Time and Frontier; preserved references under Reference. No road-art changes, deletions, player-save resets or commits.

[Living Frontier]+[Runtime]+[Recovery and Repopulation]: complete. Added shared paid rest, quest bearing/terrain card, weekly population, monthly actor migration and saved period markers. Outputs listed in CURRENT_STATE.md.
[Living Frontier]+[Validation]+[Recovery and Repopulation]: complete. Depends on Runtime. Living Frontier 18 checks and Frontier regression 106 checks passed; rendered hex/arrow inspected; exact save restoration verified. Documentation and Production baseline synchronized.

Next: human F5 playtest/acceptance, pending. No implementation blocker. Choices: user-specified six-hour rest, up to three weekly scouts, one surviving Local settler per cleared visited POI monthly. See [CURRENT_STATE.md](CURRENT_STATE.md) for contracts and limits. All references and isolated test artifacts retained.

[Living Frontier]+[Runtime]+[Six Hour Blocks]: complete. User correction authorizes six-hour inn stays and month.day.block display with Morning, Noon, Evening, Midnight. Preserve existing elapsed-time save compatibility; verify four-block rollover and inn charge.

Six Hour Blocks validation: Living Frontier 18 checks and Frontier 123 checks passed, including four-block order, day/month/year rollover and save/load. Scoped whitespace check passed. Documentation and Production hashes synchronized. Human visual acceptance pending.
