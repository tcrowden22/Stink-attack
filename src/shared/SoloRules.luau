--!strict
local Rules={Capacity=5,PickupRange=6,ItemRespawn=20,DetectRange=45,SuctionRange=18,Windup=.8,Cooldown=4,PullSpeed=16,GrabDuration=3,CaptureRange=4}
function Rules.canCollect(carried: number, distance: number, visible: boolean, available: boolean): boolean
    return available and visible and distance>=0 and distance<=Rules.PickupRange and carried<Rules.Capacity
end
function Rules.canSuction(distance: number, facing: number, visible: boolean, protected: boolean, alive: boolean, locked: boolean?): boolean
    return alive and not protected and visible and distance>=0 and distance<=Rules.SuctionRange and (facing>=.55 or (locked==true and distance<=Rules.CaptureRange))
end
function Rules.canCapture(distance: number, elapsed: number): boolean
    return distance>=0 and distance<=Rules.CaptureRange and elapsed>=Rules.Windup
end
function Rules.grabExpired(elapsed: number): boolean
    return elapsed>=Rules.Windup+Rules.GrabDuration
end
function Rules.charge(elapsed: number, dt: number, valid: boolean): number
    return if valid then math.min(Rules.Windup,elapsed+math.clamp(dt,0,.25)) else 0
end
return table.freeze(Rules)
