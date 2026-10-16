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
    local choice=ReplicatedStorage:WaitForChild("ChooseTeam") :: RemoteEvent
    local buttons: {TextButton}={}
    local status=text("CHOOSE YOUR TEAM",UDim2.fromScale(.1,.57),UDim2.fromScale(.8,.055),Color3.fromRGB(255,237,206))
    local selected=false
    for i,entry in {
        {"StinkBugs","STINK BUG • Collect, climb & escape",Color3.fromRGB(72,173,32)},
        {"Vacuums","VACUUM • Hunt & suck up bugs",Color3.fromRGB(35,111,209)},
    } do
        local button=Instance.new("TextButton")
        button.Name=entry[1]; button.Position=UDim2.fromScale(.1,.64+(i-1)*.14)
        button.Size=UDim2.fromScale(.8,.12); button.BackgroundColor3=entry[3]
        button.Text=entry[2]; button.TextColor3=Color3.new(1,1,1); button.Font=Enum.Font.GothamBold
        button.TextScaled=true; button.TextWrapped=true; button.Modal=true; button.Selectable=true; button.Parent=background
        local limit=Instance.new("UITextSizeConstraint"); limit.MaxTextSize=28; limit.MinTextSize=12; limit.Parent=button
        local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(.15,0); corner.Parent=button
        table.insert(buttons,button)
        button.Activated:Connect(function()
            if selected then return end
            selected=true; status.Text="Joining your team..."
            for _,b in buttons do b.Active=false; b.AutoButtonColor=false end
            choice:FireServer(entry[1])
        end)
    end
    text("Choose a side. AI opponents fill solo play.",UDim2.fromScale(.08,.94),UDim2.fromScale(.84,.035),Color3.fromRGB(220,213,198))
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
    local function refresh()
        if closed then return end
        if player:GetAttribute("TeamChosen") then
            selected=true
            status.Text=player:GetAttribute("SpawnStatus") or "Joining..."
            if player:GetAttribute("SpawnStatus")=="Ready" and player.Character then close() end
        end
    end
    local connection=player:GetAttributeChangedSignal("SpawnStatus"):Connect(refresh)
    local teamConnection=player:GetAttributeChangedSignal("TeamChosen"):Connect(refresh)
    local characterConnection=player.CharacterAdded:Connect(function() task.defer(refresh) end)
    gui.Destroying:Connect(function() connection:Disconnect(); teamConnection:Disconnect(); characterConnection:Disconnect() end)
    refresh()
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
