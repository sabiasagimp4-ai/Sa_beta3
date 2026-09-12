// Compact, overlapping iris apertures: source contrast controls their opening.
Pixel process(float x,float y){
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 int cx=int(floor(x/size)),cy=int(floor(y/size));
 float rr=0.0f,gg=0.0f,bb=0.0f,total=0.0f;
 LOOP for(int j=-1;j<=1;++j) LOOP for(int i=-1;i<=1;++i){
  int ix=cx+i,iy=cy+j;float h=cellHash(ix,iy,17);
  float ax=(float(ix)+.3f+.4f*h)*size,ay=(float(iy)+.3f+.4f*cellHash(ix,iy,71))*size;
  float dx=(x-ax)/size,dy=(y-ay)/size,d=sqrt(dx*dx+dy*dy+.000001f);
  float envelope=smooth01((.7f-d)/.22f);if(envelope<=0.0f)continue;
  Guide g=guideAt(ax,ay,max(1.0f,min(radius*.45f,48.0f)));
  float e=g.edge;float theta=atan2(dy,dx),opening=.22f+.18f*(.5f+.5f*g.rg);
  float ribs=.5f+.5f*cos(theta*iterations+g.gb*4.0f+h*6.2831853f);
  float ring=exp(-abs(d-opening)*18.0f);
  float offset=radius*e*(.25f+.6f*ring)*(.25f+.75f*ribs);
  Pixel q=sampleAt(x+dx/(d+.02f)*offset,y+dy/(d+.02f)*offset);
  float relief=1.0f-.55f*exp(-d*d/((opening*.75f)*(opening*.75f)))+.3f*ring*ribs;
  float w=envelope*e*q.a;rr+=red(q)*relief*w;gg+=green(q)*relief*w;bb+=blue(q)*relief*w;total+=w;
 }
 if(total<=.000001f)return src;
 return finish(src,rgb(rr/total,gg/total,bb/total),saturate(total));
}
