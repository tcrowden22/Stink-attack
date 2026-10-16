# Reference-inspired characters and opening screen

The October 16 reference replaces the green bug with a brown armored bug. The first player is a bug, the second a human with a blue vacuum; larger lobbies target four bugs per human. Multiple bugs are player characters, not autonomous NPCs.

## Studio steps, preserving your existing house

1. Stop Play and save your current house with its furniture imports. Keep that place open; the clean preview build does not contain Studio-only imports.
2. Sync Rojo at localhost:34872. This loads the new server appearance, house details, leg animation and welcome screen. If the sync server is stopped, run scripts/Serve.ps1.
3. Use Home > Import for each file in C:\Projects\Roblox Game\assets\characters\reference:
   - StinkBugV2.fbx: import as separate meshes, keeping BugBody, LegL1, LegL2, LegL3, LegR1, LegR2 and LegR3. Do not merge the legs into the body.
   - VacuumV2.fbx: keep VacuumBody and VacuumGlow separate.
4. In Explorer, put each imported group under ServerStorage > CharacterAssets. Name the outer Models StinkBugV2 and VacuumV2 respectively. If Studio creates loose parts, group the appropriate parts into a Model and give it that name. Preserve the child mesh names above. The previous StinkBug model can remain; the new code uses V2 only.
5. Save, then Play. The green Play button closes the introduction. Moving a bug should swing and lift alternating groups of three legs. Idle and airborne legs return to neutral. Humans wear blue, have brown hair and caps, and carry a blue cleaner.
6. Start Server & Clients with two clients. Observe each bug from the other client; test respawns, stairs, vents, mobile controls, vacuum grip, texture orientation and the welcome button.
7. Optional edit-mode house preview: after syncing, run require(game.ServerScriptService.Server.ReferenceDetails).apply() in the Command Bar. This adds the signs and display props to the editor. Play also creates them automatically.

Missing/incomplete V2 imports select the new native brown bug or blue vacuum. The native bug also has moving legs. An imported bug's Appearance attribute reads Blender V2 animated brown bug. The fallback reads Native V2 animated brown bug.

Facing correction: the imported bug receives a 180-degree turn at spawn before its joints are created. This aligns the observed Studio import with the humanoid's travel direction and turns the hip frames with the body. The native bug already faces forward. Sync and restart Play to apply this correction; no reimport is needed. The user confirmed the legs animate in Studio; the facing correction still needs a fresh play check.

## What from the photo is represented

| Reference feature | Prototype implementation |
| --- | --- |
| Brown shield bug, large eyes, eyebrows, amber belly, antennae | Blender model and native fallback; six separate moving leg assemblies |
| Blue cleaner, black ribbed hose, broad lit nozzle, glowing eyes | Blender model with separate Neon glow mesh; native fallback; CLEAN TEAM badge |
| Human cleaners | R15 humans, blue clothing, brown hair, caps, held cleaner |
| Oversized robot-like vacuum | Static living-room mascot with display arms; no robot AI |
| Purple cleaner | Shelf display; no paid variant |
| Crowned small bug | Shelf decoration; no progression reward |
| Plants and paper/wall slogans | Potted plants and all four major pictured slogans/checklist |
| Warm floor, rug, sofa, lamp, bookshelf/books, windows | Existing furnished house retained |
| Large title and green Play button | Responsive welcome UI with a 3D character preview, mouse/touch activation |
| Upgrade/customize/rank rewards | Remain outside Week 1: no store, purchases or persistent progression |
| Cinematic photograph, logo effects and composition | Visual direction, not a pixel-identical recreation or uploaded background image |

The welcome button dismisses the introduction; it does not start a round. The large vacuum and crowned bug are decorations. Player-held vacuums remain visual props; the separate solo CleanTeamRobot can now chase and capture bugs. See SOLO_SNACK_RUN.md.

## Animation and ownership

The server selects teams and constructs R15 movement/collision rigs, cosmetics, welds and six Motor6D joints. Only the legs are articulated; the underlying rig is invisible for bugs. All cosmetic geometry is massless and non-colliding. Leg yaw/lift is bounded.

Each client animates all tagged bug legs from observed character velocity and grounded state during PreSimulation. No animation asset upload or per-frame remote is needed. Removing a character removes its animation entries. Tests exercise alternating tripods, idle/air behavior, angle limits and frame-gap clamping. Client visuals are not authoritative gameplay state.

## Reproduction and checks

- Blender 5.1: run scripts/build_reference_characters.py, then scripts/validate_reference_characters.py in background mode.
- Assets and the packed source .blend are in assets/characters/reference. Bug: 5,804 triangles across seven meshes. Vacuum: 5,092 triangles across two meshes.
- Run tests/TeamPolicy.spec.luau and tests/BugGait.spec.luau; scripts/Build.ps1 includes both.
- A separate build is available at build/StinkBugsVsVacuums-reference-preview.rbxlx. The existing saved house was not overwritten.
- Blender FBX round-trip and source compile/build checks are not Studio runtime verification. Follow docs/MULTIPLAYER_TESTING.md.
- Preserve the saved place and uploaded asset references. A clean Rojo build uses native fallbacks until imports are restored.
