# Gated implementation plan

Implement one feature and verify its acceptance criteria before starting the next. Do not treat unchecked runtime criteria as passed.

| Order | Feature | Required evidence | Status |
| --- | --- | --- | --- |
| 1 | Repository, Rojo, minimum map and server-owned R15/team foundation | Build, allocation tests, two-client movement/spawn/tunnel test | Code/build complete; Studio gate pending |
| 2 | Vacuum suction | Range, forward cone, obstruction, cooldown, invalid-request and spam tests; desktop/mobile intent input | Not started |
| 3 | Capture and spectator lifecycle | Atomic capture, spectator exclusion, safe camera fallback and reset behavior | Not started |
| 4 | Lobby and rounds | 15-second lobby, 300-second round, minimum two players, wins and automatic resets | Not started |
| 5 | Lifecycle edge cases | Mid-round join, disconnect, spawn failure, reset and transition races | Not started |
| 6 | Match HUD and end-to-end test | Timer/team/bugs, mobile layout, three rounds with at least two players | Not started |

## Architecture for remaining Week 1 work

- Add a server RoundService owning phase, round ID, participants and deadline; publish only UI state.
- Add SuctionService validating phase, membership, living character, rate limit/cooldown, range, forward cone and server raycast. Never accept client-selected capture results.
- Add a single server capture transition so repeated requests cannot decrement bug counts twice.
- CharacterService must consult participation state before every spawn once rounds exist; foundation free-play respawning must not carry over unchanged.
- Late joiners should spectate until the next lobby. Define outcomes when the final member of either team disconnects before implementing transitions.
- Keep input and camera modules on the client. Bind one ability intent for keyboard/mouse and a touch button.
- Test server rules with integration checks in Studio as well as pure policy tests outside the engine.

## Week 2 recommendations

Only start these after Week 1 gates pass:

1. Replace stiff default motion with reviewed animation and add readable suction/capture sound and visual feedback.
2. Tune speeds, tunnel placement and suction timings using recorded two-, four- and eight-player sessions.
3. Add server movement plausibility checks suitable for the chosen networking model; test latency before enforcing penalties.
4. Improve spectator controls, onboarding and accessible color/icon cues.
5. Profile low-end mobile performance and camera clipping around small bug avatars.
6. Automate Studio integration scenarios and add CI for compile/build/pure-policy tests.

Keep monetization, cosmetic shops and persistent progression outside the prototype until the core loop is proven.
