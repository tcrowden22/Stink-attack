--!strict
local Rules={StinkRange=12,StinkCooldown=12,SlowDuration=4,SlowMultiplier=.45,RefugeGrace=5,BiteRange=3,BiteWindup=.4}
function Rules.canStink(alive: boolean,now: number,ready: number): boolean
 return alive and now>=ready
end
function Rules.canSlow(distance: number,clear: boolean): boolean
 return distance>=0 and distance<=Rules.StinkRange and clear
end
function Rules.spiderAwake(elapsed: number): boolean
 return elapsed>Rules.RefugeGrace
end
function Rules.canBite(distance: number,clear: boolean,elapsed: number): boolean
 return distance>=0 and distance<=Rules.BiteRange and clear and elapsed>=Rules.BiteWindup
end
return table.freeze(Rules)
