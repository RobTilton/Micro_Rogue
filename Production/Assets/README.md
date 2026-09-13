# Runtime Assets
Updated: 2026-09-12
Checkpoint: [Production Promotion]+[Runtime]+[Modules]

Production owns independent copies of every resource used by the accepted game: Terrain sheets, the Actors atlas and the available Items sprite. Original source artwork remains preserved outside this runtime. Placeholder status does not create a runtime dependency on its source location.

The actor atlas retains its existing magenta-key shader treatment in UI/actor_sprite.gd. Terrain/water art and approved sheet sampling are unchanged, including exclusion of road samples from the named wasteland sheet. Only the existing bronze-sword image is supplied for inventory art; other item types retain their established fallback presentation. No replacement artwork or sprite-equipment animation was introduced.

The promotion manifest records source and destination hashes. Texture import parameters were compared and match the accepted originals; copied resources received independent Godot import identities.
