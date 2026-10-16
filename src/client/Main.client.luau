--!strict
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- Roblox PlayerModule provides desktop movement and mobile thumbstick/jump.
local function onCharacter(character: Model)
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = humanoid
    end
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
    task.spawn(onCharacter, player.Character)
end
require(script.Parent.Hud).start()
require(script.Parent.BugAnimation).start()
require(script.Parent.Welcome).start()
