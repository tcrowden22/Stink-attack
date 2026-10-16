--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContextActionService=game:GetService("ContextActionService")
local GuiService=game:GetService("GuiService")
local Menu={}
function Menu.start()
    local player=Players.LocalPlayer
    local gui=Instance.new("ScreenGui")
    gui.Name="Welcome"; gui.ResetOnSpawn=false; gui.DisplayOrder=20
    gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
    local background=Instance.new("Frame")
    background.Size=UDim2.fromScale(1,1); background.BackgroundColor3=Color3.fromRGB(30,25,23); background.Parent=gui
    local view=Instance.new("ViewportFrame")
    view.Size=UDim2.fromScale(1,1); view.BackgroundTransparency=1
    view.Ambient=Color3.fromRGB(170,151,124); view.LightColor=Color3.fromRGB(255,230,187)
    view.LightDirection=Vector3.new(-1,-1,-1); view.Parent=background
    local camera=Instance.new("Camera")
    camera.CFrame=CFrame.lookAt(Vector3.new(6,5,-12),Vector3.new(0,1.5,0))
    camera.FieldOfView=48; camera.Parent=view; view.CurrentCamera=camera
    local function text(value: string, pos: UDim2, size: UDim2, color: Color3): TextLabel
        local label=Instance.new("TextLabel")
        label.Text=value; label.Position=pos; label.Size=size; label.BackgroundTransparency=1
        label.Font=Enum.Font.GothamBlack; label.TextScaled=true; label.TextWrapped=true
        label.TextColor3=color; label.TextStrokeTransparency=.15; label.Parent=background
        local limit=Instance.new("UITextSizeConstraint"); limit.MaxTextSize=66; limit.MinTextSize=12; limit.Parent=label
        return label
    end
    text("STINK BUGS",UDim2.fromScale(.05,.04),UDim2.fromScale(.9,.12),Color3.fromRGB(155,243,49))
    text("vs. VACUUMS",UDim2.fromScale(.05,.16),UDim2.fromScale(.9,.1),Color3.fromRGB(161,219,255))
    text("SMALL BUGS. BIG CHAOS!",UDim2.fromScale(.08,.28),UDim2.fromScale(.84,.045),Color3.fromRGB(255,224,166))
    local play=Instance.new("TextButton")
    play.Name="Play"; play.AnchorPoint=Vector2.new(.5,.5)
    play.Position=UDim2.fromScale(.5,.8); play.Size=UDim2.fromScale(.65,.115)
    play.BackgroundColor3=Color3.fromRGB(72,213,32); play.Text="▶  PLAY"
    play.TextColor3=Color3.new(1,1,1); play.Font=Enum.Font.GothamBlack; play.TextScaled=true
    play.TextStrokeTransparency=.25; play.Modal=true; play.Selectable=true; play.Parent=background
    local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(520,95); max.Parent=play
    local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(.18,0); corner.Parent=play
    local stroke=Instance.new("UIStroke"); stroke.Thickness=4; stroke.Color=Color3.fromRGB(24,103,23); stroke.Parent=play
    text("BUG ROUTES  •  CLEAN TEAM  •  TEAM REFUGE  •  EXPLORE",UDim2.fromScale(.04,.89),UDim2.fromScale(.92,.04),Color3.fromRGB(255,237,206))
    text("House exploration prototype",UDim2.fromScale(.1,.95),UDim2.fromScale(.8,.025),Color3.fromRGB(220,213,198))
    gui.Parent=player:WaitForChild("PlayerGui")
    local oldTouch=GuiService.TouchControlsEnabled
    GuiService.TouchControlsEnabled=false
    ContextActionService:BindActionAtPriority("WelcomeMovement",function() return Enum.ContextActionResult.Sink end,false,3000,table.unpack(Enum.PlayerActions:GetEnumItems()))
    local closed=false
    local function close()
        if closed then return end
        closed=true
        ContextActionService:UnbindAction("WelcomeMovement")
        GuiService.TouchControlsEnabled=oldTouch
        gui:Destroy()
    end
    play.Activated:Connect(close)
    gui.Destroying:Connect(function()
        if not closed then
            closed=true
            ContextActionService:UnbindAction("WelcomeMovement")
            GuiService.TouchControlsEnabled=oldTouch
        end
    end)
    task.spawn(function()
        local preview=ReplicatedStorage:WaitForChild("ReferencePreview",10)
        if closed or not preview then return end
        local world=Instance.new("WorldModel"); world.Parent=view
        preview:Clone().Parent=world
    end)
end
return Menu
