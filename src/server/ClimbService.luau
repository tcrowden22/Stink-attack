--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Rules = require(game:GetService("ReplicatedStorage").Shared.ClimbRules)
local Climb = {}
type State = {active: boolean, last: number, root: BasePart?, lift: LinearVelocity?, attachment: Attachment?, connections: {RBXScriptConnection}}
local states: {[Player]: State} = {}
local function stop(player: Player, state: State)
    state.active = false
    if state.lift then state.lift:Destroy(); state.lift = nil end
    if state.attachment then state.attachment:Destroy(); state.attachment = nil end
    if state.root and state.root.Parent then
        local v = state.root.AssemblyLinearVelocity
        state.root.AssemblyLinearVelocity = Vector3.new(v.X, math.min(v.Y, 0), v.Z)
        state.root.Parent:SetAttribute("BugClimbing", false)
    end
    state.root = nil
    player:SetAttribute("BugClimbing", false)
end
function Climb.cancel(player: Player)
    local state = states[player]
    if state then stop(player, state) end
end
local function surface(player: Player): BasePart?
    if player.Parent ~= Players or not player.Team or player.Team.Name ~= "StinkBugs"
        or player:GetAttribute("FlightActive") or player:GetAttribute("CleanerPulling") then return nil end
    local c = player.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not c or not h or h.Health <= 0 or h.Sit or h.PlatformStand
        or not root or not root:IsA("BasePart") then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {c}
    params.CollisionGroup = "StinkBugs"
    params.RespectCanCollide = true
    -- Check head clearance first; ceilings never become climb surfaces.
    if workspace:Raycast(root.Position, Vector3.new(0, 1.4, 0), params) then return nil end
    local look = root.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < .1 then return nil end
    -- The lower probe keeps lifting until the feet clear a furniture edge.
    for _,height in {0, -.8} do
        local hit = workspace:Raycast(root.Position + Vector3.new(0,height,0), flat.Unit * Rules.Reach, params)
        if hit and hit.Instance:IsA("BasePart") and Rules.canClimb(hit.Distance, hit.Normal.Y,
            hit.Instance.Anchored, hit.Instance.CanCollide) then return root end
    end
    return nil
end
local function join(player: Player)
    if states[player] then return end
    local state: State = {active = false, last = -math.huge, root = nil, lift = nil, attachment = nil, connections = {}}
    states[player] = state
    player:SetAttribute("BugClimbing", false)
    table.insert(state.connections, player.CharacterRemoving:Connect(function() stop(player,state) end))
    table.insert(state.connections, player.CharacterAdded:Connect(function() stop(player,state) end))
    table.insert(state.connections, player:GetPropertyChangedSignal("Team"):Connect(function() stop(player,state) end))
end
function Climb.start()
    local remote = Instance.new("RemoteEvent")
    remote.Name = "ClimbRequest"
    remote.Parent = game:GetService("ReplicatedStorage")
    remote.OnServerEvent:Connect(function(player)
        local state = states[player]
        local now = os.clock()
        if not state or now - state.last < .2 then return end
        state.last = now
        if state.active then stop(player,state); return end
        local root = surface(player)
        if not root then
            player:SetAttribute("ForageMessage", "Face a wall or solid furniture, then press C / Climb.")
            return
        end
        local attachment = Instance.new("Attachment")
        attachment.Name = "ClimbAttachment"; attachment.Parent = root
        local lift = Instance.new("LinearVelocity")
        lift.Name = "BugClimb"; lift.Attachment0 = attachment
        lift.RelativeTo = Enum.ActuatorRelativeTo.World
        lift.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
        lift.LineDirection = Vector3.yAxis; lift.LineVelocity = Rules.Speed
        lift.ForceLimitsEnabled = true; lift.ForceLimitMode = Enum.ForceLimitMode.Magnitude
        lift.MaxForce = root.AssemblyMass * workspace.Gravity * 4
        lift.Parent = root
        state.active = true; state.root = root; state.lift = lift; state.attachment = attachment
        player:SetAttribute("BugClimbing", true)
        root.Parent:SetAttribute("BugClimbing", true)
    end)
    Players.PlayerAdded:Connect(join)
    Players.PlayerRemoving:Connect(function(player)
        local state = states[player]
        if not state then return end
        stop(player,state)
        for _,connection in state.connections do connection:Disconnect() end
        states[player] = nil
    end)
    for _,player in Players:GetPlayers() do join(player) end
    RunService.Heartbeat:Connect(function()
        for player,state in states do
            if state.active and (surface(player) ~= state.root or not state.lift or not state.lift.Parent) then
                stop(player,state)
            end
        end
    end)
end
return Climb
