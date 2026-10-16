--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage.Shared.FlightRules)
local Flight = {}
type Active = {character: Model, root: BasePart, attachment: Attachment, lift: LinearVelocity, wings: Model, started: number, baseY: number}
type State = {charges: number, readyAt: number, lastRequest: number, active: Active?, connections: {RBXScriptConnection}, died: RBXScriptConnection?}
local states: {[Player]: State} = {}

local function bug(player: Player): (Model?, Humanoid?, BasePart?)
    local c = player.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if player.Parent ~= Players or not player.Team or player.Team.Name ~= "StinkBugs"
        or not c or not h or h.Health <= 0 or not r or not r:IsA("BasePart") then return nil, nil, nil end
    return c, h, r
end
local function sync(player: Player, state: State)
    player:SetAttribute("FlightCharges", state.charges)
    player:SetAttribute("FlightReadyAt", state.readyAt)
    player:SetAttribute("FlightActive", state.active ~= nil)
end
local function stop(player: Player, state: State)
    local active = state.active
    state.active = nil
    if active then
        active.lift:Destroy()
        active.attachment:Destroy()
        active.wings:Destroy()
        -- Remove remaining upward momentum when the burst expires.
        if active.root.Parent then
            local v = active.root.AssemblyLinearVelocity
            active.root.AssemblyLinearVelocity = Vector3.new(v.X, math.min(v.Y, 0), v.Z)
        end
    end
    sync(player, state)
end
local function reset(player: Player, state: State)
    state.charges = 0
    state.readyAt = 0
    stop(player, state)
end
function Flight.award(player: Player)
    local state = states[player]
    if not state or not bug(player) then return end
    state.charges = Rules.earn(state.charges)
    sync(player, state)
end
local function ceiling(root: BasePart, character: Model): boolean
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.RespectCanCollide = true
    params.CollisionGroup = "StinkBugs"
    return workspace:Raycast(root.Position, Vector3.new(0, 2, 0), params) ~= nil
end
local function wings(character: Model, root: BasePart): Model
    local model = Instance.new("Model")
    model.Name = "FlightWings"
    for _,side in {-1, 1} do
        local part = Instance.new("Part")
        part.Name = if side < 0 then "LeftWing" else "RightWing"
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(1.6, .08, .8)
        part.Color = Color3.fromRGB(255, 225, 155)
        part.Transparency = .35
        part.Material = Enum.Material.Glass
        part.Massless = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CFrame = root.CFrame * CFrame.new(side * .9, .35, .35) * CFrame.Angles(0, side * .4, side * .2)
        part.Parent = model
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = root
        weld.Part1 = part
        weld.Parent = part
    end
    model.Parent = character
    return model
end
local function request(player: Player)
    local state = states[player]
    local now = workspace:GetServerTimeNow()
    if not state or now - state.lastRequest < .2 then return end
    state.lastRequest = now
    local character, humanoid, root = bug(player)
    if not character or not humanoid or not root then return end
    if not Rules.canStart(state.charges, now, state.readyAt, state.active ~= nil,
        humanoid.FloorMaterial ~= Enum.Material.Air) then return end
    if humanoid.Sit or humanoid.PlatformStand or ceiling(root, character) then return end
    -- Only this server path spends a charge and creates lift. The client sends no physics values.
    state.charges -= 1
    state.readyAt = now + Rules.Cooldown
    local attachment = Instance.new("Attachment")
    attachment.Name = "FlightAttachment"
    attachment.Parent = root
    local lift = Instance.new("LinearVelocity")
    lift.Name = "SnackFlight"
    lift.Attachment0 = attachment
    lift.RelativeTo = Enum.ActuatorRelativeTo.World
    lift.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
    lift.LineDirection = Vector3.yAxis
    lift.LineVelocity = Rules.Speed
    lift.ForceLimitsEnabled = true
    lift.ForceLimitMode = Enum.ForceLimitMode.Magnitude
    lift.MaxForce = root.AssemblyMass * workspace.Gravity * 4
    lift.Parent = root
    state.active = {character = character, root = root, attachment = attachment, lift = lift,
        wings = wings(character, root), started = now, baseY = root.Position.Y}
    sync(player, state)
end
local function join(player: Player)
    if states[player] then return end
    local state: State = {charges = 0, readyAt = 0, lastRequest = -math.huge, active = nil, connections = {}, died = nil}
    states[player] = state
    local function characterAdded(character: Model)
        reset(player, state)
        if state.died then state.died:Disconnect(); state.died = nil end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            state.died = humanoid.Died:Connect(function() reset(player, state) end)
        end
    end
    table.insert(state.connections, player.CharacterAdded:Connect(characterAdded))
    table.insert(state.connections, player.CharacterRemoving:Connect(function() reset(player, state) end))
    table.insert(state.connections, player:GetPropertyChangedSignal("Team"):Connect(function() reset(player, state) end))
    if player.Character then characterAdded(player.Character) else sync(player, state) end
end
function Flight.start()
    local remote = Instance.new("RemoteEvent")
    remote.Name = "FlightRequest"
    remote.Parent = ReplicatedStorage
    remote.OnServerEvent:Connect(request)
    Players.PlayerAdded:Connect(join)
    Players.PlayerRemoving:Connect(function(player)
        local state = states[player]
        if not state then return end
        stop(player, state)
        if state.died then state.died:Disconnect() end
        for _,connection in state.connections do connection:Disconnect() end
        states[player] = nil
    end)
    for _,player in Players:GetPlayers() do join(player) end
    RunService.Heartbeat:Connect(function()
        local now = workspace:GetServerTimeNow()
        for player,state in states do
            local active = state.active
            if not active then continue end
            local character, humanoid, root = bug(player)
            if character ~= active.character or not humanoid or root ~= active.root
                or not active.lift.Parent or now - active.started >= Rules.Duration
                or humanoid.Sit or humanoid.PlatformStand then
                stop(player, state)
                continue
            end
            if ceiling(active.root, active.character) then
                stop(player, state)
                continue
            end
            active.lift.LineVelocity = Rules.lift(active.root.Position.Y - active.baseY)
        end
    end)
end
return Flight
