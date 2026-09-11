import ctypes,json,subprocess,os
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
META=json.loads((ROOT/'tests/effects.json').read_text())
NAMES=META['names']
DEFAULT=[85,36,24,18,12,35,7]
LIBS={}
def build():
 for name in NAMES:
  for baseline in [False,True]:
   dest=ROOT/'tests'/f'{name}{"_baseline" if baseline else ""}.so'
   cmd=['g++','-O3','-std=c++17','-fopenmp','-shared','-fPIC','-ffp-contract=off',f'-DEFFECT_CORE="../effects/{name}/Core.hlsli"']
   if baseline:cmd+=['-DBASELINE']
   subprocess.run(cmd+[str(ROOT/'tests/reference.cpp'),'-o',str(dest)],check=True)
def run(name,src,ui=DEFAULT,baseline=False,origin=(0,0)):
 key=(name,baseline)
 if key not in LIBS:
  lib=ctypes.CDLL(str(ROOT/'tests'/f'{name}{"_baseline" if baseline else ""}.so'))
  lib.render.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_void_p,ctypes.c_int,ctypes.c_int];LIBS[key]=lib
 p=np.array(ui,dtype=np.float32);p[0]/=100;p[3]/=255;p[5]*=np.pi/180
 src=np.ascontiguousarray(src,dtype=np.float32);out=np.empty_like(src);h,w=src.shape[:2]
 LIBS[key].render(src.ctypes.data,out.ctypes.data,w,h,p.ctypes.data,*origin)
 return out
if __name__=='__main__':build()
