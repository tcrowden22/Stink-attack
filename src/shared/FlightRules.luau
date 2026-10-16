--!strict
local Rules = {MaxCharges = 3, Duration = 1.8, Rise = 6, Speed = 7, Cooldown = 3}
function Rules.earn(charges: number): number
    return math.min(Rules.MaxCharges, charges + 1)
end
function Rules.canStart(charges: number, now: number, readyAt: number, active: boolean, grounded: boolean): boolean
    return charges > 0 and now >= readyAt and not active and grounded
end
function Rules.lift(height: number): number
    return math.clamp((Rules.Rise - height) * 5, 0, Rules.Speed)
end
return table.freeze(Rules)
