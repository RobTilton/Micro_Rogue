# Sprite Background Edit Prompts
Updated: 2026-09-15

Tool: built-in image_gen, background-extraction edits. All requested final atlases copied into Production/Assets/Scenery. Original inputs retained.

Props and enemy first pass requested removal of painted gradients (and enemy text), actual PNG alpha, preserving every sprite position, dimensions, ordering and 1536×1024 canvas. Output had painted checkerboards and was not adopted.

Final props/enemies prompt applied to the first-pass outputs:
> Edit target: supplied sprite atlas. Replace ONLY the gray/white checkerboard background with perfectly uniform saturated pure magenta RGB(255,0,255), #ff00ff. The prior transparency was a painted checkerboard, so use chroma key instead. No gradient, no checkerboard, no shadows outside silhouettes. Keep every sprite exactly as-is, identical layout and 1536x1024 canvas. Do not move resize redraw or add objects. Magenta everywhere outside object silhouettes, including gaps between limbs.

People prompt, applied to Actors_01.png:
> Background extraction for existing sprite atlas. Remove all labels/text and background gradient. Replace all background with perfectly uniform saturated magenta #ff00ff (NOT checkerboard). Keep every character exactly same location size shape clothing and ordering. Preserve original 1536x1024 canvas. No new sprites or redesign. Fill gaps between arms/legs with same magenta. Production game will remove magenta with shader.

Dungeon decorations prompt, applied to Dungeon_Deco_01.png:
> Edit supplied game sprite atlas: remove all text labels and background, replacing all non-object pixels with uniform pure magenta #ff00ff for chroma key. Preserve all object sprites positions sizes shapes colors and 1536x1024 canvas. No checkerboard, no redesign or additions. Only background extraction and label removal.
