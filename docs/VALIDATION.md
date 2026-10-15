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
