# Interior furniture pass

Sixteen furniture groups add 198 anchored native parts across the living room, kitchen, bedroom, playroom, upstairs and attic. No new imported asset IDs or external dependencies are required.

| Area | Additions |
| --- | --- |
| Living room | Teal reading chair with pillow/throw; cushioned book bench |
| Kitchen | Two serving/storage carts with shelves, wheels, trays and fruit |
| Bedroom | Woven-style laundry hamper and towels; stacked luggage; cardboard crawl tunnel |
| Playroom | Blanket hideout with front and rear openings; cushioned book bench |
| Upstairs | Reading chair, laundry hamper, snack cart and luggage |
| Attic | Storage-box cluster, cardboard crawl tunnel and luggage |

Furniture frames and large bodies collide and participate in raycasts. Books, fruit, straps, pillows and other small decorations do not collide or block queries. The carts and luggage are anchored obstacles, not movable physics objects.

Two cardboard tunnels and the blanket fort have EscapeGate parts. Existing MapService setup assigns their collision group: bugs pass through; humans are blocked. Green markers identify the cardboard tunnel entrances. The blanket fort has a 3.4-stud rear opening so bugs have a second exit. These are hiding spaces, not additional protected team refuges.

## Studio actions

1. Stop Play and save your current house, preserving existing imported furniture and characters.
2. Sync Rojo. The new collection appears at Workspace > House > InteriorDetails; no Blender import is needed.
3. Start Play so MapService configures the new bug-only gates. Walk around the new furniture and through both tunnel ends as a bug.
4. Test with two clients: humans should be blocked by the three gates, but retain routes around every furniture group. Check the blanket fort's rear opening, stairs, doorway access and camera comfort.

A separate clean build is saved as build/StinkBugsVsVacuums-interior-preview.rbxlx. The user's existing saved house was not overwritten. Prefer syncing the existing house to retain its imported mesh references.

## Source and checks

- scripts/build_interiors.py creates map/InteriorDetails.model.json and map/interior-manifest.json deterministically. It checks placement envelopes against existing solid map parts, existing furniture, spawn/door/stair approach reservations and other additions before writing.
- scripts/validate_interiors.py checks that additions do not split existing human-height grid routes on floors Y=0,24,48. It also checks anchoring, collision/query consistency and the three gates.
- The route check samples a two-stud grid with 1.2-stud horizontal clearance and 5.5-stud human height. It excludes the stairwell and does not simulate jumping, moving avatars or camera collision. It covers source geometry, not manually moved Studio props or runtime-generated decorations.
- scripts/render_interiors.py creates a Blender catalogue of the same native part shapes. assets/interiors/InteriorFurniture.blend remains editable; furniture-preview.png is a catalogue, not a Studio screenshot.
- Python generation and layout checks and the Rojo build passed. Studio movement, visual placement, mobile performance and multiplayer acceptance remain pending.
