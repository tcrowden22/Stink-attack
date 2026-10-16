--!strict
local Players = game:GetService("Players")
local Actions = game:GetService("ContextActionService")
local Input = game:GetService("UserInputService")
local Flight = {}
function Flight.start()
    local player = Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("FlightRequest") :: RemoteEvent
    local action = "SnackFlight"
    local bound = false
    local function refresh()
        local eligible = player.Team ~= nil and player.Team.Name == "StinkBugs" and not gui:FindFirstChild("Welcome")
        if eligible and not bound then
            bound = true
            Actions:BindAction(action, function(_, state)
                if state == Enum.UserInputState.Begin and not Input:GetFocusedTextBox() and not gui:FindFirstChild("Welcome") then
                    remote:FireServer()
                end
                return Enum.ContextActionResult.Sink
            end, true, Enum.KeyCode.F, Enum.KeyCode.ButtonY)
            Actions:SetPosition(action, UDim2.new(1, -155, 1, -180))
        elseif not eligible and bound then
            Actions:UnbindAction(action)
            bound = false
        end
        if bound then Actions:SetTitle(action, "Fly (" .. tostring(player:GetAttribute("FlightCharges") or 0) .. ")") end
    end
    player:GetPropertyChangedSignal("Team"):Connect(refresh)
    player:GetAttributeChangedSignal("FlightCharges"):Connect(refresh)
    gui.ChildAdded:Connect(refresh)
    gui.ChildRemoved:Connect(refresh)
    refresh()
end
return Flight
