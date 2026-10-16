--!strict
local Players = game:GetService("Players")
local Actions = game:GetService("ContextActionService")
local Input = game:GetService("UserInputService")
local Climb = {}
function Climb.start()
    local player = Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("ClimbRequest") :: RemoteEvent
    local action = "BugClimb"
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
            end, true, Enum.KeyCode.C, Enum.KeyCode.ButtonX)
            Actions:SetPosition(action, UDim2.new(1, -235, 1, -180))
        elseif not eligible and bound then
            bound = false
            Actions:UnbindAction(action)
        end
        if bound then Actions:SetTitle(action, if player:GetAttribute("BugClimbing") then "Let go" else "Climb") end
    end
    player:GetPropertyChangedSignal("Team"):Connect(refresh)
    player:GetAttributeChangedSignal("BugClimbing"):Connect(refresh)
    gui.ChildAdded:Connect(refresh); gui.ChildRemoved:Connect(refresh)
    refresh()
end
return Climb
