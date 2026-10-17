--!strict
local Players=game:GetService("Players")
local Rules=require(game:GetService("ReplicatedStorage").Shared.BirdRules)
local Forage=require(script.Parent.ForageService)
local Builder=require(script.Parent.BirdModel)
local Flight=require(script.Parent.FlightService)
local Climb=require(script.Parent.ClimbService)
local Birds={}
local centers={Vector3.new(-15,84,0),Vector3.new(65,86,36),Vector3.new(100,84,85)}
type Bird={model: Model,root: BasePart,center: Vector3,index: number,mode: string,untilTime: number,
 target: Player?,character: Instance?,began: number,attacks: number,
 hold: AlignPosition?,ends: {Attachment},heldRoot: BasePart?,heldHumanoid: Humanoid?,
 oldPlatform: boolean,carryGoal: Vector3?}
local function roof(root: BasePart): boolean
 local p=root.Position
 return Rules.onRoof(p.X,p.Y,p.Z)
end
function Birds.start()
 local folder=Instance.new("Folder"); folder.Name="RooftopBirds"; folder.Parent=workspace
 local flock: {Bird}={}
 for index,center in centers do
  local model,root=Builder.create(index); model:PivotTo(CFrame.new(center)); model.Parent=folder
  table.insert(flock,{model=model,root=root,center=center,index=index,mode="Patrol",untilTime=os.clock()+index,
   target=nil,character=nil,began=0,attacks=0,hold=nil,ends={},heldRoot=nil,heldHumanoid=nil,oldPlatform=false,carryGoal=nil})
 end
 local function params(): RaycastParams
  local ignore: {Instance}={folder}
  for _,p in Players:GetPlayers() do if p.Character then table.insert(ignore,p.Character) end end
  local result=RaycastParams.new(); result.FilterType=Enum.RaycastFilterType.Exclude
  result.FilterDescendantsInstances=ignore; result.RespectCanCollide=true
  return result
 end
 local function exposed(root: BasePart,ray: RaycastParams): boolean
  return roof(root) and workspace:Raycast(root.Position,Vector3.yAxis*20,ray)==nil
 end
 local function clear(a: Vector3,b: Vector3,ray: RaycastParams): boolean
  return workspace:Raycast(a,b-a,ray)==nil
 end
 local function recover(b: Bird,now: number)
  if b.hold then b.hold:Destroy(); b.hold=nil end
  for _,a in b.ends do a:Destroy() end
  table.clear(b.ends)
  if b.heldHumanoid and b.heldHumanoid.Parent then b.heldHumanoid.PlatformStand=b.oldPlatform end
  if b.heldRoot and b.heldRoot.Parent then
   b.heldRoot.AssemblyLinearVelocity=Vector3.zero
   b.heldRoot.Parent:SetAttribute("LastBirdPeckAt",now)
   pcall(function() b.heldRoot:SetNetworkOwnershipAuto() end)
  end
  if b.target and b.heldRoot then
   b.target:SetAttribute("BirdCarried",false)
   b.target:SetAttribute("BirdEscapeRequested",false)
  end
  b.heldRoot=nil; b.heldHumanoid=nil; b.carryGoal=nil
  b.mode="Recover"; b.untilTime=now+Rules.Cooldown; b.target=nil; b.character=nil
 end
 local function pickup(b: Bird,target: BasePart,now: number): boolean
  local player=b.target
  local h=target.Parent:FindFirstChildOfClass("Humanoid")
  if not player or not h or player:GetAttribute("BirdCarried") or player:GetAttribute("CleanerPulling")
   or target.Parent:GetAttribute("VacuumHeld") then return false end
  -- Claim without yielding: only one bird can carry a player.
  target.Parent:SetAttribute("LastBirdPeckAt",now)
  player:SetAttribute("BirdCarried",true); player:SetAttribute("BirdEscapeRequested",false)
  Flight.cancel(player); Climb.cancel(player)
  b.heldRoot=target; b.heldHumanoid=h; b.oldPlatform=h.PlatformStand; h.PlatformStand=true
  target.AssemblyLinearVelocity=Vector3.zero
  target:SetNetworkOwner(nil)
  b.root.CFrame=CFrame.new(b.root.Position)
  local a=Instance.new("Attachment"); a.Name="BirdCarryBug"; a.Parent=target
  local c=Instance.new("Attachment"); c.Name="BirdCarryClaw"; c.Position=b.root.CFrame:PointToObjectSpace(target.Position); c.Parent=b.root
  local hold=Instance.new("AlignPosition"); hold.Name="BirdCarry"
  hold.Mode=Enum.PositionAlignmentMode.TwoAttachment; hold.Attachment0=a; hold.Attachment1=c
  hold.RigidityEnabled=false; hold.ApplyAtCenterOfMass=true
  hold.MaxForce=target.AssemblyMass*workspace.Gravity*4; hold.MaxVelocity=12; hold.Responsiveness=20
  hold.Parent=target; b.hold=hold; b.ends={a,c}
  b.mode="Carrying"; b.untilTime=now+Rules.CarrySeconds
  b.carryGoal=b.root.Position+Vector3.yAxis*8
  return true
 end
 local function move(b: Bird,goal: Vector3,dt: number,ray: RaycastParams): boolean
  goal=Vector3.new(math.clamp(goal.X,-46,142),math.clamp(goal.Y,65.5,95),math.clamp(goal.Z,-34,106))
  local delta=goal-b.root.Position
  if delta.Magnitude<.01 then return true end
  local step=delta.Unit*Rules.travel(delta.Magnitude,dt)*(if b.mode=="Carrying" then .3 else 1)
  if workspace:Spherecast(b.root.Position,1.3,step,ray) then return false end
  local p=b.root.Position+step
  local up=if math.abs(delta.Unit.Y)>.95 then Vector3.zAxis else Vector3.yAxis
  b.root.CFrame=if b.mode=="Carrying" then CFrame.new(p) else CFrame.lookAt(p,p+delta.Unit,up)
  return true
 end
 task.spawn(function()
  local last=os.clock()
  while folder.Parent do
   task.wait(.05)
   local now=os.clock(); local dt=now-last; last=now; local ray=params()
   local warnings: {[Player]: string}={}
   for _,p in Players:GetPlayers() do
    local r=Forage.bugRoot(p)
    if r and roof(r) then warnings[p]="ROOFTOP BIRDS! Use the fan shelters for cover." end
   end
   for _,b in flock do
    if not b.model.Parent then recover(b,now); continue end
    local target=if b.target then Forage.bugRoot(b.target) else nil
    if b.mode=="Carrying" then
     if not target or target~=b.heldRoot or not b.target or b.target:GetAttribute("BirdEscapeRequested")
      or b.target:GetAttribute("CleanerPulling") or (target and target.Parent:GetAttribute("VacuumHeld"))
      or now>=b.untilTime then recover(b,now); target=nil end
    end
    if b.mode~="Carrying" and b.target and (b.target:GetAttribute("BirdCarried") or not target or target.Parent~=b.character or not exposed(target,ray)
     or not clear(b.root.Position,target.Position,ray)
     or (target.Position-b.root.Position).Magnitude>Rules.DetectRange) then
     recover(b,now); target=nil
    end
    if b.mode=="Patrol" and now>=b.untilTime then
     local nearest=Rules.DetectRange
     for _,p in Players:GetPlayers() do
      local r=Forage.bugRoot(p)
      if not r or p:GetAttribute("BirdCarried") then continue end
      local distance=(r.Position-b.root.Position).Magnitude
      if Rules.canTarget(true,roof(r),exposed(r,ray) and clear(b.root.Position,r.Position,ray),distance) and distance<nearest then
       nearest=distance; target=r; b.target=p; b.character=r.Parent
      end
     end
     if target then b.mode="Warning"; b.began=now; b.untilTime=now+Rules.WarningSeconds end
    end
    if b.mode=="Carrying" and target and b.target then
     warnings[b.target]="PICKED UP! Press R / Stink! to make the bird drop you!"
     if b.root.Position.Y>=70 then
      local claw=b.ends[2]
      local offset=claw.Position:Lerp(Vector3.new(0,-1.8,0),math.clamp(dt*4,0,1))
      local toward=b.root.CFrame:PointToWorldSpace(offset)-target.Position
      if toward.Magnitude>.01 and workspace:Spherecast(target.Position,.8,
       toward.Unit*math.min(toward.Magnitude,12*math.clamp(dt,0,.1)),ray) then
       recover(b,now); continue
      end
      claw.Position=offset
     end
     local step=Vector3.yAxis*math.min(8*.1,8*math.clamp(dt,0,.1))
     -- Sweep the passenger too, so lifting never drags a bug through a roof prop.
     if not b.carryGoal or workspace:Spherecast(target.Position,.8,step,ray)
      or not move(b,b.carryGoal,dt,ray) or (target.Position-b.ends[2].WorldPosition).Magnitude>5 then
      recover(b,now)
     end
    elseif b.mode=="Warning" and target then
     if b.target then warnings[b.target]="BIRD SPOTTED YOU! Get under cover!" end
     if now>=b.untilTime then b.mode="Diving"; b.untilTime=now+Rules.DiveSeconds end
    elseif b.mode=="Diving" and target and b.target then
     warnings[b.target]="BIRD DIVING! Hide under a fan shelter!"
     if now>=b.untilTime or not move(b,target.Position+Vector3.yAxis*1.2,dt,ray) then
      recover(b,now)
     else
      local bite=b.root:FindFirstChild("BitePoint") :: Attachment
      if Rules.canBite(exposed(target,ray),clear(bite.WorldPosition,target.Position,ray),
       (bite.WorldPosition-target.Position).Magnitude,now-b.began) then
       local player=b.target
       local h=target.Parent:FindFirstChildOfClass("Humanoid")
       local lastPeck=target.Parent:GetAttribute("LastBirdPeckAt") or -math.huge
       if h and Rules.canPeck(now,lastPeck) and not player:GetAttribute("BirdCarried") then
        b.attacks+=1
        if b.attacks%2==0 and pickup(b,target,now) then
         warnings[player]="PICKED UP! Press R / Stink! to escape!"
        else
         target.Parent:SetAttribute("LastBirdPeckAt",now)
         b.model:SetAttribute("PeckAt",workspace:GetServerTimeNow())
         if h.Health<=Rules.PeckDamage then Forage.eliminate(player,"Too many bird pecks! Returning home...")
         else h:TakeDamage(Rules.PeckDamage); player:SetAttribute("ForageMessage","Pecked! Take cover or use Stink!") end
         recover(b,now)
        end
       else recover(b,now) end
      end
     end
    elseif b.mode=="Recover" then
     -- Rise above roof obstacles before returning to the patrol orbit.
     local goal=if b.root.Position.Y<81 then Vector3.new(b.root.Position.X,84,b.root.Position.Z) else b.center
     move(b,goal,dt,ray)
     if now>=b.untilTime and b.root.Position.Y>=81 then b.mode="Patrol" end
    elseif b.mode=="Patrol" then
     local angle=now*.22+b.index*2
     local goal=b.center+Vector3.new(math.cos(angle)*17,math.sin(angle*2)*1.5,math.sin(angle)*13)
     move(b,goal,dt,ray)
    end
    if b.model:GetAttribute("BirdState")~=b.mode then b.model:SetAttribute("BirdState",b.mode) end
   end
   for _,p in Players:GetPlayers() do
    local warning=warnings[p] or ""
    if p:GetAttribute("BirdWarning")~=warning then p:SetAttribute("BirdWarning",warning) end
   end
  end
  for _,b in flock do recover(b,os.clock()) end
 end)
end
return Birds
