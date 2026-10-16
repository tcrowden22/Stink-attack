--!strict
local R = require("../src/shared/FlightRules")
local function check(ok: boolean, message: string)
    if not ok then error(message) end
end
check(R.earn(0) == 1, "First snack earns flight")
check(R.earn(R.MaxCharges) == R.MaxCharges, "Fuel cap")
check(R.canStart(1, 3, 3, false, true), "Ready at boundary")
check(not R.canStart(0, 3, 3, false, true), "No free flight")
check(not R.canStart(1, 2.99, 3, false, true), "Cooldown")
check(not R.canStart(1, 3, 3, true, true), "No overlapping flight")
check(not R.canStart(1, 3, 3, false, false), "Must land before flying again")
check(R.lift(0) == R.Speed, "Takeoff speed")
check(R.lift(R.Rise) == 0 and R.lift(R.Rise + 2) == 0, "Height cap")
check(R.lift(R.Rise - .1) < R.Speed, "Ease into hover")
print("PASS flight rules: snack fuel, capacity, cooldown, grounded launch and limited rise")
