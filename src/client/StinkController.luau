--!strict
local Players=game:GetService("Players")
local Actions=game:GetService("ContextActionService")
local Input=game:GetService("UserInputService")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Controller={}
function Controller.start()
 local player=Players.LocalPlayer
 local gui=player:WaitForChild("PlayerGui")
 local replicated=game:GetService("ReplicatedStorage")
 local request=replicated:WaitForChild("StinkRequest") :: RemoteEvent
 local effect=replicated:WaitForChild("StinkEffect") :: RemoteEvent
 local bound=false
 effect.OnClientEvent:Connect(function(origin: CFrame)
  for i=1,8 do
   local puff=Instance.new("Part"); puff.Name="StinkPuff"; puff.Shape=Enum.PartType.Ball
   puff.Anchored=true; puff.CanCollide=false; puff.CanTouch=false; puff.CanQuery=false
   puff.Material=Enum.Material.Neon; puff.Color=if i%2==0 then Color3.fromRGB(133,211,37) else Color3.fromRGB(70,143,38)
   puff.Transparency=.32; puff.Size=Vector3.one*.5
   puff.CFrame=origin*CFrame.new(0,-.3,1)
   puff.Parent=workspace
   local destination=origin:PointToWorldSpace(Vector3.new(math.sin(i*2.4)*3,1+i*.2,2+i*.35))
   Tween:Create(puff,TweenInfo.new(1.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=destination,Size=Vector3.one*(2+i*.25),Transparency=1}):Play()
   Debris:AddItem(puff,1.5)
  end
 end)
 task.spawn(function()
  while gui.Parent do
   local eligible=player.Team~=nil and player.Team.Name=="StinkBugs" and not gui:FindFirstChild("Welcome")
   if eligible and not bound then
    bound=true
    Actions:BindAction("StinkBurst",function(_,state)
     if state==Enum.UserInputState.Begin and not Input:GetFocusedTextBox() and not gui:FindFirstChild("Welcome") then request:FireServer() end
     return Enum.ContextActionResult.Sink
    end,true,Enum.KeyCode.R,Enum.KeyCode.ButtonB)
    Actions:SetPosition("StinkBurst",UDim2.new(1,-235,1,-265))
   elseif not eligible and bound then Actions:UnbindAction("StinkBurst"); bound=false end
   if bound then
    local left=math.max(0,math.ceil((player:GetAttribute("StinkReadyAt") or 0)-workspace:GetServerTimeNow()))
    Actions:SetTitle("StinkBurst",if player:GetAttribute("BirdCarried") then "Stink! DROP" elseif left>0 then "Stink "..left.."s" else "Stink!")
   end
   task.wait(.2)
  end
 end)
end
return Controller
