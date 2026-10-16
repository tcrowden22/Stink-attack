--!strict
local Rules = {Reach = 2, Speed = 5, MaxNormalY = .3, GripSeconds = 4, RecoverRate = 2, RestDelay = .75, InputTimeout = .35}
function Rules.canClimb(distance: number, normalY: number, anchored: boolean, solid: boolean): boolean
    return distance >= 0 and distance <= Rules.Reach and math.abs(normalY) <= Rules.MaxNormalY and anchored and solid
end
function Rules.canAutoStart(grip: number,approach: number,sinceStop: number): boolean
    return grip>=.5 and approach>.65 and sinceStop>=Rules.RestDelay
end
function Rules.validAxis(value: any): boolean
    return typeof(value) == "number" and value == value and math.abs(value) <= 1.05
end
function Rules.grip(remaining: number, dt: number, active: boolean, resting: boolean): number
    if active then return math.max(0, remaining - dt) end
    if resting then return math.min(Rules.GripSeconds, remaining + dt * Rules.RecoverRate) end
    return remaining
end
return table.freeze(Rules)
