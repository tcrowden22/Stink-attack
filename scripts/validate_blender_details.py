"""Verify the exported kit can be re-imported by Blender with names, UVs and texture data."""
from pathlib import Path
import json
import shutil
import tempfile
import bpy

def check(condition, message):
    if not condition:
        raise RuntimeError(str(message))

root = Path(__file__).resolve().parents[1]
folder = root / "assets" / "blender"
manifest = json.loads((folder / "manifest.json").read_text(encoding="utf-8"))
with tempfile.TemporaryDirectory(prefix="stink-house-fbx-") as temporary:
    temp = Path(temporary)
    shutil.copy2(folder / "HouseDetailKit.fbx", temp / "HouseDetailKit.fbx")
    shutil.copy2(folder / "HousePalette.png", temp / "HousePalette.png")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.fbx(filepath=str(temp / "HouseDetailKit.fbx"))
    meshes = {obj.name: obj for obj in bpy.context.scene.objects if obj.type == "MESH"}
    check(set(meshes) == {entry["name"] for entry in manifest}, sorted(meshes))
    for entry in manifest:
        obj = meshes[entry["name"]]
        obj.data.calc_loop_triangles()
        triangles = len(obj.data.loop_triangles)
        check(triangles == entry["triangles"], (obj.name, triangles, entry["triangles"]))
        check(obj.data.uv_layers.active is not None, obj.name)
        check(all(value > 0 for value in obj.dimensions), obj.name)
        images = []
        for material in obj.data.materials:
            if material and material.use_nodes:
                images.extend(node.image for node in material.node_tree.nodes
                              if node.type == "TEX_IMAGE" and node.image)
        check(images and all(image.has_data for image in images), obj.name)
        print(f"PASS {obj.name}: {triangles} triangles, UVs, texture, positive bounds")
print("PASS: FBX round-trip. Roblox Studio import still requires separate verification.")
