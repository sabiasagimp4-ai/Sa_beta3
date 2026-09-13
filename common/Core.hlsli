// Scalar production code: compiled as HLSL and as C++ by the reference runner.
#include "Pixel.hlsli"
struct Guide { float gx; float gy; float rg; float gb; float edge; };
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
 // Apply the finish in straight RGB before the final strength blend.
 // This keeps RGB <= alpha and makes strength=50% the exact midpoint.
 float e=saturate(activity*1.8f),lsrc=lum(src);
 float shadow=saturate((0.58f-lsrc)*1.8f),light=saturate((lsrc-0.42f)*1.7f);
 float tr=saturate(saturate(mean+(r-mean)*c+(b-g)*s)+e*(shadow*.008f+light*.012f));
 float tg=saturate(saturate(mean+(g-mean)*c+(r-b)*s)+e*(shadow*.014f+light*.006f));
 float tb=saturate(saturate(mean+(b-mean)*c+(g-r)*s)+e*(shadow*.028f-light*.004f));
 Pixel outp;
 outp.r=lerp(src.r,tr*src.a,strength);
 outp.g=lerp(src.g,tg*src.a,strength);
 outp.b=lerp(src.b,tb*src.a,strength);
 outp.a=src.a;return outp;
}
