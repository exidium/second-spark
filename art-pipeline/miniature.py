"""Blender, headless: a carved miniature of a finished model (D177): decimate to a few hundred triangles, flat shading,
textures down to 256 px. The cabin's map stands these on its landmark spots.

  blender -b --factory-startup --python art-pipeline/miniature.py -- in.glb out.glb <triangles>
"""
import sys
import bpy

src, dst, target = sys.argv[sys.argv.index('--') + 1:][:3]
target = int(target)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
bpy.ops.object.select_all(action='DESELECT')
for o in meshes:
    o.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
if len(meshes) > 1:
    bpy.ops.object.join()
obj = bpy.context.view_layer.objects.active
tris = sum(len(p.vertices) - 2 for p in obj.data.polygons)
if tris > target:
    mod = obj.modifiers.new('Decimate', 'DECIMATE')
    mod.decimate_type = 'COLLAPSE'
    mod.ratio = target / tris
    mod.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=mod.name)
for p in obj.data.polygons:   # carved: flat faces
    p.use_smooth = False
for im in bpy.data.images:
    w, h = im.size
    if max(w, h) > 256:
        im.scale(max(1, w * 256 // max(w, h)), max(1, h * 256 // max(w, h)))
        im.pack()
after = sum(len(p.vertices) - 2 for p in obj.data.polygons)
print(f'MINI {tris} -> {after} triangles')
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_image_format='JPEG', export_jpeg_quality=85)
