# Belt Pouch Layout
Updated: 2026-09-15
Checkpoint: [Belt Pouch Layout]+[Inventory]+[Wrapping]

Production/UI/game_ui.gd uses five columns for the equipped belt GridContainer. Godot wraps additional pouches automatically: a 14-slot belt displays 5/5/4. Capacity and interactions are unchanged. Verified the single targeted property change; no gameplay tests warranted for this layout-only edit. Human visual acceptance pending.

Checkpoint: [Belt Pouch Layout]+[Inventory]+[Potion Shortcut]
Shift-click backpack potions calls the existing shared belt transfer with the equipped belt ID and no explicit pouch index. GridInventory chooses the first free pouch. Missing/full belt refuses atomically; potion remains in backpack. Existing combat activation costs remain enforced. Controls help updated. Verified source routing and existing _put_belt/transaction behavior.
