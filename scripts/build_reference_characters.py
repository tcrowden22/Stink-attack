"""Build the reference-inspired brown bug (seven rigid meshes) and blue vacuum."""
from pathlib import Path
import math, json
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"assets"/"characters"/"reference"
OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.delete(use_global=False)
colors=["724120","A9652B","D59A45","30241D","FFF3DB","101523","1649C4","31DFFF","B9C3D1","252D42","9141DF","D7B84A"]
mats=[]
for i,c in enumerate(colors):
    m=bpy.data.materials.new("Palette"+str(i)); m.use_nodes=True
    rgb=[int(c[j:j+2],16)/255 for j in (0,2,4)]
    m.diffuse_color=(*[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb],1)
    m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value=m.diffuse_color
    m.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value=.35
    mats.append(m)
parts=[]
def finish(o,c):
    o.data.materials.append(mats[c]); o["Glow"]=(c==7); parts.append(o); return o
def box(p,s,c,bevel=.03):
    bpy.ops.mesh.primitive_cube_add(size=1,location=p); o=bpy.context.object; o.dimensions=s
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        m=o.modifiers.new("Edge","BEVEL"); m.width=bevel; m.segments=2
        bpy.ops.object.modifier_apply(modifier=m.name)
    return finish(o,c)
def ball(p,s,c):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=1,location=p)
    o=bpy.context.object; o.scale=s
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    for f in o.data.polygons:f.use_smooth=True
    return finish(o,c)
def rod(a,b,r,c,block=False):
    a,b=Vector(a),Vector(b)
    if block:
        o=box((a+b)/2,(r*2,r*2,(b-a).length),c,.025)
    else:
        bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=r,depth=(b-a).length,location=(a+b)/2)
        o=finish(bpy.context.object,c)
    o.rotation_euler=(b-a).to_track_quat("Z","Y").to_euler(); return o
def cylinder(p,r,d,c):
    bpy.ops.mesh.primitive_cylinder_add(vertices=16,radius=r,depth=d,location=p)
    return finish(bpy.context.object,c)
def join(name):
    global parts
    bpy.ops.object.select_all(action="DESELECT")
    for o in parts:o.select_set(True)
    bpy.context.view_layer.objects.active=parts[0]
    bpy.ops.object.convert(target="MESH"); bpy.ops.object.join()
    o=bpy.context.object; o.name=name; o.data.name=name
    matrix=o.matrix_world.copy()
    for v in o.data.vertices:v.co=matrix@v.co
    o.matrix_world.identity(); parts=[]
    return o
# Wide faceted shield and segmented amber abdomen.
ball((0,0,.66),(.83,.87,.48),0)
for z,width in ((.32,1.15),(.52,1.42),(.73,1.56)):
    box((0,.71,z),(width,.24,.18),2)
for x in (-.4,.4):
    o=box((x,0,1.04),(.77,1.48,.24),1,.08); o.rotation_euler.y=x*.18
# Angular brow/helmet and center seam.
box((0,.68,1.1),(1.68,.4,.2),0,.07)
rod((0,-.71,1.17),(0,.62,1.17),.025,3)
for side in (-1,1):
    for j in range(4):
        box((side*(.6-.035*j),-.55+j*.3,1.19),(.1,.11,.025),3,.005)
    ball((side*.37,.884,.88),(.33,.11,.34),4)
    ball((side*.32,.985,.91),(.17,.04,.22),5)
    ball((side*.28,1.019,1.005),(.055,.015,.065),4)
    brow=box((side*.36,.99,1.16),(.73,.15,.15),3)
    brow.rotation_euler.y=side*-.22
    rod((side*.48,.26,1.17),(side*.61,.43,1.79),.055,0,True)
    rod((side*.61,.43,1.79),(side*.87,.57,1.95),.05,2,True)
# Smirk, geometric mouth.
rod((-.22,.92,.48),(.18,.94,.44),.025,3)
rod((.18,.94,.44),(.28,.93,.52),.025,3)
bug=[join("BugBody")]
for side,label in ((-1,"L"),(1,"R")):
    for j,y in enumerate((.52,0,-.53),1):
        a=(side*.65,y,.68); b=(side*1.04,y+.08,.5); c=(side*1.22,y+.3,.1)
        rod(a,b,.13,1,True); rod(b,c,.11,0,True)
        box(c,(.25,.32,.15),0)
        bug.append(join("Leg"+label+str(j)))
# Upright robot-faced cleaner, broad head and corrugated hose.
cylinder((0,0,1.28),.53,1.35,6)
for z in (.64,1.54,1.94):cylinder((0,0,z),.56,.11,8)
box((0,.51,1.72),(.84,.12,.31),5)
for side in (-1,1):
    eye=box((side*.22,.59,1.73),(.27,.025,.08),7,.01); eye.rotation_euler.y=-side*.28
box((0,.5,1.09),(.62,.22,.58),9)
box((0,.63,1.09),(.15,.025,.55),6)
box((0,.48,.66),(.56,.18,.18),7)
rod((0,.3,.7),(0,.8,.2),.14,9)
box((0,.93,.19),(1.72,.72,.29),9,.08)
box((0,1.305,.2),(1.47,.035,.12),7,.015)
for x in (-.57,-.28,0,.28,.57):box((x,1.329,.2),(.17,.035,.1),4,.01)
# Hose curves from lid to rear port.
points=[]
for i in range(25):
    t=i/24*math.pi
    points.append((.55*(1-math.cos(t)),-.19,1.94+.8*math.sin(t)-.45*t/math.pi))
for a,b in zip(points,points[1:]):rod(a,b,.135,5)
for i,p in enumerate(points[:-1]):
    direction=Vector(points[i+1])-Vector(p)
    bpy.ops.mesh.primitive_torus_add(major_segments=12,minor_segments=4,major_radius=.14,minor_radius=.022,location=p)
    o=bpy.context.object; o.rotation_euler=direction.to_track_quat("Z","Y").to_euler(); finish(o,9)
rod((.0,-.35,1.4),(0,-.35,1.95),.08,9)
glowing=[o for o in parts if o.get("Glow")]
parts=[o for o in parts if not o.get("Glow")]
vacuum=[join("VacuumBody")]
parts=glowing
vacuum.append(join("VacuumGlow"))
# One palette texture; UV tiles retain all materials in Studio.
image=bpy.data.images.new("ReferencePalette",width=64,height=48)
pixels=[]
for y in range(48):
    for x in range(64):
        c=colors[(y//16)*4+x//16]; pixels.extend([int(c[j:j+2],16)/255 for j in (0,2,4)]+[1])
image.pixels=pixels; image.filepath_raw=str(OUT/"ReferencePalette.png"); image.file_format="PNG"; image.save(); image.pack()
atlas=bpy.data.materials.new("ReferencePalette"); atlas.use_nodes=True
tex=atlas.node_tree.nodes.new("ShaderNodeTexImage"); tex.image=image
atlas.node_tree.links.new(tex.outputs["Color"],atlas.node_tree.nodes["Principled BSDF"].inputs["Base Color"])
atlas.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value=.35
manifest=[]
for name,objects in (("StinkBugV2",bug),("VacuumV2",vacuum)):
    entries=[]
    for o in objects:
        uv=o.data.uv_layers.active or o.data.uv_layers.new(name="UVMap")
        for f in o.data.polygons:
            idx=mats.index(o.data.materials[f.material_index])
            for j,l in enumerate(f.loop_indices):
                dx,dy=((.35,.35),(.65,.35),(.65,.65),(.35,.65))[j%4]
                uv.data[l].uv=((idx%4+dx)/4,(idx//4+dy)/3)
            f.material_index=0
        o.data.materials.clear()
        material=atlas
        if o.name=="VacuumGlow":
            material=atlas.copy(); material.name="NeonBlue"
            bsdf=material.node_tree.nodes["Principled BSDF"]
            node=next(n for n in material.node_tree.nodes if n.type=="TEX_IMAGE")
            material.node_tree.links.new(node.outputs["Color"],bsdf.inputs["Emission Color"])
            bsdf.inputs["Emission Strength"].default_value=3
        o.data.materials.append(material); o.data.calc_loop_triangles()
        count=len(o.data.loop_triangles)
        if count>10000:raise RuntimeError(o.name+" over triangle budget")
        entries.append({"name":o.name,"triangles":count})
    bpy.ops.object.select_all(action="DESELECT")
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    bpy.ops.export_scene.fbx(filepath=str(OUT/(name+".fbx")),use_selection=True,object_types={"MESH"},bake_anim=False,axis_forward="-Z",axis_up="Y",apply_scale_options="FBX_SCALE_ALL",path_mode="COPY",embed_textures=True)
    manifest.append({"file":name+".fbx","meshes":entries})
(OUT/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
for o in bug:o.location.x=-1.8
for o in vacuum:o.location.x=1.6
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.03))
bpy.context.object.data.materials.append(mats[4])
world=bpy.context.scene.world; world.use_nodes=True
world.node_tree.nodes["Background"].inputs[0].default_value=(.35,.4,.5,1)
world.node_tree.nodes["Background"].inputs[1].default_value=.6
for pos,power,size in [((-3,5,7),1000,5),((5,0,6),800,4)]:
    bpy.ops.object.light_add(type="AREA",location=pos); o=bpy.context.object; o.data.energy=power; o.data.size=size
    o.rotation_euler=(Vector((0,0,.8))-o.location).to_track_quat("-Z","Y").to_euler()
bpy.ops.object.camera_add(location=(4,8,5))
camera=bpy.context.object; camera.rotation_euler=(Vector((0,.1,1))-camera.location).to_track_quat("-Z","Y").to_euler()
camera.data.type="ORTHO"; camera.data.ortho_scale=7.4
scene=bpy.context.scene; scene.camera=camera; scene.render.engine="CYCLES"; scene.cycles.samples=40
scene.render.resolution_x=1500; scene.render.resolution_y=1000; scene.render.resolution_percentage=100
scene.render.image_settings.file_format="PNG"; scene.render.filepath=str(OUT/"reference-characters.png")
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"ReferenceCharacters.blend"))
bpy.ops.render.render(write_still=True)
print("REFERENCE CHARACTERS COMPLETE",manifest)
