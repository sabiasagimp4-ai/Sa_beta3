// Curved directional filaments pull contrasting colour into a boundary's surroundings.
Pixel process(float x,float y){
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide g=guideAt(x,y,max(1.0f,min(radius*.4f,40.0f)));
 float theta=phase()*.4f,dx=cos(theta),dy=sin(theta);
 float along=(-x*dy+y*dx)/size;
 float rr=0.0f,gg=0.0f,bb=0.0f,total=0.0f,coverage=0.0f;
 LOOP for(int i=0;i<24;++i){if(i>=int(iterations))break;
  float t=(float(i)+.5f)/iterations;
  float curl=sin(t*4.0f+g.gb*3.0f+phase())*t*t*radius*.45f;
  Pixel q=sampleAt(x-dx*radius*t-dy*curl,y-dy*radius*t+dx*curl);
  float e=gate(contrast(src,q));
  float branch=sin(along*6.2831853f+g.rg*5.0f+t*.35f+sin(along*3.1415927f+phase())*.8f);
  float filament=exp(-branch*branch*(10.0f+18.0f*t));
  float w=e*exp(5.0f*e)*filament*(.2f+.8f*t)*q.a;
  rr+=red(q)*w;gg+=green(q)*w;bb+=blue(q)*w;total+=w;coverage+=e*filament;
 }
 if(total<=.000001f)return src;
 return finish(src,rgb(rr/total,gg/total,bb/total),saturate(coverage*10.0f/iterations));
}
