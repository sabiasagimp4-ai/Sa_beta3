// Scalar production code: compiled as HLSL and as C++ by the reference runner.
struct Pixel { float r; float g; float b; float a; };
struct Guide { float gx; float gy; float rg; float gb; float edge; };
Pixel sampleAt(float x,float y);
Pixel originalAt(float x,float y);
float channelR(Pixel p) { return p.a>0.000001f ? p.r/p.a : 0.0f; }
float channelG(Pixel p) { return p.a>0.000001f ? p.g/p.a : 0.0f; }
float channelB(Pixel p) { return p.a>0.000001f ? p.b/p.a : 0.0f; }
float lum(Pixel p) { return channelR(p)*.2126f+channelG(p)*.7152f+channelB(p)*.0722f; }
float difference(Pixel a,Pixel b) {
 float r=channelR(a)-channelR(b),g=channelG(a)-channelG(b),c=channelB(a)-channelB(b);
 return sqrt((r*r+g*g+c*c)/3.0f)*min(a.a,b.a);
}
float gate(float v) { float t=saturate((v-threshold)/.12f); return t*t*(3.0f-2.0f*t); }
float noisePhase() { return frac(seed*.61803398875f)*6.2831853f; }
Guide guideAt(float x,float y) {
 float h=max(1.0f,min(size*.125f,8.0f));
 Pixel c=sampleAt(x,y),l=sampleAt(x-h,y),r=sampleAt(x+h,y),u=sampleAt(x,y-h),d=sampleAt(x,y+h);
 Guide g;
 g.gx=(lum(r)-lum(l))*min(r.a,l.a);g.gy=(lum(d)-lum(u))*min(d.a,u.a);
 g.rg=channelR(c)-channelG(c);g.gb=channelG(c)-channelB(c);
 g.edge=gate(sqrt(g.gx*g.gx+g.gy*g.gy));return g;
}
Pixel colorMix(Pixel c,Pixel q,float t) {
 if(q.a<=.000001f)return c;
 Pixel p;
 p.r=lerp(channelR(c),channelR(q),t);p.g=lerp(channelG(c),channelG(q),t);p.b=lerp(channelB(c),channelB(q),t);p.a=1.0f;return p;
}
Pixel finish(Pixel src,Pixel target,float activity) {
 if(target.a<=.000001f)return src;
 float r=channelR(target),g=channelG(target),b=channelB(target);
 // Rotation about the RGB neutral axis, restricted by structural activity.
 float a=color*activity,c=cos(a),s=sin(a)*.577350269f,mean=(r+g+b)/3.0f;
 Pixel outp;
 outp.r=lerp(src.r,saturate(mean+(r-mean)*c+(b-g)*s)*src.a,strength);
 outp.g=lerp(src.g,saturate(mean+(g-mean)*c+(r-b)*s)*src.a,strength);
 outp.b=lerp(src.b,saturate(mean+(b-mean)*c+(g-r)*s)*src.a,strength);
 outp.a=src.a;return outp;
}
