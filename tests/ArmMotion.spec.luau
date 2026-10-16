--!strict
local M=require("../src/shared/ArmMotion")
local function check(ok: boolean,message: string) if not ok then error(message) end end
check(M.extension(0,.8)==0 and M.extension(.2,.8)==0,"Raise before reaching")
check(M.extension(.8,.8)==1,"Reach by end of warning")
local previous=0
for i=0,100 do
    local value=M.extension(i/100,.8)
    check(value>=previous and value<=1,"Monotonic bounded extension")
    previous=value
end
check(M.coordinate(2,8,4,10,0)==2 and M.coordinate(2,8,4,10,1)==10,"Hose endpoints remain attached")
check(M.ease(-1)==0 and M.ease(2)==1,"Clamp time boundaries")
print("PASS arm motion: raised start, eased reach, anchored endpoints")
