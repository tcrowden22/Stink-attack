# Multiplayer acceptance checklist

Status: **Not run in Roblox Studio.** Source/build checks are recorded separately in VALIDATION.md. Native Studio interaction is not available to the current agent.

Record Studio version, Git commit, date, tester, device(s), observed results and Output errors. Check boxes only after observing the behavior.

## Gate 1: foundation (current handoff)

Before starting, read README's Studio actions. Connect Rojo, stop any existing simulation, and open Output so errors are visible.

- [ ] Solo Play spawns a green R15 bug inside the clubhouse and shows Foundation free play.
- [ ] House contains furnished living room, kitchen, bedroom, playroom and Bug Clubhouse; nothing falls or drifts.
- [ ] Both teams can walk through the wide kitchen and bedroom doorways in both directions.
- [ ] Bug can cross both green-marked inter-room vents; vacuum is blocked at both.
- [ ] Kitchen counters, island and dining furniture leave navigable routes.
- [ ] Bedroom bed, wardrobe and desk leave navigable routes; test bug crawl space under the bed.
- [ ] Inspect cameras near doorways, beneath furniture and at the map perimeter.
- [ ] Use Server & Clients with **2 clients**, not two unrelated solo Play sessions.
- [ ] Exactly one client is StinkBugs and one is Vacuums. Confirm Player.Team in the server Explorer.
- [ ] On the server, both Humanoids have RigType R15; model scales are 0.35 and 1.
- [ ] Each avatar spawns clear of furniture and can move and jump using desktop controls.
- [ ] Each client can see the other player moving with the correct size and team color.
- [ ] Bug can traverse both tunnels in both directions without camera/control failures.
- [ ] Vacuum cannot enter either tunnel through either green-marked entrance.
- [ ] Reset each avatar. After approximately 3 seconds, team and scale remain correct; no duplicate live character appears.
- [ ] Disconnect a client during normal play; the remaining client has no errors.
- [ ] Add a replacement client. A missing team fills first.
- [ ] Disconnect/rejoin during avatar loading; no orphan avatar or repeated errors remain.
- [ ] Repeat with six clients: initial allocation is five bugs and one vacuum.
- [ ] Use Studio's Device Emulator with a phone profile; touch movement/jump work and HUD text fits.
- [ ] Stop all sessions, restart the test, and verify clean initialization.
- [ ] Output has no unexpected errors on server or clients.

### House expansion and team refuge

- [ ] Bugs spawn inside the clubhouse; vacuums still spawn in the living room.
- [ ] Both teams can complete the four-room loop through the main doorways.
- [ ] Bugs can enter and leave both clubhouse entrances; vacuums cannot enter normally.
- [ ] Clubhouse signs are readable and the roof does not trap the bug camera.
- [ ] Refuge HUD indicator appears inside and clears after leaving, death or reset.
- [ ] In the server test context, relocate a vacuum inside the clubhouse; it returns to its spawn within approximately 0.2 seconds without retaining launch velocity.
- [ ] Test joining, resetting and leaving repeatedly with bugs inside the refuge.
- [ ] With eight local clients expect six bugs and two vacuums.
- [ ] Private larger-server test: 20 players initially split 16 bugs / 4 vacuums. Record performance and crowding before choosing a public player limit.
- [ ] Future capture implementation checks RefugeService.isProtected at capture time; no capture test is possible yet.

### Upstairs, attic and rooftop

- [ ] Both ground-floor stairwell doorways are reachable without furniture blocking them.
- [ ] Both teams walk each of the three main flights in both directions without jumping or snagging.
- [ ] Each upper landing connects to the next flight via the west-side walkway.
- [ ] Bug jumps all 16 book steps to upstairs, then all 16 to the attic; repeat on mobile.
- [ ] Stair and book openings have no hidden floor panel blocking the avatar.
- [ ] Both attic tunnels pass bugs and exclude vacuums; crates and beams leave usable routes.
- [ ] Rooftop fans, shelters, ducts and chimney create accessible hiding spaces.
- [ ] Roof parapets and opening guards prevent accidental falls during ordinary walking.
- [ ] Camera zoom responds to ceilings on every level; no prolonged wall/ceiling obstruction.
- [ ] Leaving or resetting from upstairs/attic/roof respawns each team at its original team spawn.
- [ ] Clubhouse protection continues to apply only inside the clubhouse.
- [ ] Check frame rate on a real mobile device with the expanded 1,001-part map and multiple players.

### Accessories

- [ ] Wall pictures face into rooms and do not disappear into walls.
- [ ] Kitchen props rest on their counters/table; toy cars rest on shelves.
- [ ] Upstairs gaming setup and screen artwork are visible and readable.
- [ ] No accessory visually hides a door, bug entrance, stair or book route.
- [ ] Small avatars do not snag on any decoration; camera behavior remains usable.
- [ ] Both clients see the same decor; no unexpected Output errors appear.
- [ ] Check performance on a real mobile device after adding the 226 decorations.

**Gate result:** PENDING. Record evidence here before moving to Gate 2. Static part sizes do not establish actual avatar clearance.

## Gate 2: server-validated suction (not implemented)

- [ ] Only an active, living vacuum can request suction.
- [ ] Client sends intent only; server selects eligible targets.
- [ ] In-range bug inside the forward cone and unobstructed line of sight can be captured.
- [ ] Out-of-range, behind-the-vacuum, and wall/furniture-obscured bugs cannot be captured.
- [ ] Client-supplied targets, ranges, cooldowns or fake team values cannot authorize capture.
- [ ] Spam, malformed payloads, dead/spectating senders and cooldown bypass attempts fail safely.
- [ ] Desktop and mobile ability buttons show accepted/denied/cooldown feedback.

## Gate 3: captured spectators (not implemented)

- [ ] Captured bug loses active participation exactly once.
- [ ] Remaining bug count updates for both clients.
- [ ] Spectator cannot move into the arena, fire abilities, block players or respawn as active.
- [ ] Spectator camera handles target death/disconnection and an empty eligible-player list.

## Gate 4: round lifecycle (not implemented)

- [ ] One player cannot start a round.
- [ ] Two players trigger a 15-second lobby followed by a 300-second round.
- [ ] All bugs captured causes vacuum victory; surviving until time expires causes bug victory.
- [ ] A second capture near a transition cannot overwrite the result.
- [ ] Team departures resolve according to the documented round policy.
- [ ] Lobby departure below minimum cancels the countdown.
- [ ] Mid-round join waits as a spectator until the next round.
- [ ] Reset/death cannot escape capture or re-enter the round.
- [ ] Automatic reset clears participants, cooldowns, spectator state and HUD values.
- [ ] Run at least three complete consecutive rounds with no growing errors or stale state.
- [ ] Larger lobby honors the configured team ratio, with both teams represented.

## Gate 5: HUD, devices and private publish (not implemented)

- [ ] Round timer, team and remaining bugs reflect server state.
- [ ] Desktop keyboard/mouse and real mobile touch controls work.
- [ ] HUD respects small screens, safe insets and Roblox UI.
- [ ] Run a two-account private-session test on separate devices.
- [ ] Record latency, camera issues, balance observations and any Output errors.

## Test record

| Commit | Studio version | Tester/device | Gate | Result/evidence |
| --- | --- | --- | --- | --- |
| Pending | Pending | Pending | 1 | Not run |
# Reference character acceptance — pending Studio

- [ ] Save the current imported house; sync source changes through Rojo.
- [ ] Follow docs/CHARACTERS.md: import StinkBugV2 (body + six legs) and VacuumV2 (body + glow) into correctly named Models under ServerStorage.CharacterAssets.
- [ ] Start solo Play. Welcome screen shows title, 3D preview and green button. PLAY dismisses it and restores movement.
- [ ] Check mouse and touch activation in portrait and short landscape emulator sizes; ensure the button is visible and the thumbstick returns.
- [ ] Bug has a brown shield, expressive eyes and no visible humanoid body. Imported appearance reads Blender V2 animated brown bug.
- [ ] Walk forward, backward, strafe and turn. All six legs move in alternating tripods. Stop and jump: legs return to rest.
- [ ] With two clients, observe the moving bug from the human's client as well as its own.
- [ ] Reset each player three times: exactly one cosmetic copy and six bug motors return; no frozen legs or orphaned parts.
- [ ] Walk bugs through existing vents and up book stairs; check foot clearance throughout a stride.
- [ ] Human's vacuum has cyan glowing eyes/nozzle, correct grip and manageable size. It does not snag doorways.
- [ ] Native fallback test: move V2 imports outside CharacterAssets, restart Play, verify brown bug movement and blue vacuum. Restore imports.
- [ ] Five clients produce four bugs and one human; observe all bugs moving independently.
- [ ] Disconnect during spawn, then reconnect: correct team appearance and camera return.
- [ ] Check the four pictured slogans, potted plants, crowned shelf bug, purple cleaner and large vacuum mascot. No display should obstruct routes.
- [ ] Save, reopen and verify mesh/texture permissions before private publishing.
# Interior expansion acceptance

- [ ] Save the current house, stop Play, sync Rojo and find House.InteriorDetails.
- [ ] Check all 16 furniture groups for visual overlap with any Studio-only or manually moved imports.
- [ ] Walk a human around chairs, carts, luggage and storage; check every doorway and stair approach remains usable.
- [ ] Pass through both cardboard tunnels as a bug; humans must be blocked.
- [ ] Enter the blanket hideout from the front and leave through its rear gap as a bug; humans must be blocked.
- [ ] Check that cover blocks movement and raycasts, while books, towels, straps and fruit do not snag avatars.
- [ ] Repeat with two players and mobile controls; inspect camera clipping and performance.
# Solo robot and collection gate

Follow the complete checklist in SOLO_SNACK_RUN.md. In particular test solo patrol and capture, refuge immunity, delivery and carried-item loss, then add a second client during pursuit to verify robot/beam cleanup. Check concurrent pickup claims, character resets and disconnects before accepting this feature.
# Snack flight regression

Follow the flight checks in [Solo snack run](SOLO_SNACK_RUN.md). With two clients, verify only the StinkBug earns fuel, the Vacuum sees the bug's flight/wings, and reset or disconnect during flight leaves no lift behind. These engine checks are pending.

# Climbing and reaching-grab regression

Use the sofa/climbing/grab checklist in SOLO_SNACK_RUN.md. Confirm both clients see climbing legs, human players cannot climb or fly, and a second player joining during a solo grab removes the robot, nozzle, beam and pull immediately. Reset/disconnect a climbing bug and verify no force remains. These Studio checks are pending.

# Controlled-climb and top-hose follow-up

- [ ] Two clients observe consistent climbing movement/legs; input from a Vacuum or dead bug cannot activate climbing.
- [ ] Idle grip expires in four seconds; releasing/regrabbing airborne does not replenish it. Ground recovery is capped and reset restores normal speed/turning.
- [ ] Drop/delay movement packets: wall motion stops after the input timeout without extending grip. Try invalid/oversized/nonfinite movement inputs; server rejects them.
- [ ] In solo Play, the visible top hose raises, follows moving targets, reaches and retracts. Adding a second player removes all local hose visuals and the server pull.
- [ ] Test desktop and mobile controls, each doorway/tunnel and all floor transitions after taller walls. Verify the starting sofa in the saved imported house, not only a fresh preview build.
