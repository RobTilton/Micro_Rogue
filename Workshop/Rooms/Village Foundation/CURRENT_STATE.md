# Village Foundation — Current State
Updated: 2026-09-13
Checkpoint: [Village Foundation]+[Runtime]+[RoofShops]

Latest design direction: Rob now wants whole-building overlays without hex-shaped artwork. The two newly imported building files were inspected; their adoption is not yet implemented. The existing single-hex runtime described below remains in place until that follow-up.

Existing roof artwork is now used as six single-hex shop placeholders in newly generated Production Town locations. Whole roofs are sufficient; realistic architectural scale, interchangeable roof segments and improved artwork are deferred. Walkable building interiors remain future work.

## In game

The six locations are Inn, Blacksmith, Leatherworker, Tailor, General Goods and a closed Jeweler. Each roof occupies one blocked hex with open neighboring cells. Stand adjacent, then click the roof in movement mode or choose its name under Activate. Browsing the menu does not spend an action. The shared actor service verifies distance, sight and life state.

These are interaction placeholders: trading, stock, gold, inn healing/rest, rations, time and weekly refresh are not implemented. Menus explicitly show unavailable services; the jeweler shows Closed. No character-start change or new NPC population was made.

New Town generation replaces its former two generic wall blocks with the six shop cells. Return and Well entrances remain accessible. Already saved Town maps retain their exact geography and have no shops retrofitted. Visit a previously ungenerated Town to see these; a world reset is not required.

## Implementation

- `Production/World/village_shops.gd`: six identities and a fixed initial layout, independent of economy and actor data.
- `hex_map.gd`: shops stored by hex; occupied roof cells are not walkable.
- `location_world.gd`: installs the layout only for newly generated Town interiors.
- `Persistence/map_state.gd`: snapshots shops, validates their bounds/shape and restores older maps with an empty dictionary. Source and return cells cannot be shop cells.
- `UI/shop_roofs.gd`: atlas regions from an unchanged copy of Civilization_roof_tiles.png; shader hides near-black background. Native aspect ratio preserved, scaled inside one gameplay hex. This is rendering, not a rewritten or extracted image asset.
- `UI/world_view.gd` and `hex_board.gd`: render the roofs over normal ground; movement blocking is independent of wall appearance. Names/Closed are separate game text.
- `Actors/actor_world.gd`: shared `inspect_shop(actor, cell)` read-only proximity boundary.
- `UI/actor_game.gd` and `game_ui.gd`: adjacent click/Activate menus.

The intact source is owned under Production/Assets/Buildings. No Workshop runtime resource references. Civilization ground/floor tiles and the separate thatched kit remain unintegrated; this pass uses the earlier preferred multi-material roof sheet. Existing dungeon-style floor art remains a placeholder under the roofs.

## Evidence and next work

Rendered Godot test: 26 checks passed, covering six blocked roofs, adjacent/distant access, reachability, map roundtrip, old-map defaults, exact world save/load, menu content and six rendered sprites. Screenshot [tests/shops.png](tests/shops.png) was visually inspected; ground shows beneath roof silhouettes without black wall bases. Isolated test saves are retained under tests/saves. Human visual/playtest acceptance remains pending.

Original source pixels are preserved byte-for-byte. Changed runtime originals and prior manifest are in Reference/SingleHex. Production/BASELINE.json records adoption. No Git commit or user-save reset.

Next gameplay work is village services: settle pricing/inn costs and time/week semantics, then implement persistent stock and transactions through shared actor capabilities. Earlier art requests and reviews are retained in [ART_REVIEW_HISTORY.md](ART_REVIEW_HISTORY.md) and CHAD_CASSO_VILLAGE_REQUEST.md; neither is a request to redo the roofs.


## Whole-building source review

Rob explicitly superseded the single-hex art restriction: whole buildings can be superimposed on the map without hex silhouettes. Visual extent and gameplay footprint should be separate; an anchor, blocked hex cells and accessible doorway interaction cells can describe the building while its sprite spans the map freely. No roof slicing or arbitrary roof assembly is required.

New sources, both visually inspected and header-checked at 1536×1024, 8-bit RGBA:

- [Civilization_building_1.png](../../Chad-Casso/Civilization_building_1.png): one detailed thatched timber/stone building with a clear front doorway.
- [Civilization_buildings_1-12.png](../../Chad-Casso/Civilization_buildings_1-12.png): twelve material/weather variants of the same building form, in four columns and three rows. Labels identify Thatch, Wood Shingles, Clay Tile, Slate, Wood Plank, Log, Mossy Shingles, Weathered Thatch, Snow, Copper (Patina), Iron (Weathered), Mossy Slate.

The artwork includes visible facade/door detail; do not force it into the earlier roof-only hex templates. The variants do not inherently define shop roles, prosperity or item tiers. The contact sheet visibly includes text and background treatment; usable alpha, clean object extraction and in-game scale remain unverified. Alpha-channel presence alone does not establish clean cutouts. Original files remain untouched; no Production change in this review.

Next implementation would render one whole building at readable actor-relative scale, map its footprint independently and place shop interaction at the doorway. Adjacent menu use remains the current gameplay direction; entering interiors remains deferred.
