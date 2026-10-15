--!strict
local Players = game:GetService("Players")
Players.CharacterAutoLoads = false

local MapService = require(script.Parent.MapService)
local TeamService = require(script.Parent.TeamService)
local CharacterService = require(script.Parent.CharacterService)
MapService.init()
require(script.Parent.ArtDetailService).apply()
TeamService.init()
require(script.Parent.RefugeService).start()
workspace:SetAttribute("PrototypePhase", "Foundation free play")
local initialized: { [Player]: boolean } = {}
local function onPlayerAdded(player: Player)
    if initialized[player] then
        return
    end
    initialized[player] = true
    TeamService.assign(player)
    task.spawn(CharacterService.spawn, player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    initialized[player] = nil
    CharacterService.remove(player)
end)
for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end
print("[Foundation] Ready. Start Server & Clients with 2 players.")
