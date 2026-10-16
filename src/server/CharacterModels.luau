--!strict
-- Original native geometry keeps the reference look playable before mesh import.
local Models = {}
local brown = Color3.fromRGB(133, 77, 34)
local amber = Color3.fromRGB(199, 139, 62)
local dark = Color3.fromRGB(39, 31, 28)
local blue = Color3.fromRGB(24, 69, 190)
local cyan = Color3.fromRGB(45, 224, 255)
local silver = Color3.fromRGB(178, 191, 210)

function Models.part(model: Model, name: string, size: Vector3, cf: CFrame, color: Color3, ball: boolean?): Part
    local p = Instance.new("Part")
    p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
    p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.Massless = true
    if ball then p.Shape = Enum.PartType.Ball end
    p.Parent = model
    return p
end

function Models.rod(model: Model, name: string, a: Vector3, b: Vector3, width: number, color: Color3): Part
    return Models.part(model, name, Vector3.new(width, width, (b-a).Magnitude), CFrame.lookAt((a+b)/2,b),color)
end

function Models.label(p: BasePart, text: string, color: Color3)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front; gui.CanvasSize = Vector2.new(500, 400)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1); label.BackgroundTransparency = 1
    label.Text = text; label.TextColor3 = color; label.TextScaled = true
    label.TextWrapped = true; label.Font = Enum.Font.GothamBold
    label.Parent = gui; gui.Parent = p
end

function Models.bug(): Model
    local model = Instance.new("Model")
    Models.part(model,"Body",Vector3.new(1.65,1.05,1.65),CFrame.new(0,.68,0),brown,true)
    for i=1,3 do
        Models.part(model,"Abdomen",Vector3.new(1.05+i*.16,.17,.22),CFrame.new(0,.17+i*.2,-.74),amber)
    end
    for _,side in {-1,1} do
        Models.part(model,"Armor",Vector3.new(.78,.25,1.5),CFrame.new(side*.4,1.1,0)*CFrame.Angles(0,0,side*-.13),brown)
        Models.part(model,"Eye",Vector3.new(.64,.67,.17),CFrame.new(side*.38,.88,-.89),Color3.fromRGB(255,245,221),true)
        Models.part(model,"Pupil",Vector3.new(.32,.43,.08),CFrame.new(side*.32,.93,-.99),dark,true)
        Models.part(model,"EyeShine",Vector3.new(.1,.12,.025),CFrame.new(side*.28,1.03,-1.04),Color3.new(1,1,1),true)
        Models.part(model,"Brow",Vector3.new(.75,.16,.2),CFrame.new(side*.36,1.18,-.94)*CFrame.Angles(0,0,side*.2),dark)
        Models.rod(model,"Antenna",Vector3.new(side*.48,1.19,-.25),Vector3.new(side*.61,1.78,-.43),.09,brown)
        Models.rod(model,"Antenna",Vector3.new(side*.61,1.78,-.43),Vector3.new(side*.87,1.94,-.57),.09,amber)
        for i,z in {-.52,0,.53} do
            local name = "Leg" .. (if side == -1 then "L" else "R") .. i
            local a=Vector3.new(side*.65,.68,z)
            local b=Vector3.new(side*1.04,.5,z-.08)
            local c=Vector3.new(side*1.22,.1,z-.3)
            for _,p in {
                Models.rod(model,name,a,b,.24,brown),
                Models.rod(model,name,b,c,.2,brown),
                Models.part(model,name,Vector3.new(.25,.15,.32),CFrame.new(c),brown),
            } do p:SetAttribute("BugLeg",name) end
        end
    end
    Models.rod(model,"Smirk",Vector3.new(-.22,.48,-.91),Vector3.new(.18,.44,-.93),.035,dark)
    Models.rod(model,"Smirk",Vector3.new(.18,.44,-.93),Vector3.new(.28,.52,-.92),.035,dark)
    model.WorldPivot = CFrame.identity
    return model
end

function Models.vacuum(): Model
    local model = Instance.new("Model")
    local body = Models.part(model,"Canister",Vector3.new(1.35,1.1,1.1),CFrame.new(0,1.28,0)*CFrame.Angles(0,0,math.pi/2),blue)
    body.Shape = Enum.PartType.Cylinder
    for _,y in {.64,1.54,1.94} do
        local band=Models.part(model,"SilverBand",Vector3.new(.11,1.16,1.16),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.pi/2),silver)
        band.Shape=Enum.PartType.Cylinder
    end
    Models.part(model,"Face",Vector3.new(.86,.32,.14),CFrame.new(0,1.72,-.53),dark)
    for _,side in {-1,1} do
        local eye=Models.part(model,"EyeGlow",Vector3.new(.27,.075,.035),CFrame.new(side*.22,1.73,-.61)*CFrame.Angles(0,0,side*.28),cyan)
        eye.Material=Enum.Material.Neon
    end
    local panel=Models.part(model,"CleanTeam",Vector3.new(.7,.59,.2),CFrame.new(0,1.08,-.53),Color3.fromRGB(29,37,53))
    Models.label(panel,"CLEAN\nTEAM",Color3.new(1,1,1))
    Models.rod(model,"Wand",Vector3.new(0,.7,-.3),Vector3.new(0,.2,-.8),.26,dark)
    Models.part(model,"FloorHead",Vector3.new(1.72,.29,.72),CFrame.new(0,.19,-.93),dark)
    local light=Models.part(model,"NozzleGlow",Vector3.new(1.48,.12,.045),CFrame.new(0,.2,-1.31),cyan)
    light.Material=Enum.Material.Neon
    for i=0,19 do
        local t=i/20*math.pi
        local t2=(i+1)/20*math.pi
        local a=Vector3.new(.55*(1-math.cos(t)),1.94+.75*math.sin(t)-.45*t/math.pi,.19)
        local b=Vector3.new(.55*(1-math.cos(t2)),1.94+.75*math.sin(t2)-.45*t2/math.pi,.19)
        Models.rod(model,"HoseRib",a,b,.29,if i%2==0 then dark else Color3.fromRGB(54,63,76))
    end
    model.WorldPivot=CFrame.identity
    return model
end
return Models
