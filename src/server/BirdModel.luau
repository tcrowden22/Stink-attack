--!strict
local Geometry=require(game:GetService("ReplicatedStorage").Shared.BirdGeometry)
local Collection=game:GetService("CollectionService")
local Bird={}
function Bird.create(index: number): (Model,BasePart)
 local model=Instance.new("Model"); model.Name="RooftopBird"..index
 local root=Instance.new("Part"); root.Name="BirdRoot"; root.Size=Vector3.one*.2
 root.Anchored=true; root.Transparency=1; root.CanCollide=false; root.CanTouch=false; root.CanQuery=false
 root.Parent=model; model.PrimaryPart=root
 local frame=CFrame.new(0,-1.5,0)
 local wings: {[number]: BasePart}={}
 local head: BasePart?=nil
 for _,shape in Geometry do
  local p=Instance.new("Part"); p.Name=shape.name; p.Massless=true
  p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Color=shape.color
  p.Material=Enum.Material.SmoothPlastic
  if shape.kind=="ball" then
   p.Shape=Enum.PartType.Ball; p.Size=shape.size; p.CFrame=frame*CFrame.new(shape.center)
  else
   p.Shape=Enum.PartType.Cylinder; p.Size=Vector3.new((shape.b-shape.a).Magnitude,shape.width,shape.width)
   p.CFrame=frame*CFrame.lookAt((shape.a+shape.b)/2,shape.b)*CFrame.Angles(0,math.pi/2,0)
  end
  p.Parent=model
  if shape.name=="Head" then
   head=p
   local motor=Instance.new("Motor6D"); motor.Name="BirdPeckHead"; motor.Part0=root; motor.Part1=p
   motor.C0=root.CFrame:ToObjectSpace(p.CFrame); motor.Parent=root
   Collection:AddTag(motor,"AnimatedBirdHead")
  elseif shape.leg>0 and not wings[shape.leg] then
   wings[shape.leg]=p
   local hinge=frame*CFrame.new(if shape.leg==1 then -.85 else .85,1.65,.1)
   local motor=Instance.new("Motor6D"); motor.Name="BirdWing"..shape.leg
   motor.Part0=root; motor.Part1=p; motor.C0=root.CFrame:ToObjectSpace(hinge); motor.C1=p.CFrame:ToObjectSpace(hinge)
   motor:SetAttribute("Side",if shape.leg==1 then -1 else 1); motor:SetAttribute("Phase",index*.8)
   motor.Parent=root; Collection:AddTag(motor,"AnimatedBirdWing")
  else
   local face=string.find(shape.name,"Beak") or string.find(shape.name,"Eye") or string.find(shape.name,"Pupil") or shape.name=="Crest"
   local target=wings[shape.leg] or (if face and head then head else root)
   local weld=Instance.new("Weld"); weld.Part0=target; weld.Part1=p
   weld.C0=target.CFrame:ToObjectSpace(p.CFrame); weld.Parent=p
  end
 end
 local beak=Instance.new("Attachment"); beak.Name="BitePoint"; beak.Position=Vector3.new(0,.55,-2.4); beak.Parent=root
 return model,root
end
return Bird
