"""Render the native furniture catalogue in Blender; no mesh import is required."""
from pathlib import Path
import json, math
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"assets"/"interiors"; OUT.mkdir(parents=True,exist_ok=True)
data=json.loads((ROOT/"map"/"InteriorDetails.model.json").read_text())
manifest=json.loads((ROOT/"map"/"interior-manifest.json").read_text())
bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.delete(use_global=False)
materials={}
seen=set(); index=0
for model,entry in zip(data["Children"],manifest):
    if entry["kind"] in seen:continue
    seen.add(entry["kind"]); dx=(index%4)*14; dy=(index//4)*15; index+=1
    ox,oy,oz=entry["origin"]
    for p in model["Children"]:
        q=p["Properties"]
        if q.get("Transparency",0)==1:continue
        x,y,z=q["Position"]; sx,sy,sz=q["Size"]
        if q.get("Shape")=="Ball":
            bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=.5)
        else:bpy.ops.mesh.primitive_cube_add(size=1)
        obj=bpy.context.object; obj.name=model["Name"]+"_"+p["Name"]
        obj.location=(x-ox+dx,-(z-oz)+dy,y-oy)
        obj.scale=(sx,sz,sy)
        bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
        key=tuple(q["Color"])
        if key not in materials:
            mat=bpy.data.materials.new("Furniture"); mat.use_nodes=True
            linear=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in key]
            mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value=(*linear,1)
            mat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value=1.02
            materials[key]=mat
        obj.data.materials.append(materials[key])
    bpy.ops.object.text_add(location=(dx-4,dy+6,.03))
    label=bpy.context.object; label.data.body=entry["kind"].upper(); label.data.size=.8
bpy.ops.mesh.primitive_plane_add(size=200,location=(20,5,-.06))
mat=bpy.data.materials.new("Backdrop"); mat.diffuse_color=(.65,.63,.56,1)
bpy.context.object.data.materials.append(mat)
world=bpy.context.scene.world; world.use_nodes=True
world.node_tree.nodes["Background"].inputs[1].default_value=.7
for pos,power,size in [((10,-10,35),6000,25),((40,30,25),4000,20)]:
    bpy.ops.object.light_add(type="AREA",location=pos); light=bpy.context.object
    light.data.energy=power; light.data.size=size
bpy.ops.object.camera_add(location=(57,65,56))
camera=bpy.context.object; camera.rotation_euler=(Vector((21,8,2))-camera.location).to_track_quat("-Z","Y").to_euler()
camera.data.type="ORTHO"; camera.data.ortho_scale=65
scene=bpy.context.scene; scene.camera=camera; scene.render.engine="CYCLES"; scene.cycles.samples=32
scene.render.resolution_x=1600; scene.render.resolution_y=1000; scene.render.resolution_percentage=100
scene.render.image_settings.file_format="PNG"; scene.render.filepath=str(OUT/"furniture-preview.png")
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"InteriorFurniture.blend"))
bpy.ops.render.render(write_still=True)
