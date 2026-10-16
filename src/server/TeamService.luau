--!strict
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local TeamPolicy = require(Shared.TeamPolicy)
local TeamService = {}
local HuntRules=require(Shared.HuntRules)
local chosen: {[Player]: boolean}={}

function TeamService.init()
    Players.PlayerRemoving:Connect(function(player) chosen[player]=nil end)
    for name, color in { StinkBugs = "Lime green", Vacuums = "Bright orange" } do
        local team = Instance.new("Team")
        team.Name = name
        team.TeamColor = BrickColor.new(color)
        team.AutoAssignable = false
        team.Parent = Teams
    end
end

function TeamService.assign(player: Player)
    local bugs, vacuums = 0, 0
    for _, other in Players:GetPlayers() do
        if other ~= player and other.Team then
            if other.Team.Name == "StinkBugs" then
                bugs += 1
            elseif other.Team.Name == "Vacuums" then
                vacuums += 1
            end
        end
    end
    local name = TeamPolicy.nextTeam(bugs, vacuums, Config.VacuumFraction)
    player.Team = Teams:FindFirstChild(name) :: Team
    player.Neutral = false
end

function TeamService.choose(player: Player,name: any): boolean
    if player.Parent~=Players or not HuntRules.canChoose(name,chosen[player]==true) then return false end
    local team=Teams:FindFirstChild(name)
    if not team or not team:IsA("Team") then return false end
    chosen[player]=true
    player.Team=team; player.Neutral=false
    player:SetAttribute("TeamChosen",true)
    return true
end
return TeamService
