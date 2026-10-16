--!strict
local Rules={BotCount=3,BotRespawn=8,Range=18,Facing=.55,Windup=.7,CaptureRange=4,PullSpeed=14,Cooldown=1.5,MaxBurst=4,InputTimeout=.7}
function Rules.validTeam(name: any): boolean
    return name=="StinkBugs" or name=="Vacuums"
end
function Rules.canChoose(name: any,chosen: boolean): boolean
    return not chosen and Rules.validTeam(name)
end
function Rules.aiNeeded(bugs: number,vacuums: number): boolean
    return vacuums>0 and bugs==0
end
function Rules.canSuck(distance: number,facing: number,clear: boolean,protected: boolean): boolean
    return distance>=0 and distance<=Rules.Range and facing>=Rules.Facing and clear and not protected
end
function Rules.canMaintain(distance: number,facing: number,clear: boolean,protected: boolean,locked: boolean): boolean
    return Rules.canSuck(distance,facing,clear,protected)
        or (locked and distance>=0 and distance<=Rules.CaptureRange and clear and not protected)
end
function Rules.canCapture(distance: number,elapsed: number): boolean
    return distance>=0 and distance<=Rules.CaptureRange and elapsed>=Rules.Windup
end
return table.freeze(Rules)
