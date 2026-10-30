"""Blender, headless: make a generated model ready for the town (D172). Turns it so its front faces +Z (south in the
town), puts the origin at the centre of its base on the ground, scales it to its height in metres, exports a GLB.

  blender -b --factory-startup --python art-pipeline/finish.py -- in.glb out.glb <height m> <turn degrees>

turn: degrees about the vertical axis, counter-clockwise seen from above. Generated models usually face +X, so -90.
"""
import math, sys
import bpy
from mathutils import Matrix, Vector

src, dst, height, turn = sys.argv[sys.argv.index('--') + 1:][:4]
height, turn = float(height), float(turn)
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
for o in list(bpy.context.scene.objects):   # drop the importer's empty parents
    if o is not obj and o.type != 'MESH':
        bpy.data.objects.remove(o)
obj.parent = None
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
obj.data.transform(Matrix.Rotation(math.radians(turn), 4, 'Z'))
pts = [v.co for v in obj.data.vertices]
lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
s = height / (hi.z - lo.z)
obj.data.transform(Matrix.Scale(s, 4) @ Matrix.Translation(Vector((-(lo.x + hi.x) / 2, -(lo.y + hi.y) / 2, -lo.z))))
tris = sum(len(p.vertices) - 2 for p in obj.data.polygons)
print(f'FINISH {tris} triangles, {(hi.x - lo.x) * s:.1f} m wide (x), {(hi.y - lo.y) * s:.1f} m deep, {height:.1f} m tall, turned {turn:.0f} deg')
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB')
print('FINISH wrote', dst)
