--!strict
local Motion={}
function Motion.ease(t: number): number
    t=math.clamp(t,0,1)
    return t*t*(3-2*t)
end
function Motion.extension(elapsed: number, windup: number): number
    -- First raise the hose, then reach out before suction starts.
    return Motion.ease((elapsed-windup*.3)/(windup*.7))
end
function Motion.coordinate(a: number,b: number,c: number,d: number,t: number): number
    local u=1-t
    return u*u*u*a+3*u*u*t*b+3*u*t*t*c+t*t*t*d
end
return table.freeze(Motion)
