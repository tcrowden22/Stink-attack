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
 local heads: {[Motor6D]: boolean}={}
 local function addHead(item: Instance) if item:IsA("Motor6D") then heads[item]=true end end
 for _,item in Collection:GetTagged("AnimatedBirdHead") do addHead(item) end
 Collection:GetInstanceAddedSignal("AnimatedBirdHead"):Connect(addHead)
 Collection:GetInstanceRemovedSignal("AnimatedBirdHead"):Connect(function(item) heads[item :: Motor6D]=nil end)
 Run.PreSimulation:Connect(function()
  local now=workspace:GetServerTimeNow()
  for motor in heads do
   local root=motor.Part0
   if root and root.Parent then
    local age=now-(root.Parent:GetAttribute("PeckAt") or -10)
    local amount=if age>=0 and age<.3 then math.sin(age/.3*math.pi) else 0
    motor.Transform=CFrame.new(0,-.12*amount,-.12*amount)*CFrame.Angles(.25*amount,0,0)
   end
  end
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
