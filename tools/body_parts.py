"""Cut the generated bodies (art/source/body/body-{muscle,skin,alive}.png, flat green ground) into six parts.
Writes art/body/<state>-<part>.png, all on one 160x240 canvas so they overlay in place, plus art/body/table.png
and art/body/parts.json with each part's centre (for damage badges). Usage: python3 tools/body_parts.py"""
import json
from collections import deque
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parent.parent; SRC=ROOT/'art/source/body'; OUT=ROOT/'art/body'; OUT.mkdir(exist_ok=True)
W,H=160,240
def keyed(name):
    im=Image.open(SRC/f'body-{name}.png').convert('RGB'); w,h=im.size; px=im.load()
    a=Image.new('L',(w,h),255); ap=a.load()
    for y in range(h):
        for x in range(w):
            r,g,b=px[x,y]
            if g>120 and g>r+60 and g>b+60: ap[x,y]=0
            elif g>r+30 and g>b+30 and g>90: ap[x,y]=90   # green-tinted fringe
    rgba=im.convert('RGBA'); rgba.putalpha(a)
    small=rgba.convert('RGBa').resize((W,H),Image.BOX).convert('RGBA')
    al=small.getchannel('A').point(lambda v:255 if v>127 else 0); small.putalpha(al); return small
states={n:keyed(n) for n in ('muscle','skin','alive')}
# regions from the muscle silhouette
m=states['muscle'].getchannel('A').load()
rows=[[x for x in range(W) if m[x,y]] for y in range(H)]
ys=[y for y in range(H) if rows[y]]; top,bot=ys[0],ys[-1]; fh=bot-top
cx=sum(sum(r) for r in rows if r)//sum(len(r) for r in rows if r)
width=lambda y:(rows[y][-1]-rows[y][0]+1) if rows[y] else 0
neck=min(range(top+int(.10*fh),top+int(.30*fh)), key=width)
crotch=next(y for y in range(top+int(.40*fh),top+int(.75*fh)) if not m[cx,y] and all(not m[cx,yy] for yy in range(y,min(H,y+8))))
lab=[0]*(W*H)   # 1 head 2 torso 3 armL 4 armR 5 legL 6 legR
for y in range(H):
    for x in range(W):
        if not m[x,y]: continue
        if y<neck: lab[y*W+x]=1
        elif y>=crotch: lab[y*W+x]=5 if x<cx else 6
# the band between neck and crotch: in each row the run holding the centre column is torso, runs beside it are arms.
# Above the armpits the shoulders form one run, so there the torso keeps the width it has at the armpit row.
def runs(y):
    out=[]; x=0
    while x<W:
        if m[x,y]:
            x0=x
            while x<W and m[x,y]: x+=1
            out.append((x0,x-1))
        else: x+=1
    return out
armpit=next(y for y in range(neck,crotch) if len(runs(y))>=3 and any(r[0]<=cx<=r[1] for r in runs(y)))
tr=next(r for r in runs(armpit) if r[0]<=cx<=r[1]); tx0,tx1=tr
for y in range(neck,crotch):
    rs=runs(y); centre=next((r for r in rs if r[0]<=cx<=r[1]),None)
    for x in range(W):
        if not m[x,y]: continue
        if y<armpit: lab[y*W+x]=2 if tx0-1<=x<=tx1+1 else (3 if x<cx else 4)
        elif centre and centre[0]<=x<=centre[1]: lab[y*W+x]=2
        else: lab[y*W+x]=3 if x<cx else 4
# every other canvas pixel (hair, glow, fringe) joins the nearest region
q=deque(i for i in range(W*H) if lab[i])
while q:
    j=q.popleft(); jx,jy=j%W,j//W
    for nx,ny in ((jx+1,jy),(jx-1,jy),(jx,jy+1),(jx,jy-1)):
        if 0<=nx<W and 0<=ny<H and not lab[ny*W+nx]: lab[ny*W+nx]=lab[j]; q.append(ny*W+nx)
names={1:'head',2:'torso',3:'armL',4:'armR',5:'legL',6:'legR'}; centres={}
for k,n in names.items():
    pts=[i for i in range(W*H) if lab[i]==k and m[i%W,i//W]]
    centres[n]=[round(sum(i%W for i in pts)/len(pts)/W*100,1), round(sum(i//W for i in pts)/len(pts)/H*100,1)]
    for st,im in states.items():
        out=Image.new('RGBA',(W,H),(0,0,0,0)); src=im.load(); o=out.load()
        for i in pts: pass
        for y in range(H):
            for x in range(W):
                if lab[y*W+x]==k: o[x,y]=src[x,y]
        out.save(OUT/f'{st}-{n}.png',optimize=True)
Image.open(SRC/'body-table.png').convert('RGB').resize((W,H),Image.BOX).quantize(colors=32,dither=Image.Dither.NONE).convert('RGB').save(OUT/'table.png',optimize=True)
(OUT/'parts.json').write_text(json.dumps({'w':W,'h':H,'neck':neck,'crotch':crotch,'centres':centres}))
print('neck',neck,'armpit',armpit,'crotch',crotch,'centre x',cx,'torso x',tx0,tx1); print(centres)
