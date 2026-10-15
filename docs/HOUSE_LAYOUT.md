# House expansion

The living room is the central room. A kitchen extends east and a bedroom extends south. All geometry is authored from anchored Roblox Parts; no Toolbox assets or runtime dependencies were added.

| Room | Bounds in studs (X / Z) | Furniture |
| --- | --- | --- |
| Living room | -50 to 50 / -38 to 38 | Sofa, coffee table, TV, shelves, ottoman, lamp, books, two tunnels |
| Kitchen | 50 to 122 / -38 to 38 | Tiled floor, cabinets, sink and faucet, stove/oven, fridge, island, stools, dining table and benches |
| Bedroom | -50 to 50 / 38 to 110 | Bed with crawl space, pillows, duvet, bedside tables/lamps, wardrobe, desk/chair, toys, window and curtains |

Floor surfaces are approximately Y=0. Walls are 22 studs high. The house remains open at the top for prototype visibility and camera testing.

## Connections

- Living room to kitchen: doorway centered at X=50, Z=0; 14 wide by 12 high.
- Kitchen bug shortcut: vent at X=50, Z=-27; 4 wide by 2.4 high.
- Living room to bedroom: doorway centered at X=0, Z=38; 14 wide by 12 high.
- Bedroom bug shortcut: vent at X=-38, Z=38; 4 wide by 2.4 high.

Green floor markings indicate bug-only passages. Each new vent has a server-configured collision gate. Existing team spawn pads remain in the living room. Normal doorways and vents make alternative routes rather than single-entry dead ends.

## Studio actions

1. Stop the current simulation before accepting the Rojo update. This allows a clean map and collision setup on the next Play.
2. Connect the Rojo plugin to localhost:34872 if not connected. Confirm Workspace.House contains LivingRoom, Kitchen and Bedroom. The former top-level LivingRoom is now nested under House.
3. If live sync is unavailable, use Open from File to reopen the rebuilt build/StinkBugsVsVacuums.rbxlx. Save any unrelated Studio work first.
4. Start Server & Clients with two clients. Walk both teams through both normal doorways; traverse both low vents as a bug and verify that a vacuum is blocked.
5. Check the bedroom crawl space, kitchen furniture paths, camera clipping and Output errors. These engine-level checks remain pending.

The build and static clearance checks passed. Actual movement, visuals and multiplayer acceptance have not been observed by the agent.
