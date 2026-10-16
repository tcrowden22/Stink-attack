--!strict
local Rules = {Reach = 2, Speed = 5, MaxNormalY = .3}
function Rules.canClimb(distance: number, normalY: number, anchored: boolean, solid: boolean): boolean
    return distance >= 0 and distance <= Rules.Reach and math.abs(normalY) <= Rules.MaxNormalY and anchored and solid
end
return table.freeze(Rules)
