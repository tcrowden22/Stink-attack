# Choose a side and hunt AI bugs

Stop Play, save the imported house, sync Rojo, then start Play. Choose **STINK BUG** or **VACUUM** on the welcome screen. The menu stays up until the server finishes spawning the chosen R15 character. No new asset imports are needed.

- **Stink Bug:** the existing collecting, delivery, climbing and snack-flight game. In solo play, the Clean Team robot hunts you.
- **Vacuum:** a human carrying the blue vacuum. Three AI stink bugs roam the ground-floor rooms and flee nearby hunters. Face a bug and hold left mouse, Q, gamepad R2 or the mobile Suction button. A cyan beam shows the target. Keep it in front and in sight to pull it close and capture it.

AI bugs use the existing animated stink bug art and server-owned movement. Captured bugs respawn after eight seconds. The HUD shows session-only bugs caught and AI bugs remaining. No purchases or persistent progression are involved.

## Server rules

The server accepts only the two exact team names, once per join. Rejoin to choose the other side. Reset keeps your selection. This free-play choice takes priority over automatic team ratios; the existing allocation helper is retained for future round balancing.

AI bugs appear whenever there are vacuum players and no human stink bugs, including cooperative all-vacuum play. When a human chooses Stink Bug, AI bugs despawn and vacuum players can hunt that human instead. Captured human bugs respawn at home through the existing capture lifecycle. The robot vacuum remains solo-only.

Suction validates the hunter's live team/character, 18-stud range, forward cone, line of sight from both the character and nozzle, and clubhouse protection. Input sends only held/released intent, never a target or capture claim. A target is claimed without yielding so two vacuums cannot pull or score the same bug. Capture requires four-stud proximity after a 0.7-second lock-on. Each burst lasts at most four seconds; capture/burst exhaustion imposes a 1.5-second cooldown. Releasing, stale input, death, team change, leaving range, obstruction or disconnect cleans up the beam and pull.

## Studio acceptance — pending

- [ ] Join fresh: no automatic team or character. Both role buttons are readable on desktop and mobile. Select either role and confirm the menu closes only after its character is ready.
- [ ] Rapidly click both roles or send repeated/invalid selections: exactly one role and one spawn are accepted. Reset retains the role. Leave during loading and confirm no orphan character appears.
- [ ] Choose Vacuum alone: three animated AI bugs appear in separate rooms, move around furniture and flee. Check Output for avatar or navigation errors.
- [ ] Hold click/Q/Suction: beam appears, bug pulls toward the nozzle and score rises once on capture. Release or hide behind furniture to break suction.
- [ ] Test range, facing, clubhouse protection, cooldown and four-second burst limit. Release input or switch application focus; no stuck suction remains.
- [ ] Capture all three: count reaches zero, then bugs return after their individual respawn delays. New models do not duplicate old bugs.
- [ ] Two Vacuum clients: both see AI and their leg animation. Competing captures give exactly one player one point. Disconnect a hunter mid-pull; the bug is released.
- [ ] One player selects each side: AI bugs clear, human-bug capture respects cover/home and respawns correctly. When the human bug leaves, three AI bugs return.
- [ ] Choose Stink Bug alone: existing robot chase, snack collection, flight and controlled climbing still work.
- [ ] Test portrait/landscape touch controls, gamepad role selection and Suction release/cancel behavior.

Automated checks cover pure selection/mode/suction rules and syntax; they do not replace these engine playtests. AI currently walks and jumps along ground-floor patrol routes; it does not autonomously climb, fly or collect snacks.
