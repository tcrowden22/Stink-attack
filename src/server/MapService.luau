--!strict
local PhysicsService = game:GetService("PhysicsService")
local MapService = {}

function MapService.init()
    for _, name in { "StinkBugs", "Vacuums", "EscapeGate" } do
        if not PhysicsService:IsCollisionGroupRegistered(name) then
            PhysicsService:RegisterCollisionGroup(name)
        end
    end
    PhysicsService:CollisionGroupSetCollidable("StinkBugs", "EscapeGate", false)
    PhysicsService:CollisionGroupSetCollidable("Vacuums", "EscapeGate", true)
    PhysicsService:CollisionGroupSetCollidable("StinkBugs", "StinkBugs", false)
    PhysicsService:CollisionGroupSetCollidable("Vacuums", "Vacuums", false)
    PhysicsService:CollisionGroupSetCollidable("StinkBugs", "Vacuums", false)

    local room = workspace:WaitForChild("House")
    -- Old prototype template found in the saved place: all its furniture is stacked at origin.
    -- Quarantine only this exact obsolete signature during play; keep it recoverable.
    local legacy=workspace:FindFirstChild("LivingRoom")
    if legacy and legacy:IsA("Model") and legacy~=room then
        local seat=legacy:FindFirstChild("SofaSeat")
        local back=legacy:FindFirstChild("SofaBack")
        if seat and seat:IsA("BasePart") and back and back:IsA("BasePart")
            and seat.Position.Magnitude<.1 and back.Position.Magnitude<.1 then
            local archive=Instance.new("Folder")
            archive.Name="LegacyMapArchive"; archive.Parent=game:GetService("ServerStorage")
            legacy.Parent=archive
        end
    end
    for _, item in room:GetDescendants() do
        if item:IsA("BasePart") and string.sub(item.Name, 1, 10) == "EscapeGate" then
            item.CollisionGroup = "EscapeGate"
        end
    end
    for _, name in { "StinkBugsSpawn", "VacuumsSpawn" } do
        local marker = room:FindFirstChild(name, true)
        assert(marker and marker:IsA("BasePart"), "Missing spawn marker: " .. name)
    end
end

function MapService.spawnCFrame(teamName: string, userId: number): CFrame
    local marker = workspace.House:FindFirstChild(teamName .. "Spawn", true) :: BasePart
    -- A 6-by-4 grid spreads larger bug teams across their clear clubhouse pad.
    if teamName == "StinkBugs" then
        local slot = math.abs(userId) % 24
        return marker.CFrame + Vector3.new((slot % 6 - 2.5) * 3.5, 4, (math.floor(slot / 6) - 1.5) * 3.5)
    end
    return marker.CFrame + Vector3.new((math.abs(userId) % 3 - 1) * 3, 4, 0)
end

return MapService
