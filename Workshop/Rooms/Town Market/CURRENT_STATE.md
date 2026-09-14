> Superseded in part, 2026-09-13: Weekly stock refresh and globally tracked prosperity are now implemented. See [World Time and Frontier](<../World Time and Frontier/CURRENT_STATE.md>).

# Town Market
Updated: 2026-09-13
Checkpoint: [Town Market]+[Validation]+[Closeout]

New Production towns are 7×7 axial bounds clipped to radius 3: 37 hexes. Six shops occupy one randomly selected non-corner cell per outer edge, with shop identities shuffled. Return is at (0,3); central well retains its existing child location at (3,3). Existing saved towns remain unchanged.

New F5 characters start with all equipment slots and backpack empty and 100 gold. Existing actors/saves keep their gear and gold (missing legacy gold reads as zero). Starting location is now a named town; see ../Town Life/CURRENT_STATE.md for the subsequent startup and economy layer. The actor sprite remains the existing placeholder and does not reflect equipment.

VillageShops owns layout and stock. Town prosperity is a provisional seeded 1–6 value, not yet derived from regional simulation. Each trading shop receives max(5,3×prosperity) generated items; material and base-rank caps are min(8,1+floor(prosperity/3)). Blacksmith: metal; leatherworker: leather; tailor: cloth; general goods: belts, bows and staffs. Inn service remains deferred; jeweler closed. Price is max(1,5×base_rank + material_tier−1 + quality modifier). Stock is generated once and persists; weekly restocking awaits the time system. No selling, theft or economy simulation is introduced.

Town adds one chest, crate and barrel with fixed seeded contents on walkable radius-two cells. Existing shared search and pickup apply without ownership penalties. Props remain temporary symbols and nonblocking.

Shared ActorWorld.buy validates shop access, readiness, activation, stock identity, gold and backpack fit before mutation. Success puts the same unique item in backpack, deducts gold and one activation and removes stock. Persistent override increments geography revision; stock identity participates in global item validation. UI shop panel exposes buy buttons and HUD shows gold. Enemies can call the same buying capability, but no autonomous shopping goals or enemy money grants are added.

Validation: 32 Production scene checks passed for naked/100-gold startup, 37 cells, six reachable perimeter shops, container count, stock count, purchases, duplicate purchase refusal, insufficient-gold atomic refusal, exact save/load and unchanged stock on revisit. Dungeon/tower regression suite: 334 checks passed. Rendered final scene captured and inspected at tests/town_gameplay.png (gold is zero there because the test exercises insufficient funds). Scoped whitespace check passed. Human acceptance remains pending.

Source backups and previous baseline retained in Reference. Tests use isolated saves; no player save reset, deletion or Git commit. F5 is the game entry point.
