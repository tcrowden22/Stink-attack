--!strict
local TeamPolicy = {}

function TeamPolicy.vacuumCount(playerCount: number, fraction: number): number
    assert(playerCount >= 0 and playerCount % 1 == 0, "Player count must be a nonnegative integer")
    assert(fraction > 0 and fraction < 1, "Vacuum fraction must be between zero and one")
    if playerCount < 2 then
        return 0
    end
    return math.clamp(math.floor(playerCount * fraction + 0.5), 1, playerCount - 1)
end

-- Stable join assignments for foundation free play; no team switching on departure.
function TeamPolicy.nextTeam(bugs: number, vacuums: number, fraction: number): string
    if bugs == 0 then
        return "StinkBugs"
    end
    if vacuums < TeamPolicy.vacuumCount(bugs + vacuums + 1, fraction) then
        return "Vacuums"
    end
    return "StinkBugs"
end

return table.freeze(TeamPolicy)
