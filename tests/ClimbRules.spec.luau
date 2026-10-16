--!strict
local R = require("../src/shared/ClimbRules")
local function check(ok: boolean, message: string) if not ok then error(message) end end
check(R.canClimb(2,0,true,true), "Wall at reach boundary")
check(R.canClimb(1,.3,true,true), "Near-vertical surface")
check(not R.canClimb(2.01,0,true,true), "Cannot climb from a distance")
check(not R.canClimb(1,1,true,true), "Floors are not walls")
check(not R.canClimb(1,-1,true,true), "No upside-down ceiling climb")
check(not R.canClimb(1,0,false,true), "No climbing players or movable props")
check(not R.canClimb(1,0,true,false), "No climbing invisible decorations")
check(not R.canClimb(0/0,0,true,true), "Reject nonfinite distance")
print("PASS climb rules: wall reach, slope, anchored solid surfaces")
