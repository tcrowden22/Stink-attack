--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Models=require(script.Parent.CharacterModels)
local Appearance=require(script.Parent.CharacterAppearance)
local Details={}
local function anchor(model: Model)
    for _,p in model:GetDescendants() do
        if p:IsA("BasePart") then p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false end
    end
end
local function place(model: Model, position: Vector3, height: number, rotation: number)
    local cf,size=model:GetBoundingBox()
    model:PivotTo(cf:Inverse()*model:GetPivot())
    model:ScaleTo(height/size.Y)
    cf,size=model:GetBoundingBox()
    model:PivotTo(CFrame.new(position+Vector3.new(0,size.Y/2,0))*CFrame.Angles(0,rotation,0)*cf:Inverse()*model:GetPivot())
    anchor(model)
end
local function sign(parent: Model, name: string, text: string, pos: Vector3, color: Color3, facing: number)
    local frame=Models.part(parent,name,Vector3.new(7,8,.4),CFrame.new(pos)*CFrame.Angles(0,facing,0),color)
    Models.label(frame,text,Color3.fromRGB(49,41,29))
end
local function plant(parent: Model, pos: Vector3)
    local pot=Models.part(parent,"TerracottaPot",Vector3.new(2.2,2.4,2.2),CFrame.new(pos+Vector3.new(0,1.2,0)),Color3.fromRGB(160,84,49),true)
    for i=1,8 do
        local angle=i*math.pi/4
        local endPoint=pos+Vector3.new(math.cos(angle)*2.1,3.3+(i%3)*.6,math.sin(angle)*2.1)
        Models.rod(parent,"Stem",pos+Vector3.new(0,1.6,0),endPoint,.09,Color3.fromRGB(53,91,38))
        Models.part(parent,"Leaf",Vector3.new(.7,.16,2.3),CFrame.new(endPoint)*CFrame.Angles(.4,angle,0),Color3.fromRGB(76+i*4,118+i*3,43),true)
    end
    pot.Material=Enum.Material.SmoothPlastic
end
local function crownedBug(): Model
    local bug=Models.bug()
    Models.part(bug,"CrownBand",Vector3.new(.7,.14,.6),CFrame.new(0,1.35,0),Color3.fromRGB(255,190,30))
    for _,x in {-.28,0,.28} do
        Models.part(bug,"CrownPoint",Vector3.new(.14,.36,.15),CFrame.new(x,1.56,-.2),Color3.fromRGB(255,190,30))
    end
    return bug
end
function Details.apply()
    local house=workspace:FindFirstChild("House")
    if not house then return end
    local old=house:FindFirstChild("ReferenceDetails")
    if old then old:Destroy() end
    local model=Instance.new("Model"); model.Name="ReferenceDetails"
    sign(model,"EveryHouse","EVERY\nHOUSE\nHAS A\nSIDE.",Vector3.new(8,12,-37),Color3.fromRGB(239,227,202),math.pi)
    sign(model,"CleanerHouse","A CLEANER\nHOUSE\nSTARTS\nHERE!  :)",Vector3.new(24,12,-37),Color3.fromRGB(224,216,192),math.pi)
    sign(model,"Checklist","[x] CLEANER\n[x] BRIGHTER\n[x] HAPPIER",Vector3.new(-22,13,37),Color3.fromRGB(242,230,207),0)
    sign(model,"SmallBugs","SMALL\nBUGS\nBIG\nCHAOS! :)",Vector3.new(39,13,28),Color3.fromRGB(250,220,86),0)
    plant(model,Vector3.new(-44,0,29))
    plant(model,Vector3.new(44,0,-32))
    local king=crownedBug(); king.Name="CrownedShelfBug"
    place(king,Vector3.new(43,16.9,20),2.5,math.pi/2); king.Parent=model
    local robot=Models.vacuum(); robot.Name="VacuumMascot"
    -- Display arms evoke the poster's oversized cleaner while humans remain playable.
    for _,side in {-1,1} do
        Models.rod(robot,"RobotArm",Vector3.new(side*.5,1.3,0),Vector3.new(side*.95,.85,-.1),.36,Color3.fromRGB(178,191,210))
        Models.part(robot,"RobotGlove",Vector3.new(.4,.45,.4),CFrame.new(side*.95,.75,-.1),Color3.fromRGB(30,39,58))
    end
    place(robot,Vector3.new(18,0,-28),7,math.pi); robot.Parent=model
    local purple=Models.vacuum(); purple.Name="PurpleCleanerDisplay"
    for _,p in purple:GetDescendants() do
        if p:IsA("BasePart") and (p.Name=="Canister" or p.Name=="EyeGlow" or p.Name=="NozzleGlow") then p.Color=Color3.fromRGB(171,65,245) end
    end
    place(purple,Vector3.new(43,11.5,20),3,math.pi/2); purple.Parent=model
    anchor(model); model.Parent=house
    -- Replicated showroom for the opening screen; no uploaded poster required.
    local previous=ReplicatedStorage:FindFirstChild("ReferencePreview")
    if previous then previous:Destroy() end
    local preview=Instance.new("Model"); preview.Name="ReferencePreview"
    local bug=Appearance.bug(); place(bug,Vector3.new(-2.2,0,0),2.4,0); bug.Parent=preview
    local vacuum=Models.vacuum(); place(vacuum,Vector3.new(2,0,0),3.8,0); vacuum.Parent=preview
    local floor=Models.part(preview,"WoodFloor",Vector3.new(18,.15,13),CFrame.new(0,-.1,0),Color3.fromRGB(151,103,58))
    floor.Material=Enum.Material.WoodPlanks
    plant(preview,Vector3.new(-5,0,2))
    anchor(preview); preview.Parent=ReplicatedStorage
end
return Details
