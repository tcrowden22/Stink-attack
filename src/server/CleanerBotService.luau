--!strict
local Players=game:GetService("Players")
local PathfindingService=game:GetService("PathfindingService")
local Rules=require(game:GetService("ReplicatedStorage").Shared.SoloRules)
local Forage=require(script.Parent.ForageService)
local Refuge=require(script.Parent.RefugeService)
local Models=require(script.Parent.CharacterModels)
local Map=require(script.Parent.MapService)
local Flight=require(script.Parent.FlightService)
local Climb=require(script.Parent.ClimbService)
local Cleaner={}
local patrol={Vector3.new(24,0,8),Vector3.new(69,0,0),Vector3.new(103,0,25),Vector3.new(80,0,80),Vector3.new(27,0,55),Vector3.new(-12,0,15)}
local function solo(): Player?
    local list=Players:GetPlayers()
    if #list==1 and list[1].Team and list[1].Team.Name=="StinkBugs" then return list[1] end
    return nil
end
local function create(player: Player): Model?
    local description=Instance.new("HumanoidDescription")
    local ok,result=pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15) end)
    description:Destroy()
    if not ok then warn("[Cleaner] Robot avatar unavailable; retrying"); return nil end
    local model=result :: Model
    if solo()~=player then model:Destroy(); return nil end
    model.Name="CleanTeamRobot"
    local humanoid=model:FindFirstChildOfClass("Humanoid")
    local root=model:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or not root:IsA("BasePart") then model:Destroy(); return nil end
    humanoid.WalkSpeed=9; humanoid.UseJumpPower=false; humanoid.JumpHeight=3
    humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    for _,p in model:GetDescendants() do
        if p:IsA("BasePart") then p.Transparency=1; p.CollisionGroup="Vacuums"
        elseif p:IsA("Decal") then p.Transparency=1 end
    end
    local art=Models.vacuum()
    local cf,size=art:GetBoundingBox()
    art:PivotTo(cf:Inverse()*art:GetPivot()); art:ScaleTo(5/size.Y)
    cf,size=art:GetBoundingBox()
    local bottom=-(humanoid.HipHeight+root.Size.Y/2)
    art:PivotTo(root.CFrame*CFrame.new(0,bottom+size.Y/2,0)*cf:Inverse()*art:GetPivot())
    for _,p in art:GetDescendants() do
        if p:IsA("BasePart") then
            p.Anchored=false; p.Massless=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false
            local weld=Instance.new("WeldConstraint"); weld.Part0=root; weld.Part1=p; weld.Parent=p
        end
    end
    -- Preserve the authored hose endpoints after scaling, then animate that same top hose.
    local ribs={}
    for _,part in art:GetChildren() do
        if part:IsA("BasePart") and part.Name=="HoseRib" then table.insert(ribs,part) end
    end
    if #ribs>0 then
        local first=ribs[1]; local last=ribs[#ribs]
        local socket=Instance.new("Attachment"); socket.Name="TopHoseSocket"
        socket.Position=root.CFrame:PointToObjectSpace(first.CFrame:PointToWorldSpace(Vector3.new(0,0,first.Size.Z/2)))
        socket.Parent=root
        local rest=Instance.new("Attachment"); rest.Name="TopHoseRest"
        rest.Position=root.CFrame:PointToObjectSpace(last.CFrame:PointToWorldSpace(Vector3.new(0,0,-last.Size.Z/2)))
        rest.Parent=root
        for _,rib in ribs do rib.Transparency=1 end
    end
    local grabTarget=Instance.new("ObjectValue"); grabTarget.Name="GrabTarget"; grabTarget.Parent=model
    art.Parent=model
    model:PivotTo(Map.spawnCFrame("Vacuums",0))
    model.Parent=workspace; root:SetNetworkOwner(nil)
    return model
end
function Cleaner.start()
    task.spawn(function()
        local robot: Model?=nil
        local nextSpawn=0; local nextPath=0; local computing=false; local epoch=0
        local waypoints: {PathWaypoint}={}; local waypoint=1; local patrolIndex=1
        local patrolSince=os.clock(); local charge=0; local cooldown=0
        local seenAt=0; local lastSeen: Vector3?=nil; local chargedCharacter: Model?=nil
        local beam: Beam?=nil; local ends: {Attachment}={}
        local pull: LinearVelocity?=nil; local pulledRoot: BasePart?=nil
        local pulledPlayer: Player?=nil
        local grabStarted: number?=nil
        local function stopSuction()
            charge=0; chargedCharacter=nil; grabStarted=nil
            if pull then pull:Destroy(); pull=nil end
            if pulledRoot and pulledRoot.Parent then
                -- A broken grab releases the bug without throwing it through the room.
                pulledRoot.AssemblyLinearVelocity=Vector3.zero
            end
            pulledRoot=nil
            if pulledPlayer then pulledPlayer:SetAttribute("CleanerPulling",false); pulledPlayer=nil end
            if robot then
                local targetValue=robot:FindFirstChild("GrabTarget")
                if targetValue and targetValue:IsA("ObjectValue") then targetValue.Value=nil end
            end
            if beam then beam:Destroy(); beam=nil end
            for _,a in ends do a:Destroy() end
            table.clear(ends)
        end
        while true do
            task.wait(.15)
            local now=os.clock(); local player=solo()
            if not player then
                stopSuction()
                if robot then robot:Destroy(); robot=nil end
                epoch+=1; waypoints={}; computing=false; lastSeen=nil
                workspace:SetAttribute("CleanerState","Solo robot resting")
                for _,p in Players:GetPlayers() do p:SetAttribute("CleanerThreat","") end
                continue
            end
            if not robot then
                if now<nextSpawn then continue end
                nextSpawn=now+5; robot=create(player); nextPath=0; patrolSince=now
                if not robot then continue end
            end
            local root=robot:FindFirstChild("HumanoidRootPart") :: BasePart
            local h=robot:FindFirstChildOfClass("Humanoid")
            if not h or h.Health<=0 or root.Position.Y < -20 then
                stopSuction(); robot:Destroy(); robot=nil; epoch+=1; computing=false; waypoints={}; continue
            end
            if Refuge.containsPosition(root.Position) then
                robot:PivotTo(Map.spawnCFrame("Vacuums",0)); root.AssemblyLinearVelocity=Vector3.zero
                stopSuction(); epoch+=1; computing=false; waypoints={}; nextPath=now+1
            end
            local target=Forage.bugRoot(player)
            local protected=Refuge.isProtected(player)
            local visible=false; local distance=math.huge; local facing=-1
            if target and not protected then
                local delta=target.Position-root.Position; distance=delta.Magnitude
                local flat=Vector3.new(delta.X,0,delta.Z)
                facing=if flat.Magnitude<.1 then 1 else root.CFrame.LookVector:Dot(flat.Unit)
                local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances={robot,target.Parent}
                visible=workspace:Raycast(root.Position,delta,params)==nil
                if visible and distance<=Rules.DetectRange then lastSeen=target.Position; seenAt=now end
            end
            if not target or protected or now-seenAt>3 then lastSeen=nil end
            if chargedCharacter~=(if target then target.Parent else nil) then stopSuction() end
            if grabStarted and Rules.grabExpired(now-grabStarted) then
                stopSuction(); cooldown=now+Rules.Cooldown
            end
            local valid=target~=nil and now>=cooldown and Rules.canSuction(distance,facing,visible,protected,true,charge>=Rules.Windup)
            charge=Rules.charge(charge,.15,valid)
            if valid and target then
                chargedCharacter=target.Parent :: Model
                if not grabStarted then
                    grabStarted=now
                    robot:SetAttribute("GrabStartedAt",workspace:GetServerTimeNow())
                    local targetValue=robot:FindFirstChild("GrabTarget") :: ObjectValue
                    targetValue.Value=target.Parent
                end
                if not beam then
                    local a=Instance.new("Attachment")
                    local socket=root:FindFirstChild("TopHoseSocket")
                    if socket and socket:IsA("Attachment") then a.Position=socket.Position end
                    a.Parent=root
                    local b=Instance.new("Attachment"); b.Parent=target
                    ends={a,b}
                    beam=Instance.new("Beam"); beam.Attachment0=a; beam.Attachment1=b
                    beam.Width0=2; beam.Width1=.4; beam.FaceCamera=true
                    beam.Color=ColorSequence.new(Color3.fromRGB(60,220,255)); beam.Parent=root
                end
                local pulling=charge>=Rules.Windup
                player:SetAttribute("CleanerThreat",if pulling then "GRABBED! Break the hose's line of sight!"
                    else "HOSE REACHING! Get behind cover!")
                workspace:SetAttribute("CleanerState","Vacuuming")
                if pulling then
                    if not pull then
                        -- Stop other lift before attaching the server-created grab.
                        Flight.cancel(player); Climb.cancel(player)
                        player:SetAttribute("CleanerPulling",true); pulledPlayer=player; pulledRoot=target
                        pull=Instance.new("LinearVelocity"); pull.Name="CleanerGrab"
                        pull.Attachment0=ends[2]; pull.RelativeTo=Enum.ActuatorRelativeTo.World
                        pull.VelocityConstraintMode=Enum.VelocityConstraintMode.Line
                        pull.ForceLimitsEnabled=true; pull.ForceLimitMode=Enum.ForceLimitMode.Magnitude
                        pull.MaxForce=target.AssemblyMass*workspace.Gravity*4
                        pull.Parent=target
                    end
                    local toward=root.Position-target.Position
                    if toward.Magnitude>.05 then pull.LineDirection=toward.Unit end
                    pull.LineVelocity=Rules.PullSpeed
                    if Rules.canCapture(distance,charge) then
                        -- Rechecked range, direction, life, cover and refuge this tick.
                        Forage.capture(player); cooldown=now+Rules.Cooldown; lastSeen=nil; stopSuction()
                    end
                end
            else
                stopSuction()
                player:SetAttribute("CleanerThreat",if lastSeen then "Clean Team is chasing you!" else "")
                workspace:SetAttribute("CleanerState",if lastSeen then "Chasing" else "Patrolling")
            end
            local goal=lastSeen or patrol[patrolIndex]
            if not lastSeen and ((Vector3.new(root.Position.X,0,root.Position.Z)-goal).Magnitude<5 or now-patrolSince>18) then
                patrolIndex=patrolIndex%#patrol+1; patrolSince=now; goal=patrol[patrolIndex]; nextPath=0
            end
            if now>=nextPath and not computing then
                computing=true; nextPath=now+1; epoch+=1
                local ticket=epoch; local active=robot; local destination=goal
                task.spawn(function()
                    local path=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5.5,AgentCanJump=true,WaypointSpacing=3})
                    local ok=pcall(function() path:ComputeAsync(root.Position,destination) end)
                    if ticket~=epoch or robot~=active then path:Destroy(); return end
                    computing=false
                    if solo()~=player then waypoints={}; path:Destroy(); return end
                    waypoints=if ok and path.Status==Enum.PathStatus.Success then path:GetWaypoints() else {}
                    waypoint=2; path:Destroy()
                end)
            end
            local step=waypoints[waypoint]
            if step then
                local d=root.Position-step.Position
                if Vector3.new(d.X,0,d.Z).Magnitude<2 and math.abs(d.Y)<5 then waypoint+=1; step=waypoints[waypoint] end
            end
            if step then
                if step.Action==Enum.PathWaypointAction.Jump then h.Jump=true end
                h:MoveTo(step.Position)
            else h:MoveTo(root.Position) end
        end
    end)
end
return Cleaner
