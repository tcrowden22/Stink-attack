"""Add three furnished bathrooms and close stair-entry seams deterministically."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(path): return json.loads(path.read_text(encoding="utf-8-sig"))
def part(name,pos,size,color,solid=True,material="SmoothPlastic",shape=None):
    props=dict(Anchored=True,CanCollide=solid,CanQuery=solid,CanTouch=False,
        Position=pos,Size=size,Color=color,Material=material,TopSurface="Smooth",BottomSurface="Smooth")
    if shape: props["Shape"]=shape
    return dict(Name=name,ClassName="Part",Properties=props)
white=[.91,.94,.91]; teal=[.22,.52,.52]; dark=[.16,.22,.25]; chrome=[.65,.72,.75]
bathrooms=[]; manifest=[]
for name,x,y,z,height in [("GroundBathroom",0,0,60,24),("UpstairsBathroom",-32,24,90,24),("AtticBathroom",-32,48,24,16)]:
    children=[]
    def add(n,pos,size,color=white,solid=True,material="SmoothPlastic",shape=None):
        p=part(n,[x+pos[0],y+pos[1],z+pos[2]],size,color,solid,material,shape)
        children.append(p); return p
    for dx in range(-9,10,2):
        for dz in range(-9,10,2):
            add("Tile", [dx,.035,dz],[1.96,.06,1.96],white if (dx+dz)%4==0 else [.65,.80,.78],False)
    for dx in (-10,10): add("SideWall",[dx,height/2,0],[.5,height,20],white)
    add("BackWall",[0,height/2,-10],[20,height,.5],white)
    for dx in (-7,7): add("DoorSide",[dx,height/2,10],[6,height,.5],white)
    add("DoorHeader",[0,(height+9)/2,10],[8,height-9,.5],white)
    for dx in (-9.7,9.7): add("TileBorder",[dx,2.4,0],[.12,4.8,19.4],teal,False)
    add("BackTileBorder",[0,2.4,-9.7],[19.4,4.8,.12],teal,False)
    for dx in (-4.15,4.15): add("DoorTrim",[dx,4.5,10.3],[.3,9,.25],teal,False)
    add("DoorTrimTop",[0,9.1,10.3],[8.6,.3,.25],teal,False)
    sign=add("BathroomSign",[0,10.4,10.35],[7,1.6,.15],teal,False)
    # Shower enclosure with a wide open front.
    add("ShowerTray",[-5.5,.2,-5.5],[7,.4,7],white)
    add("ShowerDrain",[-5.5,.42,-5.5],[.7,.04,.7],chrome,False,"Metal")
    glass=add("ShowerGlass",[-1.9,4,-5.5],[.15,7.6,7],[.65,.86,.88],True,"Glass")
    glass["Properties"]["Transparency"]=.55
    add("ShowerPipe",[-5.5,5.5,-9.3],[.18,6,.18],chrome,False,"Metal")
    add("ShowerArm",[-5.5,8.4,-8.6],[.18,.18,1.5],chrome,False,"Metal")
    add("ShowerHead",[-5.5,8.3,-7.9],[1.3,.18,1.1],chrome,False,"Metal")
    add("ShowerTap",[-5.5,4,-9.1],[.8,.5,.3],chrome,False,"Metal")
    # Toilet with an inset dark bowl and an open white seat.
    add("ToiletBase",[5,1,-5.5],[2,2,2.5],white,True,shape="Ball")
    add("ToiletBowl",[5,2,-5.5],[3.4,1.6,4.2],white,True,shape="Ball")
    add("BowlOpening",[5,2.77,-5.4],[2.1,.08,2.6],[.24,.47,.52],False,shape="Ball")
    for dx in (-1.35,1.35): add("SeatSide",[5+dx,2.85,-5.5],[.45,.22,3.3],white,False,shape="Ball")
    for dz in (-1.5,1.5): add("SeatEnd",[5,2.85,-5.5+dz],[2.8,.22,.5],white,False,shape="Ball")
    add("ToiletTank",[5,3.1,-8],[3.2,3,1.3],white)
    add("TankLid",[5,4.68,-8],[3.4,.2,1.5],white,False)
    add("FlushButton",[5.8,4.82,-8],[.45,.08,.3],chrome,False,"Metal")
    # Vanity, mirror, tap, soap and towels.
    add("Vanity",[6.7,2,2],[5,4,4],teal)
    add("Countertop",[6.7,4.15,2],[5.4,.3,4.4],white)
    add("SinkInset",[6.7,4.32,2],[3.2,.06,2.5],[.32,.57,.61],False,shape="Ball")
    add("FaucetStem",[6.7,4.9,.5],[.25,1.2,.25],chrome,False,"Metal")
    add("FaucetSpout",[6.7,5.4,1],[.25,.25,1.2],chrome,False,"Metal")
    add("MirrorFrame",[9.6,7,2],[.18,4.5,5.2],chrome,False,"Metal")
    mirror=add("Mirror",[9.48,7,2],[.07,4.1,4.8],[.66,.83,.9],False,"Glass")
    mirror["Properties"]["Reflectance"]=.3
    add("SoapBottle",[8.5,4.8,2],[.55,1,.55],[.86,.64,.26],False)
    add("SoapPump",[8.5,5.4,2],[.65,.2,.2],dark,False)
    add("TowelRail",[-9.2,5,4],[.25,.25,4],chrome,False,"Metal")
    add("HangingTowel",[-8.95,3.8,4],[.15,2.5,2.6],[.88,.64,.38],False,"Fabric")
    add("BathMat",[0,.09,5],[5,.12,3.5],teal,False,"Fabric")
    for dz in (-.8,.8): add("CabinetHandle",[4.12,2.6,2+dz],[.12,.18,.65],chrome,False,"Metal")
    bathrooms.append({"Name":name,"ClassName":"Model","Children":children})
    manifest.append({"name":name,"center":[x,y,z],"size":[20,height,20],"door":[x,y,z+10]})
(ROOT/"map/Bathrooms.model.json").write_text(json.dumps({"ClassName":"Model","Children":bathrooms},indent=2)+"\n",encoding="utf-8")
(ROOT/"map/bathrooms-manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
project=read(ROOT/"default.project.json")
project["tree"]["Workspace"]["House"]["Bathrooms"]={"$path":"map/Bathrooms.model.json"}
(ROOT/"default.project.json").write_text(json.dumps(project,indent=2)+"\n",encoding="utf-8")
stairs=read(ROOT/"map/Stairwell.model.json")
stairs["Children"]=[p for p in stairs["Children"] if not p["Name"].startswith(("EntryLanding","BookEntryLanding"))]
for p in stairs["Children"]:
    n=p["Name"]; q=p.get("Properties",{})
    if n.startswith("Flight") and "Tread" in n:
        floor=int(n.split("Tread")[0].removeprefix("Flight"))
        step=int(n.split("Tread")[1]); h=step*.5
        q["Size"][1]=h; q["Position"][1]=floor+h/2
for y in (0,24,48):
    stairs["Children"].append(part("EntryLanding"+str(y),[134,y-.5,-23],[14,1,2.2],[.65,.47,.3],True,"WoodPlanks"))
for y in (0,24):
    stairs["Children"].append(part("BookEntryLanding"+str(y),[-22,y-.5,42.65],[12,1,2.5],[.65,.47,.3],True,"WoodPlanks"))
(ROOT/"map/Stairwell.model.json").write_text(json.dumps(stairs,indent=2)+"\n",encoding="utf-8")
print("Built three furnished bathrooms and five stair entry landings.")
