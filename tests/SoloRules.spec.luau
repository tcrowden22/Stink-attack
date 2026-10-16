--!strict
local R=require("../src/shared/SoloRules")
local function check(ok: boolean, message: string) if not ok then error(message) end end
check(R.canCollect(0,6,true,true),"Pickup at boundary")
check(not R.canCollect(5,1,true,true),"Capacity")
check(not R.canCollect(0,6.01,true,true),"Pickup range")
check(not R.canCollect(0,1,false,true),"Pickup through wall")
check(not R.canCollect(0,1,true,false),"Duplicate claim")
check(not R.canCollect(0,0/0,true,true),"Nonfinite distance")
check(R.canSuction(18,.55,true,false,true),"Suction boundary")
check(not R.canSuction(18.01,1,true,false,true),"Suction range")
check(not R.canSuction(2,.54,true,false,true),"Behind nozzle")
check(not R.canSuction(2,1,false,false,true),"Suction through wall")
check(not R.canSuction(2,1,true,true,true),"Refuge protection")
check(not R.canSuction(2,1,true,false,false),"Dead target")
local charge=0
for _=1,4 do charge=R.charge(charge,.15,true) end
check(charge<R.Windup,"No immediate capture")
check(R.charge(charge,.15,false)==0,"Breaking suction resets progress")
charge=R.charge(charge,100,true)
check(charge<=R.Windup,"Frame gaps bounded")
for _=1,10 do charge=R.charge(charge,.15,true) end
check(charge==R.Windup,"Continuous suction eventually captures")
print("PASS solo rules: pickup claims, capacity, cover, cone, refuge and windup")

check(R.canCapture(4,R.Windup),"Capture at nozzle range after warning")
check(not R.canCapture(4.01,R.Windup),"No instant ranged capture")
check(not R.canCapture(2,R.Windup-.01),"No capture before warning")
check(not R.grabExpired(R.Windup+R.GrabDuration-.01),"Grab window")
check(R.grabExpired(R.Windup+R.GrabDuration),"Timed escape from stalled grab")
print("PASS reaching grab: longer reach, warning, close capture and bounded duration")

check(R.canSuction(2,-1,true,false,true,true),"Robot retains already-pulled bug at center")
check(not R.canSuction(2,-1,false,false,true,true),"Robot center capture blocked by walls")
check(not R.canSuction(2,-1,true,true,true,true),"Robot center capture blocked in refuge")
