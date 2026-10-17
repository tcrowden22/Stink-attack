--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Rules = require(game:GetService("ReplicatedStorage").Shared.ClimbRules)
local Climb = {}
type State = {
    active: boolean, last: number, lastMove: number, stopped: number, grip: number, input: Vector3, normal: Vector3,
    root: BasePart?, humanoid: Humanoid?, walkSpeed: number, autoRotate: boolean,
    lift: LinearVelocity?, attachment: Attachment?, connections: {RBXScriptConnection},
}
local states: {[Player]: State} = {}
local function stop(player: Player, state: State)
    if state.active then state.stopped = os.clock() end
    state.active = false
    if state.lift then state.lift:Destroy(); state.lift = nil end
    if state.attachment then state.attachment:Destroy(); state.attachment = nil end
    if state.humanoid and state.humanoid.Parent then
        state.humanoid.WalkSpeed = state.walkSpeed
        state.humanoid.AutoRotate = state.autoRotate
    end
    state.humanoid = nil
    if state.root and state.root.Parent then
        local v = state.root.AssemblyLinearVelocity
        state.root.AssemblyLinearVelocity = Vector3.new(v.X, math.min(v.Y, 0), v.Z)
        state.root.Parent:SetAttribute("BugClimbing", false)
        local pose=state.root:FindFirstChild("BugWallPose")
        if pose and pose:IsA("Motor6D") then pose.C0=pose:GetAttribute("RestC0") or CFrame.identity end
    end
    state.root = nil; state.input = Vector3.zero
    player:SetAttribute("BugClimbing", false)
end
function Climb.cancel(player: Player)
    local state = states[player]
    if state then stop(player, state) end
end
local function character(player: Player): (BasePart?, Humanoid?)
    if player.Parent ~= Players or not player.Team or player.Team.Name ~= "StinkBugs"
        or player:GetAttribute("BirdCarried") or player:GetAttribute("FlightActive") or player:GetAttribute("CleanerPulling") then return nil, nil end
    local c = player.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not c or not h or h.Health <= 0 or h.Sit or h.PlatformStand
        or not root or not root:IsA("BasePart") then return nil, nil end
    return root, h
end
local function params(root: BasePart): RaycastParams
    local result = RaycastParams.new()
    result.FilterType = Enum.RaycastFilterType.Exclude
    result.FilterDescendantsInstances = {root.Parent}
    result.CollisionGroup = "StinkBugs"; result.RespectCanCollide = true
    return result
end
local function wall(root: BasePart, direction: Vector3): Vector3?
    local flat = Vector3.new(direction.X, 0, direction.Z)
    if flat.Magnitude < .1 then return nil end
    for _,height in {0, .8} do
        local hit = workspace:Raycast(root.Position + Vector3.new(0,height,0), flat.Unit * Rules.Reach, params(root))
        if hit and hit.Instance:IsA("BasePart") and Rules.canClimb(hit.Distance, hit.Normal.Y,
            hit.Instance.Anchored, hit.Instance.CanCollide) then
            local normal = Vector3.new(hit.Normal.X,0,hit.Normal.Z)
            return normal.Unit
        end
    end
    return nil
end
local function begin(player: Player,state: State,root: BasePart,h: Humanoid,normal: Vector3,now: number)
        local attachment=Instance.new("Attachment"); attachment.Name="ClimbAttachment"; attachment.Parent=root
        local lift=Instance.new("LinearVelocity"); lift.Name="BugClimb"; lift.Attachment0=attachment
        lift.RelativeTo=Enum.ActuatorRelativeTo.World; lift.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
        lift.VectorVelocity=Vector3.zero
        lift.ForceLimitsEnabled=true; lift.ForceLimitMode=Enum.ForceLimitMode.Magnitude
        lift.MaxForce=root.AssemblyMass*workspace.Gravity*4; lift.Parent=root
        state.active=true; state.root=root; state.humanoid=h; state.lift=lift; state.attachment=attachment
        state.normal=normal; state.lastMove=now
        state.walkSpeed=h.WalkSpeed; state.autoRotate=h.AutoRotate
        -- Client still reads MoveDirection; these prevent ordinary walking from fighting wall motion.
        h.AutoRotate=false; h.WalkSpeed=0
        player:SetAttribute("BugClimbing",true); root.Parent:SetAttribute("BugClimbing",true)
end
local function join(player: Player)
    if states[player] then return end
    local state: State = {active=false,last=-math.huge,lastMove=-math.huge,stopped=0,grip=Rules.GripSeconds,
        input=Vector3.zero,normal=Vector3.zAxis,root=nil,humanoid=nil,walkSpeed=0,autoRotate=true,
        lift=nil,attachment=nil,connections={}}
    states[player] = state
    player:SetAttribute("BugClimbing",false); player:SetAttribute("ClimbGrip",state.grip)
    table.insert(state.connections,player.CharacterRemoving:Connect(function() stop(player,state) end))
    table.insert(state.connections,player.CharacterAdded:Connect(function()
        stop(player,state); state.grip=Rules.GripSeconds; player:SetAttribute("ClimbGrip",state.grip)
    end))
    table.insert(state.connections,player:GetPropertyChangedSignal("Team"):Connect(function() stop(player,state) end))
end
function Climb.start()
    local remote = Instance.new("RemoteEvent")
    remote.Name="ClimbRequest"; remote.Parent=game:GetService("ReplicatedStorage")
    remote.OnServerEvent:Connect(function(player,kind,input)
        local state=states[player]; local now=os.clock()
        if not state then return end
        if kind=="move" then
            if now-state.lastMove<.06 or typeof(input)~="Vector3" then return end
            if not Rules.validAxis(input.X) or not Rules.validAxis(input.Y) or not Rules.validAxis(input.Z)
                or math.abs(input.Y)>.01 or input.Magnitude>1.05 then return end
            state.lastMove=now; state.input=if input.Magnitude>1 then input.Unit else input
            return
        end
        if kind~=nil or now-state.last<.2 then return end
        state.last=now
        if state.active then stop(player,state); return end
        if state.grip<.5 then
            player:SetAttribute("ForageMessage","Grip tired! Land and rest before climbing.")
            return
        end
        local root,h=character(player)
        if not root or not h then return end
        local normal=wall(root,root.CFrame.LookVector)
        if not normal then
            player:SetAttribute("ForageMessage","Face a wall or solid furniture, then press C / Climb.")
            return
        end
        begin(player,state,root,h,normal,now)
    end)
    Players.PlayerAdded:Connect(join)
    Players.PlayerRemoving:Connect(function(player)
        local state=states[player]; if not state then return end
        stop(player,state)
        for _,connection in state.connections do connection:Disconnect() end
        states[player]=nil
    end)
    for _,player in Players:GetPlayers() do join(player) end
    RunService.Heartbeat:Connect(function(dt)
        local now=os.clock()
        for player,state in states do
            local root,h=character(player)
            if state.active then
                local normal=if root then wall(root,-state.normal) else nil
                if root~=state.root or not root or not normal or not state.lift or not state.lift.Parent then
                    stop(player,state)
                else
                    state.grip=Rules.grip(state.grip,dt,true,false)
                    if state.grip<=0 then
                        player:SetAttribute("ForageMessage","Out of grip! Land to recover.")
                        stop(player,state)
                    else
                        state.normal=normal
                        local input=if now-state.lastMove<=Rules.InputTimeout then state.input else Vector3.zero
                        local pose=root:FindFirstChild("BugWallPose")
                        if pose and pose:IsA("Motor6D") then
                            local rest=pose:GetAttribute("RestC0") or CFrame.identity
                            local center=root.CFrame:PointToWorldSpace(rest.Position)+normal*.65
                            pose.C0=root.CFrame:ToObjectSpace(CFrame.lookAt(center,center+Vector3.yAxis,normal))
                        end
                        local right=Vector3.yAxis:Cross(normal)
                        local up=input:Dot(-normal)
                        if up>0 and workspace:Raycast(root.Position,Vector3.new(0,1.4,0),params(root)) then up=0 end
                        state.lift.VectorVelocity=(right*input:Dot(right)+Vector3.yAxis*up)*Rules.Speed-normal*.6
                    end
                end
            elseif root and h and now-state.stopped>=Rules.RestDelay and h.FloorMaterial~=Enum.Material.Air then
                state.grip=Rules.grip(state.grip,dt,false,true)
                if now-state.lastMove<=Rules.InputTimeout and state.input.Magnitude>.2 then
                    local normal=wall(root,state.input)
                    -- Require a tall wall probe so shallow stair risers do not auto-attach.
                    local upper=workspace:Raycast(root.Position+Vector3.yAxis*1.2,state.input.Unit*Rules.Reach,params(root))
                    if normal and upper and upper.Instance:IsA("BasePart")
                        and Rules.canClimb(upper.Distance,upper.Normal.Y,upper.Instance.Anchored,upper.Instance.CanCollide)
                        and Rules.canAutoStart(state.grip,state.input:Dot(-normal),now-state.stopped) then
                        begin(player,state,root,h,normal,now)
                    end
                end
            end
            local displayed=math.ceil(state.grip*10)/10
            if player:GetAttribute("ClimbGrip")~=displayed then player:SetAttribute("ClimbGrip",displayed) end
        end
    end)
end
return Climb
