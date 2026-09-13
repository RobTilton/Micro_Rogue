# UI
Updated: 2026-09-13
Checkpoint: [Regional Release]+[Delivery]+[Promotion]

`world_game.gd` is attached to Production/main.tscn. `start_menu.gd` builds the staggered vertical menu and `hex_menu_button.gd` draws outlined hexes, serif labels and underlines. Hover/focus lifts by 7 pixels over 0.14 seconds; disabled options remain still. Layout scales to the viewport.

Start actions: Options, Continue, World Data, New World, Regenerate World, plus Quit. Regenerate uses a new seed and a fresh adventurer, retaining difficulty only; the old world save is removed after durable replacement. Continue is disabled for unsupported old generators. Options persists movement confirmation in a preferences file. The extra-snapshot gameplay button is removed.

The composition remains base_game → game_ui → actor_game → world_game. Character creation, actor sprites, equipment panels, input and travel fade are preserved. All referenced runtime scripts/assets live inside Production. The right-click contextual menu remains unimplemented.

The HUD includes Free actions and momentum/speed. Paid controls accept flexible actions. Actor UI skips empty player ticks through the shared scheduler; travel preserves unspent budgets.

Equipment Integration adds Chest, Head, Arms and Legs targets alongside hands/belt, a versatile-grip action, exact Physical/Magical defense inspection and character totals, weapon stat/range details and six quality colors. Inventory equipment targets use a three-column layout.
