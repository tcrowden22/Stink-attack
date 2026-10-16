--!strict
local Players=game:GetService("Players")
local Rules=require(game:GetService("ReplicatedStorage").Shared.HuntRules)
local Bots=require(script.Parent.BugBotService)
local Forage=require(script.Parent.ForageService)
local Refuge=require(script.Parent.RefugeService)
local Flight=require(script.Parent.FlightService)
local Climb=require(script.Parent.ClimbService)
local Vacuum={}
type State={held: boolean,lastInput: number,lastRequest: number,cooldown: number,started: number,
    target: Model?,targetPlayer: Player?,charge: number,beam: Beam?,pull: LinearVelocity?,attachments: {Attachment},connections: {RBXScriptConnection}}
local states: {[Player]: State}={}
local function clear(state: State)
    if state.pull then state.pull:Destroy(); state.pull=nil end
    if state.beam then state.beam:Destroy(); state.beam=nil end
    for _,a in state.attachments do a:Destroy() end
    table.clear(state.attachments)
    if state.target and state.target.Parent then
        state.target:SetAttribute("VacuumHeld",false)
        local root=state.target:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then root.AssemblyLinearVelocity=Vector3.zero end
    end
    if state.targetPlayer then state.targetPlayer:SetAttribute("CleanerPulling",false) end
    state.target=nil; state.targetPlayer=nil; state.charge=0
end
local function vacuumRoot(player: Player): BasePart?
    local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    local root=c and c:FindFirstChild("HumanoidRootPart")
    if player.Parent~=Players or not player.Team or player.Team.Name~="Vacuums"
        or not h or h.Health<=0 or not root or not root:IsA("BasePart") then return nil end
    return root
end
local function valid(root: BasePart,target: Model): BasePart?
    local h=target:FindFirstChildOfClass("Humanoid")
    local r=target:FindFirstChild("HumanoidRootPart")
    if not target.Parent or not h or h.Health<=0 or not r or not r:IsA("BasePart") then return nil end
    local delta=r.Position-root.Position
    local facing=if delta.Magnitude>.01 then root.CFrame.LookVector:Dot(delta.Unit) else 1
    if not Rules.canSuck(delta.Magnitude,facing,true,Refuge.containsPosition(r.Position)) then return nil end
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={root.Parent,target}; params.RespectCanCollide=true
    params.CollisionGroup="Vacuums"
    local origin=root.CFrame:PointToWorldSpace(Vector3.new(.7,-1.5,-1.5))
    if workspace:Raycast(root.Position,delta,params) or workspace:Raycast(origin,r.Position-origin,params) then return nil end
    return r
end
local function join(player: Player)
    if states[player] then return end
    local state: State={held=false,lastInput=0,lastRequest=-math.huge,cooldown=0,started=0,
        target=nil,targetPlayer=nil,charge=0,beam=nil,pull=nil,attachments={},connections={}}
    states[player]=state
    table.insert(state.connections,player.CharacterRemoving:Connect(function() clear(state); state.held=false; state.started=0 end))
    table.insert(state.connections,player:GetPropertyChangedSignal("Team"):Connect(function() clear(state); state.held=false; state.started=0 end))
end
function Vacuum.start()
    local remote=Instance.new("RemoteEvent"); remote.Name="VacuumInput"; remote.Parent=game:GetService("ReplicatedStorage")
    remote.OnServerEvent:Connect(function(player,held)
        local state=states[player]; local now=os.clock()
        if not state or typeof(held)~="boolean" then return end
        if not held then state.held=false; clear(state); state.started=0; return end
        if now-state.lastRequest<.08 then return end
        state.lastRequest=now
        if not vacuumRoot(player) then return end
        state.held=true; state.lastInput=now
    end)
    Players.PlayerAdded:Connect(join)
    Players.PlayerRemoving:Connect(function(player)
        local state=states[player]
        if state then
            clear(state)
            for _,connection in state.connections do connection:Disconnect() end
        end
        states[player]=nil
    end)
    for _,player in Players:GetPlayers() do join(player) end
    task.spawn(function()
        while true do
            task.wait(.1)
            local now=os.clock()
            for player,state in states do
                local root=vacuumRoot(player)
                if not root or not state.held or now-state.lastInput>Rules.InputTimeout or now<state.cooldown then
                    clear(state); state.started=0
                    player:SetAttribute("VacuumStatus",if now<state.cooldown then "Vacuum cooling down..." else "Hold click / Q / Suction to vacuum")
                    continue
                end
                if state.started==0 then state.started=now end
                if now-state.started>=Rules.MaxBurst then
                    clear(state); state.started=0; state.cooldown=now+Rules.Cooldown
                    continue
                end
                if state.target and (not valid(root,state.target) or
                    (state.targetPlayer and (not state.targetPlayer.Team or state.targetPlayer.Team.Name~="StinkBugs"))) then clear(state) end
                if not state.target then
                    local nearest=math.huge
                    local candidates=Bots.list()
                    local owners: {[Model]: Player}={}
                    for _,other in Players:GetPlayers() do
                        if Forage.bugRoot(other) and other.Character then
                            table.insert(candidates,other.Character); owners[other.Character]=other
                        end
                    end
                    for _,candidate in candidates do
                        if candidate:GetAttribute("VacuumHeld") then continue end
                        local r=valid(root,candidate)
                        if r and (r.Position-root.Position).Magnitude<nearest then
                            nearest=(r.Position-root.Position).Magnitude
                            state.target=candidate; state.targetPlayer=owners[candidate]
                        end
                    end
                    if state.target then
                        -- Claim before yielding so two hunters cannot pull the same bug.
                        state.target:SetAttribute("VacuumHeld",true)
                        local targetRoot=state.target:FindFirstChild("HumanoidRootPart") :: BasePart
                        local a=Instance.new("Attachment"); a.Position=Vector3.new(.7,-1.5,-1.5); a.Parent=root
                        local b=Instance.new("Attachment"); b.Parent=targetRoot; state.attachments={a,b}
                        local beam=Instance.new("Beam"); beam.Attachment0=a; beam.Attachment1=b
                        beam.Width0=1.4; beam.Width1=.3; beam.FaceCamera=true
                        beam.Color=ColorSequence.new(Color3.fromRGB(70,220,255)); beam.Parent=root; state.beam=beam
                    end
                end
                local target=state.target
                local targetRoot=if target then valid(root,target) else nil
                if not target or not targetRoot then
                    clear(state); player:SetAttribute("VacuumStatus","Aim your character toward a bug!")
                    continue
                end
                state.charge=math.min(Rules.Windup,state.charge+.1)
                player:SetAttribute("VacuumStatus",if state.charge>=Rules.Windup then "Pulling a stink bug!" else "Locking on...")
                if state.charge>=Rules.Windup then
                    if not state.pull then
                        if state.targetPlayer then
                            Flight.cancel(state.targetPlayer); Climb.cancel(state.targetPlayer)
                            state.targetPlayer:SetAttribute("CleanerPulling",true)
                        end
                        local pull=Instance.new("LinearVelocity"); pull.Name="PlayerVacuumPull"
                        pull.Attachment0=state.attachments[2]; pull.RelativeTo=Enum.ActuatorRelativeTo.World
                        pull.VelocityConstraintMode=Enum.VelocityConstraintMode.Line
                        pull.ForceLimitsEnabled=true; pull.ForceLimitMode=Enum.ForceLimitMode.Magnitude
                        pull.MaxForce=targetRoot.AssemblyMass*workspace.Gravity*4; pull.Parent=targetRoot
                        state.pull=pull
                    end
                    local toward=state.attachments[1].WorldPosition-targetRoot.Position
                    if toward.Magnitude>.01 then state.pull.LineDirection=toward.Unit end
                    state.pull.LineVelocity=Rules.PullSpeed
                    if Rules.canCapture((targetRoot.Position-root.Position).Magnitude,state.charge) then
                        local caught=false
                        if state.targetPlayer then
                            Forage.capture(state.targetPlayer)
                            local h=target:FindFirstChildOfClass("Humanoid")
                            caught=h~=nil and h.Health<=0
                        else caught=Bots.capture(target) end
                        if caught then player:SetAttribute("BugsCaught",(player:GetAttribute("BugsCaught") or 0)+1) end
                        clear(state); state.started=0; state.cooldown=now+Rules.Cooldown
                    end
                end
            end
        end
    end)
end
return Vacuum
