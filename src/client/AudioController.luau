--!strict
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Design=require(game:GetService("ReplicatedStorage").Shared.SoundDesign)
local Audio={}
type Voice={sound: Sound,root: BasePart,kind: string}
type Candidate={model: Model,root: BasePart,kind: string,distance: number,boost: boolean}
local function sound(parent: Instance,name: string,id: string,volume: number,speed: number,range: number,looped: boolean): Sound
 local s=Instance.new("Sound"); s.Name=name; s.SoundId=id
 s.Volume=volume; s.PlaybackSpeed=speed; s.Looped=looped
 s.RollOffMode=Enum.RollOffMode.InverseTapered; s.RollOffMinDistance=5; s.RollOffMaxDistance=range
 s.Parent=parent
 return s
end
local function equalize(s: Sound,low: number,mid: number,high: number)
 local eq=Instance.new("EqualizerSoundEffect"); eq.LowGain=low; eq.MidGain=mid; eq.HighGain=high; eq.Parent=s
end
local function tremolo(s: Sound,frequency: number,depth: number)
 local effect=Instance.new("TremoloSoundEffect"); effect.Frequency=frequency; effect.Depth=depth; effect.Parent=s
end
local function rootOf(model: Model): BasePart?
 local root=model:FindFirstChild("HumanoidRootPart")
 local h=model:FindFirstChildOfClass("Humanoid")
 if not root or not root:IsA("BasePart") or not h or h.Health<=0 then return nil end
 return root
end
function Audio.start()
 local player=Players.LocalPlayer
 local gui=player:WaitForChild("PlayerGui")
 local voices: {[Model]: Voice}={}
 local bursts: {BasePart}={}
 local function listener(): BasePart?
  if gui:FindFirstChild("Welcome") or not player.Character then return nil end
  return rootOf(player.Character)
 end
 local function clear()
  for _,voice in voices do voice.sound:Destroy() end
  table.clear(voices)
  for _,part in bursts do part:Destroy() end
  table.clear(bursts)
 end
 player.CharacterRemoving:Connect(clear)
 local remote=game:GetService("ReplicatedStorage"):WaitForChild("StinkEffect") :: RemoteEvent
 remote.OnClientEvent:Connect(function(origin: CFrame)
  local localRoot=listener()
  if not localRoot or (origin.Position-localRoot.Position).Magnitude>Design.FartRange then return end
  for i=#bursts,1,-1 do if not bursts[i].Parent then table.remove(bursts,i) end end
  if #bursts>=Design.MaxBursts then table.remove(bursts,1):Destroy() end
  local emitter=Instance.new("Part"); emitter.Name="StinkAudio"
  emitter.Size=Vector3.one*.1; emitter.Transparency=1; emitter.Anchored=true
  emitter.CanCollide=false; emitter.CanTouch=false; emitter.CanQuery=false
  emitter.CFrame=origin; emitter.Parent=workspace; table.insert(bursts,emitter)
  -- A low, fluttering raspberry followed by a short airy tail.
  local rasp=sound(emitter,"FartRaspberry",Design.FartAsset,.25,.75,Design.FartRange,false)
  equalize(rasp,8,-10,-35); tremolo(rasp,18,1)
  local distortion=Instance.new("DistortionSoundEffect"); distortion.Level=.35; distortion.Parent=rasp
  local air=sound(emitter,"FartAir",Design.AirAsset,.09,.8,Design.FartRange,false)
  equalize(air,-12,-4,-15)
  rasp:Play(); air:Play()
  Tween:Create(rasp,TweenInfo.new(.85),{PlaybackSpeed=.38,Volume=0}):Play()
  Tween:Create(air,TweenInfo.new(1),{Volume=0}):Play()
  Debris:AddItem(emitter,1.1)
 end)
 task.spawn(function()
  while gui.Parent do
   task.wait(.2)
   local localRoot=listener()
   if not localRoot then clear(); continue end
   local candidates: {Candidate}={}
   local function candidate(model: Model,kind: string,boost: boolean)
    local root=rootOf(model); if not root then return end
    local distance=(root.Position-localRoot.Position).Magnitude
    local range=if kind=="vacuum" then Design.VacuumRange else Design.SpiderRange
    if distance<=range then table.insert(candidates,{model=model,root=root,kind=kind,distance=distance,boost=boost}) end
   end
   local robot=workspace:FindFirstChild("CleanTeamRobot")
   if robot and robot:IsA("Model") then candidate(robot,"vacuum",workspace:GetAttribute("CleanerState")=="Vacuuming") end
   for _,p in Players:GetPlayers() do
    if p.Team and p.Team.Name=="Vacuums" and p.Character then
     candidate(p.Character,"vacuum",p:GetAttribute("VacuumStatus")=="Pulling a stink bug!")
    end
   end
   local spiders=workspace:FindFirstChild("HouseSpiders")
   if spiders then
    for _,model in spiders:GetChildren() do
     if model:IsA("Model") then candidate(model,"spider",model:GetAttribute("SpiderBiting")==true) end
    end
   end
   table.sort(candidates,function(a,b) return a.distance<b.distance end)
   local selected: {[Model]: boolean}={}; local counts={vacuum=0,spider=0}
   for _,entry in candidates do
    local cap=if entry.kind=="vacuum" then Design.MaxVacuums else Design.MaxSpiders
    if counts[entry.kind]>=cap then continue end
    counts[entry.kind]+=1; selected[entry.model]=true
    local voice=voices[entry.model]
    if voice and (voice.root~=entry.root or not voice.sound.Parent) then voice.sound:Destroy(); voice=nil end
    if not voice then
     local vacuum=entry.kind=="vacuum"
     local s=sound(entry.root,if vacuum then "VacuumMotor" else "SpiderScuttle",
      if vacuum then Design.VacuumAsset else Design.SpiderAsset,0,
      if vacuum then .65 else 1.5,if vacuum then Design.VacuumRange else Design.SpiderRange,true)
     if vacuum then
      equalize(s,5,-3,-20)
      local distortion=Instance.new("DistortionSoundEffect"); distortion.Level=.12; distortion.Parent=s
     else equalize(s,-8,2,-8); tremolo(s,5,.75) end
     voice={sound=s,root=entry.root,kind=entry.kind}; voices[entry.model]=voice; s:Play()
    end
    local volume=if entry.kind=="vacuum" then (if entry.boost then .3 else .18) else (if entry.boost then .23 else .12)
    local speed=if entry.kind=="vacuum" then (if entry.boost then .9 else .65) else (if entry.boost then 1.9 else 1.5)
    Tween:Create(voice.sound,TweenInfo.new(.2),{Volume=volume,PlaybackSpeed=speed}):Play()
   end
   for model,voice in voices do
    if not selected[model] then voice.sound:Destroy(); voices[model]=nil end
   end
  end
  clear()
 end)
end
return Audio
