# Tile Foundation — Art Style
Updated: 2026-09-11
Checkpoint: [Tile Foundation]+[Direction]+[StyleReview]
Implementation baseline/evidence: direct inspection of the linked source sheets and current Workshop renderer; hashes in BASELINE.json. Style proposal awaiting Rob's approval.

## Direction

Proposed name: **Overhead fantasy pixel art with continuous terrain.** Earthy colors, textured natural materials, restrained highlights, and readable landmarks. The hex grid remains a gameplay coordinate system; ordinary terrain should read as one landscape.

Confirmed by Rob: 2D, top-down, no visible tile edges. Rob expressed dislike of 2.5D POIs but uncertainty about the alternative. Default proposal: roofs, tree crowns and ground footprints viewed directly from above. Do not turn that proposal into an accepted POI decision without his review.

## Visual Evidence And Derived Rules

Rows and columns below are one-based in the source sheet.

| Reference | Retain | Conflict / resulting proposal |
|---|---|---|
| [Plains](../../Chad-Casso/Local_Map_Plains.png), first row | Olive/yellow-green grass, warm exposed earth, sparse flowers and gray stones; irregular pixel clusters | Remove the black hex frame and per-cell composition. Spread detail without outlining a cell or putting a centerpiece in every cell. |
| [Forest](../../Chad-Casso/Local_Map_Forest.png), first row and ground-detail last row | Deep green foliage, brown leaf litter, small warm highlights; denser detail than Plains | Visible trunks and side-facing crowns elsewhere mix viewpoints. For overhead direction, use crown shapes and ground gaps. Reduce detail if it obscures actors at play size. |
| [Hills](../../Chad-Casso/Local_Map_Hills.png), first row columns 1–2 | Gray stone mixed with the Plains grass family | Raised ledges and cliff walls elsewhere are perspective examples, not approved terrain style. Express relief through broad stone/grass patterns and restrained shading. |
| [Mountains](../../Chad-Casso/Local_Map_Mountains.png), first row columns 1–2 | Cool gray rock, pale gravel, muted moss; snow as a distinct light material | Tall peaks and visible cliff faces elsewhere conflict with strict overhead. The current renderer already selects the first two flatter samples. |
| [Water 03](../../Chad-Casso/Water_03.png) | Deep blue/teal base, subtle lighter ripples, relatively calm surface | Dark hex seams and recurring diagonal wave structures remain visible in the assembled panel. Use its color/material direction, not its tile framing or demonstrated repeat. |
| [POI sheet](../../Chad-Casso/POI_Overlay_Tiles.png) | Warm wood, cool masonry, restrained roof/flag color for landmark recognition | Frontal doors, tall side walls and miniature scenic bases are the unresolved perspective conflict. Existing art is a reference, not evidence of acceptance for the new style. |

## Proposed Art Rules

- **Viewpoint:** directly overhead orthographic terrain. No tilted ground planes, floating hex slabs, exposed tile thickness or horizon. Object volume may have subtle shading; shading must not imply a tilted camera.
- **Palette:** related earthy greens/browns, cool gray stone and blue/teal water. Small brighter accents identify flowers or landmarks. These are observed color families, not a measured or approved fixed palette.
- **Pixel treatment:** deliberate visible pixel clusters, crisp sampling and restrained texture noise. Existing sheets mix fine painted detail with pixel styling; they do not prove a single native pixel grid or historical 8-bit palette. Approve native asset resolution using an actual-size sample before assigning a universal pixel budget.
- **Lighting:** propose soft overhead light with short contact shadows and a consistent bias across assets. Avoid bevels, dark cell perimeters, bright cell centers and directional shadows that become incorrect under rotation. No claim that all existing art shares an exact light direction.
- **Detail hierarchy:** terrain is quieter than interactive objects. Plains sparse; Forest dense but readable; water quietest. Larger variation belongs across a patch, not repeated at the same position inside every hex.
- **Joining:** no painted borders, transparent cracks, bright rims, dark gutters or regular hex-shaped shading. Neighbors of the same material must appear continuous in all six directions. Different biomes need natural transition treatment; dropping borders alone will not create blends.
- **Geometry:** retain pointy-top hex mechanics and current 32-logical-pixel radius. That produces approximately 55.4×64 logical pixels per cell. Art delivery size is separate from display size. The earlier Water request specified four 128×148 cells in a 512×148 sheet; this is a recovered water request, not yet a universal atlas specification.
- **Interaction:** keep movement/selection legible through a separate temporary overlay. Exact overlay design remains open; the no-edges requirement forbids a permanent ordinary terrain lattice. POIs should be recognizable without an orange hex border.
- **Walls:** retain the existing flat black blocked-wall contract. Do not add raised wall sprites through this art-direction pass.

## What Flat POIs Would Look Like

| POI | Proposed directly overhead treatment | Existing perspective treatment |
|---|---|---|
| Town | Small cluster of roof shapes around a visible square or courtyard | Houses show front doors and tall facade walls |
| Tower | Circular or square roof/battlement footprint with a distinct central shape | Tall building or ascending stair face |
| Dungeon | Ground opening or stairwell seen from above, stone around the opening | Upright front-facing doorway |

Retain the natural terrain beneath each landmark; supply a transparent object overlay without a scenic hex base. At current play size, silhouette and a few strong color areas matter more than architectural detail. These descriptions are proposals, not a generated visual proof. If Rob needs a comparison, show the same landmark in the same terrain patch at the same scale before choosing; do not silently adopt 2.5D.

## Water 03 Delivery Finding

Water_03.png and Water_03_Proof.png are byte-identical (SHA-256 `7ab97312a65b73b3a474f605817af312bcf2553487bad4e6ff531d69acbc47aa`). Both are 1983×793, 8-bit RGBA PNGs containing four individual tiles plus an assembled panel. An alpha channel exists; usable transparency was not decoded/verified. Neither is the requested separate 512×148 sheet. They have not been integrated. The screenshot recovered the missing review request after three Bad Request failures; those failures do not establish an artwork defect or its technical cause.

## Acceptance For Future Art

1. Review a large joined patch at actual game size and enlarged nearest-neighbor size. Include all six adjacency directions and mixed variants.
2. Ordinary terrain shows no visible grid, gaps, halos, repeated diagonal bands or per-hex light/dark pulses.
3. Inspect biome transitions and one POI on the same patch; terrain remains readable behind actors and selection feedback.
4. Verify exact sheet dimensions, cell coordinates and real alpha outside supplied shapes. Separate asset sheet from proof image.
5. Rob approves the appearance. Image delivery and technical checks alone do not count as visual acceptance.

These are future acceptance checks; no new art or runtime patch has been produced by this documentation pass.
