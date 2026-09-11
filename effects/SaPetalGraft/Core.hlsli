// Source-colour contrast sprouts lobed copies around spatially distributed graft points.
Pixel process(float x,float y) {
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide cached=guideAt(x,y);float rr=0.0f,gg=0.0f,bb=0.0f,total=0.0f,activity=0.0f;
 LOOP for(int i=0;i<16;++i){if(i>=int(iterations))break;
 Guide g=GUIDE(x,y,cached);float a=noisePhase()+float(i)*2.3999632f,u=cos(a),v=sin(a);
 float t=float(i+1)/iterations,dist=radius*t;
 Pixel bud=sampleAt(x+u*dist,y+v*dist);float contrast=gate(difference(src,bud));
 float petal=.5f+.5f*cos((x*u+y*v)/size*6.2831853f+g.rg*9.0f+g.gb*5.0f+noisePhase());
 float curl=(petal-.5f)*dist;
 Pixel q=sampleAt(x+u*dist*petal-v*curl,y+v*dist*petal+u*curl);
 float w=contrast*petal*petal*q.a;
 rr+=channelR(q)*w;gg+=channelG(q)*w;bb+=channelB(q)*w;total+=w;activity+=contrast;
 }
 Pixel target=src;if(total>.000001f){target.r=rr/total;target.g=gg/total;target.b=bb/total;target.a=1.0f;}
 target=colorMix(src,target,saturate(total*2.0f/iterations));
 return finish(src,target,saturate(activity/iterations));
}
