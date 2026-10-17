--!strict
local Collection=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Animation={}
function Animation.start()
 local wings: {[Motor6D]: boolean}={}
 local function add(item: Instance) if item:IsA("Motor6D") then wings[item]=true end end
 for _,item in Collection:GetTagged("AnimatedBirdWing") do add(item) end
 Collection:GetInstanceAddedSignal("AnimatedBirdWing"):Connect(add)
 Collection:GetInstanceRemovedSignal("AnimatedBirdWing"):Connect(function(item) wings[item :: Motor6D]=nil end)
 Run.PreSimulation:Connect(function()
  local now=workspace:GetServerTimeNow()
  for motor in wings do
   local root=motor.Part0
   if root and root.Parent then
    local diving=root.Parent:GetAttribute("BirdState")=="Diving"
    local phase=now*(if diving then 22 else 13)+(motor:GetAttribute("Phase") or 0)
    motor.Transform=CFrame.Angles(0,0,(motor:GetAttribute("Side") or 1)*math.sin(phase)*(if diving then .3 else .65))
   end
  end
 end)
end
return Animation
