"""Round-trip the authored character FBX; no Roblox engine claims."""
from pathlib import Path
import json
import shutil
import tempfile
import bpy
root=Path(__file__).resolve().parents[1]/"assets"/"characters"
manifest=json.loads((root/"manifest.json").read_text(encoding="utf-8"))
with tempfile.TemporaryDirectory(prefix="stink-bug-check-") as temporary:
    temp=Path(temporary)
    for name in ("StinkBug.fbx","StinkBugPalette.png"):
        shutil.copy2(root/name,temp/name)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.fbx(filepath=str(temp/"StinkBug.fbx"))
    meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
    if len(meshes)!=1 or meshes[0].name!="StinkBug": raise RuntimeError("Unexpected mesh names")
    bug=meshes[0]; bug.data.calc_loop_triangles()
    if len(bug.data.loop_triangles)!=manifest["triangles"]: raise RuntimeError("Triangle mismatch")
    if not bug.data.uv_layers.active: raise RuntimeError("Missing UVs")
    if any(abs(a-b)>.001 for a,b in zip(bug.dimensions,manifest["dimensions"])): raise RuntimeError("Bounds changed")
    images=[n.image for m in bug.data.materials if m and m.use_nodes for n in m.node_tree.nodes if n.type=="TEX_IMAGE" and n.image]
    if not images or not all(i.has_data for i in images): raise RuntimeError("Missing texture")
    print("PASS StinkBug: name, triangle count, UVs, dimensions and texture round-trip")
