import sys,json
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
out=Path(sys.argv[1]);data=json.loads((out/'parameters.json').read_text())
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',20)
titles=['Chromatic Zipper','Petal Graft','Chromatic Braid','Membrane Fold','Pigment Relay'];labels=['Normal','Subtle / Natural','Strong','Extreme / Experimental','Video / Balanced']
sheet=Image.new('RGB',(1920,1770),(20,22,26));d=ImageDraw.Draw(sheet)
for i,item in enumerate(data['presets']):
 row,col=divmod(i,5);im=Image.open(out/item['file']).convert('RGB').resize((384,288),Image.Resampling.LANCZOS);sheet.paste(im,(col*384,row*354+66))
 d.text((col*384+10,row*354+5),f'{row+1}. {titles[row]}',font=font,fill='white');d.text((col*384+10,row*354+33),labels[col],font=font,fill=(190,200,212))
destination=Path(sys.argv[2]) if len(sys.argv)>2 else out/'comparison.png'
destination.parent.mkdir(parents=True,exist_ok=True)
temporary=destination.with_suffix('.tmp')
sheet.save(temporary,format='PNG')
temporary.replace(destination)
