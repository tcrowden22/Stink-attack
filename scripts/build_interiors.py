"""Build deterministic native Roblox furniture and validate placement envelopes."""
from pathlib import Path
import json, math
ROOT=Path(__file__).resolve().parents[1]
MAP=ROOT/"map"
OUT=MAP/"InteriorDetails.model.json"
COLORS={"wood":[.46,.28,.16],"cream":[.88,.81,.65],"teal":[.22,.45,.43],"gold":[.83,.60,.29],
"dark":[.15,.20,.24],"blue":[.30,.49,.64],"pink":[.73,.43,.42],"leaf":[.33,.49,.24],"card":[.63,.43,.26]}
rooms={"LivingRoom":(-45,45,-33,33,0),"Kitchen":(55,117,-33,33,0),"Bedroom":(-45,45,43,105,0),
"Playroom":(55,117,43,105,0),"Upstairs":(-45,116,-33,105,24),"Attic":(-38,111,-30,100,48)}
reserved=[
(-9,9,29,47,0),(41,59,-10,10,0),(54,70,30,46,0),(42,59,75,93,0),
(-58,-41,8,24,0),(-58,-41,48,64,0),(111,130,-37,-18,0),(112,130,74,94,0),
(25,44,-27,-9,0),(10,28,-35,-21,0),(-28,-16,38,71,0),
(-28,-16,38,71,24),(-28,-16,38,71,48),(-10,10,27,43,24),(76,96,27,43,24),
(120,147,-38,110,24),(120,147,-38,110,48)]
def parts(node):
    if node.get("ClassName") in ("Part","WedgePart"):yield node
    for child in node.get("Children",[]):yield from parts(child)
existing=[]
for file in MAP.glob("*.model.json"):
    if file==OUT:continue
    for p in parts(json.loads(file.read_text(encoding="utf-8-sig"))):
        prop=p.get("Properties",{})
        if prop.get("CanCollide",True) and "Position" in prop and "Size" in prop:
            existing.append((prop["Position"],prop["Size"],p.get("Name","")))
def overlaps(a,b):
    return a[0]<b[1] and a[1]>b[0] and a[2]<b[3] and a[3]>b[2]
models=[]; manifest=[]; occupied=[]
def available(x,z,w,d,h,room):
    xmin,xmax,zmin,zmax,y=rooms[room]
    rect=(x-w/2-1.5,x+w/2+1.5,z-d/2-1.5,z+d/2+1.5)
    if rect[0]<xmin or rect[1]>xmax or rect[2]<zmin or rect[3]>zmax:return False
    for a,b,c,e,floor in reserved:
        if y==floor and overlaps(rect,(a,b,c,e)):return False
    for r,floor in occupied:
        if y==floor and overlaps(rect,r):return False
    for pos,size,name in existing:
        if pos[1]+size[1]/2<=y+.3 or pos[1]-size[1]/2>=y+h:continue
        if overlaps(rect,(pos[0]-size[0]/2,pos[0]+size[0]/2,pos[2]-size[2]/2,pos[2]+size[2]/2)):return False
    return True
current=None; origin=None
def part(name,pos,size,color="wood",solid=True,material="SmoothPlastic",shape=None):
    prop={"Anchored":True,"CanCollide":solid,"CanQuery":solid,"CanTouch":False,
          "Position":[round(origin[i]+pos[i],4) for i in range(3)],"Size":size,
          "Color":COLORS[color],"Material":material,"TopSurface":"Smooth","BottomSurface":"Smooth"}
    if shape:prop["Shape"]=shape
    node={"Name":name,"ClassName":"Part","Properties":prop}
    current["Children"].append(node)
    return node
def book(x,y,z,color="blue"):
    part("BookPages",(x,y,z),(2.4,.5,1.8),"cream",False)
    for dy in (-.3,.3):part("BookCover",(x,y+dy,z),(2.55,.1,1.95),color,False)
def chair():
    for x in (-3.3,3.3):
        for z in (-3,3):part("Leg",(x,1.15,z),(.7,2.3,.7),"wood",True,"Wood")
    part("Seat",(0,3,0),(8,1.4,7.5),"teal",True,"Fabric")
    part("Back",(0,5.3,3.5),(8,5.4,1.1),"teal",True,"Fabric")
    for x in (-3.8,3.8):part("Arm",(x,4.1,0),(1.3,3.5,8),"teal",True,"Fabric")
    part("Pillow",(-1.7,4.4,1),(3.3,1.3,3),"gold",False,"Fabric","Ball")
    part("Throw",(1.5,3.76,-.4),(2.3,.12,5),"cream",False,"Fabric")
    for x in (-2.5,0,2.5):part("Button",(x,5.7,2.91),(.18,.18,.08),"cream",False)
def cart():
    for x in (-3.7,3.7):
        for z in (-2.2,2.2):
            part("Frame",(x,3.2,z),(.3,5.5,.3),"dark",True,"Metal")
            part("Wheel",(x,.6,z),(.8,1.1,1.1),"dark",False,shape="Ball")
    for y in (3,5.8):part("Shelf",(0,y,0),(8.4,.45,5.4),"wood",True,"Wood")
    part("Tray",(0,6.15,0),(6,.18,3.8),"cream",False)
    for x in (-1.5,0,1.5):
        part("Fruit",(x,6.65,.3),(.9,.9,.9),"gold",False,shape="Ball")
    book(-1,3.65,0)
    part("Handle",(0,6.4,2.55),(8.3,.3,.3),"dark",False,"Metal")
def hamper():
    part("Base",(0,.3,0),(6,.6,5),"cream")
    for x in (-2.8,2.8):part("Side",(x,2.8,0),(.4,5,5),"cream")
    for z in (-2.3,2.3):part("Side",(0,2.8,z),(6,5,.4),"cream")
    for y in (1,2,3,4):
        for z in (-2.52,2.52):part("Weave",(0,y,z),(5.7,.1,.07),"gold",False)
    for i,c in enumerate(("pink","blue","cream")):
        part("FoldedTowel",(0,5.4+i*.45,0),(5.2,.4,4.1),c,False,"Fabric")
def tunnel():
    for x in (-3,3):part("CardboardSide",(x,1.6,0),(.5,3.2,8),"card")
    part("CardboardRoof",(0,3.4,0),(6.5,.4,8),"card")
    for z in (-3.7,3.7):
        part("Tape",(0,3.62,z),(6.5,.04,.55),"cream",False)
    gate=part("EscapeGateInteriorTunnel",(0,1.5,0),(5.5,3,1),"leaf")
    gate["Properties"]["Transparency"]=1
    for z in (-4.5,4.5):part("BugRouteMarker",(0,.06,z),(3,.08,.5),"leaf",False)
    book(0,3.95,0,"pink")
def suitcase():
    for x,y,z,c in ((0,1.1,0,"teal"),(.7,3.1,.3,"pink")):
        part("Suitcase",(x,y,z),(7,2,4.5),c)
        for dx in (-2.3,2.3):part("Strap",(x+dx,y,z-.0),(.35,2.06,4.55),"cream",False)
        part("Handle",(x,y,z-2.4),(1.7,.4,.3),"dark",False)
def bench():
    for x in (-4,4):
        for z in (-2,2):part("BenchLeg",(x,1.65,z),(.65,3.3,.65),"wood",True,"Wood")
    part("BenchSeat",(0,3.7,0),(10, .8,5.5),"wood",True,"Wood")
    for x,c in ((-2.5,"blue"),(2.5,"pink")):part("Cushion",(x,4.4,0),(4.5,.7,4.8),c,True,"Fabric")
    book(2,5.1,0,"gold")
def fort():
    for x in (-4,4):
        for z in (-3,3):part("FortPost",(x,2,z),(.6,4,.6),"wood")
    part("BlanketRoof",(0,4.2,0),(9,.4,7),"blue",True,"Fabric")
    for x in (-3.1,3.1):part("BlanketBack",(x,2,3.2),(2.8,4,.3),"blue",True,"Fabric")
    for x in (-4.3,4.3):part("BlanketSide",(x,2,0),(.3,4,7),"blue",True,"Fabric")
    part("Pillow",(0,.5,1),(4,.9,3),"gold",False,"Fabric")
    gate=part("EscapeGateBlanketFort",(0,1.9,0),(8,3.8,6.4),"leaf")
    gate["Properties"]["Transparency"]=1
def storage():
    for x,z,h in ((-2.7,0,5),(2.7,1,7)):
        part("StorageBox",(x,h/2,z),(4.8,h,5),"card")
        part("Tape",(x,h+.02,z),(.5,.05,5),"cream",False)
        part("Label",(x,h*.65,z-2.52),(2.6,1.1,.04),"cream",False)
    book(-2.7,5.5,0)
builders={"chair":(chair,10,10,9),"cart":(cart,10,7,8),"hamper":(hamper,7,6,8),
"tunnel":(tunnel,8,11,5),"suitcase":(suitcase,9,6,5),"bench":(bench,11,7,6),
"fort":(fort,11,9,5),"storage":(storage,12,8,9)}
requests=[
("LivingReadingChair","LivingRoom","chair",(-24,14)),("LivingBookBench","LivingRoom","bench",(25,18)),
("KitchenServingCart","Kitchen","cart",(89,14)),("KitchenPantryCart","Kitchen","cart",(104,-14)),
("BedroomLaundry","Bedroom","hamper",(-31,92)),("BedroomLuggage","Bedroom","suitcase",(24,52)),
("BedroomCardboardRun","Bedroom","tunnel",(-29,73)),
("PlayroomBlanketHideout","Playroom","fort",(100,74)),("PlayroomBookBench","Playroom","bench",(64,64)),
("UpstairsReadingChair","Upstairs","chair",(47,-15)),("UpstairsLaundry","Upstairs","hamper",(-36,15)),
("UpstairsSnackCart","Upstairs","cart",(65,60)),("UpstairsLuggage","Upstairs","suitcase",(107,70)),
("AtticStorageCluster","Attic","storage",(55,54)),("AtticCardboardRun","Attic","tunnel",(35,5)),
("AtticLuggage","Attic","suitcase",(92,90))]
for name,room,kind,desired in requests:
    build,w,d,h=builders[kind]; xmin,xmax,zmin,zmax,y=rooms[room]
    candidates=[(x,z) for x in range(math.ceil(xmin),math.floor(xmax),2) for z in range(math.ceil(zmin),math.floor(zmax),2)]
    candidates.sort(key=lambda p:(p[0]-desired[0])**2+(p[1]-desired[1])**2)
    location=next(((x,z) for x,z in candidates if available(x,z,w,d,h,room)),None)
    if location is None:raise RuntimeError("No safe placement for "+name)
    x,z=location; origin=(x,y,z); current={"Name":name,"ClassName":"Model","Children":[]}
    build(); models.append(current)
    occupied.append(((x-w/2,x+w/2,z-d/2,z+d/2),y))
    manifest.append({"name":name,"room":room,"kind":kind,"origin":origin,"envelope":[w,h,d]})
OUT.write_text(json.dumps({"ClassName":"Model","Children":models},indent=2)+"\n",encoding="utf-8")
(ROOT/"map"/"interior-manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
print("PASS:",len(models),"placements outside existing collision geometry and protected routes;",sum(len(m["Children"]) for m in models),"parts")
