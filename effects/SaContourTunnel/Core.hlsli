// Opposed spatial probes make nested contour cavities, with no temporal echoes.
Pixel process(float x,float y){
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide g=guideAt(x,y,max(1.0f,min(radius*.35f,24.0f)));
 float rr=0.0f,gg=0.0f,bb=0.0f,total=0.0f,cover=0.0f;
 LOOP for(int i=0;i<24;++i){if(i>=int(iterations))break;
  float t=(float(i)+.5f)/iterations;
  float a=phase()+float(i)*2.3999632f;
  float nx=g.nx*.7f+cos(a)*.3f,ny=g.ny*.7f+sin(a)*.3f;
  Pixel q=sampleAt(x+nx*radius*t,y+ny*radius*t),op=sampleAt(x-nx*radius*t,y-ny*radius*t);
  float e=gate(contrast(q,op));float ring=.5f+.5f*cos(t*radius/size*6.2831853f+contrast(src,q)*12.0f);
  float w=e*(.15f+.85f*ring*ring)*(1.0f-.6f*t)*q.a;
  float relief=.32f+.95f*ring;
  rr+=red(q)*relief*w;gg+=green(q)*relief*w;bb+=blue(q)*relief*w;total+=w;cover+=e;
 }
 if(total<=.000001f)return src;
 return finish(src,rgb(rr/total,gg/total,bb/total),saturate(cover*2.4f/iterations));
}
