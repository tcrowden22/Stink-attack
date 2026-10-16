# Bathrooms, spider connections and automatic crawling

## Studio actions

1. Stop Play to restart with the changed character construction and map.
2. Save the current imported house. This update did not overwrite `build/StinkBugsVsVacuums.rbxlx`.
3. Sync through the running Rojo server at localhost:34872. The map gains Bathrooms and stair entry landings; scripts gain automatic crawl and corrected spider joints. No model import is required.
4. Press Play, choose Stink Bug, and walk into a wall. The body should stand vertically with its feet toward the wall. Move toward the wall to climb up, away to descend, sideways to traverse, or stop to pause. Grip still lasts four seconds, including pauses. C / touch Let go drops you; a short rest prevents immediate automatic reattachment.

The separate clean preview is `build/StinkBugsVsVacuums-bathrooms-crawl-preview.rbxlx`. Prefer syncing the imported place to retain its art.

## Changes

- Three 20-by-20 bathrooms: ground floor centered at (0,0,60), upstairs at (-32,24,90), and attic at (-32,48,24). Each has floor tiles, full-height walls, an eight-stud doorway, shower, toilet, vanity, mirror, soap, towel and bath mat. Original furniture remains in place. Fixtures are static props.
- All three main stair starts and both book-stair starts have flush entry landings. Main stair treads now have solid risers without changing tread tops, half-stud rises, ramps or railings.
- Spider native body parts sit in a dedicated visual model with explicit fixed joint offsets. Automatic avatar scaling is disabled after the intended spider size is set. Head bite travel is reduced to keep overlap with the abdomen. Existing eight-leg animation is retained.
- Bug body and legs share one pose carrier. Server climbing rotates that visual assembly to the wall normal while the movement rig stays upright. It returns to its resting pose on drop, loss of wall, exhaustion, capture or reset.
- Automatic entry requires recent bounded movement intent into an anchored solid wall, a tall-wall probe, ground contact, available grip and the reattachment delay. Shallow stair risers should not trigger it. The server still validates reach, wall slope, role, life and conflicting abilities. Ceiling crawling is not included.

## Validation and pending playtest

Automated: all Luau compiles; eight rule/gait suites pass, including auto-entry grip/approach/rest boundaries. `python scripts/validate_renovations.py` checks bathroom fit, fixtures, doors, stair entrance seams and original tread heights. Existing house, route and snack checks pass. Aikido scanned all 17 changed code/data files with zero findings and no skipped paths. Rojo built the separate preview. A Blender cutaway bathroom render was visually inspected; game walls remain full height.

- [ ] Walk into walls from four directions, on desktop and touch: body and all legs stay together and align vertically. Traverse, descend and pause. Another client sees the same pose.
- [ ] Drop, exhaust grip, get vacuumed, die and reset: normal pose and movement return; no permanent tilt or immediate reattachment loop.
- [ ] Stairs do not trigger unwanted auto crawl; manually starting C still works. Flight and suction continue to cancel climbing.
- [ ] Inspect all four spiders at spawn, while walking and during bites. No separated abdomen/head/eyes/legs or scale changes. Repeat after respawn.
- [ ] Walk all main stair and book-stair entrances both ways. Check seams, rails, ramps and avatar clearance with both team sizes.
- [ ] Visit all bathrooms, including their doorways and shower entrances. Check camera behavior and frame rate with two players.

These Studio checks have not been performed by the coding agent. Source checks and a Blender preview do not establish runtime acceptance.
