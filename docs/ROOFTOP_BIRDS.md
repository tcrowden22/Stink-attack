# Rooftop birds

## Apply in Roblox Studio

1. Stop Play so the new server bird service and client wing animation start together.
2. Save your imported house. This update has not overwritten `build/StinkBugsVsVacuums.rbxlx`.
3. Sync Rojo at localhost:34872. The new bird geometry and services are included automatically; no model upload/import is needed.
4. Press Play, choose Stink Bug, and climb the stairs to the rooftop. Three birds circle overhead. Watch the HUD warning and use the fan shelters to avoid a dive.

The separate clean build is `build/StinkBugsVsVacuums-rooftop-birds-preview.rbxlx`. Sync the existing place to preserve imported furniture and character art.

## Original model

Blender source: `assets/characters/bird/RooftopBird.blend`.
Mesh export: `assets/characters/bird/RooftopBird.fbx`.
Preview: `assets/characters/bird/preview.png`.
Rebuild with Blender's background mode and `scripts/build_bird.py`.

This is original procedural art: a blue body, cream breast, orange beak/feet, expressive eyes, feathered wings and a tail. The export contains 33 shapes and two five-part wing groups. No external models or textures are used. The Blender preview was visually inspected.

The generator exports matching geometry into `src/shared/BirdGeometry.luau`. Roblox reconstructs the authored shapes as native parts with explicit joints; both wings animate on every client. The supplied FBX is not an uploaded Roblox mesh. Runtime lighting differs from the render.

## Hunting behavior

- Three birds circle above the main roof, starting at heights of 84–86 studs.
- Only live human-controlled StinkBugs in the rooftop bounds (above 64.35 studs) can be targets. Humans, the clubhouse, attic and other interior floors are excluded. Existing AI bugs stay downstairs and are not bird targets.
- The server checks a 65-stud detection radius, rooftop membership, open space above the bug and clear sight to the bird.
- A 1.1-second HUD warning precedes a dive. Dives last at most four seconds, followed by a four-second recovery. Movement is capped to avoid jumping through the scene after a server stall.
- Swept body collision checks stop a dive at solid roof obstacles. Fan shelters and blocked sight cancel pursuit. Leaving the roof, dying, resetting or disconnecting also cancels it.
- A capture requires close beak proximity (2.4 studs), completed warning, valid rooftop position and clear line of sight. The bug disappears, loses carried snacks and respawns; banked snacks remain. There is no gore.

## Automated verification

All Luau compiled; nine rule/gait suites passed, including rooftop/attic boundaries, warning duration, cover, capture distance and movement limits. Existing house, route, snack, bathroom and stair checks passed. Blender assets and wing groups were checked. Rojo built the separate preview. Aikido scanned all 11 changed first-party code files with zero findings and no skipped files.

## Pending Studio acceptance

- [ ] Inspect all three birds, including body connections, wing hinges, orientation, scale and client-visible wing movement.
- [ ] Stay downstairs/in the attic as either team: no bird attack. Vacuum players on the roof are ignored.
- [ ] Enter the rooftop as a bug: warning appears before each dive; dodge a dive and observe the recovery interval.
- [ ] Hide under each fan shelter or behind solid cover: pursuit cancels and no capture occurs through the object. Watch bird clearance around fans, ducts, chimney and parapets.
- [ ] Leave down the stairs during warning/diving: the bird returns upward and never follows into the house.
- [ ] Let a bird catch you: one elimination, carried snacks cleared, banked snacks retained, normal home respawn.
- [ ] With two bugs, reset/disconnect one during pursuit; the other remains playable. Confirm both clients see the same bird motion and no stale HUD warning.
- [ ] Test on mobile and with several players for smooth dives and acceptable performance.

Runtime and multiplayer acceptance have not been performed by the coding agent. Wing tips are cosmetic and may clip close obstacles; only the central body is swept for movement collision. Birds use simple homing dives, not full flight pathfinding.
