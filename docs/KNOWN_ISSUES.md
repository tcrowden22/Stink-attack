# Known issues and limitations

1. **Foundation only.** Suction, captures, spectator mode, 15-second lobby, five-minute rounds, victory/reset logic and the match HUD are not implemented. This is the initial requested environment milestone, not a finished Week 1 delivery.
2. **Studio acceptance pending.** Two-client execution, visual quality, mobile input, character/camera behavior and tunnel clearance have not been observed in Studio. Rojo build and Luau compile success do not establish those results.
3. **No locomotion animations yet.** Explicitly constructed R15 models have no custom Animate controller. They can use normal Humanoid movement, but may appear stiff. Animation polish is a later feature; no third-party animation model was imported.
4. **Avatar creation uses Roblox's avatar service.** First spawn can be slow or fail offline; the server retries and the HUD reports loading/failure.
5. **No movement exploit protection yet.** Roblox's normal character network ownership remains in use. Server collision assignments are not sufficient protection against client teleporting. Future ability/round work must account for implausible movement.
6. **Stable foundation teams.** A disconnect can leave one team empty until someone joins. There is no active round to resolve at this milestone.
7. **Rojo plugin registration workaround.** The CLI installer could not discover this Studio installation. The verified plugin was copied to the standard local Plugins folder; actual plugin visibility and synchronization remain unverified.
8. **No public publish or real-device test.** The generated place is local. Private publishing instructions are documented for later acceptance.
9. **Aikido coverage limitations.** Scans returned no findings for proposed first-party files. This does not establish Roblox-specific runtime security or full Luau semantic analysis.

10. **Expanded house/refuge pending runtime verification.** Playroom, clubhouse entrances, refuge membership, vacuum relocation and crowded spawn behavior have compile/build and geometry checks only. The roof may require camera tuning.
11. **Larger-lobby capacity is not configured.** Team policy supports larger groups, but the Roblox experience's maximum player count must be set separately and tested on real clients.
12. **Refuge capture integration is pending.** The server provides isProtected and excludes vacuums, but suction/capture code does not exist yet. A future capture must recheck position through that server function.

13. **Vertical traversal is not yet observed in Studio.** Static checks confirm sampled stair headroom, book-step clearance and attic tunnel centers; actual Humanoid movement and mobile book jumping must be tested.
14. **Solid ceilings change camera behavior.** Zoom occlusion is configured, but camera comfort inside the house, stairwell and attic still needs review. No ceiling transparency feature is implemented.
15. **Rooftop fans are stationary.** They are hiding geometry, not moving hazards. The skylight is decorative and does not open.
16. **Expanded map performance pending.** The house now contains 1,047 native anchored parts; larger-server and real-device performance remain unmeasured.

17. **Accessories are static visual props.** Gaming screens, appliances and electronics are not interactive. Decorative parts do not block movement or raycasts and therefore are not gameplay cover. Placement and lighting have not been visually inspected in Studio.

18. **Blender kit imported in the user's Studio place.** The user reported successful placement of 16/16 mesh details. These Studio-only asset references are not present in clean Rojo builds; preserve the saved place and imports.
19. **Mesh placement unverified in Studio.** Scale, orientation, texture appearance and sofa collision-proxy alignment require inspection after import. The Blender catalogue render is not an in-game screenshot.
20. **Portable mesh assets require owner permissions.** Save a source .rbxm with valid mesh/texture asset references under assets/imported for reproducible builds. Local-preview imports can contain temporary content.
21. **Character art needs Studio acceptance.** The original Blender stink bug passes FBX round-trip checks but needs importing into ServerStorage.CharacterAssets. Until then, bugs use a native-part costume. Check orientation, floor clearance, camera, respawning and two-client visibility in Studio.
22. **Rigid bug and decorative vacuum.** Six-leg animation is not implemented. Humans carry a non-interactive vacuum prop; suction remains a separate milestone.
