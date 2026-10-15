# House expansion

The living room is the central room. A kitchen extends east, a bedroom extends south, and a new playroom fills the southeast corner to create a circulation loop. A covered Bug Clubhouse extends west. A side stairwell extends east and connects a furnished upstairs floor, an attic and a playable roof. All geometry, including the decorative Accessories collection, is authored from anchored Roblox Parts; no Toolbox assets or runtime dependencies were added.

| Room | Bounds in studs (X / Z) | Furniture |
| --- | --- | --- |
| Living room | -50 to 50 / -38 to 38 | Sofa, coffee table, TV, shelves, ottoman, lamp, books, two tunnels |
| Kitchen | 50 to 122 / -38 to 38 | Tiled floor, cabinets, sink and faucet, stove/oven, fridge, island, stools, dining table and benches |
| Bedroom | -50 to 50 / 38 to 110 | Bed with crawl space, pillows, duvet, bedside tables/lamps, wardrobe, desk/chair, toys, window and curtains |
| Playroom | 50 to 122 / 38 to 110 | Foam mats, toy bins, building blocks, cushion fort, craft table, reading nook |
| Bug Clubhouse | -82 to -50 / 0 to 76 | Central bug spawn, team benches, cushions, green lights and signs |

Ground-floor surfaces are approximately Y=0. Main walls are 22 studs high and are now covered by the solid upstairs floor at Y=24. The clubhouse keeps its separate roof at Y=12.5. Upper floors span X=-50 to 146 and Z=-38 to 110, with explicit openings for stairs and book routes.

## Connections

- Living room to kitchen: doorway centered at X=50, Z=0; 14 wide by 12 high.
- Kitchen bug shortcut: vent at X=50, Z=-27; 4 wide by 2.4 high.
- Living room to bedroom: doorway centered at X=0, Z=38; 14 wide by 12 high.
- Bedroom bug shortcut: vent at X=-38, Z=38; 4 wide by 2.4 high.

Green floor markings indicate bug-only passages. Each new vent has a server-configured collision gate. Vacuums still spawn in the living room; bugs now spawn inside the clubhouse on a 24-position grid. Normal doorways and vents make alternative routes rather than single-entry dead ends.

## Studio actions

1. Stop the current simulation before accepting the Rojo update. This allows a clean map and collision setup on the next Play.
2. Connect the Rojo plugin to localhost:34872 if not connected. Confirm Workspace.House contains LivingRoom, Kitchen, Bedroom, Playroom, BugClubhouse, Stairwell, Upstairs, Attic and Rooftop. The former top-level LivingRoom is now nested under House.
3. If live sync is unavailable, use Open from File to reopen the rebuilt build/StinkBugsVsVacuums.rbxlx. Save any unrelated Studio work first.
4. Start Server & Clients with two clients. Walk both teams through both normal doorways; traverse both low vents as a bug and verify that a vacuum is blocked.
5. Check the bedroom crawl space, kitchen furniture paths, camera clipping and Output errors. These engine-level checks remain pending.

The build and static clearance checks passed. Actual movement, visuals and multiplayer acceptance have not been observed by the agent.

## New routes and refuge

- Kitchen ↔ playroom: X=62, Z=38, opening 16 wide and 12 high.
- Bedroom ↔ playroom: X=50, Z=84, opening 16 wide and 12 high.
- Living room ↔ clubhouse: X=-50, Z=16, opening 6 wide and 2.4 high.
- Bedroom ↔ clubhouse: X=-50, Z=56, opening 6 wide and 2.4 high.

The clubhouse has an uninterrupted central spawn area. Its server-owned bounds determine refuge membership from the character root position. Normal collision gates block vacuums; an additional check every 0.2 seconds relocates vacuum intruders. Living bugs get a refuge HUD indicator. Future capture logic must query the server refuge function directly.

After stopping Play and syncing Rojo, inspect both entrances, spawn a bug inside the clubhouse, leave and re-enter through each route, and test both entrances as a vacuum. Also test the full living room → kitchen → playroom → bedroom → living room loop. Roof/camera clearance and crowded spawning require Studio verification.

## Vertical layout

| Level | Walking surface | Features |
| --- | --- | --- |
| Ground | Y=0 | Existing rooms, clubhouse and new stairwell |
| Upstairs | Y=24 | Bedroom, lounge, study, toy chest and reading cushions |
| Attic | Y=48 | Beams, storage crates, trunk and bug crawl tunnels |
| Rooftop | Y=64 | Three stationary ventilation fans, hiding shelters, ducts, chimney and skylight detail |

### Main stair route

- Stairwell bounds: X=122 to 146, Z=-38 to 110.
- Kitchen doorway: X=122, Z=-28. Playroom doorway: X=122, Z=84.
- The first two flights run from Z=-22 to 38 at X=134, climbing 24 studs each.
- The final flight runs from Z=-22 to 18 at X=134, climbing 16 studs.
- Walk along the west side of the stair opening at each floor to return to the next flight's north entrance.
- Each flight is 12 studs wide, with a continuous collision slope of about 22 degrees and noncolliding visual steps. Upper landings and guard barriers preserve a route around the openings.

### Book route and hiding spots

Sixteen book steps near X=-22, Z=44 to 66.5 connect the bedroom to upstairs. A second flight in the same position connects upstairs to the attic. Each rise is 1.5 studs, below the bug's configured 2-stud jump height. They are an alternative climbing route, not a team-restricted entrance.

Attic tunnels at approximately (15,48,28) and (80,48,60) have 2.4-stud clearance and server-assigned bug-only gates. Storage crates create other hiding alleys. Fan shelters on the roof have low crawl clearance; fan blades are stationary props.

### Studio acceptance

Stop Play before syncing the model additions. Confirm all nine models appear under Workspace.House. Run two clients, take both teams from the kitchen to the roof and back, jump the book route as a bug, and try the attic gates as both teams. Check camera movement under ceilings and the clubhouse roof, especially on mobile. These runtime checks remain pending.

## Decorating pass

| Area | New accessories |
| --- | --- |
| Living room | Wall pictures, fern, mug, remote, console/controller, throw pillows and blanket |
| Kitchen | Wall art, toaster, utensils, soap/sponge, fruit bowl, breakfast mug, plates/napkins, fridge magnets/note and herb plant |
| Bedroom | Pictures, alarm clock, plant, sketchbook/pencils and plush toy |
| Playroom | Craft paper/crayons, toy cars and poster |
| Upstairs | Gaming PC/monitor, keyboard, mouse, speaker, controller/headset, mug, posters, plant and board game |
| Attic | Radio and stored board-game boxes |
| Clubhouse | Wall picture and bench cushions |

The 226 accessories are grouped by room beneath Workspace.House.Accessories. They do not collide, fire touch events, or block raycasts. The map now contains 1,001 parts. Decor does not change team state or traversal geometry. Stop Play and sync before inspecting it. Visual placement, lighting and device performance still require Studio review.
