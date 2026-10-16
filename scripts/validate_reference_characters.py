"""Verify both reference FBXs, including independently movable bug leg meshes."""
from pathlib import Path
import json, shutil, tempfile
import bpy
root=Path(__file__).resolve().parents[1]/"assets"/"characters"/"reference"
manifest=json.loads((root/"manifest.json").read_text(encoding="utf-8"))
with tempfile.TemporaryDirectory(prefix="reference-fbx-") as temporary:
    temp=Path(temporary)
    shutil.copy2(root/"ReferencePalette.png",temp/"ReferencePalette.png")
    for entry in manifest:
        shutil.copy2(root/entry["file"],temp/entry["file"])
        bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.delete(use_global=False)
        bpy.ops.import_scene.fbx(filepath=str(temp/entry["file"]))
        meshes={o.name:o for o in bpy.context.scene.objects if o.type=="MESH"}
        if set(meshes)!={e["name"] for e in entry["meshes"]}:raise RuntimeError("Missing named meshes")
        for expected in entry["meshes"]:
            o=meshes[expected["name"]]; o.data.calc_loop_triangles()
            if len(o.data.loop_triangles)!=expected["triangles"]:raise RuntimeError("Triangle mismatch")
            if not o.data.uv_layers.active or min(o.dimensions)<=0:raise RuntimeError("Invalid geometry/UV")
            images=[n.image for m in o.data.materials if m and m.use_nodes for n in m.node_tree.nodes if n.type=="TEX_IMAGE" and n.image]
            if not images or not all(i.has_data for i in images):raise RuntimeError("Missing palette")
        if entry["file"]=="StinkBugV2.fbx" and len(meshes)!=7:raise RuntimeError("Body and six separate legs required")
        print("PASS",entry["file"],"named meshes, independent geometry, triangles, UV and texture")
