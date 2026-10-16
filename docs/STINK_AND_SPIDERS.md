# Stink burst, close captures and spiders

## Apply in Roblox Studio

1. **Stop Play** so the next session starts all updated scripts.
2. **Save your imported house** before synchronizing. The saved `build/StinkBugsVsVacuums.rbxlx` was not overwritten.
3. **Connect/sync Rojo at localhost:34872** in the open place. This adds the ability, spider geometry and services. The local server is already running.
4. **Press Play and choose Stink Bug.** Press R, gamepad B, or touch Stink! Follow the clubhouse countdown and leave through an escape opening.
5. **For multiplayer acceptance**, stop Play and start a two-player Studio server. Choose one Vacuum and one Stink Bug. Both clients should see the cloud and animated spiders.

The separate `build/StinkBugsVsVacuums-stink-spiders-preview.rbxlx` is a clean build with native fallback art. Sync your existing place to retain imported art.

## Behavior

- Acquired vacuum targets remain capturable within four studs after crossing the hunter's center. New targets require the forward cone. Cover, refuge, life, cooldown and windup checks remain server-controlled.
- Stink reaches 12 studs with line of sight and slows humans/solo robot to 45% speed for four seconds. The twelve-second cooldown persists across character resets. Repeated bursts refresh rather than multiply the slowdown. Stink does not cancel a suction hold.
- Two clubhouse spiders pursue bugs after more than five continuous seconds inside. Each bug has its own timer, reset on leaving or respawning. Another player's expired timer never removes a new arrival's grace period.
- Two attic spiders pursue bugs within 32 studs, without a grace period. Spiders stay in their assigned zone, use paths around cover and bite within three studs after a 0.4-second windup and clear line of sight.
- A head lunge accompanies a bite; the bug disappears, loses carried snacks and respawns. Delivered snacks remain. Vacuum players are not spider targets.
- The clubhouse still excludes vacuums but is no longer a permanent safe waiting area. Signs and HUD show the five-second rule.

## Original Blender asset

`assets/characters/spider/ClubhouseSpider.blend`, `.fbx`, `preview.png` and `manifest.json` come from `scripts/build_spider.py`, run with Blender 5.1.2. This original model has eight leg groups and 47 component shapes, without downloaded art or textures.

The generator also exports `src/shared/SpiderGeometry.luau`. Roblox reconstructs the same authored shapes as native parts, with eight leg joints and a head joint, so no upload/import is needed. The FBX is supplied for later mesh optimization; it is not an uploaded Roblox mesh. The Blender preview was visually inspected; runtime lighting will differ.

## Pending Studio acceptance

- [ ] Solo robot and player vacuum: complete pulls, including crossing the center. Each bug dies once and respawns without leftover forces/beams. Repeat against AI bugs.
- [ ] Solid cover and clubhouse protection still block vacuum capture; new rear targets cannot be acquired.
- [ ] R/B/touch makes one cloud. Rapid presses, character resets during cooldown, dead bugs and human-role requests cannot bypass the cooldown or create extra clouds.
- [ ] Both clients see the cloud. Hunters within 12 studs slow; hunters outside or behind walls do not. Speed restores after four seconds; overlapping bursts do not stack multipliers.
- [ ] Clubhouse countdown lasts five seconds before pursuit. Leave/reenter, reset and disconnect; no stale timer or bite. A second arrival gets its own five seconds while another bug is hunted.
- [ ] Inspect all four spiders: floor alignment, eight moving legs, head bite, paths around furniture and no bites through walls. Attic spiders must not chase downstairs.
- [ ] Eaten bugs lose carried snacks, keep banked snacks and respawn normally. Check cleanup and performance through several cycles with two clients.
- [ ] Check touch/gamepad buttons alongside movement, jumping, flight, climbing and suction on target devices.

Compilation, rule tests, geometry checks, security scans and the Rojo build passed. Studio physics, pathfinding, appearance and multiplayer acceptance remain pending.
