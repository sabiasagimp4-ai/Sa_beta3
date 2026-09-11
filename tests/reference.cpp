#include <cmath>
#include <algorithm>
#include <cstddef>
using std::sin;using std::cos;using std::exp;using std::sqrt;using std::abs;using std::max;using std::min;
static float saturate(float x){return std::clamp(x,0.f,1.f);}
static float frac(float x){return x-std::floor(x);}
static float lerp(float a,float b,float t){return a+(b-a)*t;}
static thread_local float strength,radius,size,threshold,iterations,color,seed;
static thread_local const float* pixels;
static thread_local int width,height,originX,originY;
#define LOOP
#ifdef BASELINE
#define GUIDE(x,y,cached) guideAt(x,y)
#else
#define GUIDE(x,y,cached) cached
#endif
#include "../common/Core.hlsli"
#include EFFECT_CORE
Pixel originalAt(float x,float y){
 int ix=std::clamp(int(x-.5f)-originX,0,width-1),iy=std::clamp(int(y-.5f)-originY,0,height-1);
 const float* p=pixels+(iy*width+ix)*4;return {p[0],p[1],p[2],p[3]};
}
Pixel sampleAt(float x,float y){
 x=std::clamp(x-.5f-originX,0.f,float(width-1));y=std::clamp(y-.5f-originY,0.f,float(height-1));
 int x0=int(x),y0=int(y),x1=min(x0+1,width-1),y1=min(y0+1,height-1);float tx=x-x0,ty=y-y0;
 float out[4];int offsets[4]={(y0*width+x0)*4,(y0*width+x1)*4,(y1*width+x0)*4,(y1*width+x1)*4};
 for(int c=0;c<4;++c){float v[4];for(int k=0;k<4;++k)v[k]=(c<3&&pixels[offsets[k]+3]<=0.f)?0.f:pixels[offsets[k]+c];out[c]=lerp(lerp(v[0],v[1],tx),lerp(v[2],v[3],tx),ty);}
 return {out[0],out[1],out[2],out[3]};
}
extern "C" void render(const float* src,float* dst,int w,int h,const float* p,int ox,int oy){
 #pragma omp parallel
 {
 pixels=src;width=w;height=h;originX=ox;originY=oy;
 strength=p[0];radius=p[1];size=p[2];threshold=p[3];iterations=p[4];color=p[5];seed=p[6];
 #pragma omp for
 for(int y=0;y<h;++y)for(int x=0;x<w;++x){Pixel q=process(x+ox+.5f,y+oy+.5f);size_t i=(size_t(y)*w+x)*4;dst[i]=q.r;dst[i+1]=q.g;dst[i+2]=q.b;dst[i+3]=q.a;}
 }
}
