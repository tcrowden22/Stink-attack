--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local MapService = require(script.Parent.MapService)
local CharacterAppearance = require(script.Parent.CharacterAppearance)

local CharacterService = {}
local generations: { [Player]: number } = {}
local busy: { [Player]: boolean } = {}

function CharacterService.remove(player: Player)
    generations[player] = nil
    busy[player] = nil
    if player.Character then
        player.Character:Destroy()
    end
end

function CharacterService.spawn(player: Player)
    if player.Parent ~= Players or busy[player] then
        return
    end
    local team = player.Team
    if not team then
        return
    end
    busy[player] = true
    local generation = (generations[player] or 0) + 1
    generations[player] = generation
    player:SetAttribute("SpawnStatus", "Loading R15 avatar")
    local description = Instance.new("HumanoidDescription")
    local color = Color3.fromRGB(221, 174, 132)
    description.HeadColor = color
    description.TorsoColor = Color3.fromRGB(28, 54, 76)
    description.LeftArmColor = color
    description.RightArmColor = color
    description.LeftLegColor = Color3.fromRGB(44, 65, 83)
    description.RightLegColor = Color3.fromRGB(44, 65, 83)

    -- Explicit R15 rig, without importing personal accessories or external models.
    local ok, result = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
    end)
    description:Destroy()
    if player.Parent ~= Players or generations[player] ~= generation then
        if ok then
            (result :: Model):Destroy()
        end
        return
    end
    if not ok then
        busy[player] = nil
        player:SetAttribute("SpawnStatus", "Avatar load failed; retrying")
        warn("[Characters] Avatar load failed for user", player.UserId, result)
        task.delay(5, function()
            if generations[player] == generation and player.Parent == Players then
                CharacterService.spawn(player)
            end
        end)
        return
    end

    local character = result :: Model
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    assert(humanoid, "R15 avatar has no Humanoid")
    local settings = Config.Teams[team.Name]
    character.Name = player.Name
    character:ScaleTo(settings.Scale)
    humanoid.WalkSpeed = settings.WalkSpeed
    humanoid.UseJumpPower = false
    humanoid.JumpHeight = settings.JumpHeight
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    for _, item in character:GetDescendants() do
        if item:IsA("BasePart") then
            item.CollisionGroup = team.Name
        end
    end
    if player.Character then
        player.Character:Destroy()
    end
    CharacterAppearance.apply(character, team.Name, humanoid)
    character:PivotTo(MapService.spawnCFrame(team.Name, player.UserId))
    character.Parent = workspace
    player.Character = character
    player:SetAttribute("SpawnStatus", "Ready")
    busy[player] = nil
    humanoid.Died:Once(function()
        task.delay(Config.RespawnDelay, function()
            if generations[player] == generation and player.Parent == Players then
                CharacterService.spawn(player)
            end
        end)
    end)
    print("[Characters] R15 ready:", player.Name, team.Name, "scale", character:GetScale())
end

return CharacterService
