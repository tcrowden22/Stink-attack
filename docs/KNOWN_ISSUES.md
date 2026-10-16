# Known issues and limitations

1. **Week 1 multiplayer loop incomplete.** Solo NPC suction/capture and snack collection/delivery now exist. Player-operated suction, spectator mode, 15-second lobby, five-minute rounds, victory/reset logic and the match HUD remain unfinished.
2. **Studio acceptance pending.** Two-client execution, visual quality, mobile input, character/camera behavior and tunnel clearance have not been observed in Studio. Rojo build and Luau compile success do not establish those results.
3. **Bug legs animate; human animation remains basic.** Bugs have six procedural leg joints, with idle/air poses and alternating tripods. Human R15 rigs still lack a full Animate controller and may look stiff. Engine-level animation acceptance is pending.
4. **Avatar creation uses Roblox's avatar service.** First spawn can be slow or fail offline; the server retries and the HUD reports loading/failure.
5. **No movement exploit protection yet.** Roblox's normal character network ownership remains in use. Server collision assignments are not sufficient protection against client teleporting. Future ability/round work must account for implausible movement.
6. **Stable foundation teams.** A disconnect can leave one team empty until someone joins. There is no active round to resolve at this milestone.
7. **Rojo plugin registration workaround.** The CLI installer could not discover this Studio installation. The verified plugin was copied to the standard local Plugins folder; actual plugin visibility and synchronization remain unverified.
8. **No public publish or real-device test.** The generated place is local. Private publishing instructions are documented for later acceptance.
9. **Aikido coverage limitations.** Scans returned no findings for proposed first-party files. This does not establish Roblox-specific runtime security or full Luau semantic analysis.

10. **Expanded house/refuge pending runtime verification.** Playroom, clubhouse entrances, refuge membership, vacuum relocation and crowded spawn behavior have compile/build and geometry checks only. The roof may require camera tuning.
11. **Larger-lobby capacity is not configured.** Team policy supports larger groups, but the Roblox experience's maximum player count must be set separately and tested on real clients.
12. **Refuge capture integration is partial.** Solo NPC suction and capture use live isProtected checks, and an NPC entering the refuge is relocated. Future player-operated suction must use the same server protection.

13. **Vertical traversal is not yet observed in Studio.** Static checks confirm sampled stair headroom, book-step clearance and attic tunnel centers; actual Humanoid movement and mobile book jumping must be tested.
14. **Solid ceilings change camera behavior.** Zoom occlusion is configured, but camera comfort inside the house, stairwell and attic still needs review. No ceiling transparency feature is implemented.
15. **Rooftop fans are stationary.** They are hiding geometry, not moving hazards. The skylight is decorative and does not open.
16. **Expanded map performance pending.** The house has the earlier 1,047 source parts plus 198 new interior furniture parts and runtime-created decorations; larger-server and real-device performance remain unmeasured.

17. **Accessories are static visual props.** Gaming screens, appliances and electronics are not interactive. Decorative parts do not block movement or raycasts and therefore are not gameplay cover. Placement and lighting have not been visually inspected in Studio.

18. **Blender kit imported in the user's Studio place.** The user reported successful placement of 16/16 mesh details. These Studio-only asset references are not present in clean Rojo builds; preserve the saved place and imports.
19. **Mesh placement unverified in Studio.** Scale, orientation, texture appearance and sofa collision-proxy alignment require inspection after import. The Blender catalogue render is not an in-game screenshot.
20. **Portable mesh assets require owner permissions.** Save a source .rbxm with valid mesh/texture asset references under assets/imported for reproducible builds. Local-preview imports can contain temporary content.
21. **V2 character art needs Studio acceptance.** Import StinkBugV2 and VacuumV2 into ServerStorage.CharacterAssets, preserving seven bug meshes and two vacuum meshes. Native V2 fallbacks work before import. Check orientation, size, floor clearance, animated legs, camera, respawns and two-client visibility.
22. **Player vacuum and static antennae.** Solo robot suction exists, but player-held vacuums remain decorative. Legs articulate at the hip; knees and antennae are not independently animated. The old oversized mascot and crowned bug remain static decorations, distinct from CleanTeamRobot.
23. **Reference UI needs device verification.** The welcome screen has a Play button and 3D preview, not the supplied photo as a background. Test short landscape screens, portrait touch input and movement restoration. Upgrades, cosmetics shops and ranked progression remain excluded.
24. **Interior furniture awaits Studio acceptance.** Static placement and sampled human-route checks pass on all three interior floors. Manually moved Studio objects, camera behavior, real avatar clearance and bug-only gates still need a playtest. Carts, luggage and storage are anchored; hiding spaces do not grant refuge protection.
25. **Solo AI needs engine testing.** Pathfinding around furnished rooms, suction timing, character resets and multiplayer joins/leaves are not yet observed in Studio. Patrol is downstairs; upper-floor chase depends on path availability. Rules and static snack-location checks pass.
