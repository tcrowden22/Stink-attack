--!strict
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local Models = require(script.Parent.CharacterModels)
local Appearance = {}
local LEG_NAMES = {"LegL1","LegL2","LegL3","LegR1","LegR2","LegR3"}

local function imported(name: string, required: {string}): Model?
    local library=ServerStorage:FindFirstChild("CharacterAssets")
    local source=if library then library:FindFirstChild(name,true) else nil
    if not source or not source:IsA("Model") then return nil end
    local model=Instance.new("Model")
    for _,partName in required do
        local p=source:FindFirstChild(partName,true)
        if not p or not p:IsA("BasePart") then model:Destroy(); return nil end
        local copy=p:Clone()
        for _,child in copy:GetChildren() do
            if not (child:IsA("SurfaceAppearance") or child:IsA("DataModelMesh") or child:IsA("Decal")) then
                child:Destroy()
            else
                for _,nested in child:GetDescendants() do nested:Destroy() end
            end
        end
        if copy.Name=="VacuumGlow" then copy.Material=Enum.Material.Neon end
        copy.Parent=model
    end
    return model
end

local function fit(model: Model, limit: Vector3)
    local bounds,size=model:GetBoundingBox()
    model:PivotTo(bounds:Inverse()*model:GetPivot())
    model:ScaleTo(model:GetScale()*math.min(limit.X/math.max(size.X,.01),limit.Y/math.max(size.Y,.01),limit.Z/math.max(size.Z,.01)))
end

local function weld(p: BasePart, target: BasePart, team: string)
    p.Anchored=false; p.Massless=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.CollisionGroup=team
    local joint=Instance.new("WeldConstraint")
    joint.Part0=target; joint.Part1=p; joint.Parent=p
end

local function bugJoints(model: Model, root: BasePart)
    local legs: {[string]: {BasePart}} = {}
    for _,name in LEG_NAMES do legs[name]={} end
    for _,p in model:GetDescendants() do
        if p:IsA("BasePart") then
            local name=p:GetAttribute("BugLeg") or p.Name
            if typeof(name)=="string" and legs[name] then
                table.insert(legs[name],p)
            else weld(p,root,"StinkBugs") end
        end
    end
    local bounds,size=model:GetBoundingBox()
    for index,name in LEG_NAMES do
        local group=legs[name]
        local leg=group[1]
        if not leg then continue end
        local side=if index<=3 then -1 else 1
        local row=(index-1)%3+1
        local hinge=bounds*CFrame.new(side*size.X*.23,-size.Y*.13,(row-2)*size.Z*.21)
        leg.Anchored=false; leg.Massless=true; leg.CanCollide=false; leg.CanQuery=false; leg.CanTouch=false
        leg.CollisionGroup="StinkBugs"
        local motor=Instance.new("Motor6D")
        motor.Name=name
        motor.Part0=root; motor.Part1=leg
        motor.C0=root.CFrame:ToObjectSpace(hinge)
        motor.C1=leg.CFrame:ToObjectSpace(hinge)
        motor:SetAttribute("Side",side)
        motor:SetAttribute("Phase",if (row+(if side==1 then 1 else 0))%2==0 then 0 else math.pi)
        motor.Parent=leg
        CollectionService:AddTag(motor,"AnimatedBugLeg")
        for i=2,#group do weld(group[i],leg,"StinkBugs") end
    end
end

function Appearance.bug(): Model
    local required={"BugBody"}
    for _,name in LEG_NAMES do table.insert(required,name) end
    local model=imported("StinkBugV2",required)
    if model then model:SetAttribute("ArtSource","Blender V2"); return model end
    model=Models.bug(); model:SetAttribute("ArtSource","Native V2")
    return model
end

function Appearance.vacuum(): Model
    local model=imported("VacuumV2",{"VacuumBody","VacuumGlow"})
    if model then
        fit(model,Vector3.new(1.8,2.7,2))
        local bounds,size=model:GetBoundingBox()
        local plate=Models.part(model,"CleanTeamBadge",Vector3.new(size.X*.35,size.Y*.19,.025),
            bounds*CFrame.new(0,-size.Y*.1,-size.Z*.14),Color3.fromRGB(28,36,50))
        Models.label(plate,"CLEAN\nTEAM",Color3.new(1,1,1))
    else
        model=Models.vacuum()
    end
    model.Name="Vacuum"
    return model
end

function Appearance.apply(character: Model, team: string, humanoid: Humanoid)
    local root=character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then return end
    if team=="StinkBugs" then
        local model=Appearance.bug(); model.Name="StinkBugVisual"
        fit(model,Vector3.new(2.65,1.75,2.65))
        local bounds,size=model:GetBoundingBox()
        local bottom=-(humanoid.HipHeight+root.Size.Y/2)+.08
        -- Studio imports this FBX facing +Z; the humanoid walks toward -Z.
        -- Rotate the complete imported costume before constructing its joints,
        -- so the body, hip frames and working leg animation turn together.
        local facing=if model:GetAttribute("ArtSource")=="Blender V2" then CFrame.Angles(0,math.pi,0) else CFrame.identity
        local target=root.CFrame*CFrame.new(0,bottom+size.Y/2,0)*facing
        model:PivotTo(target*bounds:Inverse()*model:GetPivot())
        for _,p in character:GetDescendants() do
            if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency=1 end
        end
        bugJoints(model,root)
        model.Parent=character
        character:SetAttribute("Appearance",model:GetAttribute("ArtSource").." animated brown bug")
    else
        local hand=character:FindFirstChild("RightHand")
        if hand and hand:IsA("BasePart") then
            local model=Appearance.vacuum()
            fit(model,Vector3.new(1.75,2.65,1.8))
            local bounds=model:GetBoundingBox()
            -- Handle near hand; keep the nozzle below and forward.
            model:PivotTo(hand.CFrame*CFrame.new(0,-.55,-.45)*bounds:Inverse()*model:GetPivot())
            for _,p in model:GetDescendants() do if p:IsA("BasePart") then weld(p,hand,team) end end
            model.Parent=character
        end
        local head=character:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            local cap=Instance.new("Model"); cap.Name="CleanTeamCap"
            local crown=Models.part(cap,"Cap",Vector3.new(1.08,.38,1.05),head.CFrame*CFrame.new(0,.55,0),Color3.fromRGB(27,52,71))
            local brim=Models.part(cap,"Brim",Vector3.new(1.2,.09,.55),head.CFrame*CFrame.new(0,.4,-.6),Color3.fromRGB(27,52,71))
            weld(crown,head,team); weld(brim,head,team)
            for _,side in {-1,1} do
                local hair=Models.part(cap,"BrownHair",Vector3.new(.16,.42,.6),head.CFrame*CFrame.new(side*.51,.12,.13),Color3.fromRGB(91,45,24))
                weld(hair,head,team)
            end
            cap.Parent=character
        end
        character:SetAttribute("Appearance","Human with blue Clean Team vacuum")
    end
end
return Appearance
