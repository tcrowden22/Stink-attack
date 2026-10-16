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
        if player.Team and player.Team.Name=="Vacuums" then
            panel.Text=string.format("CLEAN TEAM • VACUUM\nBugs caught: %d • AI bugs roaming: %d\n%s\nFace a bug • Hold click / Q / Suction",
                player:GetAttribute("BugsCaught") or 0,workspace:GetAttribute("AIBugsRemaining") or 0,
                if player.Character and (player.Character:GetAttribute("StinkSlowedUntil") or 0)>workspace:GetServerTimeNow() then "STINKED! Movement slowed for a few seconds." else player:GetAttribute("VacuumStatus") or "Find the stink bugs hiding around the house.")
            return
        end
        local threat=player:GetAttribute("CleanerThreat") or ""
        local message=player:GetAttribute("ForageMessage") or "Collect glowing snacks."
        local safe=player:GetAttribute("InBugRefuge")
        local spider=player:GetAttribute("SpiderWarning") or ""
        local status=if spider~="" then spider elseif threat~="" then threat elseif safe then "HOME • Deliver and leave before spiders wake!" else message
        local readyAt=player:GetAttribute("FlightReadyAt") or 0
        local remaining=math.max(0,math.ceil(readyAt-workspace:GetServerTimeNow()))
        local flightHint=if player:GetAttribute("FlightActive") then "Flying! Steer normally."
            elseif remaining>0 then "Flight recharging: "..remaining.."s"
            elseif player:GetAttribute("BugClimbing") then string.format("Grip %.1fs • Move to climb • C: drop",player:GetAttribute("ClimbGrip") or 0)
            else "Walk into walls: climb • C: drop • F: fly • R: stink"
        panel.Text=string.format(
            "STINK BUGS vs. VACUUMS • %s\nCarrying %d/5  •  Delivered %d  •  Flights %d/3\n%s\nE / tap: collect • %s",
            teamName,player:GetAttribute("CarriedSnacks") or 0,player:GetAttribute("BankedSnacks") or 0,
            player:GetAttribute("FlightCharges") or 0,status,flightHint
        )
    end
    player:GetPropertyChangedSignal("Team"):Connect(refresh)
    player:GetAttributeChangedSignal("SpawnStatus"):Connect(refresh)
    player:GetAttributeChangedSignal("InBugRefuge"):Connect(refresh)
    for _,name in {"CarriedSnacks","BankedSnacks","ForageMessage","CleanerThreat","FlightCharges"} do
        player:GetAttributeChangedSignal(name):Connect(refresh)
    end
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(function()
        task.defer(refresh)
    end)
    refresh()
    task.spawn(function()
        while gui.Parent do
            task.wait(.2)
            refresh()
        end
    end)
end

return Hud
