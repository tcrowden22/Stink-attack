--!strict
local Players = game:GetService("Players")
local MapService = require(script.Parent.MapService)
local RefugeService = {}
local bounds: BasePart? = nil

local function contains(position: Vector3): boolean
    local zone = bounds
    if not zone then return false end
    local point = zone.CFrame:PointToObjectSpace(position)
    local half = zone.Size / 2
    return math.abs(point.X) <= half.X
        and math.abs(point.Y) <= half.Y
        and math.abs(point.Z) <= half.Z
end

-- Future capture code must call this at the moment of capture, not trust a HUD attribute.
function RefugeService.isProtected(player: Player): boolean
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return player.Parent == Players and player.Team ~= nil
        and player.Team.Name == "StinkBugs"
        and humanoid ~= nil and humanoid.Health > 0
        and root ~= nil and root:IsA("BasePart") and contains(root.Position)
end

function RefugeService.start()
    local clubhouse = workspace.House:WaitForChild("BugClubhouse")
    local zone = clubhouse:WaitForChild("RefugeBounds")
    assert(zone:IsA("BasePart"), "Missing clubhouse bounds")
    bounds = zone
    for _, item in clubhouse:GetChildren() do
        if item:IsA("BasePart") and string.sub(item.Name, 1, 13) == "ClubhouseSign" then
            local surface = Instance.new("SurfaceGui")
            surface.Face = if item.Name == "ClubhouseSignInside" then Enum.NormalId.Front else Enum.NormalId.Right
            surface.CanvasSize = Vector2.new(700, 180)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(237, 255, 196)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Text = "BUG CLUBHOUSE\nSTINK BUGS ONLY"
            label.Parent = surface
            surface.Parent = item
        end
    end
    task.spawn(function()
        while true do
            for _, player in Players:GetPlayers() do
                local protected = RefugeService.isProtected(player)
                if player:GetAttribute("InBugRefuge") ~= protected then
                    player:SetAttribute("InBugRefuge", protected)
                end
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                -- Collision gates handle ordinary entry; this also removes vacuums
                -- that reach the enclosed refuge through unexpected movement.
                if player.Team and player.Team.Name == "Vacuums"
                    and character and root and root:IsA("BasePart") and contains(root.Position) then
                    character:PivotTo(MapService.spawnCFrame("Vacuums", player.UserId))
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
            task.wait(0.2)
        end
    end)
end

return RefugeService
