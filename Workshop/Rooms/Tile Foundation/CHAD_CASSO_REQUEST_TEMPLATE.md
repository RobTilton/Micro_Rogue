# Tile Foundation — Chad-Casso Request Template
Updated: 2026-09-11
Checkpoint: [Tile Foundation]+[Delivery]+[TileRequirements]
Implementation baseline/evidence: working ART_STYLE.md and TILE_SET_REQUIREMENTS.md; template only, not a sent request or generated asset.

## Preparation

Copy the prompt below and replace every bracketed field for one set. Attach only the named permitted reference images; Chad-Casso may not have access to repository paths. Paste the applicable G, O or R delivery profile from [requirements](TILE_SET_REQUIREMENTS.md). Remove unused choices before sending. Keep requirements and chosen references consistent across batches.

## Copyable Prompt

Create **[SET NAME]** for a 2D game viewed directly from above.

Art direction: overhead fantasy pixel art, crisp deliberate pixel clusters, earthy natural colors, restrained highlights and continuous terrain. Match the attached reference's **[SPECIFIC COLORS / MATERIALS]**. Correct its **[BORDERS / SIDE FACES / REPETITION]**. No tilted camera, visible tile thickness, bevels, scenic hex bases, painted tile outlines or per-cell light/dark shading.

Required content: **[COPY THIS SET'S REQUIRED FEATURES]**.
Exclude: **[COPY THIS SET'S EXCLUSIONS]**.

Exact output specification:
**[PASTE THE COMPLETE APPLICABLE DELIVERY PROFILE, INCLUDING COUNT, CANVAS SIZE, CELL SIZE, COORDINATES/ANCHOR AND ALPHA RULES]**

Keep the same palette, pixel treatment and lighting across variants. Vary small surface details without changing the tile's overall brightness. For ground, all variants must join naturally along every one of the six hex sides; do not rely on a grid line to conceal mismatches. Do not add shores, roads or POIs unless this request explicitly includes them.

Deliver separate files:
1. **[SET NAME]_Assets.png** — exact clean production layout, no labels, headings, reference images or preview panel.
2. **[SET NAME]_Proof.png** — **[EXACT PROFILE-SPECIFIC PROOF]**, assembled using the actual delivered asset pixels. No visible terrain grid. Include actual game-scale viewing as specified.
3. A short text note stating dimensions, left-to-right cell order, intended transparency and any unmet requirement.

Do not combine assets and proof into one image or send the same composite under two filenames. Do not draw a different landscape and call it an assembly proof. If exact dimensions, alpha or assembly cannot be delivered, identify that limitation explicitly so we can prepare the final files separately.

The assembled result is the crucial visual check: **[A CALM UNBROKEN LAKE / CONTINUOUS FIELD / READABLE OVERHEAD LANDMARK ON TERRAIN]**. Attractive isolated tiles are not enough.

## Ready-to-Copy Example: Lake

Create four calm lake-water variants for a directly overhead 2D fantasy pixel-art game. Use the attached Water_03 image for its deep blue/teal palette and restrained pale ripples. Remove its dark hex borders and recurring diagonal ripple structures. No shorelines, foam rims, plants, rocks, boats, tilted perspective or hex-shaped shading.

Deliver Lake_Assets.png as a 512×148 RGBA PNG: four adjacent 128×148 cells in one row. Each cell contains a pointy-top hex with boundary vertices (64,0), (128,37), (128,111), (64,148), (0,111), (0,37). Coordinates describe boundaries, not pixel indices. Fill the hex completely; use real transparency outside it, without a colored fringe or painted outline. Keep the palette and overall brightness identical across variants. Small ripple details may vary. All six sides must join naturally across mixed variants without needing rotation.

Deliver Lake_Proof.png separately: an 8×6 or larger patch of touching hexes using all four actual asset variants, with no gaps or drawn grid. Include a view at approximately 55×64 logical pixels per hex as well as the larger asset-scale patch. Record the variant placement order in a short text note. The lake should appear calm and continuous, without diagonal stripes or repeating hex-shaped shading.

The proof must use the exact asset pixels. Do not combine the sheet and proof into a composite or duplicate one composite under two filenames. State any export or assembly limitation explicitly. No labels or presentation background in Lake_Assets.png.

## After Delivery

Review against TILE_SET_REQUIREMENTS.md. A visually attractive proof does not establish that the asset file has the requested dimensions, transparency or joins. Keep original delivered files; integration and any conversion are a separate task. This template does not send messages or authorize generating an entire batch automatically.
