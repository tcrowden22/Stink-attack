# Validation evidence

Date: 2026-10-15 (America/Chicago).

## Passed locally

- Official Rojo 7.7.1 Windows archive SHA-256 matched its GitHub release digest.
- Official Luau 0.742 Windows archive SHA-256 matched its GitHub release digest.
- Official Rojo 7.7.1 plugin SHA-256 matched its GitHub release digest.
- Nine Luau source/test files compiled with luau-compile.
- Standalone Luau analysis passed for TeamPolicy and its test file; Roblox-dependent modules still require Studio Script Analysis.
- Initial foundation built-place XML contained 77 Parts and eight runtime scripts/modules; the test file is excluded.
- Team policy tests passed: zero/one/two-player counts, larger lobbies, ratios near both extremes, sequential joins, missing-team replacement and rejected invalid configuration.
- Rojo built the DataModel into build/StinkBugsVsVacuums.rbxlx without warnings after removal of an ignored top-level model name.
- Aikido full-content scans of proposed Luau/configuration files and PowerShell scripts returned zero findings.
- Final Aikido file-path scan covered all 14 code/configuration files: zero findings and no skipped paths.

## Pending or limited

- Roblox Studio execution and Script Analysis: not performed.
- Two-player multiplayer, mobile controls and visual inspection: not performed.
- Rojo plugin connection in Studio: not observed. CLI registration failed; official plugin copied into standard local Plugins folder.
- Aikido returning no findings is not evidence of complete Luau-specific analyzer coverage.
- No Roblox experience has been published.

Build output is reproducible from source. Do not mark the foundation accepted until the Studio checklist is completed.

## House expansion — 2026-10-15

- Added Kitchen and Bedroom room models under Workspace.House; retained and connected the LivingRoom.
- Rojo build and all nine Luau compile checks passed; existing allocation tests passed.
- Static geometry checks confirmed all 243 parts are anchored with positive dimensions, no duplicate names within a room, and clear volumes through both doorways and both new bug vents (excluding intentional bug-only gates).
- Six escape gates exist across the house and are handled by the server's recursive collision-group setup. Spawn lookup now traverses the House hierarchy.
- Full-content Aikido scan of all six changed code/configuration/model files returned zero findings.
- Studio visual inspection, Rojo synchronization observation, actual avatar clearance and two-player traversal are still pending.

## Playroom and Bug Clubhouse — 2026-10-15

- Built 337 authored parts across five room models, including eight bug-only gates.
- All ten Luau files compile; allocation tests pass for the configured 1/5 vacuum fraction, including 10, 20 and 30-player splits and the two-player minimum.
- Static clearance checks passed for the two playroom doors, two clubhouse entrances and the central clubhouse spawn volume.
- Full-content Aikido scan of all 12 proposed code/configuration/model/test files returned zero findings.
- Refuge enforcement, HUD state, signs, roof/camera behavior, actual avatar clearance and larger-lobby performance remain unverified in Studio.

## Upstairs, attic and rooftop — 2026-10-15

- Added Stairwell, Upstairs, Attic and Rooftop models; rebuilt place contains 775 Parts across nine room/structure models.
- All ten Luau files compile; existing allocation tests pass.
- Static checks confirmed positive sizes, anchored parts and unique names within each model.
- Sampled 6.5-stud vertical headroom in three lanes along all three main collision ramps, using inverse rotation for oriented parts: clear.
- Sampled 2-stud headroom above each of the 32 book steps: clear. Both attic tunnel centers are clear except their intentional bug-only gates.
- Aikido full-content scan covered the eight changed code/configuration/model files; rescanned the three adjusted upper-level models after geometry fixes. All scans returned zero findings.
- Roblox Studio traversal, visual inspection, camera behavior and mobile performance remain unverified.

## House accessories — 2026-10-15

- Added 226 authored decorative parts, grouped into seven rooms in Accessories; built place now contains 1,001 parts.
- All accessory parts have positive dimensions, are anchored, and have CanCollide, CanTouch and CanQuery disabled. Names are unique within each room group.
- Rojo build, all ten Luau compile checks and existing allocation tests passed.
- Aikido full-content scans of the new model and updated project configuration returned no findings; the model was rescanned after placement/orientation corrections.
- No character code, gameplay validation, collision gates or existing traversal models changed.
- Visual placement, lighting, camera behavior and desktop/mobile performance remain pending in Studio.

## Blender art revision — 2026-10-15

- Blender 5.1.2 generated nine original models, a shared palette PNG, individual FBXs, combined FBX, packed .blend source and rendered preview.
- Inspected the rendered asset catalogue and corrected the lamp shade. Final unique geometry totals 14,906 triangles; every mesh is below 10,000 triangles.
- Combined FBX re-imported in Blender with exact expected object names, triangle counts, UVs, texture data and positive dimensions.
- Rojo build and all twelve Luau compile checks passed; existing allocation tests passed.
- Native art revision has 1,047 parts before optional imported meshes: softer colors/materials, rounded small props, curtains, ceiling trim and warm lights.
- Aikido initially flagged Python assertions in the FBX validator. Replaced them with explicit errors and rescanned with zero findings. Other proposed code/configuration/model scans returned zero findings.
- Roblox Studio import, upload permissions, asset placement, collision-proxy alignment, runtime integration and mobile performance remain pending. No Roblox mesh asset IDs were invented or uploaded.
- Final Aikido file scan covered 12 changed first-party code/configuration/model files: zero findings, no skipped paths.
# Character milestone — 2026-10-15

- Blender 5.1.2 generated an original shield-shaped stink bug: 7,665 triangles, six legs, antennae, eyes, textured shell.
- Inspected the actual Blender render. FBX round-trip passed mesh name, triangle count, UV, dimension and embedded texture checks.
- All source/test Luau files compiled. Existing team-policy tests passed, including two-player split and larger-lobby ratios.
- Rojo 7.7.1 built build/StinkBugsVsVacuums-characters-preview.rbxlx. The user's existing StinkBugsVsVacuums.rbxlx was not overwritten.
- Aikido full-content proposal scans passed; final on-disk scan covered five code/config files with zero issues and no skipped files (retried once after a connection timeout).
- Studio import, runtime character physics, vacuum grip, camera, two-client play and mobile testing remain pending. See the character acceptance checklist.
# Reference art milestone — 2026-10-16

- Authored and visually reviewed Blender brown shield bug and blue vacuum. Bug: 5,804 triangles, seven independent meshes. Vacuum: 5,092 triangles, two meshes including a separate glow mesh.
- Both FBXs passed round-trip checks for exact names, triangle counts, nonzero bounds, UVs and embedded texture data.
- All Luau source/tests compiled. Team-policy and bug-gait tests passed. Gait checks cover idle, air, alternating tripods, bounded angles and clamped frame gaps.
- Built a separate StinkBugsVsVacuums-reference-preview.rbxlx; existing user-saved house and import folders were not overwritten.
- Aikido proposal scans and final scan of 13 first-party code files reported zero findings; none were skipped.
- Added source-controlled Play screen, client leg animation, server cosmetics, blue human clothing/caps/hair, house slogans, plants and static display mascots.
- Studio runtime, exact import orientation/grip, multi-client animation, menu layout and mobile interaction remain unverified. No public publish or progression systems added.
# Interior expansion — 2026-10-16

- Added 16 groups / 198 native anchored parts across six interior areas.
- Generator checked new furniture envelopes against source collision geometry, protected approaches and other additions.
- Static human-route connectivity passed on floors Y=0,24,48. Three bug-only gates and collision/query consistency passed.
- Inspected the Blender catalogue made from the same furniture source geometry. Editable .blend and preview saved.
- Rojo built StinkBugsVsVacuums-interior-preview.rbxlx without overwriting the user's existing saved house.
- Aikido scanned six changed source/config/data files with zero findings and zero skipped files.
- Live avatar clearance, manually moved/imported Studio props, gate behavior and mobile performance remain pending Studio acceptance.
# Solo snack run — 2026-10-16

- Added server-owned solo robot, patrol/chase paths, validated suction windup/cooldown, and capture with home respawn.
- Added twelve shared snack pickups, server inventory capacity and automatic clubhouse delivery. Counts are session-only.
- All Luau compiled. Team, gait and solo-rule tests passed, including pickup range/availability/capacity, wall checks, facing cone, safe refuge and continuous windup.
- Twelve snack locations passed the static source-part overlap check. Built StinkBugsVsVacuums-solo-preview.rbxlx separately from the user's saved house.
- Aikido final scan: ten changed code files, zero issues, zero skipped.
- Actual Roblox pathfinding, capture feel, respawn visuals, mobile prompts and join/leave transitions remain pending Studio acceptance in SOLO_SNACK_RUN.md.

# Snack-powered flight — 2026-10-16

- Gold pickups award one server-owned flight charge, capped at three. Flight preserves carried/banked snack counts.
- Added server-validated grounded launches, 1.8-second lift, six-stud target rise, three-second launch cooldown and cleanup on death/character removal/team change/disconnect.
- Desktop F, gamepad Y and mobile Fly request the same server action. HUD shows fuel and recharge time; temporary native wings require no imports.
- All Luau compiled; team policy, bug gait, solo rules and new flight rule tests passed.
- Separate Rojo build: build/StinkBugsVsVacuums-flight-preview.rbxlx. The existing imported Studio house was not overwritten.
- Aikido proposal scan reported zero issues; final on-disk scan covered all nine changed first-party code files with zero findings and zero skipped paths.
- Studio flight physics, steering, ceiling clearance, touch layout and multiplayer replication are not yet verified. See SOLO_SNACK_RUN.md for the acceptance checklist.
- User confirmed existing robot vacuum works well; longer/stronger suction remains deferred and its settings were not changed.
