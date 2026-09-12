import json,re,hashlib
import numpy as np
from runtime import *
rng=np.random.default_rng(120926)
random=rng.random((23,29,4),dtype=np.float32);random[:,:,:3]*=random[:,:,3:]
transparent=rng.random((9,13,4),dtype=np.float32);transparent[:,:,3]=0
edge=random.copy();edge[:8,:,3]=0;edge[:8,:,:3]=.9
cases=[np.array([[[.3,.2,.1,.5]]],np.float32),transparent,random,edge,np.zeros((1,19,4),np.float32),np.ones((19,1,4),np.float32)]
for c in [[0,0,0,1],[1,1,1,1],[.3,.2,.1,.5],[1,0,0,1],[0,1,0,1],[0,0,1,1]]:cases.append(np.broadcast_to(np.array(c,np.float32),(11,17,4)).copy())
results=[]
for name in NAMES:
 default=META['defaults'][name]
 settings=[default,[0,256,4,0,24,180,65535,0],[100,0,4,0,24,180,65535,100],[100,256,4,0,24,180,65535,0],[100,256,192,255,1,-180,0,100],[100,256,192,0,24,0,0,100]]
 count=0;maxerr=0
 for ci,src in enumerate(cases):
  for p in settings:
   a=run(name,src,p);b=run(name,src,p,True)
   assert np.isfinite(a).all(),name
   assert np.array_equal(a[:,:,3],src[:,:,3]),name
   mask=src[:,:,3]==0;assert np.array_equal(a[mask],src[mask]),name
   valid=~mask;assert (a[valid,:3]>=-1e-7).all() and (a[valid,:3]<=src[valid,3:]+1e-7).all(),name
   assert np.array_equal(a,run(name,src,p)),name
   if p[0]==0 or p[1]==0 or ci>=6 or ci==0:assert np.array_equal(a,src),name
   err=float(np.max(abs(a-b)));maxerr=max(maxerr,err);assert err<1e-6,(name,err)
   count+=1
 clean=edge.copy();clean[clean[:,:,3]==0,:3]=0
 a=run(name,edge);b=run(name,clean);assert np.array_equal(a[edge[:,:,3]>0],b[edge[:,:,3]>0])
 # Sufficient conservative halo, negative scene origin and independently cropped input.
 src=rng.random((256,288,4),dtype=np.float32);src[:,:,3]=1
 p=[85,12,8,10,12,35,7,75];full=run(name,src,p,origin=(-120,-130));tile=run(name,src[20:236,20:268],p,origin=(-100,-110))
 roi_error=float(np.max(abs(full[110:146,110:178]-tile[90:126,90:158])));assert roi_error<1e-6,(name,roi_error)
 altered=src.copy();altered[:,:,:3]=np.clip(altered[:,:,:3]+1e-4,0,1)
 change=abs(run(name,altered)-run(name,src));perturb=float(change.mean());assert perturb<.01,(name,perturb)
 # Seed is effective on a textured input, but immutable across call order.
 p1=default.copy();p1[6]+=1
 assert not np.array_equal(run(name,src),run(name,src,p1)),name
 p0=default.copy();p0[0]=50;p1=default.copy();p1[0]=100
 half=run(name,src,p0);whole=run(name,src,p1)
 assert np.max(abs(half-(whole+src)*.5))<2e-7,name
 # Layout contracts: unique assembly/namespace/resource and numeric slider ranges.
 d=ROOT/'effects'/name;cs=(d/f'{name}Effect.cs').read_text();proj=(d/f'{name}.csproj').read_text()
 assert f'<AssemblyName>{name}</AssemblyName>' in proj and f'<RootNamespace>{name}</RootNamespace>' in proj
 pairs=re.findall(r'AnimationSlider\("[^"]+", "[^"]*", ([\d-]+), ([\d-]+)\)\]\s+public Animation (\w+) \{get;\} = new\(([^,]+),([^,]+),([^\)]+)\)',cs)
 assert len(pairs)==8
 for lo,hi,prop,val,amin,amax in pairs:assert float(lo)==float(amin) and float(hi)==float(amax) and float(lo)<=float(val)<=float(hi),(name,prop)
 results.append(dict(effect=name,cases=count,baseline_max_error=maxerr,roi_max_error=roi_error,perturbation_mae=perturb,perturbation_max=float(change.max()),alpha_exact=True,hidden_rgb_exact=True,premultiplied_valid=True,solid_identity=True,reproducible=True,seed_effective=True,strength_linear=True,ui_ranges=True))
print(json.dumps(results,indent=2));(ROOT/'docs/structures/tests.json').write_text(json.dumps(results,indent=2))
