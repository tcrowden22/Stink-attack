--!strict
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local TeamPolicy = require(Shared.TeamPolicy)
local TeamService = {}

function TeamService.init()
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

return TeamService
