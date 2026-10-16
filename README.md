# Stink Bugs vs. Vacuums

A Roblox multiplayer hide-and-chase prototype, built in Luau with Rojo.

**New: [solo snack run](docs/SOLO_SNACK_RUN.md).** Collect glowing snacks, return them to the bug clubhouse, and evade a server-controlled Clean Team robot. Capture loses carried snacks and respawns you at home; delivered totals last only for the session. The robot is enabled for one StinkBug player. Player vacuum abilities and full multiplayer rounds remain unfinished.

**Current milestone: foundation free play, awaiting Studio acceptance. This is not yet the complete Week 1 game.** The repository contains a multi-level house with four ground-floor rooms, upstairs rooms, an attic, a rooftop and a bug clubhouse, two server-assigned teams, explicit R15 character creation, scaled avatars, respawning, bug-only tunnel collision rules, and a small diagnostic HUD. No external models or runtime packages are used.

Repository: https://github.com/tcrowden22/Stink-attack

## Quick start on this computer

The place has already been built at `build/StinkBugsVsVacuums.rbxlx`. Rojo 7.7.1 and Luau 0.742 are installed in the ignored `.tools` directory.

1. **Save your current Studio work.** Reopen Studio if needed so it loads the newly installed local Rojo plugin. The CLI plugin installer failed to find Studio's registry entry on this computer; the official, checksum-verified `Rojo.rbxm` was instead copied to `%LOCALAPPDATA%\Roblox\Plugins`. If it is absent in Studio, open Studio's Plugins Folder and copy `.tools/Rojo.rbxm` into that actual folder, then restart Studio.
2. **Open the place:** use Studio's Open from File action and select `C:\Projects\Roblox Game\build\StinkBugsVsVacuums.rbxlx`. This loads the authored map and scripts; no Toolbox models are needed.
3. **Start synchronization:** in PowerShell at the repository root run `.\scripts\Serve.ps1`. In Studio open the Rojo plugin, connect to `localhost:34872`, and review/accept its initial sync. Check that `Workspace.House`, `ReplicatedStorage.Shared`, `ServerScriptService.Server`, and `StarterPlayer.StarterPlayerScripts.Client` exist. Rojo owns these project instances; edit their source files rather than making unsaved changes in Studio.
4. **Check one avatar first:** choose Play (not Run, which creates no player), then the green PLAY button. Expect a brown armored stink bug with moving legs, the foundation HUD, and a furnished house. Movement uses Roblox keyboard/mouse and touch controls with R15 underneath the bug costume. Follow [V2 character installation](docs/CHARACTERS.md) for the Blender bug and blue vacuum; native versions work before import.
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
| `map/*.model.json` | House structure, accessories and art finish, plus 198 new interior furniture parts |
| `src/shared/Config.luau` | Scales, speeds, team ratio, future round timing |
| `src/shared/TeamPolicy.luau` | Pure allocation policy, independently tested |
| `src/server/MapService.luau` | Collision groups and spawn positions |
| `src/server/TeamService.luau` | Server-only team selection |
| `src/server/RefugeService.luau` | Server refuge membership, vacuum exclusion and clubhouse signs |
| `src/server/CharacterService.luau` | Explicit R15 creation, scaling, respawn, departure cleanup |
| `src/server/Main.server.luau` | Server bootstrap |
| `src/client/` | Camera setup and diagnostic HUD |
| `tests/` | Allocation tests; excluded from the place |
| `scripts/` | Pinned setup, compile/test/build, local sync |

## Behavior and boundaries

The first player becomes a StinkBug; the second becomes a Vacuum. `VacuumFraction = 1/5` targets roughly one vacuum per five players in larger lobbies, with at least one player on each team at a population of two or more. Assignments remain stable when someone disconnects; the next join fills a missing team first. Foundation solo exploration is intentional, while actual rounds will require two players.

Bugs use an invisible R15 rig at scale 0.35 with a stink bug costume; humans use scale 1 and carry a vacuum prop. No personal accessories are imported. The server controls assignment, appearance and spawn lifecycle. In-progress avatar requests discard their result if the player leaves. Failed avatar requests retry after five seconds; dead characters respawn after three seconds. See [character setup and limitations](docs/CHARACTERS.md).

The living room retains its two tunnels. The kitchen and bedroom each connect through a 14-stud-wide, 12-stud-high doorway plus a separate 4-stud-wide, 2.4-stud-high bug vent. Green markings identify bug routes; invisible gates collide with vacuums but not bugs. The bed also has crawl space underneath. See [house layout](docs/HOUSE_LAYOUT.md). These are collision rules for ordinary play, not an anti-teleport system. Future capture validation must use server state and validate movement assumptions.

The HUD shows carried snacks, delivered snacks and robot warnings. Solo NPC suction/capture is implemented; player-operated suction, spectators, round transitions and mid-round policies are not. Pickup prompts are validated on the server, and no client inventory or capture remote is exposed.

## Verification

The latest [interior expansion](docs/INTERIOR_EXPANSION.md) adds 16 furniture groups and three bug-only hiding spaces without additional imports. After map edits, run `python scripts/build_interiors.py` and `python scripts/validate_interiors.py` to check the generated placements and sampled human routes.

Run `.\scripts\Build.ps1` after edits. This compiles all Luau files, tests allocation policy and produces the Studio place. Compilation does not prove Roblox API correctness or replace a multiplayer playtest. See [validation evidence](docs/VALIDATION.md), [multiplayer testing](docs/MULTIPLAYER_TESTING.md), and [known issues](docs/KNOWN_ISSUES.md).

For first-party code changes, run Aikido with the full file contents before saving proposed code, or use its file-path scan for existing files. Resolve findings before proceeding. Aikido's absence of findings is not a Luau gameplay security certification.

## Publishing

Publishing is pending completion of the Week 1 acceptance gates; no experience has been published.

1. Build the place, open it in Studio, and run the full multiplayer checklist.
2. Use Studio's **Publish to Roblox As** action to create/select the intended experience named **Stink Bugs vs. Vacuums**. Verify the owning account/group and destination before publishing.
3. Keep the initial experience private and configure tester access in Creator Dashboard. Keep maximum players at least two; start with eight for local checks, then test a private 20-player server before raising public capacity. Player capacity is an experience setting, not changed by the team-ratio config.
4. Check avatar settings use R15 consistently with this project's explicit R15 spawn path. Leave API-service access and HTTP requests disabled; this prototype needs neither.
5. Join the private experience with two authorized accounts/devices and repeat round, disconnect, respawn, and mobile checks once those features exist.
6. Record the tested Git commit and results before changing audience availability. Do not publish a stale built place after editing source; rebuild or verify the current sync first.

## Remaining milestones

See [the gated Week 1 plan and Week 2 recommendations](docs/ROADMAP.md). Monetization, cosmetic stores, and persistent progression are out of scope.

## Larger house and bug clubhouse

The playroom connects the kitchen and bedroom into a loop. A covered BugClubhouse west of the house has separate low entrances from the living room and bedroom, team seating and the new bug spawn pad. Server collision gates exclude vacuums; a server bounds check also returns an intruding vacuum to its spawn. The HUD identifies bugs inside the refuge.

At 10 players the initial split is 8 bugs / 2 vacuums; at 20 it is 16 / 4; at 30 it is 24 / 6. Two-player testing remains 1 / 1. These are player slots, not generated AI bugs. Configuring Roblox's actual server capacity and load-testing it are still required.

Solo robot suction and capture call `RefugeService.isProtected(player)` using live position. The replicated HUD attribute is informational. Player-operated suction must use the same checks when implemented; full rounds remain unfinished.

## Upstairs, attic and rooftop

The ground floor now has a solid ceiling formed by the upstairs floor. Enter the side stairwell from the kitchen's northeast doorway (X=122, Z=-28) or the playroom's east doorway (X=122, Z=84). Main stairs connect ground level (Y=0), upstairs (Y=24), attic (Y=48), and rooftop (Y=64). At each landing, walk around the stair opening to the north end to start the next flight. The stairs use invisible continuous collision ramps beneath visible treads so small avatars can walk up without climbing every riser.

Book-stack routes in the bedroom (near X=-22, Z=44) and upstairs lead to the next floor with 1.5-stud jumps. The attic contains crates, rafters, a trunk and two low bug-only crawl tunnels. The roof has three stationary fan housings, sheltered hiding spots, ducts, a chimney and a raised skylight detail. Roof-edge parapets and guards surround stair openings.

The default camera uses Zoom occlusion with a 24-stud maximum distance. Ceilings stay solid and visible. Actual stair traversal, book jumps, head clearance and camera behavior need Studio acceptance; the geometric checks are not a substitute for Humanoid playtesting.

## House accessories

`map/Accessories.model.json` groups 226 decorative parts by room. It includes framed geometric pictures, plants, sofa cushions, a TV console/controller, kitchen appliances and utensils, mugs/food props, bedroom art and toys, craft supplies, toy cars, and an upstairs gaming PC with monitor, keyboard, mouse, headset and controller. Attic and clubhouse decorations are included too.

All accessories are anchored and have collision, touch and raycast queries disabled. They are visual props, not functional electronics, hiding barriers, or climbable platforms. Existing structural furniture, book-climbing routes and bug gates retain their original behavior. The pictures and monitor artwork use authored geometry rather than external images or models.

To view: stop Play, sync Rojo, and inspect `Workspace.House.Accessories`. Alternatively reopen the rebuilt place. Walk the rooms and check prop placement, camera readability and frame rate on desktop and mobile before accepting the decorating pass. Character work follows this milestone.

## Blender visual upgrade

See [Blender details and Studio import](docs/BLENDER_DETAILS.md) for the rendered nine-model kit, source files and exact import steps. Native colors/materials, rounded props, curtains, trim and warm lighting are already in the build. The Blender meshes require a Studio import into ServerStorage.DetailAssets before the server can install their 16 placements. The current clean build uses native fallbacks; it does not contain uploaded Roblox mesh assets.
