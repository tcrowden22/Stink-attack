--!strict
local Players = game:GetService("Players")
local Hud = {}

function Hud.start()
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "PrototypeHUD"
    gui.ResetOnSpawn = false
    gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    local panel = Instance.new("TextLabel")
    panel.Name = "Status"
    panel.AnchorPoint = Vector2.new(0.5, 0)
    panel.Position = UDim2.new(0.5, 0, 0, 8)
    panel.Size = UDim2.new(0.92, 0, 0, 100)
    panel.BackgroundColor3 = Color3.fromRGB(28, 37, 39)
    panel.BackgroundTransparency = 0.08
    panel.TextColor3 = Color3.fromRGB(246, 240, 216)
    panel.Font = Enum.Font.GothamMedium
    panel.TextSize = 15
    panel.TextWrapped = true
    panel.Parent = gui
    local limit = Instance.new("UISizeConstraint")
    limit.MaxSize = Vector2.new(520, 100)
    limit.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = panel
    gui.Parent = player:WaitForChild("PlayerGui")

    local function refresh()
        local teamName = if player.Team then player.Team.Name else "Assigning team"
        local count = #Players:GetPlayers()
        local status = player:GetAttribute("SpawnStatus") or "Loading"
        if player:GetAttribute("InBugRefuge") then
            status = "BUG CLUBHOUSE • Team refuge"
        end
        panel.Text = string.format(
            "STINK BUGS vs. VACUUMS\nFoundation free play • %s • %d player(s)\n%s\nGreen passages lead to bug shortcuts and the clubhouse.",
            teamName, count, status
        )
    end
    player:GetPropertyChangedSignal("Team"):Connect(refresh)
    player:GetAttributeChangedSignal("SpawnStatus"):Connect(refresh)
    player:GetAttributeChangedSignal("InBugRefuge"):Connect(refresh)
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(function()
        task.defer(refresh)
    end)
    refresh()
end

return Hud
