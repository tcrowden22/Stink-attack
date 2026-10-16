# Solo snack run

One Clean Team robot activates when exactly one player is present and assigned to StinkBugs. It uses the existing blue native vacuum art over an invisible R15 movement rig, with server network ownership. No new asset imports are required.

## Play

1. Stop Play, save the current house and sync Rojo. Keep the saved place with the imported bug/furniture.
2. Start ordinary solo Play and press the green PLAY button.
3. Find glowing gold snacks. Press E nearby, or tap the prompt on mobile, to collect.
4. Carry up to five snacks. Return anywhere inside the bug clubhouse to automatically deliver them.
5. Avoid the robot. It patrols six ground-floor points and chases a visible bug within 45 studs. It remembers the last seen location for up to three seconds.
6. Suction requires a target within nine studs, in front of the robot, with an unobstructed ray and outside the clubhouse. A cyan beam and HUD warning precede capture; break the conditions to reset the 1.2-second windup.
7. Capture removes carried snacks and hides the caught bug. The existing death/respawn lifecycle returns you home after approximately three seconds. Delivered snacks remain for this server session.

The robot moves at nine studs/second, slower than the bug's thirteen. Captures have a four-second cooldown. Snacks respawn after twenty seconds. There are eight ground-floor snacks and four upstairs/attic snacks. The robot patrols downstairs; its chase path can use reachable routes elsewhere. Path failures stop movement and retry; the robot does not directly teleport through obstacles to catch a target.

## Boundaries

- The robot is solo-only. It despawns with two or more players and resumes when a sole StinkBug remains. A sole Vacuum left after a multiplayer session keeps that team; rejoin solo to become a bug.
- Collection/delivery works for bug players in multiplayer, but player-operated vacuum suction, full rounds and spectator mode remain separate work.
- Solo capture respawns the player rather than leaving a single player spectating indefinitely.
- Scores are session-only. No DataStore, progression unlocks, purchases or monetization were added.
- Collection checks team/life, server inventory capacity, item availability, rate, distance and line of sight. Shared item claims do not yield before consumption.
- Character reset loses carried snacks; disconnect clears session state. Captures recheck refuge protection from server position.
- Normal Roblox player movement ownership remains in place; the prototype does not yet reject all client movement exploits.

## Verification and Studio acceptance

All Luau compiled, team/gait/solo rule tests passed, twelve snack positions passed the source-geometry overlap check, and Rojo built build/StinkBugsVsVacuums-solo-preview.rbxlx. The original saved house was not overwritten.

- [ ] Robot appears and patrols in solo Play; no duplicate appears after reset.
- [ ] Collect five snacks on desktop and mobile; sixth is rejected, and delivery resets carry count while increasing delivered count exactly once.
- [ ] Robot chases outside the clubhouse; walls and furniture break its suction.
- [ ] Beam/warning lasts before capture; entering the clubhouse cancels it immediately.
- [ ] Capture returns the bug home and loses only carried snacks; reset also clears carried snacks.
- [ ] Two players attempting the same snack cannot both claim it.
- [ ] Add a second player while the robot is chasing/computing a path: robot and beam disappear. Remove that player and verify one robot resumes.
- [ ] Disconnect/rejoin during capture or NPC avatar loading; no abandoned robot or inventory is retained.
- [ ] Try all six patrol areas, stair approaches and obstacle corners; inspect Output for navigation errors.
- [ ] Check snack visibility against any Studio-only or manually moved furniture.

Runtime AI movement, multiplayer transitions and real touch input still require these Studio checks. The Python overlap check covers source parts, not manually moved imports.
