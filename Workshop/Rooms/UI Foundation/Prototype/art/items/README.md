# Item Artwork
Updated: 2026-09-10
Checkpoint: [UI Foundation]+[Presentation]+[ItemCards]

Current approved artwork: `bronze_sword.png`, generated with the built-in image generation tool. Other items and characters retain their existing placeholders until Rob supplies sprites or requests more artwork. Equipment overlays on characters remain deferred.

The full source PNG and alpha are preserved. The runtime trims transparent margins through an AtlasTexture and displays it with nearest-neighbor filtering; no source pixels are rewritten. Every bronze sword rarity uses the same material artwork. Rarity colors and statistics are shown only when the item is within inspection reach or in the player's possession.

## Final Generation Prompt

Use case: stylized-concept. Asset type: a single transparent-background inventory sprite for a small 8-bit fantasy roguelike. Subject: one plain bronze sword, upright vertically with pointed blade at top and leather grip/pommel at bottom, simple crossguard. Crisp chunky 8-bit pixel art, intentionally very low detail as if drawn on a 32 by 32 pixel grid and enlarged without smoothing. Restrained colors, dark outline, bronze blade and brown grip. Center the whole item with generous transparent margin, no cropped parts. Flat front view, isolated object only. Genuine transparent alpha background. No text, no border, no card frame, no other items, no scenery, no shadow on background, no magical glow, no gradients or antialiasing. Designed to remain immediately readable inside a narrow two-cell inventory slot.

## Provenance

Built-in `image_gen` mode. Original retained at `/home/serra/.codex/generated_images/01a08868-ea06-7660-8f9a-d0c8841a4a1e/exec-ab7980c6-580f-40bc-8e15-156fa96bce28.png`; project uses its own copied asset here. The subsequent generation requests hit the image usage limit. Rob then explicitly chose to use just the sword for now; no API fallback or substitute sprite generation was performed.
