"""Conservative human-height grid check against existing and added static parts."""
from pathlib import Path
from collections import deque
import json
ROOT=Path(__file__).resolve().parents[1]
def parts(n):
    if n.get("ClassName") in ("Part","WedgePart"):yield n
    for c in n.get("Children",[]):yield from parts(c)
base=[]; added=[]
for file in (ROOT/"map").glob("*.model.json"):
    target=added if file.name=="InteriorDetails.model.json" else base
    target.extend(parts(json.loads(file.read_text(encoding="utf-8-sig"))))
manifest=json.loads((ROOT/"map"/"interior-manifest.json").read_text())
def blocked(parts,y):
    rects=[]
    for p in parts:
        q=p.get("Properties",{})
        if not q.get("CanCollide",True) or "Position" not in q:continue
        x,py,z=q["Position"]; sx,sy,sz=q["Size"]
        if py+sy/2<=y+.3 or py-sy/2>=y+5.5:continue
        rects.append((x-sx/2-1.2,x+sx/2+1.2,z-sz/2-1.2,z+sz/2+1.2))
    return rects
def free(rects):
    return {(x,z) for x in range(-46,120,2) for z in range(-34,108,2)
            if not any(a<x<b and c<z<d for a,b,c,d in rects)}
def flood(cells,seed):
    visited={seed}; queue=deque([seed])
    while queue:
        x,z=queue.popleft()
        for p in ((x+2,z),(x-2,z),(x,z+2),(x,z-2)):
            if p in cells and p not in visited:visited.add(p); queue.append(p)
    return visited
def components(cells):
    remaining=set(cells); result=[]
    while remaining:
        component=flood(remaining,next(iter(remaining)))
        remaining-=component; result.append(component)
    return result
for y in (0,24,48):
    before=free(blocked(base,y)); after=free(blocked(base+added,y))
    # Ignore intended interiors of new furniture; check existing external routes.
    for m in manifest:
        x,floor,z=m["origin"]; w,h,d=m["envelope"]
        if floor==y:
            after={p for p in after if not (abs(p[0]-x)<w/2 and abs(p[1]-z)<d/2)}
    for component in components(before):
        survivors=component&after
        if len(survivors)<20:continue
        reached=flood(after,next(iter(survivors)))
        if not survivors<=reached:
            raise RuntimeError(f"New furniture splits an existing route on floor {y}: {len(survivors-reached)} cells")
    print("PASS human route connectivity on floor",y)
for p in added:
    q=p["Properties"]
    if not q.get("Anchored"):raise RuntimeError("Unanchored furniture")
    if min(q["Size"])<=0:raise RuntimeError("Invalid part size")
    if q["CanCollide"]!=q["CanQuery"]:raise RuntimeError("Cover query/collision mismatch")
gates=[p for p in added if p["Name"].startswith("EscapeGate")]
if len(gates)!=3:raise RuntimeError("Expected three bug-only entrances")
print("PASS anchored geometry, solid cover queries and three escape gates")
