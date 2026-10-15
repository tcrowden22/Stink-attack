"""Author an original, texture-atlased stink bug; Blender background entry point."""
from pathlib import Path
import math
import json
import bpy
from mathutils import Vector
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "characters"
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
colors = ["557D36", "8BA64B", "C3CF78", "303B26", "EDE5C4", "151E24", "A47543", "D5A653"]
mats=[]
for i,c in enumerate(colors):
    m=bpy.data.materials.new("BugColor"+str(i)); m.use_nodes=True
    rgb=[int(c[j:j+2],16)/255 for j in (0,2,4)]
    m.diffuse_color=(*[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb],1)
    m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value=m.diffuse_color
    m.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value=.48
    mats.append(m)
parts=[]
def finish(obj,color):
    obj.data.materials.append(mats[color]); parts.append(obj)
    for p in obj.data.polygons: p.use_smooth=True
    return obj
def ball(pos,scale,color):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=1,location=pos)
    o=bpy.context.object; o.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return finish(o,color)
def rod(a,b,r,color):
    a,b=Vector(a),Vector(b)
    bpy.ops.mesh.primitive_cone_add(vertices=10,radius1=r,radius2=r*.72,depth=(b-a).length,location=(a+b)/2)
    o=bpy.context.object; o.rotation_euler=(b-a).to_track_quat("Z","Y").to_euler()
    return finish(o,color)
# Broad shoulders, tapered abdomen and triangular scutellum identify a shield bug.
outline=[(-.48,.72),(-.78,.4),(-.71,-.35),(-.35,-.91),(0,-1.08),(.35,-.91),(.71,-.35),(.78,.4),(.48,.72)]
verts=[(x,y,.42) for x,y in outline]+[(x*.86,y*.9,.76) for x,y in outline]+[(0,0,.94)]
n=len(outline); faces=[tuple(reversed(range(n)))]
for i in range(n):
    j=(i+1)%n; faces.extend([(i,j,j+n,i+n),(i+n,j+n,2*n)])
mesh=bpy.data.meshes.new("Shield"); mesh.from_pydata(verts,[],faces); mesh.update()
o=bpy.data.objects.new("Shield",mesh); bpy.context.collection.objects.link(o); finish(o,0)
bevel=o.modifiers.new("Soft shell edge","BEVEL"); bevel.width=.07; bevel.segments=3
bpy.context.view_layer.objects.active=o
bpy.ops.object.modifier_apply(modifier=bevel.name)
# Raised wing panels, front collar and a gold-edged central shield.
ball((-.29,-.17,.76),(.36,.64,.18),1)
ball((.29,-.17,.76),(.36,.64,.18),1)
tri=bpy.data.meshes.new("Scutellum")
tri.from_pydata([(-.38,.38,.94),(.38,.38,.94),(0,-.52,.99),(0,.18,1.035)],[],[(0,1,3),(1,2,3),(2,0,3)])
tri.update(); ob=bpy.data.objects.new("Scutellum",tri); bpy.context.collection.objects.link(ob); finish(ob,2)
ball((0,.53,.78),(.65,.32,.23),0)
ball((0,.83,.65),(.38,.33,.28),0)
for side in (-1,1):
    # Six articulated-looking legs, with alternating light edge markings.
    for j,y in enumerate((.42,-.08,-.55)):
        a=(side*.5,y,.52); b=(side*(.94+.07*j),y+(.15 if j==0 else -.12),.32)
        c=(side*(1.14+.04*j),y+(.34 if j==0 else -.29),.08)
        rod(a,b,.065,3); ball(b,(.085,.085,.085),1); rod(b,c,.045,3)
        ball(c,(.085,.13,.05),3)
    for y in (-.25,-.55,-.76):
        ball((side*(.68 if y>-.5 else .5),y,.6),(.075,.1,.045),7)
    ball((side*.25,1.035,.77),(.17,.105,.18),4)
    ball((side*.25,1.12,.78),(.088,.045,.115),5)
    ball((side*.227,1.153,.825),(.026,.015,.03),4)
    a=(side*.24,.99,.9); b=(side*.43,1.24,1.15); c=(side*.62,1.53,1.23)
    rod(a,b,.028,3); rod(b,c,.022,6); ball(c,(.045,.06,.045),7)
# Join, center, and atlas every polygon for reliable FBX colors.
bpy.ops.object.select_all(action="DESELECT")
for o in parts:o.select_set(True)
bpy.context.view_layer.objects.active=parts[0]
bpy.ops.object.convert(target="MESH"); bpy.ops.object.join()
bug=bpy.context.object; bug.name="StinkBug"; bug.data.name="StinkBug"
matrix=bug.matrix_world.copy()
for v in bug.data.vertices:v.co=matrix@v.co
bug.matrix_world.identity()
image=bpy.data.images.new("StinkBugPalette",width=64,height=32)
pixels=[]
for y in range(32):
    for x in range(64):
        c=colors[(y//16)*4+x//16]
        pixels.extend([int(c[j:j+2],16)/255 for j in (0,2,4)]+[1])
image.pixels=pixels; image.filepath_raw=str(OUT/"StinkBugPalette.png"); image.file_format="PNG"; image.save(); image.pack()
uv=bug.data.uv_layers.active or bug.data.uv_layers.new(name="UVMap")
for face in bug.data.polygons:
    idx=mats.index(bug.data.materials[face.material_index])
    for k,loop in enumerate(face.loop_indices):
        dx,dy=((.35,.35),(.65,.35),(.65,.65),(.35,.65))[k%4]
        uv.data[loop].uv=((idx%4+dx)/4,(idx//4+dy)/2)
    face.material_index=0
atlas=bpy.data.materials.new("StinkBugPalette"); atlas.use_nodes=True
tex=atlas.node_tree.nodes.new("ShaderNodeTexImage"); tex.image=image
atlas.node_tree.links.new(tex.outputs["Color"],atlas.node_tree.nodes["Principled BSDF"].inputs["Base Color"])
atlas.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value=.48
bug.data.materials.clear(); bug.data.materials.append(atlas)
bug.data.calc_loop_triangles()
triangles=len(bug.data.loop_triangles)
if triangles>10000: raise RuntimeError("Bug exceeds mesh triangle budget")
bpy.ops.export_scene.fbx(filepath=str(OUT/"StinkBug.fbx"),use_selection=True,object_types={"MESH"},bake_anim=False,axis_forward="-Z",axis_up="Y",apply_scale_options="FBX_SCALE_ALL",path_mode="COPY",embed_textures=True)
(OUT/"manifest.json").write_text(json.dumps({"name":"StinkBug","triangles":triangles,"forward":"Blender +Y / Roblox -Z","dimensions":list(bug.dimensions)},indent=2)+"\n",encoding="utf-8")
# Render the actual asset for review.
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.015))
floor=bpy.context.object; floor.data.materials.append(mats[4])
world=bpy.context.scene.world; world.use_nodes=True
world.node_tree.nodes["Background"].inputs[0].default_value=(.6,.7,.8,1)
world.node_tree.nodes["Background"].inputs[1].default_value=.45
for pos,power,size in [((-3,4,6),550,5),((4,-2,4),400,4)]:
    bpy.ops.object.light_add(type="AREA",location=pos)
    light=bpy.context.object; light.data.energy=power; light.data.size=size
    light.rotation_euler=(Vector((0,0,.5))-light.location).to_track_quat("-Z","Y").to_euler()
bpy.ops.object.camera_add(location=(3.2,4.8,3.4))
camera=bpy.context.object; camera.rotation_euler=(Vector((0,.15,.55))-camera.location).to_track_quat("-Z","Y").to_euler()
camera.data.type="ORTHO"; camera.data.ortho_scale=4.3
scene=bpy.context.scene; scene.camera=camera; scene.render.engine="CYCLES"; scene.cycles.samples=32
scene.render.resolution_x=1200; scene.render.resolution_y=1000; scene.render.resolution_percentage=100
scene.view_settings.view_transform="AgX"; scene.render.image_settings.file_format="PNG"
scene.render.filepath=str(OUT/"stink-bug-preview.png")
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"StinkBug.blend"))
bpy.ops.render.render(write_still=True)
print("STINK BUG BUILT:",triangles,"triangles")
