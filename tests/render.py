import sys,json,time,hashlib,platform
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont
from runtime import *
source=Path(sys.argv[1]);out=Path(sys.argv[2]);out.mkdir(parents=True,exist_ok=True)
src=np.asarray(Image.open(source).convert('RGBA'),dtype=np.float32)/255;src[:,:,:3]*=src[:,:,3:]
labels=['通常','弱め・自然','強い','極端・実験','映像向け']
sets=[[78,42,20,10,16,28,7],[42,18,32,24,12,12,11],[94,76,16,8,16,68,19],[100,176,8,0,16,118,41],[68,34,30,16,12,24,17]]
fontpaths=['/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc','/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf']
font=next((ImageFont.truetype(f,21) for f in fontpaths if Path(f).exists()),ImageFont.load_default())
cellw,cellh=384,288
sheet=Image.new('RGB',(cellw*5, (cellh+66)*5),(20,22,26));draw=ImageDraw.Draw(sheet)
report=[];parameters=[]
for row,name in enumerate(NAMES):
 timings=[]
 for col,p in enumerate(sets):
  # Warmup then median of 3 measurements of the same complete full-resolution core.
  run(name,src,p);ts=[]
  for _ in range(3):
   t=time.perf_counter();a=run(name,src,p);ts.append((time.perf_counter()-t)*1000)
  t=time.perf_counter();b=run(name,src,p,True);baseline=(time.perf_counter()-t)*1000
  err=float(np.max(abs(a-b)));mae=float(np.mean(abs(a-b)))
  assert err<1e-6
  straight=a.copy();np.divide(a[:,:,:3],a[:,:,3:],out=straight[:,:,:3],where=a[:,:,3:]>0)
  im=Image.fromarray(np.uint8(np.clip(straight*255+.5,0,255)),'RGBA');filename=f'{row+1:02}_{name}_{col+1:02}.png';im.save(out/filename)
  thumb=im.convert('RGB').resize((cellw,cellh),Image.Resampling.LANCZOS);sheet.paste(thumb,(col*cellw,row*(cellh+66)+66))
  draw.text((col*cellw+10,row*(cellh+66)+5),f'{row+1}. {META["japanese"][row]}',font=font,fill='white')
  draw.text((col*cellw+10,row*(cellh+66)+33),labels[col],font=font,fill=(190,200,212))
  parameters.append(dict(file=filename,effect=name,preset=labels[col],ui={m[1]:v for m,v in zip(META['parameters'],p)}))
  timings.append(dict(preset=labels[col],optimized_ms=float(np.median(ts)),baseline_ms=baseline,max_error=err,mae=mae,change_mae=float(np.mean(abs(a-src)))))
  print(name,labels[col],round(timings[-1]['optimized_ms'],1),'ms',flush=True)
 report.append(dict(effect=name,timings=timings))
sheet.save(out/'comparison.png')
(out/'parameters.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),source_size=[src.shape[1],src.shape[0]],renderer='Production HLSL scalar cores compiled as C++ (not YMM4 GPU)',presets=parameters),ensure_ascii=False,indent=2))
(out/'benchmark.json').write_text(json.dumps(dict(platform=platform.platform(),threads=os.environ.get('OMP_NUM_THREADS'),size=[src.shape[1],src.shape[0]],optimized_statistic='median of 3 after warmup',baseline_statistic='single run',effects=report),ensure_ascii=False,indent=2))

# Rebuild labels in a portable Latin font when Japanese fonts are unavailable.
import subprocess
subprocess.run([sys.executable,str(ROOT/"tests/contact_sheet.py"),str(out)],check=True)
