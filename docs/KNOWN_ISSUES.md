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
