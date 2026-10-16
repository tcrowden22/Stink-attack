"""Check structural seams, doorway clearance and starting-sofa source alignment."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def parts(node):
    if node.get("ClassName") in ("Part", "WedgePart"):
        yield node
    for child in node.get("Children", []):
        yield from parts(child)

rooms = {path.name.split(".")[0]: json.loads(path.read_text(encoding="utf-8-sig"))
         for path in (ROOT / "map").glob("*.model.json")}
geometry = [p for room in rooms.values() for p in parts(room)]

def occupied(position, bug=False):
    for part in geometry:
        prop = part.get("Properties", {})
        if not prop.get("CanCollide", True) or "Position" not in prop:
            continue
        if bug and part["Name"].startswith("EscapeGate"):
            continue
        if all(abs(position[i] - prop["Position"][i]) < prop["Size"][i] / 2 for i in range(3)):
            return True
    return False

for point in [(50, 6, 0), (0, 6, 38), (62, 6, 38), (50, 6, 84),
              (122, 6, -28), (122, 6, 84), (0, 30, 35), (86, 30, 35)]:
    if occupied(point):
        raise RuntimeError(f"Human doorway blocked at {point}")
for point in [(-50, 1, 16), (-50, 1, 56), (50, 1, -27), (-38, 1, 38)]:
    if occupied(point, bug=True):
        raise RuntimeError(f"Bug passage blocked at {point}")
for point in [(50, 23.5, 0), (0, 23.5, 38), (62, 23.5, 38), (50, 23.5, 84),
              (-29.5, 47.5, 35), (43, 47.5, 35), (108, 47.5, 35),
              (0, 47.5, 35), (86, 47.5, 35)]:
    if not occupied(point):
        raise RuntimeError(f"Fly-over seam still open at {point}")
for part in geometry:
    if "Threshold" in part["Name"] or "Marker" in part["Name"]:
        if part.get("Properties", {}).get("Size", [0, 0, 0])[1] > 1:
            raise RuntimeError(f"Decorative doorway strip stretched: {part['Name']}")
living = {p["Name"]: p["Properties"] for p in parts(rooms["LivingRoom"])}
if living["SofaBack"]["Position"][2] >= living["SofaSeat"]["Position"][2]:
    raise RuntimeError("Starting sofa back must be on the north-wall side")
if 'Name = "LivingSofa"' in (ROOT / "src/server/ArtPlacements.luau").read_text():
    raise RuntimeError("Ambiguous imported sofa overlay still enabled")
print("PASS: human/bug openings, full-height dividers, doorway strips and unobscured starting sofa")
