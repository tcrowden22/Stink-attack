--!strict
-- Server-created cosmetics. The R15 rig remains responsible for movement/collision.
local ServerStorage = game:GetService("ServerStorage")
local CharacterAppearance = {}

local function part(model: Model, name: string, size: Vector3, cf: CFrame, color: Color3, ball: boolean?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if ball then p.Shape = Enum.PartType.Ball end
    p.Parent = model
    return p
end

local function rod(model: Model, name: string, a: Vector3, b: Vector3, width: number, color: Color3)
    return part(model, name, Vector3.new(width, width, (b - a).Magnitude),
        CFrame.lookAt((a + b) / 2, b), color, false)
end

local function fallbackBug(): Model
    local model = Instance.new("Model")
    local green = Color3.fromRGB(101, 143, 55)
    local light = Color3.fromRGB(175, 196, 99)
    local dark = Color3.fromRGB(44, 53, 33)
    part(model, "ShieldBody", Vector3.new(1.5, .65, 1.9), CFrame.new(0, .65, .1), green, true)
    part(model, "WingLeft", Vector3.new(.65, .25, 1.35), CFrame.new(-.32, .91, .25), light, true)
    part(model, "WingRight", Vector3.new(.65, .25, 1.35), CFrame.new(.32, .91, .25), light, true)
    part(model, "Head", Vector3.new(.8, .5, .65), CFrame.new(0, .65, -.9), green, true)
    for _, side in {-1, 1} do
        for index, z in {-.5, .1, .65} do
            local a = Vector3.new(side * .55, .6, z)
            local b = Vector3.new(side * .95, .36, z + .12)
            local c = Vector3.new(side * 1.15, .08, z + .32)
            rod(model, "LegUpper" .. side .. index, a, b, .09, dark)
            rod(model, "LegLower" .. side .. index, b, c, .07, dark)
        end
        part(model, "Eye", Vector3.new(.3, .32, .22), CFrame.new(side * .24, .76, -1.18), Color3.fromRGB(245, 238, 210), true)
        part(model, "Pupil", Vector3.new(.15, .19, .08), CFrame.new(side * .24, .76, -1.29), dark, true)
        rod(model, "Antenna", Vector3.new(side * .25, .87, -1), Vector3.new(side * .6, 1.3, -1.55), .045, dark)
        part(model, "AntennaTip", Vector3.new(.09, .09, .09), CFrame.new(side * .6, 1.3, -1.55), light, true)
    end
    return model
end

local function importedBug(): Model?
    local library = ServerStorage:FindFirstChild("CharacterAssets")
    local source = if library then library:FindFirstChild("StinkBug", true) else nil
    if not source or not (source:IsA("Model") or source:IsA("BasePart")) then return nil end
    -- Copy visual parts only. Never copy scripts, rigs, constraints or other behavior.
    local model = Instance.new("Model")
    local candidates: {Instance} = source:GetDescendants()
    table.insert(candidates, source)
    local count = 0
    for _, item in candidates do
        if item:IsA("BasePart") then
            local copy = item:Clone()
            for _, child in copy:GetChildren() do
                if not (child:IsA("SurfaceAppearance") or child:IsA("DataModelMesh") or child:IsA("Decal")) then
                    child:Destroy()
                else
                    for _, descendant in child:GetDescendants() do descendant:Destroy() end
                end
            end
            copy.Parent = model
            count += 1
        end
    end
    if count == 0 then model:Destroy(); return nil end
    return model
end

local function attach(model: Model, target: BasePart, team: string)
    for _, item in model:GetDescendants() do
        if item:IsA("BasePart") then
            item.Anchored = false
            item.Massless = true
            item.CanCollide = false
            item.CanTouch = false
            item.CanQuery = false
            item.CollisionGroup = team
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = target
            weld.Part1 = item
            weld.Parent = item
        end
    end
end

local function vacuum(hand: BasePart): Model
    local model = Instance.new("Model")
    model.Name = "Vacuum"
    local orange = Color3.fromRGB(233, 135, 49)
    local dark = Color3.fromRGB(38, 47, 57)
    local silver = Color3.fromRGB(159, 180, 185)
    part(model, "Grip", Vector3.new(.2, .65, .22), CFrame.new(), dark)
    part(model, "MotorHousing", Vector3.new(.65, .85, .65), CFrame.new(0, -.45, .2), orange, true)
    part(model, "DustCanister", Vector3.new(.5, .75, .5), CFrame.new(0, -.9, .2), silver, true)
    rod(model, "Wand", Vector3.new(0, -.9, 0), Vector3.new(0, -2.35, -.65), .13, silver)
    part(model, "FloorHead", Vector3.new(1.1, .24, .6), CFrame.new(0, -2.35, -.8), dark)
    part(model, "Intake", Vector3.new(.8, .1, .08), CFrame.new(0, -2.36, -1.11), orange)
    model.WorldPivot = CFrame.identity
    model:PivotTo(hand.CFrame)
    return model
end

function CharacterAppearance.apply(character: Model, team: string, humanoid: Humanoid)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then return end
    if team == "StinkBugs" then
        local model = importedBug()
        local appearance = if model then "Blender stink bug" else "Native stink bug"
        if not model then model = fallbackBug() end
        model.Name = "StinkBugVisual"
        -- Normalize arbitrary import size/pivot. Keep the complete costume inside
        -- a 2.8 x 1.5 x 2.8 envelope, below the 2.4-stud vent height.
        local bounds, size = model:GetBoundingBox()
        model:PivotTo(bounds:Inverse() * model:GetPivot())
        local factor = math.min(2.8 / math.max(size.X, .01), 1.5 / math.max(size.Y, .01), 2.8 / math.max(size.Z, .01))
        model:ScaleTo(factor)
        bounds, size = model:GetBoundingBox()
        local bottom = -(humanoid.HipHeight + root.Size.Y / 2) + .06
        local target = root.CFrame * CFrame.new(0, bottom + size.Y / 2, 0)
        model:PivotTo(target * bounds:Inverse() * model:GetPivot())
        for _, item in character:GetDescendants() do
            if item:IsA("BasePart") or item:IsA("Decal") then item.Transparency = 1 end
        end
        attach(model, root, team)
        model.Parent = character
        character:SetAttribute("Appearance", appearance)
    else
        local hand = character:FindFirstChild("RightHand")
        if hand and hand:IsA("BasePart") then
            local model = vacuum(hand)
            attach(model, hand, team)
            model.Parent = character
        end
        character:SetAttribute("Appearance", "Human with vacuum")
    end
end

return CharacterAppearance
