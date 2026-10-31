"""The companion's body parts for the operating table (D187).

blender -b --factory-startup --python art-pipeline/body_parts.py [-- part-look ...]

Reads the low-poly models in art/source/3dModels/ai/companion/<part>-<look>-low.glb (Prism 3.1, then Smart Low Poly)
and writes godot/assets/cabin/body/<part>-<look>.glb, ready to lie on the table:
- on her back, the body's length along +X (head end), up +Z in Blender, so in Godot length +x, up +y;
- the head and torso were made standing, face to +X; an arm or leg lies along its own longest axis (which end is the
  joint is found from the end that is widest at its narrowest, which way is up from the hand's or foot's shape, with a per-model flip if it guesses wrong);
- the heads were made as busts: cut just under the neck stitches and the hole closed;
- scaled to its length and, separately, its width from the full-body concept (see H), origin at the joint end (the neck for head and torso, shoulder or hip for a limb),
  centred across, resting on z = 0;
- textures down to 512 px (the parts are a few centimetres long), JPEG.
The models are of the left arm and leg; the table mirrors them for the right.
"""
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

SRC = "art/source/3dModels/ai/companion"
DST = "godot/assets/cabin/body"

# Sizes come from the full-body concept (out/companion/concept-skin.jpg, D188), as fractions of her height crown to
# sole: head to the neck cut 0.17, shoulders across 0.235, torso neck to hips 0.42, arm 0.39 (upper arm 0.045 thick),
# leg 0.48 (thigh 0.08 thick), head 0.11 wide. Each part is scaled to its length along the body and, separately, to
# its width across (thickness scaled the same), so a fat or thin generated model still matches the others.
H = 0.27   # her height on the table, metres
# part: (length, width, width taken as "max" across the whole part or "limb" (median over the upper half), which way
# the free end points (+1 toward the head end), bust cut as a fraction of the height from the bottom, flip up)
PARTS = {
    "head-skin": (0.17, 0.11, "max", +1, 0.2, False),
    "head-muscle": (0.17, 0.11, "max", +1, 0.24, False),
    "torso-skin": (0.42, 0.235, "max", -1, 0.0, False),
    "torso-muscle": (0.42, 0.235, "max", -1, 0.0, False),
    "arm-skin": (0.39, 0.045, "limb", -1, 0.0, False),
    "arm-muscle": (0.39, 0.045, "limb", -1, 0.0, False),
    "leg-skin": (0.48, 0.08, "limb", -1, 0.0, False),
    "leg-muscle": (0.48, 0.08, "limb", -1, 0.0, False),
}


def load(path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)
    obs = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    bpy.ops.object.select_all(action='DESELECT')
    for o in obs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = obs[0]
    if len(obs) > 1:
        bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active
    ob.parent = None
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return ob


def cut_bust(ob, frac):
    """Remove everything below frac of the height and close the hole."""
    me = ob.data
    zs = [v.co.z for v in me.vertices]
    z = min(zs) + frac * (max(zs) - min(zs))
    bm = bmesh.new()
    bm.from_mesh(me)
    geom = bm.verts[:] + bm.edges[:] + bm.faces[:]
    res = bmesh.ops.bisect_plane(bm, geom=geom, plane_co=(0, 0, z), plane_no=(0, 0, 1), clear_inner=True)
    edges = [e for e in res["geom_cut"] if isinstance(e, bmesh.types.BMEdge)]
    if edges:
        bmesh.ops.holes_fill(bm, edges=edges)
    bm.to_mesh(me)
    bm.free()


def frame(ob, name):
    """The part's long axis (joint end to free end) and its up direction, in the model's own coordinates."""
    if name.startswith(("head", "torso")):
        d = Vector((0, 0, 1)) if name.startswith("head") else Vector((0, 0, -1))
        return d, Vector((1, 0, 0))
    import numpy as np
    P = np.array([v.co[:] for v in ob.data.vertices])
    c = P.mean(0)
    # The limb's own long axis: some models lie diagonally in their file.
    w, V = np.linalg.eigh(np.cov((P - c).T))
    ax, e1, e2 = V[:, 2], V[:, 1], V[:, 0]
    t = (P - c) @ ax
    lo, hi = t.min(), t.max()
    span = hi - lo

    def slab(a, b):
        return P[(t >= a) & (t <= b)]

    def narrow(sl):
        # the narrower width across: a cut thigh or shoulder is round, a foot or a flat hand is narrow one way
        q = sl - c
        return min(np.ptp(q @ e1), np.ptp(q @ e2))
    joint_at_lo = narrow(slab(lo, lo + 0.08 * span)) > narrow(slab(hi - 0.08 * span, hi))
    d = ax if joint_at_lo else -ax
    # Up: the foot's toes stick up; a hand lies flat, so its thinnest direction across is up.
    end = slab(hi - 0.18 * span, hi) if joint_at_lo else slab(lo, lo + 0.18 * span)
    mid = slab(lo + 0.4 * span, lo + 0.6 * span)
    if name.startswith("leg"):
        up = end.mean(0) - mid.mean(0)
    else:
        best = None
        for i in range(36):
            a = np.pi * i / 36
            n = np.cos(a) * e1 + np.sin(a) * e2
            ext = np.ptp((end - c) @ n)
            if best is None or ext < best[0]:
                best = (ext, n)
        up = best[1]
    return Vector(d.tolist()), Vector(up.tolist()).normalized()


def orient(ob, name):
    length, width, how, sign, cut, flip = PARTS[name]
    if cut > 0:
        cut_bust(ob, cut)
    d, up = frame(ob, name)
    if flip:
        up = -up
    up = (up - d * up.dot(d)).normalized()
    s = up.cross(d)
    td, tu = Vector((sign, 0, 0)), Vector((0, 0, 1))
    ts = tu.cross(td)
    src = Matrix((d, up, s)).transposed()
    dst = Matrix((td, tu, ts)).transposed()
    r = (dst @ src.transposed()).to_4x4()
    ob.data.transform(r)
    co = [v.co for v in ob.data.vertices]
    xs = [c.x for c in co]
    x_lo, x_hi = min(xs), max(xs)
    if how == "max":
        across = max(c.y for c in co) - min(c.y for c in co)
    else:
        # median width across the upper half of the limb, from its joint end
        widths = []
        for i in range(10):
            f = 0.08 + 0.04 * i
            x = x_hi - f * (x_hi - x_lo) if sign < 0 else x_lo + f * (x_hi - x_lo)
            ys = [c.y for c in co if abs(c.x - x) < 0.02 * (x_hi - x_lo)]
            if ys:
                widths.append(max(ys) - min(ys))
        across = sorted(widths)[len(widths) // 2]
    kx = length * H / (x_hi - x_lo)
    ky = width * H / across
    ob.data.transform(Matrix.Diagonal((kx, ky, ky, 1)))
    co = [v.co for v in ob.data.vertices]
    x0 = min(c.x for c in co) if sign > 0 else max(c.x for c in co)
    y0 = (min(c.y for c in co) + max(c.y for c in co)) / 2
    z0 = min(c.z for c in co)
    ob.data.transform(Matrix.Translation((-x0, -y0, -z0)))
    ob.data.update()
    print(f"BODY {name}: length scale {kx:.4f}, width scale {ky:.4f} (ratio {ky / kx:.2f})")


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else list(PARTS)
    os.makedirs(DST, exist_ok=True)
    for name in args:
        ob = load(f"{SRC}/{name}-low.glb")
        orient(ob, name)
        for im in bpy.data.images:
            w, h = im.size
            if max(w, h) > 512:
                im.scale(max(1, w * 512 // max(w, h)), max(1, h * 512 // max(w, h)))
        dst = f"{DST}/{name}.glb"
        bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_image_format='JPEG', export_jpeg_quality=85)
        tris = sum(len(p.vertices) - 2 for p in ob.data.polygons)
        print(f"BODY {name}: {tris} triangles, {os.path.getsize(dst) // 1024} KB")


main()
