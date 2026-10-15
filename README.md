# Stink Bugs vs. Vacuums

A Roblox multiplayer hide-and-chase prototype, built in Luau with Rojo.

**Current milestone: foundation free play, awaiting Studio acceptance. This is not yet the complete Week 1 game.** The repository contains a stylized living room, two server-assigned teams, explicit R15 character creation, scaled avatars, respawning, bug-only tunnel collision rules, and a small diagnostic HUD. No external models or runtime packages are used.

Repository: https://github.com/tcrowden22/Stink-attack

## Quick start on this computer

The place has already been built at `build/StinkBugsVsVacuums.rbxlx`. Rojo 7.7.1 and Luau 0.742 are installed in the ignored `.tools` directory.

1. **Save your current Studio work.** Reopen Studio if needed so it loads the newly installed local Rojo plugin. The CLI plugin installer failed to find Studio's registry entry on this computer; the official, checksum-verified `Rojo.rbxm` was instead copied to `%LOCALAPPDATA%\Roblox\Plugins`. If it is absent in Studio, open Studio's Plugins Folder and copy `.tools/Rojo.rbxm` into that actual folder, then restart Studio.
2. **Open the place:** use Studio's Open from File action and select `C:\Projects\Roblox Game\build\StinkBugsVsVacuums.rbxlx`. This loads the authored map and scripts; no Toolbox models are needed.
3. **Start synchronization:** in PowerShell at the repository root run `.\scripts\Serve.ps1`. In Studio open the Rojo plugin, connect to `localhost:34872`, and review/accept its initial sync. Check that `Workspace.LivingRoom`, `ReplicatedStorage.Shared`, `ServerScriptService.Server`, and `StarterPlayer.StarterPlayerScripts.Client` exist. Rojo owns these project instances; edit their source files rather than making unsaved changes in Studio.
4. **Check one avatar first:** choose Play (not Run, which creates no player). Expect a small green R15 bug, the foundation HUD, and a furnished room. Movement uses Roblox's standard keyboard/mouse and touch controls. The server explicitly requests R15, so it does not depend on an account's chosen avatar rig.
5. **Run the acceptance gate:** stop Play, choose **Server & Clients** in Studio's test controls, select **2 clients**, and start. Expect one StinkBug and one Vacuum. Follow [the foundation checklist](docs/MULTIPLAYER_TESTING.md) before implementing the next feature. Roblox may ask for local-server firewall access.
6. **Stop all test sessions** before editing/syncing again. Save a local copy if desired; source files remain authoritative.

The exact toolbar placement varies with Studio layout. See Roblox's [testing modes documentation](https://create.roblox.com/docs/studio/testing-modes) and Rojo's [new game guide](https://rojo.space/docs/v7/getting-started/new-game/).

## Fresh Windows setup

Install Roblox Studio, Git, and PowerShell. Clone the repository and run:

```powershell
git clone https://github.com/tcrowden22/Stink-attack.git
cd Stink-attack
.\scripts\Setup.ps1
.\.tools\rojo\rojo.exe plugin install
.\scripts\Build.ps1
.\scripts\Serve.ps1
```

The setup script downloads pinned official Windows x86-64 binaries and checks SHA-256 before extraction. No global PATH changes are required. Follow your machine's PowerShell execution policy if it blocks local scripts. For other operating systems, install Rojo **7.7.1** and Luau **0.742** from their official releases and run the equivalent commands below.

```text
luau tests/TeamPolicy.spec.luau
rojo build default.project.json --output build/StinkBugsVsVacuums.rbxlx
rojo serve default.project.json --address 127.0.0.1 --port 34872
```

Create the build directory before using the raw build command. For Lua syntax checks, run `luau-compile --null` on each source and test file. The PowerShell build script does all of this and stops on failures.

## Source layout

| Path | Responsibility |
| --- | --- |
| `default.project.json` | Rojo DataModel mappings and lighting |
| `map/LivingRoom.model.json` | Authored map: 77 anchored parts, furniture, tunnel entrances, spawn markers |
| `src/shared/Config.luau` | Scales, speeds, team ratio, future round timing |
| `src/shared/TeamPolicy.luau` | Pure allocation policy, independently tested |
| `src/server/MapService.luau` | Collision groups and spawn positions |
| `src/server/TeamService.luau` | Server-only team selection |
| `src/server/CharacterService.luau` | Explicit R15 creation, scaling, respawn, departure cleanup |
| `src/server/Main.server.luau` | Server bootstrap |
| `src/client/` | Camera setup and diagnostic HUD |
| `tests/` | Allocation tests; excluded from the place |
| `scripts/` | Pinned setup, compile/test/build, local sync |

## Behavior and boundaries

The first player becomes a StinkBug; the second becomes a Vacuum. `VacuumFraction = 1/3` targets roughly one vacuum per three players in larger lobbies, with at least one player on each team at a population of two or more. Assignments remain stable when someone disconnects; the next join fills a missing team first. Foundation solo exploration is intentional, while actual rounds will require two players.

Bugs use scale 0.35 and vacuums use scale 1. Characters have fixed, team-colored bodies and no personal accessories. The server controls assignment and spawn lifecycle. In-progress avatar requests discard their result if the player leaves. Failed avatar requests retry after five seconds; dead characters respawn after three seconds.

Two tunnels have 2.4-stud clearance, green entrance markings, and invisible gates that collide with vacuums but not bugs. These are collision rules for ordinary play, not an anti-teleport system. Future capture validation must use server state and validate movement assumptions.

The current HUD deliberately says **Foundation free play**. It is not the future round timer/remaining-bug HUD. Suction, captures, spectators, round transitions and mid-round policies are not implemented yet. No game action remotes exist at this milestone.

## Verification

Run `.\scripts\Build.ps1` after edits. This compiles all Luau files, tests allocation policy and produces the Studio place. Compilation does not prove Roblox API correctness or replace a multiplayer playtest. See [validation evidence](docs/VALIDATION.md), [multiplayer testing](docs/MULTIPLAYER_TESTING.md), and [known issues](docs/KNOWN_ISSUES.md).

For first-party code changes, run Aikido with the full file contents before saving proposed code, or use its file-path scan for existing files. Resolve findings before proceeding. Aikido's absence of findings is not a Luau gameplay security certification.

## Publishing

Publishing is pending completion of the Week 1 acceptance gates; no experience has been published.

1. Build the place, open it in Studio, and run the full multiplayer checklist.
2. Use Studio's **Publish to Roblox As** action to create/select the intended experience named **Stink Bugs vs. Vacuums**. Verify the owning account/group and destination before publishing.
3. Keep the initial experience private and configure tester access in Creator Dashboard. Keep maximum players at least two; start with eight for the prototype.
4. Check avatar settings use R15 consistently with this project's explicit R15 spawn path. Leave API-service access and HTTP requests disabled; this prototype needs neither.
5. Join the private experience with two authorized accounts/devices and repeat round, disconnect, respawn, and mobile checks once those features exist.
6. Record the tested Git commit and results before changing audience availability. Do not publish a stale built place after editing source; rebuild or verify the current sync first.

## Remaining milestones

See [the gated Week 1 plan and Week 2 recommendations](docs/ROADMAP.md). Monetization, cosmetic stores, and persistent progression are out of scope.
