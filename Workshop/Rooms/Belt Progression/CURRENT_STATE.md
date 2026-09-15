# Belt Progression
Updated: 2026-09-14
Checkpoint: [Belt Progression]+[Validation]+[Capacity]

Production belt capacity = clamp(2 + material tier - 1 + quality bonus, 1, 14). Quality bonuses: Trash -1, Common 0, Exceptional +1, Masterwork +2, Mythic +3, Touched by the Gods +5. T1 Common holds 2; T3 Masterwork 6; T8 God-Touched 14. All generated belts receive belt_capacity_version 2. The generator owns the formula; item validation consumes it.

Validated saves accept prior unversioned capacities, then upgrade belts throughout actors, bags, shops, ground and archived map states before restoration. IDs, names, potion contents and pouch indices are preserved. Migration is idempotent. Belts predating material metadata retain their legacy capacity. Normal save/load persists the upgraded values. Restart/load the game to upgrade existing generated belts.

Inventory pouches use seven columns, so 14 slots occupy two rows. The existing HUD and transfer logic already iterate actual capacity. No pricing or quality weight changes.

Validation: belt_test.gd passes all 48 tier/quality combinations, generated and migrated item validation, idempotent migration, preserved IDs/contents, filling every pouch and refusing overflow. Adventure Loop 51 integration checks passed, including save/load. Human F5 visual acceptance pending. Original modified files retained in Reference/. No player-save reset or commit.
