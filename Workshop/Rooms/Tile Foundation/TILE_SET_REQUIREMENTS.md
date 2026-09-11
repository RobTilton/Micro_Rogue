# Tile Foundation — Tile Set Requirements
Updated: 2026-09-11
Checkpoint: [Tile Foundation]+[Delivery]+[TileRequirements]
Implementation baseline/evidence: current world_view.gd, poi_art.gd, marsh_art.gd, wasteland_art.gd and river_art.gd in UI Foundation/Prototype, inspected 2026-09-11. Requirements are proposed replacement deliverables, not existing asset capabilities.

## Shared Direction

Use [ART_STYLE.md](ART_STYLE.md) as the working art specification: overhead fantasy pixel art, earthy materials, continuous terrain, no visible tile edges. Flat overhead POIs are the working request direction; Rob's final visual adoption remains pending. This inventory covers terrain, floor, river and POI sheets used by the Workshop map renderer. Actor, sword/item and splash art are separate systems.

Retain color/material identity from each source. Replace side-facing buildings, trunks, peaks and cliffs with overhead forms. Avoid cell-centered compositions, directional bands, bevels, glow rims and baked hex outlines. Real terrain boundaries such as water meeting land are distinct from unwanted tile borders.

## Proposed Delivery Profiles

These are new request defaults. Existing renderer coordinates will need a later integration change; these files are not drop-in replacements. Four variants per material are an initial manageable batch, not a claim that four guarantee seamlessness.

**G — Ground:** four pointy-top hex variants, each in a 128×148 transparent cell; single-row 512×148 RGBA PNG, no padding between cells. Use local hex boundary coordinates (64,0), (128,37), (128,111), (64,148), (0,111), (0,37), measured on cell boundaries; the right/bottom boundary is outside the last pixel center. Fully cover the hex interior, transparent outside it, no antialiased matte fringe. All variants share compatible edge color/detail across all six sides. Keep edge detail quiet without creating a uniform visible ring. No rotation required to achieve joins. Crisp pixel clusters; exact native pixel density remains subject to actual-size review.

**O — Object overlay:** Town, Dungeon and Tower in three 128×148 cells, single-row 384×148 RGBA PNG, ordered left to right. Transparent outside the actual object, including within the cell; no ground hex, scenic background or cell frame. Center each footprint at (64,74); keep the complete object inside the central 112×128 area. Recognizable at roughly 55×64 logical pixels. Draw underlying terrain independently in the future renderer.

**R — River surface:** one 128×128 opaque PNG containing only a calm water surface, seamless on opposite horizontal and vertical edges. No painted river shape, banks, bridges, arrows or flow direction. The existing code supplies shared-edge geometry and junctions. Proof must include repeated surface plus an example of narrow connected strips; this illustrative proof does not replace a future in-engine junction check.

For each profile provide separate `<SetName>_Assets.png` and `<SetName>_Proof.png`, plus a short text description of cell order and dimensions. Proof must be assembled from the exact asset pixels, not a separately imagined landscape. If exact assembly/export is unavailable, say so; a concept rendering must be labeled concept, not proof. Never overwrite the existing source files.

Ground proof: at least 8×6 touching hexes using all four variants with a recorded placement order, no gaps or grid overlay. Include original asset-scale patch and a separate game-size view at approximately 55×64 per hex. No requirement that opposite rectangular atlas edges themselves tile: the six hex edges are the join contract. Cross-biome blending is separate work; these homogeneous base sets do not solve every biome transition.

## Currently Used Sources And Required Replacements

Source filenames below are relative to Workshop/Chad-Casso. Counts describe requested output, while the current-use column records existing sampling.

| Existing source / current use | Required updated set(s) | Required material and overhead features | Exclude / proof focus |
|---|---|---|---|
| Local_Map_Plains.png; eight first-row samples | Plains — G, four variants | Olive/yellow-green grass, warm soil flecks, sparse tiny flowers and stones | No roads, trees, fences, ponds or central landmark. Joined open field must stay quiet. |
| Local_Map_Forest.png; eight first-row samples; also current Swamp fallback | Forest — G, four variants | Deep greens, overhead canopy clusters, leaf litter and irregular ground openings | No exposed upright trunks, side-facing trees or framed clearings. Check that repeated crowns do not form a lattice. Does not serve as final Swamp art. |
| Local_Map_Hills.png; first two flatter samples | Hills — G, four variants | Plains-related grass and gray rock, gentle overhead relief indicated by irregular material patches | No cliff faces, terraces viewed from the side or raised slabs. Check continuity with Plains color family. |
| Local_Map_Mountains.png; first two flatter samples | Mountains — G, four variants | Cool rocky ground, overhead ridge patterns, pale gravel, restrained moss/snow accents | No upright pyramidal peaks, exposed side walls or miniature mountain dioramas. Do not fill every cell with a centered peak. |
| Local_Map_Desert.png; eight first-row samples | Desert — G, four variants | Warm muted sand, subtle overhead dune traces and sparse pebbles | No dunes presented in profile, roads, ruins or periodic diagonal ridges. Keep edge brightness consistent. |
| Local_Map_Marsh.png; seven explicitly selected mud/reed/pool samples; Global and Local | Marsh — G, four variants | Mud, low vegetation, overhead reed tufts and small irregular shallow pools | No buildings, boats, bridges or full-cell water borders. Pool placement must not trace the hex perimeter. |
| Local_Map_Wasteland_DO_NOT_USE_THE_ROADS.png; three selected ground samples | Wasteland A — G, four variants | Dry cracked earth and weathered gray/brown stone; use only permitted non-road source areas | No source roads, modern objects, buildings or implied usable POIs. Cracks must not outline each tile. |
| Local_Map_Wasteland_02.png; three selected samples, mixed with first sheet | Wasteland B — G, four variants | Same compatible earth/stone palette and boundary treatment as A, with subtle rubble differences | This source's stone roads are permitted but not needed in this ground batch. Mixed A/B proof must join without palette checkerboarding. |
| Ocean_And_Lake_Tiles.png; interior samples for Local sea/lake and Salt Marsh water | Sea — G, four variants; Lake — G, four variants | Broad quiet blue/teal open water. Sea may be slightly deeper/cooler; Lake may be slightly softer/greener while matching approved reference colors | No shorelines, foam rings, rocks, plants, boats or full-hex wave pattern. Each set must pass its own joined proof. Use Water_03 as color/ripple reference, not a border/layout example. |
| ground_prototype_02.png; seven floor samples for POI/fallback floor | DungeonFloor — G, four variants | Overhead worn stone, muted earth/moss and restrained small cracks | No raised masonry, painted wall tiles, stairs or perspective. Existing blocked walls stay code-drawn black. |
| River_Water_Texture.png; only an 80×20 interior water rectangle currently sampled | RiverWater — R | Calm fine blue/teal surface compatible with open-water palette, legible at narrow widths | No bank built into the texture; confirm no obvious repeats at strip joins. |
| POI_Overlay_Tiles.png; Town, Dungeon, Tower only | LocalPOI — O, three distinct objects | Town: roof cluster/courtyard; Dungeon: overhead ground opening/stairwell; Tower: distinct roof/battlement footprint | No frontal doors, tall facade views, scenic hex bases, orange outlines or cast shadows across neighboring cells. Proof each over Plains and Forest at play size. |
| OVERWORLD_TILES_BIOME.png; eight biome samples, with Swamp→Forest and Salt Marsh→Sea fallbacks; Marsh separately sampled | GlobalBiomes — four G variants for each of the eight base identities, delivered as eight separately named G sheets | Plains, Wasteland, Hills, Mountains, Forest, Sea, Lakes, Desert. Same materials as Local, simplified to broad recognizable overhead patterns at one-cell regional scale | No mountain/building side faces, mini-dioramas, hex rims or excessive Local-scale clutter. Provide a labeled contact sheet separately from assets and a mixed regional proof. Exact order of the old atlas is not a new delivery constraint. |

This accounts for all 13 currently loaded source sheets, counting both Wasteland sheets individually. The proposed Global pack contains eight identities; Marsh remains its separate current source. A combined Global atlas can be assembled during later integration from accepted sheets without requiring the artist to improvise packing.

## Existing Fallbacks And Files Not Yet Used

- **Swamp:** Local_Map_Swamp.png exists but is not loaded by this renderer. Future Swamp — G should show overhead dense wet canopy, dark soil and irregular standing water, visually distinct from open Marsh. This is a planned replacement for Forest fallback, not a current-source claim.
- **Salt Marsh:** Local_Map_Saltwater_Marsh.png exists but is not loaded. Future SaltMarsh — G should show low salt-tolerant vegetation, gray/tan mud and tidal pools with sea-compatible water. It is a land/wetland identity, not another name for ocean. Separate runtime mapping will be needed.
- **Water_03.png / Water_03_Proof.png:** review references only, byte-identical composite images. Keep their calmer water direction; require separate assets and true proof for new deliveries.
- Earlier floor sheets, Water_Hexes_v2.0, city POI sheets, dungeon decoration sheets and unused POI kinds are not requested merely because they exist.
- DO_NOT_USE_FutureWasteland.png remains prohibited for inspection and use. Do not attach it as a reference.
- Ice caps and blocked dungeon walls are code-drawn colors; no replacement sheet requested.

## Review And Integration Boundary

First request a small representative batch: Plains, Lake, Forest and Town (a single O cell, 128×148, when requested alone). Validate the working style at actual scale before ordering every set. Then use the same profile across remaining sets.

Check pixel dimensions, alpha, cell alignment, six-direction joins, mixed variants, repeating patterns and POI readability. Rob judges visual acceptance. Asset validation is not gameplay validation. Later integration must update source paths/UVs/counts, remove ordinary board outlines and POI rims, retain terrain beneath overlays, and preserve movement/hit testing. This document does not implement those changes or claim seamless transitions between different biomes.
