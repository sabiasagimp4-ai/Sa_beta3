// A bounded inverse fold driven by the original local membrane normal.
Pixel process(float x,float y) {
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide cached=guideAt(x,y);float px=x,py=y,activity=0.0f;
 LOOP for(int i=0;i<16;++i){if(i>=int(iterations))break;
 Guide g=GUIDE(x,y,cached);float n=sqrt(g.gx*g.gx+g.gy*g.gy)+.02f;
 float pressure=g.rg*float(i+1)/iterations;
 float fold=sin(pressure*12.0f+(x*g.gx+y*g.gy)/max(n*size,1.0f)+noisePhase());
 float k=radius/iterations*g.edge*fold;
 px-=k*g.gx/n;py-=k*g.gy/n;activity+=g.edge*abs(fold);
 }
 return finish(src,sampleAt(px,py),activity/iterations);
}
