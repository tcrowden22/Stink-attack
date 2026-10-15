# Stink bug and human characters

The server chooses a team on join. The first player is a bug, the second a human with a vacuum; larger lobbies target four bugs per human. Each player gets a separate character and cosmetic copy. There are no NPC bugs in this milestone.

Both teams retain the existing R15 movement rig and desktop/mobile controls. Bugs hide the humanoid body under a small costume; humans have skin-colored heads/arms, orange shirts, blue trousers and a permanently attached vacuum prop. Cosmetics are massless, non-colliding and excluded from raycasts. The server still owns team assignment, rig creation and respawning.

## Install in your current Studio house

1. Stop any Play session and save your current house, including the imported furniture. Keep that place open. The character preview build is a separate clean build and does not contain your Studio-only furniture imports.
2. Connect the Rojo plugin to localhost:34872 and sync the source changes. This adds ServerScriptService.Server.CharacterAppearance and ServerStorage.CharacterAssets. The sync server is already running on this computer. If restarted, run scripts/Serve.ps1 first.
3. In Home, choose Import (the cube icon). Select C:\Projects\Roblox Game\assets\characters\StinkBug.fbx. Import the model with its texture. This is an ordinary mesh import, not an Avatar Setup conversion: the code supplies the R15 movement rig.
4. In Explorer, move the imported StinkBug mesh/model into ServerStorage > CharacterAssets. Keep the mesh/model name StinkBug. Do not move HouseDetailKit out of DetailAssets. If the importer adds a wrapper, it may remain as long as a descendant is named StinkBug.
5. Save the place. Start Play to spawn as a stink bug. The character's Appearance attribute should say Blender stink bug. Native stink bug means the imported name/folder was not found. Stop Play before correcting the import, then Play again.
6. Use Server & Clients with two clients to see one bug and one human holding the vacuum. Inspect facing direction, feet on the floor, vacuum grip, tunnel clearance and mobile movement before accepting this feature.

The source .blend and FBX are in assets/characters, with a packed palette texture. The FBX is 7,665 triangles. Blender forward is +Y, exported toward Roblox -Z. Roblox orientation and texture appearance still require an in-Studio check.

## Reproduce and validate

Run Blender in background mode with scripts/build_stink_bug.py to rebuild the original mesh, texture, FBX, manifest and preview. Run scripts/validate_stink_bug.py in Blender to verify the FBX imports again with its name, triangles, UVs, dimensions and texture intact.

Compile the Luau source and run tests/TeamPolicy.spec.luau. Build to build/StinkBugsVsVacuums-characters-preview.rbxlx for a clean fallback preview. Do not rebuild over your saved house containing Studio-only mesh imports. Export/preserve those imports separately before replacing a place with a clean Rojo build.

## Current limits

- The bug is a rigid cosmetic mesh, with no leg or antenna animation yet.
- The vacuum is a held visual prop. Suction and capture are not implemented.
- The humanoid collision rig remains the movement proxy; the mesh is not a custom six-legged physics rig.
- Runtime, multiplayer and real-device acceptance remain pending. No asset upload or publishing was performed.
- Uploaded mesh/texture ownership must match the publishing experience. Keep the Studio place with the imported asset references; FBX source alone cannot provide Roblox content IDs to a clean build.
