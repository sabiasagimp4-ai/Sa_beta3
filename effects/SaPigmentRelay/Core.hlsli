// Soft pigment competition: saturation wins, dissimilar colours form a coloured contact seam.
Pixel process(float x,float y) {
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide cached=guideAt(x,y);float rr=channelR(src),gg=channelG(src),bb=channelB(src),total=1.0f,activity=0.0f;
 LOOP for(int i=0;i<16;++i){if(i>=int(iterations))break;
 Guide g=GUIDE(x,y,cached);float a=noisePhase()+float(i)*2.3999632f,u=cos(a),v=sin(a),t=float(i+1)/iterations;
 float reach=radius*t*(.65f+.35f*cos((x*u+y*v)/size+g.rg*4.0f));
 Pixel q=sampleAt(x+u*reach,y+v*reach);
 float r=channelR(q),b=channelB(q),c=channelG(q),ch=max(r,max(c,b))-min(r,min(c,b));
 float contrast=gate(difference(src,q));float w=exp(ch*5.0f-t*2.0f)*contrast*q.a;
 rr+=r*w;gg+=c*w;bb+=b*w;total+=w;activity+=contrast;
 }
 Pixel target;target.r=rr/total;target.g=gg/total;target.b=bb/total;target.a=1.0f;
 return finish(src,target,saturate(activity/iterations));
}
