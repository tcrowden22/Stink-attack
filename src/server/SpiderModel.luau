--!strict
local Geometry=require(game:GetService("ReplicatedStorage").Shared.SpiderGeometry)
local Collection=game:GetService("CollectionService")
local Spider={}
function Spider.dress(model: Model,h: Humanoid,root: BasePart)
 for _,part in model:GetDescendants() do
  if part:IsA("BasePart") then part.Transparency=1; part.CollisionGroup="StinkBugs"
  elseif part:IsA("Decal") then part.Transparency=1 end
 end
 local floor=root.CFrame*CFrame.new(0,-h.HipHeight-root.Size.Y/2,0)
 local visual=Instance.new("Model"); visual.Name="ConnectedSpider"; visual.Parent=model
 local limbs: {[number]: BasePart}={}
 local head: BasePart?=nil
 for _,shape in Geometry do
  local p=Instance.new("Part"); p.Name=shape.name
  p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Massless=true
  p.Color=shape.color; p.Material=Enum.Material.SmoothPlastic
  if shape.kind=="ball" then
   p.Shape=Enum.PartType.Ball; p.Size=shape.size; p.CFrame=floor*CFrame.new(shape.center)
  else
   local delta=shape.b-shape.a
   p.Shape=Enum.PartType.Cylinder; p.Size=Vector3.new(delta.Magnitude,shape.width,shape.width)
   p.CFrame=floor*CFrame.lookAt((shape.a+shape.b)/2,shape.b)*CFrame.Angles(0,math.pi/2,0)
  end
  p.Parent=visual
  if shape.name=="GreenHead" then
   head=p
   local joint=Instance.new("Motor6D"); joint.Name="SpiderBite"; joint.Part0=root; joint.Part1=p
   joint.C0=root.CFrame:ToObjectSpace(p.CFrame); joint.Parent=root
   Collection:AddTag(joint,"AnimatedSpiderHead")
  elseif shape.leg>0 and not limbs[shape.leg] then
   limbs[shape.leg]=p
   local hinge=floor*CFrame.new(shape.a)
   local joint=Instance.new("Motor6D"); joint.Name="SpiderLeg"..shape.leg
   joint.Part0=root; joint.Part1=p; joint.C0=root.CFrame:ToObjectSpace(hinge); joint.C1=p.CFrame:ToObjectSpace(hinge)
   joint:SetAttribute("Side",if shape.leg<=4 then -1 else 1)
   joint:SetAttribute("Phase",if shape.leg%2==0 then math.pi else 0)
   joint.Parent=root; Collection:AddTag(joint,"AnimatedBugLeg")
  else
   local target=limbs[shape.leg] or (if head and (string.find(shape.name,"Eye") or string.find(shape.name,"Pupil") or string.find(shape.name,"Fang")) then head else root)
   local weld=Instance.new("Weld"); weld.Name="FixedSpiderJoint"
   weld.Part0=target; weld.Part1=p
   weld.C0=target.CFrame:ToObjectSpace(p.CFrame); weld.C1=CFrame.identity; weld.Parent=p
  end
 end
end
return Spider
