--!strict
local Players = game:GetService("Players")
Players.CharacterAutoLoads = false

local MapService = require(script.Parent.MapService)
local TeamService = require(script.Parent.TeamService)
local CharacterService = require(script.Parent.CharacterService)
MapService.init()
require(script.Parent.ArtDetailService).apply()
require(script.Parent.ReferenceDetails).apply()
TeamService.init()
require(script.Parent.RefugeService).start()
require(script.Parent.FlightService).start()
require(script.Parent.ClimbService).start()
require(script.Parent.ForageService).start()
require(script.Parent.CleanerBotService).start()
require(script.Parent.BugBotService).start()
require(script.Parent.PlayerVacuumService).start()
workspace:SetAttribute("PrototypePhase", "Choose a side")
local initialized: { [Player]: boolean } = {}
local function onPlayerAdded(player: Player)
    if initialized[player] then
        return
    end
    initialized[player] = true
    player.Team=nil; player.Neutral=true
    player:SetAttribute("TeamChosen",false)
    player:SetAttribute("SpawnStatus","Choose your team")
    player:SetAttribute("BugsCaught",0)
end
local choice=Instance.new("RemoteEvent")
choice.Name="ChooseTeam"; choice.Parent=game:GetService("ReplicatedStorage")
choice.OnServerEvent:Connect(function(player,name)
    if initialized[player] and TeamService.choose(player,name) then
        task.spawn(CharacterService.spawn,player)
    end
end)
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    initialized[player] = nil
    CharacterService.remove(player)
end)
for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end
print("[Team choice] Ready: Stink Bug escape or Vacuum bug hunt.")

require(script.Parent.StinkService).start()
require(script.Parent.SpiderService).start()

require(script.Parent.BirdService).start()
