# Shop Sales
Updated: 2026-09-14
Checkpoint: [Shop Sales]+[Validation]+[Trading]

F5 Production supports selling backpack gear to any open merchant. Inn and closed jeweler do not trade. Equipped gear must first be unequipped; loaded belts must be emptied. Weapons, armor, shields and empty belts are accepted regardless of merchant specialty. Potions are not included in gear sales.

Sale payout is floor(50% of the shared retail formula). Retail remains max(1, 5 × base rank + material tier − 1 + quality modifier). A 5-gold item pays 2 gold. A sale removes the actual item from the backpack, pays gold once, and adds that same item ID and properties to that shop at retail price. It can be bought back until normal weekly stock refresh. Existing carrying, reach and combat-only activation rules remain in force.

Click a buy or sell button to confirm the item and price. Cancel does nothing. Hold Ctrl while activating the action to trade immediately. Confirmed transactions recheck map, shop reach, item presence and quoted price; underlying purchase/sale checks still enforce funds, capacity and action availability. Stock buttons and sale buttons retain inspection tooltips.

New characters start with 50 gold. Existing characters' balances are preserved. No save reset required.

Files: Production/World/village_shops.gd owns shared pricing/sellability; Production/Actors/actor_world.gd owns sale transfer; Production/Persistence/persistent_actor_world.gd marks stock changes; Production/UI/actor_game.gd owns confirmations, sale list and new-character gold. Prior sources/baseline retained in Reference.

Validation: Shop Sales 15 checks passed (odd-price rounding, payout, item identity/stock, duplicate-sale refusal, buyback, buy/sell confirmation/cancel, synthetic Ctrl bypass, exact save/load). Free Exploration 13 checks passed. Frontier 124 checks passed including actual new-character 50 gold. Synthetic Ctrl input is flushed immediately to avoid popup focus clearing the test key. Human mouse/hover acceptance pending. Isolated test artifacts retained; no commit or player-save reset.
