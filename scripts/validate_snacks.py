"""Find static source obstacles overlapping the configured snack positions."""
from pathlib import Path
import json,re
root=Path(__file__).resolve().parents[1]
source=(root/"src/server/ForageService.luau").read_text()
block=source.split("local positions={",1)[1].split("}",1)[0]
positions=[tuple(map(float,m)) for m in re.findall(r"Vector3.new\(([-\d.]+),([-\d.]+),([-\d.]+)\)",block)]
def walk(n):
    if n.get("ClassName")=="Part":yield n
    for c in n.get("Children",[]):yield from walk(c)
obstacles=[]
for f in (root/"map").glob("*.model.json"):
    for n in walk(json.loads(f.read_text(encoding="utf-8-sig"))):
        q=n.get("Properties",{})
        if q.get("CanCollide",True) and "Position" in q:obstacles.append((n["Name"],q))
bad=[]
for i,p in enumerate(positions,1):
    for name,q in obstacles:
        if all(abs(p[j]-q["Position"][j])<q["Size"][j]/2+.5 for j in range(3)):
            bad.append((i,p,name))
if bad:raise RuntimeError("Snack overlap: "+str(bad))
print("PASS",len(positions),"snack positions outside static solid geometry")
