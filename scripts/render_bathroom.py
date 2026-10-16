"""Render a cutaway preview of the authored bathroom; game walls remain full height."""
import json
from pathlib import Path
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
data=json.loads((ROOT/"map/Bathrooms.model.json").read_text())["Children"][0]
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
materials={}
for p in data["Children"]:
    q=p["Properties"]; x,y,z=q["Position"]; z-=60
    sx,sy,sz=q["Size"]; name=p["Name"]
    if name.startswith("Door") or name=="BathroomSign" or (name=="SideWall" and x>0): continue
    if name in ("SideWall","BackWall"): y=4.5; sy=9
    if q.get("Shape")=="Ball": bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,radius=.5)
    else: bpy.ops.mesh.primitive_cube_add(size=1)
    obj=bpy.context.object; obj.name=name; obj.location=(x,-z,y); obj.scale=(sx,sz,sy)
    key=tuple(q["Color"])+(q.get("Transparency",0),)
    if key not in materials:
        mat=bpy.data.materials.new(name); mat.use_nodes=True
        color=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in q["Color"]]
        shader=mat.node_tree.nodes["Principled BSDF"]; shader.inputs["Base Color"].default_value=(*color,1)
        shader.inputs["Roughness"].default_value=.45
        if key[-1]>0: shader.inputs["Transmission Weight"].default_value=.8
        materials[key]=mat
    obj.data.materials.append(materials[key])
for pos in ((5,-12,25),(-10,5,20)):
    bpy.ops.object.light_add(type="AREA",location=pos); bpy.context.object.data.energy=4500; bpy.context.object.data.size=15
bpy.ops.object.camera_add(location=(23,-28,24))
cam=bpy.context.object; cam.rotation_euler=(Vector((0,0,2))-cam.location).to_track_quat("-Z","Y").to_euler()
cam.data.type="ORTHO"; cam.data.ortho_scale=32
scene=bpy.context.scene; scene.camera=cam; scene.render.engine="CYCLES"; scene.cycles.samples=32
scene.render.resolution_x=1100; scene.render.resolution_y=900; scene.render.resolution_percentage=100
scene.world.color=(.3,.3,.3); scene.render.filepath=str(ROOT/"build/bathroom-cutaway.png")
bpy.ops.render.render(write_still=True)
