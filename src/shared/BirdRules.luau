--!strict
local Rules={DetectRange=65,WarningSeconds=1.1,DiveSeconds=4,Cooldown=4,Speed=25,BiteRange=2.4,PeckDamage=20,PeckCooldown=2,CarrySeconds=5}
function Rules.onRoof(x: number,y: number,z: number): boolean
 return x>=-49 and x<=145 and z>=-37 and z<=109 and y>=64.35 and y<=100
end
function Rules.canTarget(aliveBug: boolean,onRoof: boolean,clear: boolean,distance: number): boolean
 return aliveBug and onRoof and clear and distance>=0 and distance<=Rules.DetectRange
end
function Rules.canBite(onRoof: boolean,clear: boolean,distance: number,elapsed: number): boolean
 return onRoof and clear and distance>=0 and distance<=Rules.BiteRange and elapsed>=Rules.WarningSeconds
end
function Rules.canPeck(now: number,last: number): boolean
 return now-last>=Rules.PeckCooldown
end
function Rules.canEscape(carried: boolean,requested: boolean): boolean
 return carried and not requested
end
function Rules.travel(distance: number,dt: number): number
 return math.min(math.max(0,distance),Rules.Speed*math.clamp(dt,0,.1))
end
return table.freeze(Rules)
