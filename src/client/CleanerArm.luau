--!strict
-- Smooth local visuals follow server target state; capture and forces stay on the server.
local RunService=game:GetService("RunService")
local Shared=game:GetService("ReplicatedStorage").Shared
local Motion=require(Shared.ArmMotion)
local Rules=require(Shared.SoloRules)
local Arm={}
local function part(parent: Model,name: string,size: Vector3,color: Color3): Part
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Color=color
    p.Material=Enum.Material.SmoothPlastic; p.Anchored=true
    p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.CastShadow=true; p.Parent=parent
    return p
end
local function curve(a: Vector3,b: Vector3,c: Vector3,d: Vector3,t: number): Vector3
    return Vector3.new(Motion.coordinate(a.X,b.X,c.X,d.X,t),
        Motion.coordinate(a.Y,b.Y,c.Y,d.Y,t),Motion.coordinate(a.Z,b.Z,c.Z,d.Z,t))
end
function Arm.start()
    local current: Model?=nil; local visual: Model?=nil
    local segments: {Part}={}; local nozzle: Part?=nil; local glow: Part?=nil
    local tip: Vector3?=nil; local previousBase: Vector3?=nil
    RunService.RenderStepped:Connect(function(dt)
        local candidate=workspace:FindFirstChild("CleanTeamRobot")
        local robot=if candidate and candidate:IsA("Model") then candidate else nil
        if current~=robot then
            if visual then visual:Destroy() end
            current=robot; visual=nil; nozzle=nil; glow=nil; tip=nil; previousBase=nil; table.clear(segments)
        end
        if not robot then return end
        local root=robot:FindFirstChild("HumanoidRootPart")
        local socket=root and root:FindFirstChild("TopHoseSocket")
        local rest=root and root:FindFirstChild("TopHoseRest")
        if not root or not root:IsA("BasePart") or not socket or not socket:IsA("Attachment")
            or not rest or not rest:IsA("Attachment") then return end
        if not visual then
            visual=Instance.new("Model"); visual.Name="AnimatedTopHose"; visual.Parent=robot
            for i=1,24 do
                local p=part(visual,"HoseRib",Vector3.new(.55,.55,1),
                    if i%2==0 then Color3.fromRGB(27,35,49) else Color3.fromRGB(58,70,86))
                table.insert(segments,p)
            end
            nozzle=part(visual,"GrabNozzle",Vector3.new(1.35,.8,1.1),Color3.fromRGB(32,72,145))
            glow=part(visual,"NozzleRim",Vector3.new(1.5,.9,.15),Color3.fromRGB(65,220,255))
            glow.Material=Enum.Material.Neon
        end
        local targetValue=robot:FindFirstChild("GrabTarget")
        local character=if targetValue and targetValue:IsA("ObjectValue") then targetValue.Value else nil
        local target=character and character:FindFirstChild("HumanoidRootPart")
        local base=socket.WorldPosition
        local restTip=rest.WorldPosition
        local goal=restTip
        local extending=false
        if target and target:IsA("BasePart") then
            local elapsed=workspace:GetServerTimeNow()-(robot:GetAttribute("GrabStartedAt") or 0)
            local raised=restTip+Vector3.new(0,2.2,0)
            local raise=Motion.ease(elapsed/(Rules.Windup*.3))
            local reach=Motion.extension(elapsed,Rules.Windup)
            local toward=target.Position-base
            local endPoint=if toward.Magnitude>.1 then target.Position-toward.Unit*.6 else target.Position
            goal=restTip:Lerp(raised,raise):Lerp(endPoint,reach)
            extending=true
        end
        if not tip or (previousBase and (base-previousBase).Magnitude>12) then tip=restTip end
        tip=tip:Lerp(goal,1-math.exp(-dt*16))
        previousBase=base
        -- The first curve tangent always rises from the top socket, never from the robot's waist.
        local bend=math.clamp((tip-base).Magnitude*.22,1.8,4)
        local control1=base+Vector3.new(0,bend,0)
        local control2=tip+Vector3.new(0,if extending then 1 else 1.5,0)
        for i,p in segments do
            local a=curve(base,control1,control2,tip,(i-1)/#segments)
            local b=curve(base,control1,control2,tip,i/#segments)
            local length=(b-a).Magnitude
            p.Size=Vector3.new(.55,.55,math.max(.03,length+.08))
            if length>.001 then p.CFrame=CFrame.lookAt((a+b)/2,b) end
        end
        if nozzle and glow then
            local aim=if target and target:IsA("BasePart") then target.Position else tip-Vector3.yAxis
            if (aim-tip).Magnitude<.01 then aim=tip-root.CFrame.LookVector end
            nozzle.CFrame=CFrame.lookAt(tip,aim)
            glow.CFrame=nozzle.CFrame*CFrame.new(0,0,-.58)
        end
    end)
end
return Arm
