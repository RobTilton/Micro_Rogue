# World save storage
Updated: 2026-09-12

World Foundation automatically checkpoints gameplay to append-only `.journal` files under `autosaves/`. Each complete record is compressed, checksummed, flushed and closed. Continue uses the latest valid checkpoint; incomplete tails recover to the preceding complete state. Manual extra `.world` snapshots and per-location `.bin` unload archives remain here. Unload archives alone are not the complete game, but manual saving is no longer required.

Earlier outputs are retained. Automated snapshots/journals belong under `../tests/saves/` and are excluded from the player's Continue selection. No retention pruning or journal compaction is implemented.
