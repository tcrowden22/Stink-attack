# Solo snack run

One Clean Team robot activates when exactly one player is present and assigned to StinkBugs. It uses the existing blue native vacuum art over an invisible R15 movement rig, with server network ownership. No new asset imports are required.

## Play

1. Stop Play, save the current house and sync Rojo. Keep the saved place with the imported bug/furniture.
2. Start ordinary solo Play and press the green PLAY button.
3. Find glowing gold snacks. Press E nearby, or tap the prompt on mobile, to collect.
4. Carry up to five snacks. Return anywhere inside the bug clubhouse to automatically deliver them.
5. Avoid the robot. It patrols six ground-floor points and chases a visible bug within 45 studs. It remembers the last seen location for up to three seconds.
6. The robot reaches up to 18 studs with a visible extending hose/nozzle and cyan warning beam. After a 0.8-second warning, it pulls the bug toward itself at 16 studs/second along the hose. Capture requires coming within four studs. Breaking range, front-facing direction or line of sight releases the grab; the clubhouse remains protected.
7. Capture removes carried snacks and hides the caught bug. The existing death/respawn lifecycle returns you home after approximately three seconds. Delivered snacks remain for this server session.

The robot moves at nine studs/second, slower than the bug's thirteen. Captures have a four-second cooldown. Snacks respawn after twenty seconds. There are eight ground-floor snacks and four upstairs/attic snacks. The robot patrols downstairs; its chase path can use reachable routes elsewhere. Path failures stop movement and retry; the robot does not directly teleport through obstacles to catch a target.

## Snack-powered flight

Every successful gold snack pickup grants one flight charge, up to three. Press **F** (gamepad **Y**) or tap **Fly** on mobile while standing on the ground. Steer with ordinary movement. Each burst lasts 1.8 seconds and approaches a six-stud rise before gravity resumes. Temporary translucent wings show during the burst.

Flight spends a charge, not a carried snack. Delivering snacks preserves remaining charges. Land before taking off again; launches have a three-second cooldown. Capture, reset, character replacement, team change and disconnect clear fuel and stop lift. Low ceilings block launch or end a burst. Flight does not grant immunity to the robot. A robot grab cancels active flight; remaining charges are retained until capture.

The server awards fuel only after a validated pickup and checks team, life, floor contact, cooldown and fuel before creating lift. Requests contain no movement values. Normal Roblox character physics ownership is retained for steering; this is not a complete movement anti-cheat.

### Flight acceptance in Studio (pending)

- [ ] No snack: F/Fly does not lift the bug. One pickup adds exactly one charge; four pickups cap fuel at three while carrying four snacks.
- [ ] F/Fly spends exactly one charge, shows wings, lifts smoothly, permits steering and ends after the short burst.
- [ ] Repeated presses during flight, cooldown or airborne falling do not spend another charge or extend flight.
- [ ] Walls, low furniture, ceilings and attic slopes block movement normally. No clipping or leftover upward drift after the burst.
- [ ] Delivery banks the original snack count and retains unused flight charges.
- [ ] Capture/reset while flying removes wings/lift and returns home with zero fuel. Robot can still capture a flying bug in range.
- [ ] Mobile Fly button does not overlap jump/collection controls in portrait or landscape; menu hides flight input.
- [ ] With two players, only the bug receives flight; the other client sees lift and wings. Team changes, disconnects and respawns leave no constraints behind.

## Wall and furniture climbing

Face a solid wall or furniture within two studs, then press **C** (gamepad **X**) or tap **Climb**. Normal movement toward the wall climbs up; movement away climbs down; sideways movement traverses the wall. Releasing movement pauses. Speed is capped at five studs/second and climbing costs no snacks. Legs animate with motion. Press C / Let go again to release.

Grip lasts four seconds including time spent paused. Releasing/regrabbing in the air does not refill it. After 0.75 seconds off the wall, grounded bugs recover two seconds of grip per second, up to four. The HUD shows remaining grip while climbing. Stale or invalid movement input stops wall motion; the server owns speed, wall checks and grip.

The server checks nearby anchored collision geometry continuously. Floors, ceilings, bug-only gates, decorative non-colliding props, players and the robot are not climb surfaces. Overhead obstacles stop upward motion but still permit descending. Climbing releases at a lost surface, exhausted grip, death, respawn, team change or grab. Flight and climbing cannot run together. The character stays upright; ceiling crawling is not implemented.

The robot now animates the authored top hose, with a raised start, curved ribbed reach and smooth retraction. Visuals run on each client; the server still validates and applies grabs. Ground walls reach Y=24, upper walls/dividers reach Y=48, and attic perimeter walls reach Y=64. Doorways and bug routes remain open: flying through an open doorway is still possible.

The saved house contained an obsolete Workspace.LivingRoom with furniture stacked at the origin, separate from Workspace.House.LivingRoom. Only that exact obsolete signature is moved into ServerStorage.LegacyMapArchive during play. The ambiguous imported sofa overlay is disabled; the visible native seat/back/cushions now match their collision geometry. The imported Sofa asset remains in the library. The decoration installer now expects 15 placements.

### Sofa, climbing and reaching-grab acceptance (pending Studio)

- [ ] From the starting room, confirm there is one visible sofa with the back toward the wall and cushions toward the room. Check the old overlay is gone and the native seat/arms match collisions.
- [ ] Climb a room wall, sofa back, cabinet and attic box. Test up/down/sideways, pause and C to release. Overhead clearance should stop upward motion without blocking descent.
- [ ] Time four seconds on a wall, including pauses. Grip expires, airborne regrabbing cannot refill it, and resting on the floor restores it. Walk speed and turning return on release/reset/grab.
- [ ] Watch the top hose lift before reaching, bend toward a moving bug and retract after cover/capture. No second waist hose or frozen top hose should remain.
- [ ] Try flying over downstairs seams and upstairs dividers from furniture; the walls should block passage. Test every doorway, stairs and bug tunnel still works.
- [ ] Try C in open air, on a floor, under a ceiling, at invisible decorations and near the robot: no free-air climb.
- [ ] Try flight during climbing and climbing during flight: neither overlaps nor consumes an extra flight charge.
- [ ] Watch the hose extend before pulling; no instant capture at 18 studs. Cover, refuge, leaving range and turning behind the robot break the grab.
- [ ] A stalled grab times out after three seconds beyond the warning and waits four seconds before retrying.
- [ ] Reset, disconnect, switch team or join a second client during climbing/grab. No abandoned force, hose or climbing state remains.
- [ ] Mobile Climb, Fly and jump controls remain separate in portrait and landscape. Human players cannot use either bug ability.
- [ ] Both clients see climbing legs; robot disappears when multiplayer begins, including during a grab.

## Other boundaries

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
