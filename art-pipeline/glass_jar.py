"""Blender, headless: give the Leyden jar a glass upper body (D182). Faces of the jar's body between the top of the
foil band and the stopper get their own material named "glass" (Godot swaps it for a clear glass material); the foil
band, stopper and rod keep the texture.

  blender -b --factory-startup --python art-pipeline/glass_jar.py -- in.glb out.glb [z_from z_to] [preview.png]
"""
import sys
import bpy

args = sys.argv[sys.argv.index("--") + 1:]
src, dst = args[:2]
z0 = float(args[2]) if len(args) > 2 else 0.075
z1 = float(args[3]) if len(args) > 3 else 0.128
preview = args[4] if len(args) > 4 else ""
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
o = [o for o in bpy.context.scene.objects if o.type == "MESH"][0]
glass = bpy.data.materials.new("glass")
glass.diffuse_color = (1, 0, 0, 1)
o.data.materials.append(glass)
gi = len(o.data.materials) - 1
n = 0
for f in o.data.polygons:
    z = (o.matrix_world @ f.center).z
    r = (f.center.x ** 2 + f.center.y ** 2) ** 0.5
    if z0 <= z <= z1 and r > 0.012:          # the body's wall only, not the small parts round the axis
        f.material_index = gi
        n += 1
print("GLASS faces", n)
if preview:
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_WORKBENCH"
    sc.display.shading.color_type = "MATERIAL"
    sc.render.resolution_x = sc.render.resolution_y = 400
    cam = bpy.data.objects.new("c", bpy.data.cameras.new("c"))
    sc.collection.objects.link(cam)
    sc.camera = cam
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 0.26
    cam.location = (0.4, -0.4, 0.2)
    from mathutils import Vector
    cam.rotation_euler = (Vector((0, 0, 0.095)) - cam.location).to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = preview
    bpy.ops.render.render(write_still=True)
bpy.ops.export_scene.gltf(filepath=dst, export_format="GLB")
