"""Build original, palette-textured props for Studio; run with Blender --background --python."""
from pathlib import Path
import json
import math
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "blender"
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
COLORS = {
    "teal": "#376C68", "light_teal": "#65948B", "cream": "#E8DCC4",
    "wood": "#704A33", "dark": "#26333D", "metal": "#8D9B99",
    "orange": "#C88450", "leaf": "#52865B", "leaf_light": "#87A66A",
    "pink": "#CB8B8B", "blue": "#598BBA", "coffee": "#453025",
    "gold": "#D8B16C", "white": "#F5EFDF", "screen": "#1C3C51",
    "paper": "#CCBA9A",
}
def rgb(code):
    return tuple(int(code[i:i+2],16)/255 for i in (1,3,5))
def linear(v):
    return v/12.92 if v <= 0.04045 else ((v+0.055)/1.055)**2.4
MATS = {}
for key, code in COLORS.items():
    mat = bpy.data.materials.new(key)
    mat.diffuse_color = (*[linear(v) for v in rgb(code)], 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = mat.diffuse_color
    bsdf.inputs["Roughness"].default_value = 0.7
    MATS[key] = mat
current = []
def finish(obj, material, smooth=False):
    obj.data.materials.append(MATS[material])
    if smooth:
        for f in obj.data.polygons:
            f.use_smooth = True
    current.append(obj)
    return obj
def cube(pos, size, material, bevel=0.05):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    obj = bpy.context.object
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new("Soft edges", "BEVEL")
        mod.width = min(bevel, min(size)*0.4)
        mod.segments = 3
        bpy.ops.object.modifier_apply(modifier=mod.name)
        normal = obj.modifiers.new("Weighted normals", "WEIGHTED_NORMAL")
        bpy.ops.object.modifier_apply(modifier=normal.name)
    return finish(obj, material)
def sphere(pos, scale, material):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=1, location=pos)
    obj=bpy.context.object
    obj.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return finish(obj, material, True)
def cylinder(pos, radius, depth, material, radius2=None):
    if radius2 is None:
        bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=radius,depth=depth,location=pos)
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=24,radius1=radius,radius2=radius2,depth=depth,location=pos)
    return finish(bpy.context.object, material, True)
def torus(pos, major, minor, material, rotation=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=24,minor_segments=8,
        location=pos,rotation=rotation,major_radius=major,minor_radius=minor)
    return finish(bpy.context.object,material,True)
def lathe(profile, material):
    verts=[];faces=[];n=32
    for radius,z in profile:
        for i in range(n):
            a=2*math.pi*i/n
            verts.append((radius*math.cos(a),radius*math.sin(a),z))
    for j in range(len(profile)-1):
        for i in range(n):
            a=j*n+i;b=j*n+(i+1)%n
            faces.append((a,b,b+n,a+n))
    mesh=bpy.data.meshes.new("Lathed ceramic")
    mesh.from_pydata(verts,[],faces);mesh.update()
    obj=bpy.data.objects.new("Ceramic",mesh)
    bpy.context.collection.objects.link(obj)
    return finish(obj,material,True)

def sofa():
    for x in (-1.45,1.45):
        for y in (-.42,.42): cylinder((x,y,.12),.07,.24,"wood")
    cube((0,0,.38),(3.5,1.35,.4),"teal",.14)
    cube((0,-.55,.91),(3.5,.28,1.15),"teal",.12)
    for x in (-1.68,1.68): cube((x,0,.74),(.28,1.35,.65),"teal",.13)
    for x in (-1.03,0,1.03):
        cube((x,.12,.66),(.98,1.05,.22),"light_teal",.095)
        cube((x,-.38,1.03),(.98,.28,.75),"light_teal",.09)
    for x,color in ((-1.1,"cream"),(1.1,"pink")):
        obj=cube((x,-.1,1.02),(.55,.22,.55),color,.09)
        obj.rotation_euler[1]=.15 if x<0 else -.15
    cube((.35,.28,.79),(.55,.9,.05),"gold",.02)

def mug():
    lathe([(0,.02),(.25,.02),(.28,.08),(.29,.57),(.27,.62),
           (.23,.62),(.22,.12),(0,.12)],"cream")
    cylinder((0,0,.49),.225,.02,"coffee")
    torus((.34,0,.34),.18,.045,"cream",(math.pi/2,0,0))

def plant():
    lathe([(0,0),(.25,0),(.32,.08),(.39,.64),(.42,.66),(.42,.73),
           (.35,.73),(.34,.64),(.28,.15),(0,.15)],"orange")
    cylinder((0,0,.65),.34,.025,"coffee")
    for i in range(9):
        angle=i*2.4
        x=.25*math.cos(angle); y=.25*math.sin(angle); z=.95+(i%3)*.18
        stem=cylinder((x*.6,y*.6,.9),.015,.5,"leaf")
        leaf=sphere((x,y,z),(.13,.34,.035),"leaf_light" if i%2 else "leaf")
        leaf.rotation_euler=(.3*math.cos(angle),.4*math.sin(angle),angle)

def toaster():
    cube((0,0,.37),(1.1,.72,.7),"cream",.18)
    cube((0,0,.035),(1.05,.67,.07),"dark",.03)
    for x in (-.22,.22):
        cube((x,0,.725),(.13,.49,.018),"dark",.02)
        cube((x,0,.76),(.09,.34,.13),"gold",.025)
    cube((.575,.08,.35),(.08,.2,.07),"metal",.02)
    knob=cylinder((.55,.16,.2),.07,.05,"dark");knob.rotation_euler[1]=math.pi/2

def fruit():
    lathe([(0,0),(.3,0),(.6,.12),(.75,.35),(.73,.4),(.68,.4),
           (.55,.17),(.25,.05),(0,.05)],"teal")
    for x,y,col in ((-.3,0,"orange"),(.25,-.1,"pink"),(0,.28,"leaf_light")):
        sphere((x,y,.42),(.24,.23,.22),col)
        cylinder((x,y,.64),.022,.1,"wood")
    sphere((.23,.3,.61),(.11,.05,.025),"leaf")

def controller():
    cube((0,0,.2),(1.05,.52,.25),"dark",.12)
    for x in (-.4,.4):
        grip=sphere((x,.18,.16),(.19,.36,.15),"dark")
        grip.rotation_euler[2]=.3 if x<0 else -.3
    for x,y in ((-.15,.02),(.2,-.05)):
        cylinder((x,y,.37),.085,.07,"metal")
        cylinder((x,y,.41),.07,.02,"dark")
    cube((-.33,-.12,.35),(.21,.06,.04),"cream",.01)
    cube((-.33,-.12,.35),(.06,.21,.04),"cream",.01)
    for i in range(4):
        a=i*math.pi/2
        cylinder((.35+.09*math.cos(a),-.12+.09*math.sin(a),.36),.032,.03,
                 ("pink","blue","leaf_light","gold")[i])

def monitor():
    cube((0,0,.06),(.6,.38,.12),"dark",.06)
    cube((0,-.05,.4),(.12,.12,.68),"metal",.03)
    cube((0,0,.9),(1.65,.12,.94),"dark",.055)
    cube((0,.072,.9),(1.52,.015,.81),"screen",.01)
    cube((0,.085,.59),(1.45,.01,.1),"leaf",0)
    for x,z in ((-.45,.8),(-.25,.8),(-.35,1),(.42,1.1)):
        cube((x,.09,z),(.14,.015,.14),"gold" if x>0 else "pink",.005)
    cube((0,.085,.48),(.08,.01,.02),"light_teal",0)

def lamp():
    cylinder((0,0,.04),.3,.08,"dark")
    cylinder((0,0,.5),.035,.92,"metal")
    shade=lathe([(.36,.98),(.16,1.35),(.13,1.35),(.32,.98),(.36,.98)],"gold")
    sphere((0,0,1.1),(.14,.14,.14),"cream")

def frame():
    cube((0,0,.6),(1.55,.10,1.2),"wood",.035)
    cube((0,.06,.6),(1.43,.025,1.08),"cream",.01)
    cube((0,.08,.6),(1.24,.015,.88),"blue",0)
    cube((0,.095,.36),(1.24,.012,.4),"leaf",0)
    sphere((.32,.11,.86),(.12,.018,.12),"gold")
    # Tiny stylized mountain landscape.
    mesh=bpy.data.meshes.new("Mountains")
    mesh.from_pydata([(-.6,.11,.35),(-.22,.11,.86),(.22,.11,.35),
                        (-.1,.115,.35),(.18,.115,.7),(.58,.115,.35)],[],[(0,1,2),(3,4,5)])
    obj=bpy.data.objects.new("Mountains",mesh);bpy.context.collection.objects.link(obj)
    finish(obj,"cream")

BUILDERS={"Sofa":sofa,"CeramicMug":mug,"PottedFern":plant,"Toaster":toaster,
          "FruitBowl":fruit,"GameController":controller,"GamingMonitor":monitor,
          "DeskLamp":lamp,"PictureFrame":frame}

# One baked color palette image makes FBX import independent of Blender materials.
image=bpy.data.images.new("HousePalette",width=64,height=64)
keys=list(COLORS)
pixels=[]
for y in range(64):
    for x in range(64):
        index=(y//16)*4+x//16
        pixels.extend((*rgb(COLORS[keys[index]]),1))
image.pixels=pixels
image.filepath_raw=str(OUT/"HousePalette.png")
image.file_format="PNG"
image.save()
image.pack()
atlas=bpy.data.materials.new("HousePalette")
atlas.use_nodes=True
node=atlas.node_tree.nodes.new("ShaderNodeTexImage");node.image=image
atlas.node_tree.links.new(node.outputs["Color"],atlas.node_tree.nodes["Principled BSDF"].inputs["Base Color"])
atlas.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value=.68

assets=[]; manifest=[]
for name,builder in BUILDERS.items():
    current=[]
    builder()
    bpy.ops.object.select_all(action="DESELECT")
    for obj in current: obj.select_set(True)
    bpy.context.view_layer.objects.active=current[0]
    bpy.ops.object.convert(target="MESH")
    bpy.ops.object.join()
    obj=bpy.context.object;obj.name=name;obj.data.name=name
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    # Normalize each object to a centered ground pivot.
    coords=[obj.matrix_world@v.co for v in obj.data.vertices]
    offset=Vector(((min(v.x for v in coords)+max(v.x for v in coords))/2,
                   (min(v.y for v in coords)+max(v.y for v in coords))/2,
                   min(v.z for v in coords)))
    matrix=obj.matrix_world.copy()
    for vertex in obj.data.vertices: vertex.co=matrix@vertex.co-offset
    obj.matrix_world.identity()
    uv=obj.data.uv_layers.active or obj.data.uv_layers.new(name="UVMap")
    for poly in obj.data.polygons:
        material=obj.data.materials[poly.material_index]
        index=keys.index(material.name)
        # Keep each face inside its palette tile; no cross-tile texture bleeding.
        for j,loop in enumerate(poly.loop_indices):
            du,dv=((.35,.35),(.65,.35),(.65,.65),(.35,.65))[j%4]
            uv.data[loop].uv=((index%4+du)/4,(index//4+dv)/4)
        poly.material_index=0
    obj.data.materials.clear();obj.data.materials.append(atlas)
    obj.data.calc_loop_triangles()
    tris=len(obj.data.loop_triangles)
    if tris>10000: raise RuntimeError(f"{name}: too many triangles ({tris})")
    manifest.append({"name":name,"triangles":tris,"dimensionsBlender":list(obj.dimensions)})
    bpy.ops.export_scene.fbx(filepath=str(OUT/(name+".fbx")),use_selection=True,
        object_types={"MESH"},bake_anim=False,axis_forward="-Z",axis_up="Y",
        apply_scale_options="FBX_SCALE_ALL",path_mode="COPY",embed_textures=True)
    assets.append(obj)

# Display at readable sizes on a warm gallery plinth.
for i,obj in enumerate(assets):
    factor=2.7/max(obj.dimensions)
    obj.scale=(factor,)*3
    obj.location=((i%3-1)*4.2,(i//3-1)*4.0,.16)
bpy.ops.object.select_all(action="DESELECT")
for obj in assets:obj.select_set(True)
bpy.ops.export_scene.fbx(filepath=str(OUT/"HouseDetailKit.fbx"),use_selection=True,
    object_types={"MESH"},bake_anim=False,axis_forward="-Z",axis_up="Y",
    apply_scale_options="FBX_SCALE_ALL",path_mode="COPY",embed_textures=True)

# Studio-independent render for reviewing actual modeled assets.
for i,obj in enumerate(assets):
    cube((obj.location.x,obj.location.y,-.1),(3.6,3.4,.4),"cream",.12)
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.31))
floor=bpy.context.object;floor.data.materials.append(MATS["cream"])
world=bpy.context.scene.world
world.use_nodes=True;world.node_tree.nodes["Background"].inputs[0].default_value=(.55,.65,.75,1)
world.node_tree.nodes["Background"].inputs[1].default_value=.5
for name,pos,power,size in (("Key",(-5,8,14),1600,9),("Fill",(9,-4,9),1100,8)):
    bpy.ops.object.light_add(type="AREA",location=pos)
    light=bpy.context.object;light.name=name;light.data.energy=power;light.data.shape="DISK";light.data.size=size
    light.rotation_euler=(Vector((0,0,0))-light.location).to_track_quat("-Z","Y").to_euler()
bpy.ops.object.camera_add(location=(12,17,15))
camera=bpy.context.object
camera.rotation_euler=(Vector((0,0,.5))-camera.location).to_track_quat("-Z","Y").to_euler()
camera.data.type="ORTHO";camera.data.ortho_scale=18
scene=bpy.context.scene;scene.camera=camera
scene.render.engine="CYCLES";scene.cycles.samples=32
scene.render.resolution_x=1400;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
scene.view_settings.view_transform="AgX"
scene.render.image_settings.file_format="PNG"
scene.render.filepath=str(OUT/"detail-kit-preview.png")
(OUT/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/"HouseDetailKit.blend"))
bpy.ops.render.render(write_still=True)
print("BUILT DETAIL KIT",sum(x["triangles"] for x in manifest),"triangles")
