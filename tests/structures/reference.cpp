#include <cmath>
#include <algorithm>
#include <cstddef>
#include <cstdint>
using uint=uint32_t;
using std::sin;using std::cos;using std::exp;using std::sqrt;using std::abs;using std::max;using std::min;using std::floor;using std::atan2;
static float saturate(float x){return std::clamp(x,0.f,1.f);}
static float frac(float x){return x-std::floor(x);}
static float lerp(float a,float b,float t){return a+(b-a)*t;}
static thread_local float strength,radius,size,threshold,iterations,color,seed,stability;
static thread_local const float* pixels;
static thread_local int width,height,originX,originY;
#define LOOP
#include "../../common/structures/Core.hlsli"
#include EFFECT_CORE
Pixel originalAt(float x,float y){
 int ix=std::clamp(int(x-.5f)-originX,0,width-1),iy=std::clamp(int(y-.5f)-originY,0,height-1);
 const float* p=pixels+(size_t(iy)*width+ix)*4;return {p[0],p[1],p[2],p[3]};
}
Pixel sampleAt(float x,float y){
 x=std::clamp(x-.5f,float(originX),float(originX+width-1));y=std::clamp(y-.5f,float(originY),float(originY+height-1));
 float bx=floor(x),by=floor(y),tx=x-bx,ty=y-by;
 int x0=int(bx)-originX,y0=int(by)-originY,x1=min(x0+1,width-1),y1=min(y0+1,height-1);
 size_t offsets[4]={(size_t(y0)*width+x0)*4,(size_t(y0)*width+x1)*4,(size_t(y1)*width+x0)*4,(size_t(y1)*width+x1)*4};
#ifndef BASELINE
 if(tx==0.f&&ty==0.f){const float* p=pixels+offsets[0];return p[3]<=0.f?Pixel{0.f,0.f,0.f,p[3]}:Pixel{p[0],p[1],p[2],p[3]};}
#endif
 float out[4];
#ifdef BASELINE
 // Simple per-channel, four-tap reference. Hidden RGB is cleaned before interpolation.
 for(int c=0;c<4;++c){float v[4];for(int k=0;k<4;++k)v[k]=(c<3&&pixels[offsets[k]+3]<=0.f)?0.f:pixels[offsets[k]+c];out[c]=lerp(lerp(v[0],v[1],tx),lerp(v[2],v[3],tx),ty);}
#else
 // Reuse alpha checks and contiguous texels across all channels. Same lerp order.
 Pixel v[4];
 for(int k=0;k<4;++k){const float* p=pixels+offsets[k];v[k]={p[0],p[1],p[2],p[3]};if(p[3]<=0.f){v[k].r=0.f;v[k].g=0.f;v[k].b=0.f;}}
 out[0]=lerp(lerp(v[0].r,v[1].r,tx),lerp(v[2].r,v[3].r,tx),ty);
 out[1]=lerp(lerp(v[0].g,v[1].g,tx),lerp(v[2].g,v[3].g,tx),ty);
 out[2]=lerp(lerp(v[0].b,v[1].b,tx),lerp(v[2].b,v[3].b,tx),ty);
 out[3]=lerp(lerp(v[0].a,v[1].a,tx),lerp(v[2].a,v[3].a,tx),ty);
#endif
 return {out[0],out[1],out[2],out[3]};
}
extern "C" void render(const float* src,float* dst,int w,int h,const float* p,int ox,int oy){
 #pragma omp parallel
 {
 pixels=src;width=w;height=h;originX=ox;originY=oy;
 strength=p[0];radius=p[1];size=p[2];threshold=p[3];iterations=p[4];color=p[5];seed=p[6];stability=p[7];
 #pragma omp for
 for(int y=0;y<h;++y)for(int x=0;x<w;++x){Pixel q=process(x+ox+.5f,y+oy+.5f);size_t i=(size_t(y)*w+x)*4;dst[i]=q.r;dst[i+1]=q.g;dst[i+2]=q.b;dst[i+3]=q.a;}
 }
}
