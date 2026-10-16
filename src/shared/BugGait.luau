--!strict
-- Pure gait math: alternating tripods, stationary legs at idle/in air.
local Gait={}
function Gait.step(phase: number, dt: number, speed: number, grounded: boolean, offset: number): (number, number, number)
    if not grounded or speed<.35 then return phase,0,0 end
    local strength=math.clamp(speed/8,0,1)
    local nextPhase=(phase+math.min(dt,.1)*(6+math.min(speed,20)*.8))%(2*math.pi)
    local angle=nextPhase+offset
    return nextPhase,math.sin(angle)*.3*strength,math.max(0,math.cos(angle))*.25*strength
end
return Gait
