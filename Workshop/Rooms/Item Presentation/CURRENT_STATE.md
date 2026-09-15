# Item Presentation
Updated: 2026-09-14
Checkpoint: [Item Presentation]+[Validation]+[Tooltips and Paper Doll]

F5 Production inventory follows the supplied concept: paper-doll equipment above the original 8×5 backpack, equipped belt pouch drag targets between them, and a right-side column for six stats, HP, Physical/Magical defense, main-hand damage range/average before target defense, gold and calendar. All seven real equipment slots use existing transfer/selection behavior. Eight rings and two necklaces are disabled labeled future placeholders; no jewelry gameplay is implemented. Placeholder silhouette/icons require no new art.

Inventory uses a full-viewport overlay to fit the full grid at the normal 1440×900 viewport; closing it or switching panels restores normal map-stage containment. Cleanup restores ownership before rebuilding the UI. Smaller viewports retain scrolling. No equipment/state schema changes.

Shared inspection text now appears on equipment, backpack items, belt pouch items, loot cards/Take actions, active potion/nearby-item actions and item context-menu entries. Map hover aggregates visible ground items and container labels at the hex. Nearby ground items expose detailed stats; distant ones expose appearance only. Unopened containers show no hidden contents. Shop sale/purchase details remain in place. The inherited TooltipPanel style is opaque near-black with a light border and readable text. No new identification rules or tooltip-only stat calculations.

Leather naming check: generator uses quality + material + base name. Several leather base names already include Rawhide/Leather/Hide, producing duplicate or contradictory wording (e.g. Common Rawhide Rawhide Armor). This is a presentation/catalog composition issue; stats use category/material fields, not the display name. Naming changes were not part of this UI implementation. Suggested follow-up: material-neutral base display labels, preserving base IDs and progression.

Validation: Item Presentation 12 checks passed, including backpack/nearby hover, distant-stat concealment, opaque background values, every equipment and equipped-pouch target, shared equip action. Final rendered inventory inspected at tests/paper_doll.png. Mouse Play regression 26 checks passed; Free Exploration 13 passed. Human hover/drag acceptance pending. Scoped whitespace check passed. Prior modified sources/baseline and test artifacts retained. No save reset or commit.
