--!strict
local Players=game:GetService("Players")
local Replicated=game:GetService("ReplicatedStorage")
local Rules=require(Replicated.Shared.DangerRules)
local Forage=require(script.Parent.ForageService)
local BirdRules=require(Replicated.Shared.BirdRules)
local Service={}
local cooldowns: {[Player]: number}={}
local slowed: {[Humanoid]: {speed: number,expires: number}}={}
function Service.start()
 local request=Instance.new("RemoteEvent"); request.Name="StinkRequest"; request.Parent=Replicated
 local effect=Instance.new("RemoteEvent"); effect.Name="StinkEffect"; effect.Parent=Replicated
 request.OnServerEvent:Connect(function(player)
  local now=workspace:GetServerTimeNow()
  local escape=BirdRules.canEscape(player:GetAttribute("BirdCarried")==true,player:GetAttribute("BirdEscapeRequested")==true)
  if not escape and not Rules.canStink(true,now,cooldowns[player] or 0) then return end
  local root=Forage.bugRoot(player); if not root then return end
  if escape then player:SetAttribute("BirdEscapeRequested",true) end
  cooldowns[player]=now+Rules.StinkCooldown
  player:SetAttribute("StinkReadyAt",cooldowns[player])
  effect:FireAllClients(root.CFrame)
  local targets: {Model}={}
  for _,p in Players:GetPlayers() do
   if p.Team and p.Team.Name=="Vacuums" and p.Character then table.insert(targets,p.Character) end
  end
  local robot=workspace:FindFirstChild("CleanTeamRobot")
  if robot and robot:IsA("Model") then table.insert(targets,robot) end
  for _,model in targets do
   local h=model:FindFirstChildOfClass("Humanoid"); local r=model:FindFirstChild("HumanoidRootPart")
   if not h or h.Health<=0 or not r or not r:IsA("BasePart") then continue end
   local delta=r.Position-root.Position
   if delta.Magnitude>Rules.StinkRange then continue end
   local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
   params.FilterDescendantsInstances={root.Parent,model}; params.RespectCanCollide=true
   if not Rules.canSlow(delta.Magnitude,workspace:Raycast(root.Position,delta,params)==nil) then continue end
   local state=slowed[h] or {speed=h.WalkSpeed,expires=0}
   state.expires=now+Rules.SlowDuration; slowed[h]=state
   h.WalkSpeed=state.speed*Rules.SlowMultiplier
   model:SetAttribute("StinkSlowedUntil",state.expires)
  end
 end)
 Players.PlayerRemoving:Connect(function(p) cooldowns[p]=nil end)
 task.spawn(function()
  while true do
   task.wait(.1)
   local now=workspace:GetServerTimeNow()
   for h,state in slowed do
    if not h.Parent or h.Health<=0 or now>=state.expires then
     if h.Parent then h.WalkSpeed=state.speed; h.Parent:SetAttribute("StinkSlowedUntil",0) end
     slowed[h]=nil
    end
   end
  end
 end)
end
return Service
