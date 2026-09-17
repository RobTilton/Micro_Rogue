# Interior Presentation
Updated: 2026-09-15
Checkpoint: [Interior Presentation]+[Validation]+[Floors and Hover]

F5 uses existing Chad-Casso floor art for distinct interiors: caves dirt/loose stone, dungeons laid/cracked stone, ruins mossy stone, wells wet stone, towers wooden planks. Source Dungeon_Tile_Set_Lots_Are_Bad.png copied unchanged to Production/Assets/Terrain/interior_floor_atlas.png. Only suitable first-row floor cells are sampled, inset from painted borders. No generated/edited art. Existing town and outdoor floors unchanged.

UI/interior_floor_art.gd owns source selection and UV rendering. actor_game supplies the saved location template to world_view. Cave topology takes precedence, including cave outcomes beneath wells; Underground ruin outcomes use mossy stone. Existing saved maps receive the new presentation without geometry changes or save migration. Wet floor appearance does not add water/traversal mechanics.

Decorative rug/rubble hover shows their name only, with any actual ground item details still appended. Containers retain search/searched wording. Existing menus already excluded decorative search actions and remain unchanged.

Validation: interior_test.gd passed 54 checks, including rug/rubble/container hover distinctions and the 51 Adventure Loop gameplay/persistence checks. floor_preview.gd rendered all five treatments; floors.png inspected for distinct textures and clipped borders. Human F5 acceptance pending. Original UI sources retained under Reference/. No commit or player-save reset.
