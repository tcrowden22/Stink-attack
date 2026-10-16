--!strict
local Collection=game:GetService("CollectionService")
local Run=game:GetService("RunService")
local Animation={}
function Animation.start()
 local heads: {[Motor6D]: boolean}={}
 local function add(item: Instance)
  if item:IsA("Motor6D") then heads[item]=true end
 end
 for _,item in Collection:GetTagged("AnimatedSpiderHead") do add(item) end
 Collection:GetInstanceAddedSignal("AnimatedSpiderHead"):Connect(add)
 Collection:GetInstanceRemovedSignal("AnimatedSpiderHead"):Connect(function(item) heads[item :: Motor6D]=nil end)
 Run.PreSimulation:Connect(function()
  local t=workspace:GetServerTimeNow()
  for motor in heads do
   local root=motor.Part0
   if root and root.Parent then
    local bite=root.Parent:GetAttribute("SpiderBiting")
    motor.Transform=if bite then CFrame.new(0,0,-.25*(1+math.sin(t*24)))*CFrame.Angles(math.sin(t*24)*.18,0,0) else CFrame.identity
   end
  end
 end)
end
return Animation
