# Village — Chad-Casso Art Request
Updated: 2026-09-13
Checkpoint: [Village Foundation]+[Art]+[Request]

Prepared from [the existing request template](<../Tile Foundation/CHAD_CASSO_REQUEST_TEMPLATE.md>) and [object-overlay delivery profile O](<../Tile Foundation/TILE_SET_REQUIREMENTS.md>). This adapts O from three objects to six, retaining cell dimensions, anchors, transparency and game-scale proof. It is a request for reviewable placeholder village interaction landmarks, not approval of final building scale or a new renderer contract.

## Attach these references

Chad-casso may not have repository access. Attach these actual images with the prompt:

- [Local_Map_Plains.png](../../Chad-Casso/Local_Map_Plains.png) — first-row grass/earth colors and pixel texture only. Ignore black hex frames.
- [Local_Map_Forest.png](../../Chad-Casso/Local_Map_Forest.png) — deep green and brown palette only. Ignore black frames, upright trunks and side-facing trees.

Do not attach water, actor, inventory-item or prohibited artwork. The request below is ready to copy in full.

## Copyable request

Create **Village_Core_01**, six modular object overlays for a directly overhead 2D fantasy pixel-art game. These are individual village buildings/stalls placed on separately rendered terrain, not one complete village illustration and not a village icon for the world map.

Art direction: overhead fantasy pixel art with crisp deliberate pixel clusters, earthy natural colors and restrained highlights. Match the attached Plains reference’s olive/yellow-green surroundings and warm earth, and the Forest reference’s deep greens and browns. Use warm weathered timber, muted fabric, dull iron and cool gray stone for the objects. References establish palette/material treatment only: remove their hex borders and disregard side-facing forms.

View everything vertically from above. Show roofs, canopy tops, counters, roof openings and ground footprints. No tilted camera, isometric perspective, visible building facades, upright shopfronts, floating platforms, tile thickness, bevels, scenic hex bases, painted tile outlines or per-cell light/dark shading. Use short, restrained contact shadows only, contained within the object’s permitted area.

Required content, in this exact left-to-right order:

1. **Inn:** a modest timber-and-stone inn landmark, recognizable by its roof silhouette, warm roof color and small chimney. Indicate its access side with a small overhead threshold extending from the roof footprint. No frontal door or interior cutaway. This is a compact exterior interaction placeholder, not a full architectural plan.
2. **Blacksmith stall:** an open-sided work stall with a partial canopy, unmistakable overhead anvil, compact forge/hearth and a small metal-work counter. Keep those shapes clear at game size; no smoke covering the silhouette.
3. **Leatherworker stall:** a matching village stall with a tan/brown canopy, a worktable and one recognizable hide laid flat on it. Sparse leather rolls may reinforce the trade.
4. **Tailor stall:** a matching stall with muted colored fabric, a folded-cloth counter and a few broad fabric rolls. Make it distinct from the leatherworker through color and shape rather than tiny stitching details.
5. **General-goods stall:** a matching stall with a simple counter, crates, sacks and a basket. Practical supplies, modest colors and no recognizable magical equipment.
6. **Closed jeweler:** a small matching booth with its counter visibly shuttered or covered and a closure bar/plaque. Use one restrained gem-shaped emblem to identify the trade. The closure must read without words. No visible merchandise, customers or glowing treasure. The game can add a readable “Closed” label separately.

The shop props communicate trade identity only; they must not depict specific saleable items, quality tiers or randomized stock. Keep the inn slightly more substantial in silhouette than a stall, but fit all six assets into the same cell specification. Do not add alternate versions in this batch.

Exclude NPCs, player/enemy sprites, animals, ground tiles, roads, fences, walls enclosing the village, wells, churches, castles, extra shops, UI buttons, text, prices, labels and headings. Ambient villagers and shopkeepers are separate game actors, not painted into these assets. No inn interior, beds, animation or open-jeweler variant is requested.

**Exact asset specification — adapted object-overlay profile O:**

- Export **Village_Core_01_Assets.png**, a **768×148 RGBA PNG**.
- Six adjacent **128×148 cells**, one row, no padding or gutters between cells.
- Cell origins: **(0,0), (128,0), (256,0), (384,0), (512,0), (640,0)**.
- Within each cell, center the object footprint at **(64,74)**.
- Keep the entire object, small threshold and contact shadow within the central **112×128** area: local boundary coordinates **x=8 through 120, y=10 through 138**. These are boundaries, not inclusive pixel indices.
- Use genuine transparency outside the actual object, including empty space inside the cell. No filled hex, terrain beneath the object, checkerboard baked into the image, matte fringe or opaque background.
- Keep palette, pixel treatment and lighting consistent across all six objects. Silhouette and a few clear trade details must remain recognizable when each cell is displayed at approximately **55×64 logical pixels**.
- Do not draw cell dividers, coordinates, captions or a preview panel into the asset sheet.

**Deliver the proof separately:**

Export **Village_Core_01_Proof.png**, assembled using the exact pixels from the delivered asset sheet. Show the six objects in a loose village-square arrangement with generous walkable gaps, inn at one side, stalls facing the open square and the closed jeweler clearly visible. Use simple, quiet olive grass/warm earth beneath them, matching the reference palette. This background is proof-only; it must not appear in the asset PNG.

Include the assembly at original asset scale and a second version at approximately 55×64 logical pixels per cell using nearest-neighbor sampling. Also show the same six assets over a darker Forest-colored ground swatch at game size so transparent edges and silhouettes can be judged. Do not paint over, resize independently or redraw individual assets to improve the proof. No visible hex grid. Labels may sit outside the proof panels only.

Provide **Village_Core_01_Notes.txt** stating exact dimensions, left-to-right object order, transparency intent, proof placement/scaling and any unmet requirement. If exact dimensions, alpha or assembly cannot be delivered, explicitly state the limitation. A separately drawn village is a concept illustration, not an assembly proof.

Deliver the asset PNG, proof PNG and note as separate files. Do not combine assets and proof into a composite or send the same composite under two names.

The crucial visual check is **a readable, modest overhead village whose trades are distinguishable at actual game size, without visible tile borders or 2.5D buildings**. Attractive isolated stalls are not enough.

## Scope after delivery

Rob reviews the appearance. Technical review must verify actual dimensions, cell order, alpha and proof fidelity before integration. Preserve original deliveries. The village layout, terrain, collision, access cells, shop menus, NPCs, inn action and stock persistence remain gameplay work; this brief does not implement or settle them.

Village intent supplied by Rob: inn rest passes time and heals 2×CON without consuming a ration, at a gold cost; blacksmith, leatherworker, tailor and general goods; ambient NPCs; closed jeweler. Each shop stocks max(5, 3×prosperity) randomly generated items, retained until a new week. Every three prosperity points raises the maximum item tier. Week duration, starting-tier interpretation, price adjustments and inn price still need concrete gameplay rules. None affects the requested asset count or appearance.
