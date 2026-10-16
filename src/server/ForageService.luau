--!strict
local Players=game:GetService("Players")
local Rules=require(game:GetService("ReplicatedStorage").Shared.SoloRules)
local Refuge=require(script.Parent.RefugeService)
local Flight=require(script.Parent.FlightService)
local Forage={}
local states: {[Player]: {carried: number,banked: number,last: number,connection: RBXScriptConnection?}}={}
local positions={
    Vector3.new(-10,1,15),Vector3.new(25,1,5),Vector3.new(65,1,-5),Vector3.new(103,1,26),
    Vector3.new(-8,1,55),Vector3.new(29,1,78),Vector3.new(81,1,65),Vector3.new(104,1,95),
    Vector3.new(49,25,0),Vector3.new(65,25,80),Vector3.new(34,49,50),Vector3.new(90,49,45),
}
function Forage.bugRoot(player: Player): BasePart?
    if player.Parent~=Players or not player.Team or player.Team.Name~="StinkBugs" then return nil end
    local c=player.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    local r=c and c:FindFirstChild("HumanoidRootPart")
    if not h or h.Health<=0 or not r or not r:IsA("BasePart") then return nil end
    return r
end
local function sync(p: Player)
    local s=states[p]
    if not s then return end
    p:SetAttribute("CarriedSnacks",s.carried); p:SetAttribute("BankedSnacks",s.banked)
end
function Forage.capture(p: Player)
    local s=states[p]; local root=Forage.bugRoot(p)
    if not s or not root or Refuge.isProtected(p) then return end
    s.carried=0; sync(p)
    p:SetAttribute("ForageMessage","Vacuumed up! Returning home...")
    p:SetAttribute("CleanerThreat","")
    local h=root.Parent:FindFirstChildOfClass("Humanoid")
    if h then
        for _,p in root.Parent:GetDescendants() do
            if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency=1 end
        end
        h.Health=0
    end
end
local function join(p: Player)
    if states[p] then return end
    states[p]={carried=0,banked=0,last=0,connection=nil}
    sync(p)
    local function character(c: Model)
        local s=states[p]; if not s then return end
        s.carried=0; sync(p)
        p:SetAttribute("ForageMessage","Collect snacks and bring them home.")
        p:SetAttribute("CleanerThreat","")
        local h=c:FindFirstChildOfClass("Humanoid")
        if h then h.Died:Once(function()
            if p.Character==c and states[p] then states[p].carried=0; sync(p) end
        end) end
    end
    states[p].connection=p.CharacterAdded:Connect(character)
    if p.Character then character(p.Character) end
end
function Forage.start()
    local folder=Instance.new("Folder"); folder.Name="ForageSnacks"; folder.Parent=workspace
    Players.PlayerAdded:Connect(join)
    Players.PlayerRemoving:Connect(function(p)
        local s=states[p]; if s and s.connection then s.connection:Disconnect() end
        states[p]=nil
    end)
    for _,p in Players:GetPlayers() do join(p) end
    for i,position in positions do
        local snack=Instance.new("Part")
        snack.Name="Snack"..i; snack.Shape=Enum.PartType.Ball; snack.Size=Vector3.new(1.2,.6,1.2)
        snack.Color=Color3.fromRGB(245,186,67); snack.Material=Enum.Material.Neon
        snack.Anchored=true; snack.CanCollide=false; snack.CanTouch=false; snack.CanQuery=false
        snack.Position=position; snack.Parent=folder
        local prompt=Instance.new("ProximityPrompt")
        prompt.ActionText="Collect"; prompt.ObjectText="Snack"; prompt.MaxActivationDistance=Rules.PickupRange
        prompt.HoldDuration=.15; prompt.RequiresLineOfSight=true; prompt.Parent=snack
        local ready=true
        prompt.Triggered:Connect(function(p)
            local s=states[p]; local root=Forage.bugRoot(p)
            if not s or not root or os.clock()-s.last<.2 then return end
            s.last=os.clock()
            local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances={root.Parent,folder}
            local clear=workspace:Raycast(root.Position,snack.Position-root.Position,params)==nil
            if not Rules.canCollect(s.carried,(root.Position-snack.Position).Magnitude,clear,ready) then
                if s.carried>=Rules.Capacity then p:SetAttribute("ForageMessage","Bag full! Take your snacks home.") end
                return
            end
            -- No yield between claiming the shared item and updating server inventory.
            ready=false; prompt.Enabled=false; snack.Transparency=1
            s.carried+=1; sync(p)
            Flight.award(p)
            p:SetAttribute("ForageMessage","Snack collected! Flight charged. Bring snacks home.")
            task.delay(Rules.ItemRespawn,function()
                if snack.Parent then ready=true; snack.Transparency=0; prompt.Enabled=true end
            end)
        end)
    end
    task.spawn(function()
        while folder.Parent do
            for p,s in states do
                if s.carried>0 and Refuge.isProtected(p) then
                    local amount=s.carried; s.banked+=amount; s.carried=0; sync(p)
                    p:SetAttribute("ForageMessage","Delivered "..amount.." snacks! Go find more.")
                end
            end
            task.wait(.2)
        end
    end)
end
return Forage
