--!strict
local Players=game:GetService("Players")
local Actions=game:GetService("ContextActionService")
local Input=game:GetService("UserInputService")
local Controller={}
function Controller.start()
    local player=Players.LocalPlayer; local gui=player:WaitForChild("PlayerGui")
    local remote=game:GetService("ReplicatedStorage"):WaitForChild("VacuumInput") :: RemoteEvent
    local bound=false; local held=false; local sources: {[string]: boolean}={}
    local function release()
        table.clear(sources)
        if held then held=false; remote:FireServer(false) end
    end
    local function refresh()
        local eligible=player.Team~=nil and player.Team.Name=="Vacuums" and not gui:FindFirstChild("Welcome")
        if eligible and not bound then
            bound=true
            Actions:BindAction("PlayerSuction",function(_,state,input)
                local key=tostring(input.KeyCode)..tostring(input.UserInputType)
                if state==Enum.UserInputState.Begin and not Input:GetFocusedTextBox() then sources[key]=true
                elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then sources[key]=nil end
                held=next(sources)~=nil; remote:FireServer(held)
                return Enum.ContextActionResult.Sink
            end,true,Enum.UserInputType.MouseButton1,Enum.KeyCode.Q,Enum.KeyCode.ButtonR2)
            Actions:SetTitle("PlayerSuction","Suction")
            Actions:SetPosition("PlayerSuction",UDim2.new(1,-155,1,-180))
        elseif not eligible and bound then
            release(); bound=false; Actions:UnbindAction("PlayerSuction")
        end
    end
    player:GetPropertyChangedSignal("Team"):Connect(refresh)
    gui.ChildAdded:Connect(refresh); gui.ChildRemoved:Connect(refresh)
    player.CharacterRemoving:Connect(release)
    Input.WindowFocusReleased:Connect(release)
    Input.TextBoxFocused:Connect(release)
    refresh()
    task.spawn(function()
        while true do
            task.wait(.25)
            if held then remote:FireServer(true) end
        end
    end)
end
return Controller
