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
