import json,hashlib
import numpy as np
from runtime import *
rng=np.random.default_rng(934)
random=rng.random((27,31,4),dtype=np.float32);random[:,:,:3]*=random[:,:,3:]
transparent=np.zeros((9,13,4),np.float32);transparent[:,:,:3]=rng.random((9,13,3))
solid=np.full((17,19,4),.3,np.float32);solid[:,:,3]=1
edge=random.copy();edge[:8,:,3]=0;edge[:8,:,:3]=.9
cases=[np.array([[[.3,.2,.1,.5]]],np.float32),transparent,solid,random,edge]
settings=[DEFAULT,[0,256,2,0,16,180,65535],[100,0,2,0,16,180,65535],[100,256,2,0,16,180,65535],[100,256,128,255,1,-180,0]]
results=[]
for name in NAMES:
 count=0;maxerr=0
 for src in cases:
  for p in settings:
   a=run(name,src,p);b=run(name,src,p,True)
   assert np.isfinite(a).all()
   assert np.array_equal(a[:,:,3],src[:,:,3])
   mask=src[:,:,3]==0;assert np.array_equal(a[mask],src[mask])
   assert np.array_equal(a,run(name,src,p))
   if p[0]==0 or p[1]==0:assert np.array_equal(a,src)
   err=float(np.max(abs(a-b)));maxerr=max(maxerr,err);assert err<1e-6
   count+=1
 # Transparent hidden RGB must not influence neighbouring visible pixels.
 clean=edge.copy();clean[clean[:,:,3]==0,:3]=0
 a=run(name,edge);b=run(name,clean);assert np.array_equal(a[edge[:,:,3]>0],b[edge[:,:,3]>0])
 # Tile + halo gives identical scene-coordinate output; include negative origin.
 src=rng.random((130,150,4),dtype=np.float32);src[:,:,3]=1
 p=[85,12,24,18,12,35,7];full=run(name,src,p,origin=(-30,-40));tile=run(name,src[10:120,10:140],p,origin=(-20,-30))
 roi_error=float(np.max(abs(full[50:80,50:100]-tile[40:70,40:90])));assert roi_error<1e-4
 # Tiny input changes are measured, not claimed to prove flicker-free video.
 shifted=src.copy();shifted[:,:,:3]+=1e-4
 stability=float(np.mean(abs(run(name,src)-run(name,shifted))))
 results.append(dict(effect=name,cases=count,baseline_max_error=maxerr,perturbation_mean_error=stability,alpha=True,hidden_rgb=True,roi=True,roi_max_error=roi_error,reproducible=True))
print(json.dumps(results,indent=2));(ROOT/'docs/tests.json').write_text(json.dumps(results,indent=2))
