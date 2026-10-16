# Sounds and stair covering repair

## Apply in Studio

1. Stop Play so the new client audio controller starts next session.
2. Save the imported house, then sync Rojo at localhost:34872. No audio or model upload is required.
3. Press Play and choose Stink Bug. Approach the robot, approach a clubhouse spider, and press R / Stink! to check all three sounds. Check Studio and system sound volume if silent.
4. Walk the main stairs and check that the tall cream/brown covering is gone. Entrance landings and collision ramps remain.

Your imported saved place was not overwritten. A separate clean preview is available at `build/StinkBugsVsVacuums-sound-stairs-preview.rbxlx`.

## Sound design

- Vacuum proximity: a low, filtered whirr from the solo robot and human vacuum players, within approximately 55 studs. Suction increases its level and pitch.
- Spider proximity: a tremolo scuttle/rattle within approximately 30 studs. Bites increase urgency. Guards can be heard before they attack.
- Stink: the existing server-approved StinkEffect event triggers a short bass raspberry and airy tail at the cloud's position, audible within approximately 45 studs. Invalid/cooldown requests cannot create new sound events.
- These are designed prototype effects made from bundled falling, plastic-footstep, explosion and swimming sounds, using pitch, filtering, distortion and tremolo. They are not newly uploaded recordings. Their presence in this computer's Studio content directory was verified.
- Sound comes from each character or effect location and attenuates with distance. Ordinary walls do not occlude it. Character-based range selection and Roblox's camera-based listener can differ slightly.
- Each client limits continuous voices to the nearest three vacuums and two spiders; at most six stink emitters remain active. Bursts expire after 1.1 seconds. Removal, death, reset, menu state and leaving range remove loops. The controller does not send extra network events.

## Stair correction

The previous riser change enlarged alternating cream/brown tread blocks down to the floor, creating tall visible panels underneath the stair flights. Treads are now half a stud thick, uniformly wood-colored, with unchanged top heights. All five gap-closing entrance landings remain. The generator and regression validator enforce this so regeneration cannot restore the covering.

## Pending Studio acceptance

- [ ] Approach/leave the solo vacuum: motor gets louder nearby, quieter away; suction changes its tone. Confirm comfortable volume on speakers and headphones.
- [ ] With two clients, approach a human vacuum and hear the motor; release suction, die or disconnect without a stuck sound.
- [ ] Approach all four spiders; hear a distinct scuttle/rattle. Bites intensify it and leaving range silences it. Several spiders do not produce excessive volume.
- [ ] Press Stink! Both clients nearby hear one short cartoon fart aligned with the cloud. Cooldown spam makes no extra sounds. Check the first burst after joining, not just cached playback.
- [ ] Reset or return to the menu during audio: no orphaned loops or invisible emitters. Check Studio Output for audio loading errors.
- [ ] Inspect the saved imported house's main stairs from above and below, including upper flights. No tall striped panel remains; entry gaps stay closed and movement/rail clearance still work.

All Luau compiles, all eight rule/gait suites and house/interior/snack/renovation checks pass. The separate Rojo build passes. Aikido scanned all six changed first-party code/data files with zero findings and no skipped paths. Listening tests, real stair appearance, and multiplayer/audio acceptance remain unverified in Studio.
