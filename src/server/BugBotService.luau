--!strict
local Players=game:GetService("Players")
local Pathfinding=game:GetService("PathfindingService")
local Shared=game:GetService("ReplicatedStorage").Shared
local Rules=require(Shared.HuntRules)
local Appearance=require(script.Parent.CharacterAppearance)
local Bots={}
local active: {[Model]: boolean}={}
local slots: {{model: Model?, ready: number}}={}
local folder: Folder?=nil
local points={Vector3.new(-10,0,15),Vector3.new(25,0,5),Vector3.new(65,0,-5),Vector3.new(103,0,26),
    Vector3.new(-8,0,55),Vector3.new(29,0,78),Vector3.new(81,0,65),Vector3.new(104,0,95)}
local function needed(): boolean
    local bugs,vacuums=0,0
    for _,p in Players:GetPlayers() do
        if p.Team and p.Team.Name=="StinkBugs" then bugs+=1
        elseif p.Team and p.Team.Name=="Vacuums" then vacuums+=1 end
    end
    return Rules.aiNeeded(bugs,vacuums)
end
local function count()
    local total=0
    for _ in active do total+=1 end
    workspace:SetAttribute("AIBugsRemaining",total)
end
function Bots.list(): {Model}
    local result={}
    for model in active do table.insert(result,model) end
    return result
end
function Bots.capture(model: Model): boolean
    if not active[model] then return false end
    active[model]=nil
    for _,slot in slots do
        if slot.model==model then slot.model=nil; slot.ready=os.clock()+Rules.BotRespawn end
    end
    model:Destroy(); count()
    return true
end
local function wander(model: Model,index: number)
    task.spawn(function()
        local root=model:FindFirstChild("HumanoidRootPart") :: BasePart
        local h=model:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local route=index; local nextPath=0; local computing=false
        local steps: {PathWaypoint}={}; local stepIndex=2; local ticket=0
        while active[model] and model.Parent do
            task.wait(.2)
            if not active[model] or not model.Parent then break end
            if h.Health<=0 or root.Position.Y < -20 then Bots.capture(model); break end
            if model:GetAttribute("VacuumHeld") then
                h.WalkSpeed=0; h:MoveTo(root.Position)
                steps={}; ticket+=1; computing=false; nextPath=0
                continue
            end
            h.WalkSpeed=9
            local threat: Vector3?=nil; local nearest=35
            for _,p in Players:GetPlayers() do
                local c=p.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
                local human=c and c:FindFirstChildOfClass("Humanoid")
                if p.Team and p.Team.Name=="Vacuums" and r and r:IsA("BasePart") and human and human.Health>0 then
                    local d=(r.Position-root.Position).Magnitude
                    if d<nearest then nearest=d; threat=r.Position end
                end
            end
            local now=os.clock()
            if now>=nextPath and not computing then
                route=route%#points+1
                if threat then
                    local best=-math.huge
                    for i,point in points do
                        -- Favor escaping the hunter without always traversing the whole house.
                        local score=(point-threat).Magnitude-(point-root.Position).Magnitude*.35
                        if score>best then best=score; route=i end
                    end
                end
                computing=true; nextPath=now+2; ticket+=1
                local mine=ticket; local goal=points[route]
                task.spawn(function()
                    local path=Pathfinding:CreatePath({AgentRadius=1,AgentHeight=2,AgentCanJump=true,WaypointSpacing=3})
                    local ok=pcall(function() path:ComputeAsync(root.Position,goal) end)
                    if not active[model] or not model.Parent or mine~=ticket then path:Destroy(); return end
                    computing=false
                    steps=if ok and path.Status==Enum.PathStatus.Success then path:GetWaypoints() else {}
                    stepIndex=2; path:Destroy()
                end)
            end
            local step=steps[stepIndex]
            if step and (root.Position-step.Position).Magnitude<2 then stepIndex+=1; step=steps[stepIndex] end
            if step then
                if step.Action==Enum.PathWaypointAction.Jump then h.Jump=true end
                h:MoveTo(step.Position)
            else h:MoveTo(root.Position) end
        end
    end)
end
local function create(index: number): Model?
    local description=Instance.new("HumanoidDescription")
    local ok,result=pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15) end)
    description:Destroy()
    if not ok then warn("[Bug hunt] AI avatar unavailable; retrying"); return nil end
    local model=result :: Model
    if not needed() then model:Destroy(); return nil end
    local h=model:FindFirstChildOfClass("Humanoid")
    local root=model:FindFirstChild("HumanoidRootPart")
    if not h or not root or not root:IsA("BasePart") then model:Destroy(); return nil end
    model.Name="AIStinkBug"..index; model:ScaleTo(.35)
    h.WalkSpeed=9; h.UseJumpPower=false; h.JumpHeight=2; h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    for _,part in model:GetDescendants() do if part:IsA("BasePart") then part.CollisionGroup="StinkBugs" end end
    Appearance.apply(model,"StinkBugs",h)
    model:PivotTo(CFrame.new(points[((index-1)*3)%#points+1]+Vector3.new(0,3,0)))
    model.Parent=folder; root:SetNetworkOwner(nil)
    active[model]=true; count(); wander(model,index)
    return model
end
function Bots.start()
    folder=Instance.new("Folder"); folder.Name="AIStinkBugs"; folder.Parent=workspace
    for _=1,Rules.BotCount do table.insert(slots,{model=nil,ready=0}) end
    count()
    task.spawn(function()
        while folder and folder.Parent do
            task.wait(.5)
            if not needed() then
                for _,slot in slots do
                    if slot.model then active[slot.model]=nil; slot.model:Destroy(); slot.model=nil end
                    slot.ready=0
                end
                count(); continue
            end
            for i,slot in slots do
                if not slot.model and os.clock()>=slot.ready then
                    slot.ready=os.clock()+5
                    slot.model=create(i)
                end
            end
        end
    end)
end
return Bots
