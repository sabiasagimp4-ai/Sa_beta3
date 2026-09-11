// Opposing colour boundaries interlock into alternating teeth; no channel separation.
Pixel process(float x,float y) {
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide cached=guideAt(x,y);float dx=0.0f,dy=0.0f,total=0.0f;
 LOOP for(int i=0;i<16;++i){if(i>=int(iterations))break;
 Guide g=GUIDE(x,y,cached);float a=noisePhase()+float(i)*2.3999632f;
 float u=cos(a),v=sin(a),t=float(i+1)/iterations;
 Pixel p=sampleAt(x+u*radius*t,y+v*radius*t),q=sampleAt(x-u*radius*t,y-v*radius*t);
 float w=gate(difference(p,q));float teeth=sin((x*(-v)+y*u)/size*6.2831853f+g.rg*7.0f+noisePhase());
 float signColor=(channelR(p)-channelB(p))-(channelR(q)-channelB(q));
 dx+=u*w*teeth*t*signColor;dy+=v*w*teeth*t*signColor;total+=w;
 }
 float norm=max(1.0f,total);Pixel target=sampleAt(x+radius*dx/norm,y+radius*dy/norm);
 return finish(src,target,saturate(total/iterations));
}
