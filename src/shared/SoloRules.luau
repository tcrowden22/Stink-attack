--!strict
local Rules={Capacity=5,PickupRange=6,ItemRespawn=20,DetectRange=45,SuctionRange=9,Windup=1.2,Cooldown=4}
function Rules.canCollect(carried: number, distance: number, visible: boolean, available: boolean): boolean
    return available and visible and distance>=0 and distance<=Rules.PickupRange and carried<Rules.Capacity
end
function Rules.canSuction(distance: number, facing: number, visible: boolean, protected: boolean, alive: boolean): boolean
    return alive and not protected and visible and distance>=0 and distance<=Rules.SuctionRange and facing>=.55
end
function Rules.charge(elapsed: number, dt: number, valid: boolean): number
    return if valid then math.min(Rules.Windup,elapsed+math.clamp(dt,0,.25)) else 0
end
return table.freeze(Rules)
