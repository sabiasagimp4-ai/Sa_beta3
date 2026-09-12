// Image-oriented tapered crystal plates; no Voronoi palette reduction or mirror tiling.
Pixel process(float x,float y){
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 int cx=int(floor(x/size)),cy=int(floor(y/size));float rr=0.0f,gg=0.0f,bb=0.0f,total=0.0f;
 LOOP for(int j=-1;j<=1;++j) LOOP for(int i=-1;i<=1;++i){
  int ix=cx+i,iy=cy+j;float h=cellHash(ix,iy,123);
  float ax=(float(ix)+.35f+.3f*h)*size,ay=(float(iy)+.35f+.3f*cellHash(ix,iy,54))*size;
  float dx=(x-ax)/size,dy=(y-ay)/size;
  if(dx*dx+dy*dy>1.0f)continue;
  Guide g=guideAt(ax,ay,max(1.0f,min(radius*.4f,48.0f)));
  float angle=phase()+h*3.1415927f+g.rg*2.0f;float co=cos(angle),si=sin(angle);
  float u=dx*co+dy*si,v=-dx*si+dy*co;
  float height=saturate(1.0f-abs(u)/.72f-abs(v)/.32f);
  float coverage=smooth01(height*size*.3f);if(coverage<=0.0f)continue;
  float ridge=.5f+.5f*cos(u*iterations*3.1415927f+g.gb*3.0f);
  float displacement=radius*height*g.edge;
  Pixel q=sampleAt(x+co*displacement,y+si*displacement);
  float relief=.65f+.75f*smooth01(v*8.0f+.5f)+.18f*ridge*height;
  float w=coverage*g.edge*q.a;rr+=red(q)*relief*w;gg+=green(q)*relief*w;bb+=blue(q)*relief*w;total+=w;
 }
 if(total<=.000001f)return src;
 return finish(src,rgb(rr/total,gg/total,bb/total),saturate(total*1.6f));
}
