"""Regression checks for bathroom fit and closed stair entrances."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(name): return json.loads((ROOT/name).read_text(encoding="utf-8-sig"))
def parts(node):
    if node.get("ClassName") in ("Part","WedgePart"): yield node
    for child in node.get("Children",[]): yield from parts(child)
def contains(q,p):
    return all(abs(q["Position"][i]-p[i])<q["Size"][i]/2 for i in range(3))
existing=[]
for path in (ROOT/"map").glob("*.model.json"):
    if path.name=="Bathrooms.model.json": continue
    for n in parts(json.loads(path.read_text(encoding="utf-8-sig"))):
        q=n.get("Properties",{})
        if q.get("CanCollide",True) and "Position" in q: existing.append((n["Name"],q))
bath=read("map/Bathrooms.model.json")
manifest=read("map/bathrooms-manifest.json")
if len(bath["Children"])!=3: raise RuntimeError("Expected bathroom on each interior floor")
for model,entry in zip(bath["Children"],manifest):
    x,y,z=entry["center"]
    names={p["Name"] for p in parts(model)}
    if not {"ToiletBowl","Vanity","Mirror","ShowerTray","HangingTowel","BathroomSign"}<=names:
        raise RuntimeError("Missing bathroom fixtures")
    for name,q in existing:
        px,py,pz=q["Position"]; sx,sy,sz=q["Size"]
        if py+sy/2<=y+.3 or py-sy/2>=y+12: continue
        if abs(px-x)<sx/2+10.3 and abs(pz-z)<sz/2+10.3:
            raise RuntimeError(f"{entry['name']} overlaps existing {name}")
    solids=[q for _,q in existing]+[p["Properties"] for p in parts(model) if p["Properties"]["CanCollide"]]
    for dz in (8,10,12):
        for dx in (-1.2,0,1.2):
            for dy in (1,3,5):
                if any(contains(q,(x+dx,y+dy,z+dz)) for q in solids):
                    raise RuntimeError("Bathroom doorway/approach blocked")
    print("PASS bathroom fixtures, fit and doorway:",entry["name"])
stairs={p["Name"]:p["Properties"] for p in read("map/Stairwell.model.json")["Children"]}
for floor in (0,24,48):
    first=stairs[f"Flight{floor}Tread1"]; entry=stairs[f"EntryLanding{floor}"]
    if entry["Position"][2]+entry["Size"][2]/2<first["Position"][2]-first["Size"][2]/2:
        raise RuntimeError("Open gap before first stair")
    if abs(entry["Position"][1]+entry["Size"][1]/2-floor)>.001:
        raise RuntimeError("Stair entrance not flush with floor")
    for step in range(1,(32 if floor==48 else 48)+1):
        q=stairs[f"Flight{floor}Tread{step}"]
        if abs(q["Size"][1]-.5)>.001:
            raise RuntimeError("Tall stair covering returned")
        if q["Material"]!="WoodPlanks" or q["Color"]!=[.56,.37,.22]:
            raise RuntimeError("Alternating white/brown stair covering returned")
        if abs(q["Position"][1]+q["Size"][1]/2-(floor+step*.5))>.001:
            raise RuntimeError("Stair rise changed")
for floor in (0,24):
    first=stairs[f"BookClimb{floor}Book1"]; entry=stairs[f"BookEntryLanding{floor}"]
    if entry["Position"][2]+entry["Size"][2]/2<first["Position"][2]-first["Size"][2]/2:
        raise RuntimeError("Open gap before book stair")
print("PASS all stair entrance seams and unchanged half-stud rises")

for floor in (0,24):
    ramp=stairs[f"BookWalkRamp{floor}"]
    if not ramp["CanCollide"] or ramp["Orientation"]!=[-45,0,0]:
        raise RuntimeError("Book stair needs continuous walkable collision ramp")
    steps=[q for name,q in stairs.items() if name.startswith(f"BookClimb{floor}Book")]
    if len(steps)!=48 or any(q["CanCollide"] or q["Size"][1]!=.5 for q in steps):
        raise RuntimeError("Tall jumping steps returned")
for model in bath["Children"]:
    names={p["Name"] for p in parts(model)}
    if not {"ToiletSeat","ToiletLid","ToiletFoot"}<=names or "SeatSide" in names or "SeatEnd" in names:
        raise RuntimeError("Disconnected toilet seat returned")
print("PASS continuous wooden stair surfaces and connected closed toilet seats")
