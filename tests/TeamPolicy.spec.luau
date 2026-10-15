--!strict
local policy = require("../src/shared/TeamPolicy")
local config = require("../src/shared/Config")
assert(policy.vacuumCount(2, config.VacuumFraction) == 1)
assert(policy.vacuumCount(10, config.VacuumFraction) == 2)
assert(policy.vacuumCount(20, config.VacuumFraction) == 4)
assert(policy.vacuumCount(30, config.VacuumFraction) == 6)
assert(policy.vacuumCount(0, 1 / 3) == 0)
assert(policy.vacuumCount(1, 1 / 3) == 0)
assert(policy.vacuumCount(2, 1 / 3) == 1)
assert(policy.vacuumCount(6, 1 / 3) == 2)
assert(policy.vacuumCount(8, 0.5) == 4)
for _, ratio in { 0.01, 1 / 3, 0.5, 0.99 } do
    for total = 2, 100 do
        local count = policy.vacuumCount(total, ratio)
        assert(count >= 1 and count < total)
    end
end
local bugs, vacuums = 0, 0
for total = 1, 32 do
    local team = policy.nextTeam(bugs, vacuums, config.VacuumFraction)
    if team == "StinkBugs" then bugs += 1 else vacuums += 1 end
    assert(vacuums == policy.vacuumCount(total, config.VacuumFraction))
end
assert(policy.nextTeam(0, 4, 1 / 3) == "StinkBugs")
assert(policy.nextTeam(4, 0, 1 / 3) == "Vacuums")
assert(not pcall(policy.vacuumCount, 2, 0))
assert(not pcall(policy.vacuumCount, 2, 1))
assert(not pcall(policy.vacuumCount, -1, 0.5))
print("PASS: team policy, two-player minimum split, ratios, departures, invalid configuration")
