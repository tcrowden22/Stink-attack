--!strict
-- Import the authored kit into ServerStorage.DetailAssets, then run apply in edit mode
-- or start Play. Missing imports deliberately leave native props visible.
local ServerStorage = game:GetService("ServerStorage")
local Placements = require(script.Parent.ArtPlacements)
local ArtDetailService = {}
local ATTRIBUTE = "DetailOriginalTransparency"

local function folderAt(root: Instance, path: string): Instance?
    local cursor: Instance? = root
    for segment in string.gmatch(path, "[^/]+") do
        cursor = if cursor then cursor:FindFirstChild(segment) else nil
    end
    return cursor
end

function ArtDetailService.apply()
    local house = workspace:FindFirstChild("House")
    if not house then return end
    -- Reapply safely after a reimport; restore native props before replacement.
    for _, item in house:GetDescendants() do
        if item:IsA("BasePart") then
            local original = item:GetAttribute(ATTRIBUTE)
            if typeof(original) == "number" then
                item.Transparency = original
                item:SetAttribute(ATTRIBUTE, nil)
            end
        end
    end
    local previous = house:FindFirstChild("MeshDetails")
    if previous then previous:Destroy() end
    local output = Instance.new("Folder")
    output.Name = "MeshDetails"
    output.Parent = house
    local library = ServerStorage:FindFirstChild("DetailAssets")
    local installed = 0
    for _, placement in Placements do
        local source = if library then library:FindFirstChild(placement.Asset, true) else nil
        if not source or not (source:IsA("Model") or source:IsA("BasePart")) then
            continue
        end
        local model = Instance.new("Model")
        model.Name = placement.Name
        local copy = source:Clone()
        copy.Parent = model
        local count = 0
        for _, item in model:GetDescendants() do
            if item:IsA("LuaSourceContainer") then
                item:Destroy()
            elseif item:IsA("BasePart") then
                item.Anchored = true
                item.CanCollide = false
                item.CanTouch = false
                item.CanQuery = false
                count += 1
            end
        end
        if count == 0 then
            model:Destroy()
            continue
        end
        local bounds, size = model:GetBoundingBox()
        if size.X <= 0 then
            model:Destroy()
            continue
        end
        -- Normalize imported grid placement before scaling and positioning.
        model:PivotTo(bounds:Inverse() * model:GetPivot())
        model:ScaleTo(placement.Width / size.X)
        bounds, size = model:GetBoundingBox()
        local target = CFrame.new(placement.Position + Vector3.new(0, size.Y / 2, 0))
            * CFrame.Angles(0, math.rad(placement.Yaw), 0)
        model:PivotTo(target * bounds:Inverse() * model:GetPivot())
        model.Parent = output
        for _, selector in placement.Hide do
            local parent = folderAt(house, selector[1])
            if parent then
                for _, item in parent:GetDescendants() do
                    if item:IsA("BasePart")
                        and string.sub(item.Name, 1, #selector[2]) == selector[2] then
                        item:SetAttribute(ATTRIBUTE, item.Transparency)
                        item.Transparency = 1
                    end
                end
            end
        end
        installed += 1
    end
    house:SetAttribute("InstalledDetailInstances", installed)
    house:SetAttribute("ExpectedDetailInstances", #Placements)
    print(string.format("[Art] Placed %d/%d mesh details; missing imports retain native props.", installed, #Placements))
end

return ArtDetailService
