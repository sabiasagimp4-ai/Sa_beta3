// Production scalar kernel, shared verbatim with the portable C++ renderer.
struct Pixel { float r; float g; float b; float a; };
struct Guide { float nx; float ny; float edge; float rg; float gb; };
Pixel sampleAt(float x,float y);
Pixel originalAt(float x,float y);
float red(Pixel p){return p.a>0.000001f?p.r/p.a:0.0f;}
float green(Pixel p){return p.a>0.000001f?p.g/p.a:0.0f;}
float blue(Pixel p){return p.a>0.000001f?p.b/p.a:0.0f;}
float luminance(Pixel p){return red(p)*.2126f+green(p)*.7152f+blue(p)*.0722f;}
float smooth01(float x){x=saturate(x);return x*x*(3.0f-2.0f*x);}
float gate(float v){return smooth01((v-threshold)/(.045f+.2f*stability));}
float contrast(Pixel a,Pixel b){float r=red(a)-red(b),g=green(a)-green(b),c=blue(a)-blue(b);return sqrt((r*r+g*g+c*c)/3.0f)*min(a.a,b.a);}
float phase(){return frac(seed*.61803398875f)*6.2831853f;}
// Integer hash: no frame number, input colour, or sin-dependent random state.
float cellHash(int x,int y,int salt){uint h=uint(x)*1597334677u ^ uint(y)*3812015801u ^ uint(seed)*2798796415u ^ uint(salt);h^=h>>16;h*=2246822519u;h^=h>>13;h*=3266489917u;h^=h>>16;return float(h&16777215u)/16777216.0f;}
Guide guideAt(float x,float y,float h){
 Pixel c=sampleAt(x,y),l=sampleAt(x-h,y),r=sampleAt(x+h,y),u=sampleAt(x,y-h),d=sampleAt(x,y+h);
 // Opponent-colour slope catches equal-luminance edges as well.
 float gx=(luminance(r)-luminance(l)+.35f*(red(r)-blue(r)-red(l)+blue(l)))*min(r.a,l.a);
 float gy=(luminance(d)-luminance(u)+.35f*(red(d)-blue(d)-red(u)+blue(u)))*min(d.a,u.a);
 float n=sqrt(gx*gx+gy*gy+.0004f);
 Guide g;g.nx=gx/n;g.ny=gy/n;g.edge=gate(max(contrast(l,r),contrast(u,d)));g.rg=red(c)-green(c);g.gb=green(c)-blue(c);return g;
}
Pixel rgb(float r,float g,float b){Pixel p;p.r=r;p.g=g;p.b=b;p.a=1.0f;return p;}
Pixel blendColor(Pixel a,Pixel b,float w){if(b.a<=.000001f)return a;return rgb(lerp(red(a),red(b),w),lerp(green(a),green(b),w),lerp(blue(a),blue(b),w));}
Pixel shade(Pixel p,float value){return rgb(red(p)*value,green(p)*value,blue(p)*value);}
Pixel finish(Pixel src,Pixel target,float activity){
 if(activity<=0.0f||target.a<=.000001f)return src;
 float r=red(target),g=green(target),b=blue(target),a=color*activity;
 float co=cos(a),si=sin(a)*.577350269f,m=(r+g+b)/3.0f;
 float w=strength*saturate(activity);
 Pixel q;
 q.r=lerp(src.r,saturate(m+(r-m)*co+(b-g)*si)*src.a,w);
 q.g=lerp(src.g,saturate(m+(g-m)*co+(r-b)*si)*src.a,w);
 q.b=lerp(src.b,saturate(m+(b-m)*co+(g-r)*si)*src.a,w);
 q.a=src.a;return q;
}
