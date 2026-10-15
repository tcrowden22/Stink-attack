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
    -- Spread simultaneous arrivals across a pad; floor surface is y = 0.
    return marker.CFrame + Vector3.new((math.abs(userId) % 3 - 1) * 3, 4, 0)
end

return MapService
