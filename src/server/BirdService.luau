--!strict
local Players=game:GetService("Players")
local Rules=require(game:GetService("ReplicatedStorage").Shared.BirdRules)
local Forage=require(script.Parent.ForageService)
local Builder=require(script.Parent.BirdModel)
local Birds={}
local centers={Vector3.new(-15,84,0),Vector3.new(65,86,36),Vector3.new(100,84,85)}
type Bird={model: Model,root: BasePart,center: Vector3,index: number,mode: string,untilTime: number,
 target: Player?,character: Instance?,began: number}
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
   target=nil,character=nil,began=0})
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
  b.mode="Recover"; b.untilTime=now+Rules.Cooldown; b.target=nil; b.character=nil
 end
 local function move(b: Bird,goal: Vector3,dt: number,ray: RaycastParams): boolean
  goal=Vector3.new(math.clamp(goal.X,-46,142),math.clamp(goal.Y,65.5,95),math.clamp(goal.Z,-34,106))
  local delta=goal-b.root.Position
  if delta.Magnitude<.01 then return true end
  local step=delta.Unit*Rules.travel(delta.Magnitude,dt)
  if workspace:Spherecast(b.root.Position,1.3,step,ray) then return false end
  local p=b.root.Position+step
  local up=if math.abs(delta.Unit.Y)>.95 then Vector3.zAxis else Vector3.yAxis
  b.root.CFrame=CFrame.lookAt(p,p+delta.Unit,up)
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
    if not b.model.Parent then continue end
    local target=if b.target then Forage.bugRoot(b.target) else nil
    if b.target and (not target or target.Parent~=b.character or not exposed(target,ray)
     or not clear(b.root.Position,target.Position,ray)
     or (target.Position-b.root.Position).Magnitude>Rules.DetectRange) then
     recover(b,now); target=nil
    end
    if b.mode=="Patrol" and now>=b.untilTime then
     local nearest=Rules.DetectRange
     for _,p in Players:GetPlayers() do
      local r=Forage.bugRoot(p)
      if not r then continue end
      local distance=(r.Position-b.root.Position).Magnitude
      if Rules.canTarget(true,roof(r),exposed(r,ray) and clear(b.root.Position,r.Position,ray),distance) and distance<nearest then
       nearest=distance; target=r; b.target=p; b.character=r.Parent
      end
     end
     if target then b.mode="Warning"; b.began=now; b.untilTime=now+Rules.WarningSeconds end
    end
    if b.mode=="Warning" and target then
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
       Forage.eliminate(b.target,"A rooftop bird gobbled you! Returning home...")
       recover(b,now)
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
 end)
end
return Birds
