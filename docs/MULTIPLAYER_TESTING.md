# Multiplayer acceptance checklist

Status: **Not run in Roblox Studio.** Source/build checks are recorded separately in VALIDATION.md. Native Studio interaction is not available to the current agent.

Record Studio version, Git commit, date, tester, device(s), observed results and Output errors. Check boxes only after observing the behavior.

## Gate 1: foundation (current handoff)

Before starting, read README's Studio actions. Connect Rojo, stop any existing simulation, and open Output so errors are visible.

- [ ] Solo Play spawns a green R15 bug and shows Foundation free play.
- [ ] Room contains sofa, table, TV, shelves, books and two tunnels; nothing falls or drifts.
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
- [ ] Repeat with six clients: initial allocation is four bugs and two vacuums.
- [ ] Use Studio's Device Emulator with a phone profile; touch movement/jump work and HUD text fits.
- [ ] Stop all sessions, restart the test, and verify clean initialization.
- [ ] Output has no unexpected errors on server or clients.

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
