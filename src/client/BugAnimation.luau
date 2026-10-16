--!strict
-- Every client animates every visible bug; no per-frame network messages.
local CollectionService=game:GetService("CollectionService")
local RunService=game:GetService("RunService")
local Gait=require(game:GetService("ReplicatedStorage").Shared.BugGait)
local Animation={}
function Animation.start()
    local motors: {[Motor6D]: number}={}
    local function added(item: Instance)
        if item:IsA("Motor6D") then motors[item]=0 end
    end
    for _,item in CollectionService:GetTagged("AnimatedBugLeg") do added(item) end
    CollectionService:GetInstanceAddedSignal("AnimatedBugLeg"):Connect(added)
    CollectionService:GetInstanceRemovedSignal("AnimatedBugLeg"):Connect(function(item) motors[item :: Motor6D]=nil end)
    RunService.PreSimulation:Connect(function(dt)
        for motor,phase in motors do
            local root=motor.Part0
            if not root or not root.Parent or not motor.Part1 then continue end
            local humanoid=root.Parent:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end
            local v=root.AssemblyLinearVelocity
            local speed=Vector3.new(v.X,0,v.Z).Magnitude
            local walking=humanoid.Health>0 and humanoid.FloorMaterial~=Enum.Material.Air
            local nextPhase,yaw,lift=Gait.step(phase,dt,speed,walking,motor:GetAttribute("Phase") or 0)
            motors[motor]=nextPhase
            local side=motor:GetAttribute("Side") or 1
            motor.Transform=CFrame.Angles(0,yaw,side*lift)
        end
    end)
end
return Animation
