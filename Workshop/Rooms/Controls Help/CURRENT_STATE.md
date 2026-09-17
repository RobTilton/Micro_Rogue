# Controls Help
Updated: 2026-09-15
Checkpoint: [Controls Help]+[Validation]+[Options Page]

Start-menu Options and in-game Options both expose Controls. Shared text lives in Production/UI/controls_help.gd. The start page uses a scroll container and Back to Options; in-game help uses the existing scrollable panel host, close control and Back to Options.

First section explains actual Global access: leave POI to Local, find Return to Global via the Map panel's coordinate listing, stand on that exit, then double-click self or select its transition in Map/Activate. No new overview/travel shortcut or keyboard binding is introduced. Includes movement confirmation and Shift bypass, camera pan/zoom/focus, Local-edge crossing and route restrictions, contextual combat, equip/unequip, belt emptying, item rotation, shop confirmation bypass, recovery, quests, Escape and autosaving. Sidebar numbers are explicitly labels rather than keyboard shortcuts.

Validated current handlers and location generation when writing instructions. controls_test.gd passed 56 checks including both Options entries, shared help sections, Back navigation and 51 Adventure Loop gameplay/save checks. Rendered controls.png inspected. Human reading/playtest acceptance pending. Original modified scripts retained under Reference/. No save changes or commit.
