# Actor Sprite Source And Processing
Updated: 2026-09-11
Checkpoint: [Actor Foundation]+[Presentation]+[Sprites]
Implementation baseline/evidence: supplied Workshop/Chad-Casso/Actors_01.png, inspected in the session; built-in imagegen edits used. Source sheet unchanged.

`actor_sprites_keyed.png` is a 1774×887 RGB source-derived atlas: player left, goblin right. The image tool did not deliver requested alpha/exact dimensions; the first result contained a painted checkerboard. A second edit replaced the background with a magenta key. The game samples explicit rectangles in ui/actor_sprite.gd and discards magenta in its CanvasItem shader, preserving dark outlines and white sword details. This is a runtime keyed asset, not a claim of a transparent PNG or pixel-exact original cutouts. No equipment animation is implied.

Both generated originals remain in the tool output directory; the selected atlas was copied into this Room for project use. No source files or generated variants were deleted. No CLI/API fallback used.

## First Built-in Edit Prompt

Use case: background-extraction. Edit the supplied character reference sheet into a production sprite atlas on REAL transparent background. Preserve the exact style, proportions, colors, south-facing poses, clothing and identities of only TWO existing characters: the Player in the bottom SIZE COMPARISON row (brown tousled hair, green tunic, brown boots) and the Goblin in the top MONSTERS row (green skin, ears, small sword). Remove all other characters, background, ground, shadows, labels and headings. Output a 1024x512 RGBA transparent canvas divided into two equal 512x512 cells. Left cell Player; right cell Goblin. Each complete character centered horizontally in its cell, feet aligned at y=460, whole silhouette inside x margins 100 pixels within each cell and y=60..460. No overlap between cells; preserve clean dark character outlines. These are static game sprites, not portraits or a promotional image. No text, no hex bases, no visible checkerboard, no glow. Preserve source design rather than invent new gear.

## Selected Background Edit Prompt

Edit only the background of this two-character sprite atlas. Replace ALL checkerboard/background pixels, including gaps between legs and arms, with one absolutely flat solid RGB #FF00FF magenta color. Keep both character silhouettes, faces, clothes, colors, black outlines, weapons, relative size and placement unchanged. No checkerboard, no transparency simulation, no gradients, no shadows, no text. The magenta is a chroma key for a game shader. Preserve all character pixels and clean hard edges as faithfully as possible.

## Validation

PNG header checked; imported as Texture2D. Actual Godot gameplay capture inspected after shader color correction. Visible character surroundings reveal the terrain rather than a rectangular image background. Visual acceptance by Rob is pending.
