# Sprite Integration
Updated: 2026-09-15
Checkpoint: [Sprite Integration]+[Validation]+[Existing Objects]

F5 Production replaces current prop placeholders with cropped art: chest (closed/open), barrel and crate (intact/broken), rug, bones, corpse remains and rubble. Opened bones/remains/chests are dimmed. Chest contents pictured in the art are decorative, not a representation of generated loot. No loot or interaction changes.

Wells, ladders, downward DungeonFloor/Underground transitions and upward TowerFloor transitions have matching sprites. Existing Local POI art stays intact. The scenery layer draws only the same visible props supplied by actor_game; transition links retain prior visibility and hit targets. Crops scale with map zoom, below actors. Friendly actor indicators stay teal.

Enemy goblins use scout art and chief art for bosses; raiders use matching raider art. Town Crier uses elder art, residents use civilian art. Player keeps existing art. Wolves retain the previous placeholder because no matching wolf sprite was found. Skeletons/orcs and other unused sheet creatures are not added to generation. No equipment-dependent sprite system was introduced.

Production assets: Assets/Scenery/props_keyed.png, enemies_keyed.png, people_keyed.png, dungeon_keyed.png. Sources: Workshop/Chad-Casso/POI_Overlay_Scenery_02.png, Slice_Enemies_01.png, Actors_01.png, Dungeon_Deco_01.png. Built-in imagegen prepared background-edited copies; original sources remain untouched. The initial requested alpha edit produced a painted checkerboard, so final copies use solid magenta removed by a runtime shader. They are RGB atlases, not PNGs with alpha. Region mappings were visually inspected; image editing can slightly change source detail. Prompt record: ART_PROMPTS.md.

Runtime: UI/scenery_layer.gd owns prop regions and keyed draw; actor_view.gd feeds visible objects; world_view.gd suppresses replaced transition letters; actor_sprite.gd chooses matching actor art. All runtime assets resolve within Production.

Validation: completed Godot texture import; rendered sprite_preview.gd and preview.png inspected for all prop states, transition appearances and actor choices; live town screenshot inspected. Adventure Loop 51 checks and Interior Scenery 37 checks passed. Final transition/friendly-color adjustment rendered successfully. Scoped whitespace passed. Human F5 acceptance pending. References and test artifacts retained; no save reset or commit.
