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
        local threat=player:GetAttribute("CleanerThreat") or ""
        local message=player:GetAttribute("ForageMessage") or "Collect glowing snacks."
        local safe=player:GetAttribute("InBugRefuge")
        local status=if threat~="" then threat elseif safe then "HOME • Safe from Clean Team" else message
        panel.Text=string.format(
            "STINK BUGS vs. VACUUMS • %s\nCarrying %d/5  •  Delivered %d\n%s\nCollect nearby snacks (E / tap). Return home to deliver.",
            teamName,player:GetAttribute("CarriedSnacks") or 0,player:GetAttribute("BankedSnacks") or 0,status
        )
    end
    player:GetPropertyChangedSignal("Team"):Connect(refresh)
    player:GetAttributeChangedSignal("SpawnStatus"):Connect(refresh)
    player:GetAttributeChangedSignal("InBugRefuge"):Connect(refresh)
    for _,name in {"CarriedSnacks","BankedSnacks","ForageMessage","CleanerThreat"} do
        player:GetAttributeChangedSignal(name):Connect(refresh)
    end
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(function()
        task.defer(refresh)
    end)
    refresh()
end

return Hud
