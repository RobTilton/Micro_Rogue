# Micro Rogue — Production Slice System

## Current Adopted Runtime — 2026-09-10

Checkpoint: [UI Foundation]+[Delivery]+[ProductionPromotion]. Root F5 now launches `Production/Current/ui/main.tscn`. See `Production/README.md` for current controls and the UI Foundation CURRENT_STATE.md promotion section for implementation details. Adopted additions: floating UI, grid inventory/card presentation, hex splash/floors, black blocked cells, shared Global/Local/POI grids with per-run state retention, path-based Lunge, and explicit Move/Loot/Look selection over ground items with entrance access. Production has no Workshop resource dependency. 2,190 checks pass. Old Gameplay/Splash remain preserved earlier-baseline sources. The arena-only launch, straight-line Lunge, list inventory and deferred map/UI descriptions below describe that earlier baseline and are superseded by this promotion. Combat formulas and character/item rules remain unless explicitly superseded above.

Updated: 2026-09-10
Checkpoint: [starting Slice]+[Delivery]+[ProductionPromotion]

## Rapid Shape

The accepted starting Slice is now the Production runtime baseline. The repository has one root `project.godot`. Root F5 currently launches the UI Foundation Workshop scene; the promoted slice is `Production/Gameplay/main.tscn` (open and press F6). All promoted runtime code and splash art live under Production. Workshop owns development Rooms, tests, design and AI-facing documentation. Production has no resource dependency on Workshop.

Rob accepted the slice with “everything so far works” and explicitly requested promotion. This is a tested proof/slice, not a claim that combat balance or the full game is finished. No Git checkpoint was created. The relocation preserved behavior and Godot script UID sidecars; the main scene now uses its explicit script path to avoid an existing cached UID resolving the old location.

Future experiments belong in a bounded Workshop Room. Import only the dependencies needed for that experiment. Updating the adopted runtime is a separately scoped Production promotion; Workshop is not a second live runtime owner. Root retains only launcher/repository infrastructure and generated ignored Godot cache.

## Entry Points And Controls

Open [root project.godot](../../../project.godot) in Godot 4.4.1 and open Production/Gameplay/main.tscn, then press F6 for this promoted slice. F5 runs the latest Workshop UI. The retained Room splash is also a scene in this same project; old nested configs are reference files only.

1. Begin adventure. Six d6 are rolled once. Drag a die onto a stat, or click source then destination. Assignments swap; the random assignment button redistributes the same roll. Confirm only after all stats have dice. Select difficulty here.
2. Click Move, Attack, or Lunge, then a highlighted hex or enemy. Ordinary movement is one continuous action. Lunge moves in a straight line; click an adjacent enemy for its optional attack, or skip. Riposte arms a counter. End Turn skips remaining actions.
3. Unlock Lunge → Riposte → Show-Off in the sidebar. One point at level 1 and each subsequent level. Stance Mastery is unavailable.
4. Inventory buttons equip, stock, remove potions, or drop items. Dropping equipped or backpack items places them at the player’s feet; each drop costs one activation in combat. Removing one potion from either an equipped or backpack belt moves it into the backpack and costs one activation in combat. Both are free outside combat. Empty weapon slots cannot perform weapon attacks; empty armor/shield slots contribute no equipment Defense. Dropped belts retain all contents. Inventory mutations wait until the pending optional Lunge attack is resolved or skipped. Inventory buttons also equip or stock items. A removed item goes into the backpack. A picked-up potion fills the equipped belt first. Backpack belts can be stocked and retain contents when equipped. Equipment/stocking costs one activation in combat.
5. Defeat an enemy, approach its tile, and take actual possessions. A next-test-encounter button spawns another level-1 enemy without healing/resetting the player; gear and remaining ground loot persist. This button is a test harness, not an overworld mechanic. Ground loot retains its own hex coordinates across test encounters.
6. Death permits a fresh character and roll.

## Component Locations And Ownership

- `Production/Gameplay/main.gd`: presentation, selection state, encounter orchestration, simple enemy decisions; owns actor instances and action allowances.
- `Production/Gameplay/actors.gd`: six-stat generation and actor initialization; XP progression.
- `Production/Gameplay/items.gd`: rarity, material dice, armor and belt generation; equipment rolls.
- `Production/Gameplay/combat.gd`: hex distance, action allowances, attack/Defense calculation, difficulty rounding, healing and loot costs. Includes attack/range modifier inputs; no affix implementation.
- `Production/Gameplay/cooldowns.gd`: reusable ability-ID clock for skills and future spells; independent counters and outside-combat fractional elapsed time. Values live in `main.gd` SKILL_COOLDOWNS.
- `Production/Gameplay/inventory.gd`: item ownership transfers, equip swaps, potion removal, equipped/backpack dropping and actual-possession drops. Belts own their stored potions.
- `Production/Gameplay/die_slot.gd`: drag/drop die presentation and transfer signal.
- `Production/Gameplay/hex_board.gd`: board drawing, highlights and selection signal. No combat damage ownership.
- `Production/Gameplay/main.tscn`: root scene. Splash art is loaded from `Production/Splash/splash_art.gd`, copied unchanged from the preserved standalone Room prototype.
- `Workshop/Tests/StartingSlice/slice_test.gd`, `Workshop/Tests/StartingSlice/flow_test.gd`, `Workshop/Tests/StartingSlice/inventory_cooldowns_test.gd`: headless rules and integration checks.

## Implemented Rules

- HP = 3 WIL. CON heals only through events. Lesser Health restores CON up to max HP; no passive regeneration.
- Sword damage = material die + rarity bonus + 0.5(STR + DEX) + attack modifier. Lunge adds 1.5 STR to this full attack.
- Defense is freshly rolled for each attack: DEX + 0.5 WIL + armor die/rarity + equipped shield die/rarity + Defense effects. Riposte adds DEX while armed. No stat scaling is added to the equipment rolls themselves.
- All attacks connect. Subtract Defense, clamp at zero, then round final damage. Only positive rounded damage lands. The pre-health-mutation boundary is reserved for future landing effects; no generic affix engine is introduced.
- Normal: outgoing ceil/incoming floor. Hard: ceil both. True Rogue: outgoing floor/incoming ceil. Healing remains capped independently of rounding.
- Turn: one attack, movement, activation; any order. Show-Off with two swords grants two attacks, main then offhand. Lunge/Riposte spend attack actions. Movement: 3 + DEX. Lunge: up to ceil(0.5 DEX + 1), straight, blocked by occupied/out-of-bounds hexes; attack optional.
- Riposte lasts through the next received attack, including zero damage, or until the next player turn. Counter costs no additional action and obeys weapon range. Positive counter damage offers optional travel up to ceil(0.5 DEX). Prototype interpretation: a dead actor cannot counter.
- Lunge cooldown starts at 4 on movement commit, even when its optional attack is skipped. The use-turn End Turn reduces it to 3; the following three player turns are gated until subsequent End Turns reach zero. Riposte starts at 2 on activation, gating one following turn. Both counters reduce once per player End Turn in combat, or once per 3 seconds outside combat while alive in the arena. No real-time recovery in combat, creation, or death screens. Counters survive encounter transitions; new characters start clear. Entering combat discards a partial real-time tick. Wisdom scaling is deferred. Buttons display remaining ticks and disable unavailable skills; Show-Off cannot bypass a skill cooldown.
- No split ordinary movement. Equipping a second sword mid-turn grants the second-attack allowance next turn; swapping equipment never replenishes spent actions.
- Combat loot cost per item: activation, each attack, then movement. Exhausted actors cannot loot. Outside combat no action costs. Enemy AI moves toward the player, attacks in range, and drinks a belt potion at HP ≤ half maximum.
- Level 1→2 costs 5 XP; each following requirement doubles. Excess XP carries forward. Enemy reward equals its level. Enemy skills remain absent.
- Player rarity weights: 20/40/20/18/2; enemy 40/60 Trash/Common. Bonuses: -1/0/1/2/4. Bronze sword 1d4; wooden shield 1d2. All nine armors uniformly selected with supplied dice. Starting belt material uniformly chosen; capacity 3/4/5/6/8 plus material tier 0/1/2. Each slot independently has 5% potion probability. Starting actor/enemy stats use the same six-d6 generation.

## Validation And Limits

Godot 4.4.1 Linux headless execution: 2,027 existing rule checks plus 37 inventory/cooldown regression checks passed. The added tests cover turn/real-time timing, Show-Off gating, activation costs, empty slots, stocked belts, distinct drop locations, and encounter persistence. Integration flow passed creation, arena, Lunge, Riposte, loot, equipment, next encounter, and death/restart. Root scene smoke run passed. Editor startup completed but sandbox socket-listener errors and a warning about the preserved nested splash project occurred; direct game and test execution are the useful validation evidence. Windows Godot execution from WSL failed with a socket error.

Commands (Linux validation binary retained in /tmp):

```sh
XDG_DATA_HOME=/tmp/slice_godot_data /tmp/godot_slice_validation/Godot_v4.4.1-stable_linux.x86_64 --headless --path . --script Workshop/Tests/StartingSlice/slice_test.gd
XDG_DATA_HOME=/tmp/slice_godot_data /tmp/godot_slice_validation/Godot_v4.4.1-stable_linux.x86_64 --headless --path . --script Workshop/Tests/StartingSlice/flow_test.gd
```

Rob visually played and accepted the slice, including inventory/cooldown changes. Relocation was verified headlessly; no new human visual test of the moved paths is claimed. Overall encounter balance remains open. Current Defense rolls can produce frequent zero damage and some unwinnable stat/gear matchups; supplied numbers are preserved. Low-bit splash/actor geometry is in place; gameplay UI uses Godot's readable default font. Backpack is a list, not the eventual grid. No save/load, procedural world/POIs, full equipment affixes, alternate die pools, stat-derived loadouts, or DEX initiative clock.

All runtime outputs are adopted into Production; tests reside in Workshop/Tests/StartingSlice and the original splash remains in its Room. Relocation was authorized; no content was discarded and no Git commit was made. Validation artifacts: /tmp/build_slice.py, /tmp/godot_slice_validation.zip, /tmp/godot_slice_validation/, /tmp/slice_godot_data/, /tmp/slice_godot_config/, /tmp/slice_godot_cache/. Godot .godot/ cache is ignored by the added root .gitignore.

## Production Promotion Evidence

All 24 relocated source, scene, UID and design files matched their pre-move SHA-256 values after normalizing the intentional resource-path changes and removal of the stale main-script UID reference. All 11 Production resource references resolve inside Production. The adopted splash script is byte-identical to the retained prototype.

After relocation: 2,027 rule checks and 37 inventory/cooldown checks passed; full flow test and root-scene smoke test passed on Godot 4.4.1. The initial smoke test exposed the stale scene UID reference; explicit path resolution fixed it. Tests import Production source directly, so they validate the adopted code. Preservation manifest retained at `/tmp/starting_slice_promotion_manifest.json`.

The project-level provisional design is [Workshop/Design/Micro_Adventure_Roguelike_Design_Doc_v0.1.md](../../Design/Micro_Adventure_Roguelike_Design_Doc_v0.1.md). Its unresolved/future items do not override the implemented slice contract above.
