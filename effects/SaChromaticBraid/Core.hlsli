// Alternating opponent-colour ribbons exchange their crossing positions.
Pixel process(float x,float y) {
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide cached=guideAt(x,y);float px=x,py=y,activity=0.0f;
 LOOP for(int i=0;i<16;++i){if(i>=int(iterations))break;
 Guide g=GUIDE(x,y,cached);Pixel c=src;
 float rg=channelR(c)-channelG(c),gb=channelG(c)-channelB(c);
 float w=gate(sqrt(rg*rg+gb*gb)*.5f);float a=noisePhase()+float(i)*.35f;
 float step=radius/iterations;
 px+=step*w*sin(y/size*6.2831853f+rg*6.0f+a)*( .4f+.6f*abs(g.rg));
 py+=step*w*sin(x/size*6.2831853f-gb*6.0f-a)*( .4f+.6f*abs(g.gb));activity+=w;
 }
 return finish(src,sampleAt(px,py),activity/iterations);
}
