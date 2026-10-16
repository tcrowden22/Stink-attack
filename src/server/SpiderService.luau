--!strict
local Players=game:GetService("Players")
local Pathfinding=game:GetService("PathfindingService")
local Rules=require(game:GetService("ReplicatedStorage").Shared.DangerRules)
local Forage=require(script.Parent.ForageService)
local Refuge=require(script.Parent.RefugeService)
local ModelBuilder=require(script.Parent.SpiderModel)
local Service={}
local visits: {[Player]: {character: Instance,entered: number}}={}
local nests={
 {position=Vector3.new(-75,0,22),club=true},
 {position=Vector3.new(-75,0,62),club=true},
 {position=Vector3.new(34,48,12),club=false},
 {position=Vector3.new(95,48,80),club=false},
}
local function inZone(position: Vector3,club: boolean): boolean
 if club then return Refuge.containsPosition(position) end
 return position.Y>=48 and position.Y<64 and position.X>-49 and position.X<145 and position.Z>-37 and position.Z<109
end
local function eligible(p: Player,club: boolean): BasePart?
 local root=Forage.bugRoot(p)
 if not root or not inZone(root.Position,club) then return nil end
 if club then
  local visit=visits[p]
  if not visit or visit.character~=root.Parent or not Rules.spiderAwake(os.clock()-visit.entered) then return nil end
 end
 return root
end
local function clearLine(model: Model,target: BasePart,root: BasePart): boolean
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances={model,target.Parent}; params.RespectCanCollide=true
 return workspace:Raycast(root.Position,target.Position-root.Position,params)==nil
end
local function run(model: Model,h: Humanoid,root: BasePart,nest)
 local steps: {PathWaypoint}={}; local stepIndex=2; local computing=false; local ticket=0; local nextPath=0
 local bitten: Player?=nil; local biteSince=0; local lastGoal: Vector3?=nil
 while model.Parent and h.Health>0 do
  task.wait(.1)
  if not model.Parent then break end
  local now=os.clock()
  if not inZone(root.Position,nest.club) then
   model:PivotTo(CFrame.new(nest.position+Vector3.new(0,2,0)))
   root.AssemblyLinearVelocity=Vector3.zero; steps={}; ticket+=1; computing=false; nextPath=0
  end
  local target: BasePart?=nil; local owner: Player?=nil; local nearest=if nest.club then 100 else 32
  for _,p in Players:GetPlayers() do
   local r=eligible(p,nest.club)
   if r then
    local distance=(r.Position-root.Position).Magnitude
    if distance<nearest then nearest=distance; target=r; owner=p end
   end
  end
  if target and owner and nearest<=Rules.BiteRange and clearLine(model,target,root) then
   if bitten~=owner then bitten=owner; biteSince=now end
   model:SetAttribute("SpiderBiting",true)
   if Rules.canBite(nearest,true,now-biteSince) then
    -- Eligibility is rechecked every tick, including departure from the clubhouse.
    Forage.eliminate(owner,"The spider gobbled you! Returning home...")
    bitten=nil; biteSince=0
   end
  else bitten=nil; biteSince=0; model:SetAttribute("SpiderBiting",false) end
  local goal=if target then target.Position else nest.position
  if now>=nextPath and not computing then
   computing=true; nextPath=now+1; ticket+=1
   local mine=ticket; lastGoal=goal
   task.spawn(function()
    local path=Pathfinding:CreatePath({AgentRadius=2,AgentHeight=3,AgentCanJump=false,WaypointSpacing=3})
    local ok=pcall(function() path:ComputeAsync(root.Position,goal) end)
    if not model.Parent or mine~=ticket then path:Destroy(); return end
    computing=false
    steps=if ok and path.Status==Enum.PathStatus.Success then path:GetWaypoints() else {}
    stepIndex=2; path:Destroy()
   end)
  end
  -- Cancel stale pursuit immediately when a bug leaves its danger zone.
  if not target and lastGoal and (lastGoal-nest.position).Magnitude>1 then
   steps={}; ticket+=1; computing=false; nextPath=0; lastGoal=nil
  end
  local step=steps[stepIndex]
  if step and (root.Position-step.Position).Magnitude<2.5 then stepIndex+=1; step=steps[stepIndex] end
  if target and nearest<=Rules.BiteRange then h:MoveTo(root.Position)
  elseif step and inZone(step.Position+Vector3.new(0,1,0),nest.club) then h:MoveTo(step.Position)
  else h:MoveTo(root.Position) end
 end
 ticket+=1
 model:Destroy()
end
local function create(folder: Folder,index: number,nest): boolean
 local description=Instance.new("HumanoidDescription")
 local ok,result=pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15) end)
 description:Destroy()
 if not ok then warn("[Spiders] Avatar creation unavailable; retrying"); return false end
 local model=result :: Model
 local h=model:FindFirstChildOfClass("Humanoid"); local root=model:FindFirstChild("HumanoidRootPart")
 if not h or not root or not root:IsA("BasePart") then model:Destroy(); return false end
 model.Name=(if nest.club then "ClubhouseSpider" else "AtticSpider")..index; model:ScaleTo(.45)
 h.WalkSpeed=12; h.UseJumpPower=false; h.JumpHeight=0; h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 h.AutomaticScalingEnabled=false
 ModelBuilder.dress(model,h,root)
 model:PivotTo(CFrame.new(nest.position+Vector3.new(0,2,0)))
 model.Parent=folder; root:SetNetworkOwner(nil)
 run(model,h,root,nest)
 return true
end
function Service.start()
 local folder=Instance.new("Folder"); folder.Name="HouseSpiders"; folder.Parent=workspace
 Players.PlayerRemoving:Connect(function(p) visits[p]=nil end)
 task.spawn(function()
  while folder.Parent do
   local now=os.clock()
   for _,p in Players:GetPlayers() do
    local root=Forage.bugRoot(p); local warning=""
    if root and Refuge.containsPosition(root.Position) then
     local visit=visits[p]
     if not visit or visit.character~=root.Parent then visit={character=root.Parent,entered=now}; visits[p]=visit end
     local elapsed=now-visit.entered
     warning=if Rules.spiderAwake(elapsed) then "SPIDERS AWAKE! Leave the clubhouse!"
      else "Deliver and go! Spiders wake in "..math.max(0,math.ceil(Rules.RefugeGrace-elapsed)).."s"
    else
     visits[p]=nil
     if root and inZone(root.Position,false) then warning="Attic spiders patrol here. Keep moving!" end
    end
    if p:GetAttribute("SpiderWarning")~=warning then p:SetAttribute("SpiderWarning",warning) end
   end
   task.wait(.1)
  end
 end)
 for index,nest in nests do
  task.spawn(function()
   while folder.Parent do
    create(folder,index,nest)
    task.wait(5)
   end
  end)
 end
end
return Service
