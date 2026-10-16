--!strict
local Gait=require("../src/shared/BugGait")
local function check(ok: boolean, message: string)
    if not ok then error(message) end
end
local phase,yaw,lift=Gait.step(1,.016,0,true,0)
check(phase==1 and yaw==0 and lift==0,"Idle must hold neutral pose")
phase,yaw,lift=Gait.step(1,.016,10,false,0)
check(phase==1 and yaw==0 and lift==0,"Airborne must not walk")
local _,left,up=Gait.step(0,.016,10,true,0)
local _,right,down=Gait.step(0,.016,10,true,math.pi)
check(math.abs(left+right)<1e-6,"Tripods must swing in opposite directions")
check(up>0 and down==0,"Only one tripod lifts at this phase")
local p1=Gait.step(0,10,10,true,0)
local p2=Gait.step(0,.1,10,true,0)
check(p1==p2,"Large frame gaps must clamp")
for speed=0,100 do
    for i=1,120 do
        phase,yaw,lift=Gait.step((i/10)%(2*math.pi),1/60,speed,true,0)
        check(phase>=0 and phase<2*math.pi,"Phase must stay bounded")
        check(math.abs(yaw)<=.3 and lift>=0 and lift<=.25,"Joint angles must stay bounded")
    end
end
print("PASS bug gait: idle, air, opposite tripods, frame gaps, bounded angles")
