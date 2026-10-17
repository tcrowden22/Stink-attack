# Bird pecks, stink escapes, stairs and toilets

## Apply in Studio

1. Stop Play, then save your imported house. The saved place was not overwritten.
2. Sync Rojo at localhost:34872 to update the bird behavior, stairs and all three bathroom models.
3. Press Play. Test a rooftop peck and pickup; press R, gamepad B or Stink! while carried. Walk both main and former book-stair routes without jumping. Inspect each bathroom toilet.

A separate clean build is `build/StinkBugsVsVacuums-peck-stairs-preview.rbxlx`; sync the existing place to preserve imported art.

## Bird changes

- Each bird alternates successful peck and pickup attacks. A peck removes 20 health, so a full-health bug survives it. A shared two-second interval prevents simultaneous birds from dealing several pecks at once. Repeated pecks can still defeat a weakened bug and trigger the existing snack-loss/respawn flow.
- Head/beak animation shows a short peck. Cover, rooftop bounds, warning and close-range validation remain in place.
- Pickups claim one bug per bird and one bird per bug without yielding. The bird lifts about eight studs, settles the passenger beneath its feet when clear, and releases after at most five seconds. Pickup timeout does not kill the bug.
- Pressing Stink while carried triggers the usual cloud/sound and requests a server-authorized drop. One emergency burst is available per pickup even during an existing stink cooldown; duplicate requests cannot repeat the bypass. The normal cooldown restarts afterward.
- Flight and climbing cancel during pickup. Movement state, attachments and physics ownership are restored after release, reset, death, target removal or a conflicting vacuum grab. Passenger collision sweeps abort unsafe lifts. Recently dropped bugs get a brief peck grace period.

## Stair and toilet changes

- Main stairs keep their existing gentle continuous collision ramps and thin brown treads.
- Both steep book staircases now use 48 close-spaced brown wooden treads over continuous invisible collision ramps. The visible steps do not obstruct walking. These short routes remain steeper (45 degrees) than the long main flights, but no longer have 1.5-stud jumping steps. Entrance landings and upper-floor openings remain.
- All three toilets now have a compact pedestal, bowl, single oval closed seat/lid, hinge, tank and flush button. Disconnected ring pieces and the dark bowl patch were removed. A dedicated Blender preview was visually inspected at `build/toilet-preview.png`.

## Pending Studio checks

- [ ] A full-health bug survives a peck; damage is 20. Multiple birds cannot apply damage inside the two-second interval. Head and beak move together.
- [ ] A pickup visibly raises the bug and leaves it alive. R/B/Stink! drops it promptly, including when stink was already cooling down. Spamming does not produce multiple emergency bursts.
- [ ] Wait out a pickup: drop after five seconds without a kill. Reset/disconnect/get vacuumed during a pickup: no leftover force, frozen movement or stuck carried flag.
- [ ] Verify passenger clearance near fans, chimney and roof edges, and both clients' view of the carry. Check touch Stink! remains reachable.
- [ ] Walk all three main flights and both former book flights in both directions as human and bug, without jumping. Check entrances, top landings, ceilings and automatic climb behavior.
- [ ] Check all toilets in the imported house for attached parts, normal proportions and camera clearance.

All Luau compiled, all nine rule/gait suites and map validators passed, and Rojo built the separate preview. Aikido scanned 14 changed code/data files with zero findings and no skipped paths; the final passenger-settling adjustment also passed a rescan. Actual pickup physics, walking feel and multiplayer acceptance remain pending in Studio.
