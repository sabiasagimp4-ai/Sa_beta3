import sys,json,time,hashlib,platform,argparse,io
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont
from runtime import *
parser=argparse.ArgumentParser();parser.add_argument('source');parser.add_argument('output');parser.add_argument('--quick',action='store_true');parser.add_argument('--font');args=parser.parse_args()
source=Path(args.source);out=Path(args.output);out.mkdir(parents=True,exist_ok=True)
src=np.asarray(Image.open(source).convert('RGBA'),dtype=np.float32)/255;src[:,:,:3]*=src[:,:,3:]
labels=['通常設定','弱め・自然','強い設定','極端・実験','映像向け']
fontpath=args.font or '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
font=ImageFont.truetype(fontpath,20);small=ImageFont.truetype(fontpath,15)
cw,ch=384,288
sheet=Image.new('RGB',(cw*5,64+(ch+64)*5),(19,22,29));draw=ImageDraw.Draw(sheet)
draw.text((16,10),'Sa_beta3 / 5 STRUCTURE EFFECTS / production-core CPU renders',font=font,fill='white')
draw.text((16,38),'1536 x 1152 | Same source pixels | No image-generation AI',font=small,fill=(175,190,208))
def save_image(im,path):
 buffer=io.BytesIO();im.save(buffer,format='PNG');data=buffer.getvalue()
 temporary=path.with_suffix('.tmp');temporary.write_bytes(data);temporary.replace(path)
 with Image.open(path) as check:check.load()
records=[];bench=[]
for row,name in enumerate(NAMES):
 p=META['defaults'][name]
 weak=[42,p[1]*.5,p[2]*1.3,p[3]+8,p[4],p[5]*.35,p[6],90]
 strong=[96,min(p[1]*1.8,256),max(p[2]*.8,4),4,min(p[4]+6,24),70,p[6],65]
 extreme=[100,min(p[1]*3.5,256),max(p[2]*.65,4),0,24,135,p[6]+10,40]
 video=[70,p[1]*.8,p[2]*1.15,p[3]+4,p[4],p[5]*.65,p[6],90]
 sets=[p,weak,strong,extreme,video];times=[]
 for col,preset in enumerate(sets):
  # Baseline and optimized share production formulas and differ only in sampling reuse.
  a=run(name,src,preset)
  ts=[];bs=[]
  if not args.quick:
   run(name,src,preset,True)
   for k in range(3):
    order=[False,True] if k%2==0 else [True,False]
    for baseline in order:
     t=time.perf_counter();v=run(name,src,preset,baseline);elapsed=(time.perf_counter()-t)*1000
     if baseline:bs.append(elapsed);b=v
     else:ts.append(elapsed);a=v
   err=float(np.max(abs(a-b)));mae=float(np.mean(abs(a-b)));assert err<1e-6
   times.append(dict(preset=labels[col],optimized_ms=float(np.median(ts)),baseline_ms=float(np.median(bs)),optimized_samples_ms=ts,baseline_samples_ms=bs,max_error=err,mae=mae,change_rgb_mae=float(np.mean(abs(a[:,:,:3]-src[:,:,:3])))))
  straight=a.copy();np.divide(a[:,:,:3],a[:,:,3:],out=straight[:,:,:3],where=a[:,:,3:]>0)
  im=Image.fromarray(np.uint8(np.clip(straight*255+.5,0,255)));fn=f'{row+1:02}_{name}_{col+1:02}.png';save_image(im,out/fn)
  sheet.paste(im.convert('RGB').resize((cw,ch),Image.Resampling.LANCZOS),(col*cw,64+row*(ch+64)+64))
  draw.text((col*cw+10,64+row*(ch+64)+4),f'{row+1}. {META["japanese"][row]}',font=font,fill='white')
  draw.text((col*cw+10,64+row*(ch+64)+32),labels[col],font=font,fill=(179,196,218))
  records.append(dict(file=fn,effect=name,preset=labels[col],properties=dict(zip(['Strength','Radius','Size','Threshold','Iterations','Color','Seed','Stability'],preset)),ui=dict(zip(META['parameters'],preset))))
  print(name,labels[col],round(times[-1]['optimized_ms'],1) if times else 'rendered',flush=True)
 bench.append(dict(effect=name,timings=times))
save_image(sheet,out/'comparison.png')
for row,name in enumerate(NAMES):
 save_image(sheet.crop((0,64+row*(ch+64),cw*5,64+(row+1)*(ch+64))),out/f'{row+1:02}_{name}_comparison.png')
(out/'parameters.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),source_size=[src.shape[1],src.shape[0]],renderer='Production HLSL scalar kernels compiled verbatim as C++ (CPU, not YMM4 GPU capture)',presets=records),ensure_ascii=False,indent=2))
if not args.quick:
 (out/'benchmark.json').write_text(json.dumps(dict(platform=platform.platform(),cpu=next((l.split(':',1)[1].strip() for l in Path('/proc/cpuinfo').read_text().splitlines() if l.startswith('model name')),''),threads=os.environ.get('OMP_NUM_THREADS'),size=[src.shape[1],src.shape[0]],compiler=subprocess.check_output(['g++','--version'],text=True).splitlines()[0],statistic='median of 3 per implementation after warmup, alternating order; includes output allocation; excludes decode and PNG encode',effects=bench),ensure_ascii=False,indent=2))
