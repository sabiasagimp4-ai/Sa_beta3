// WARP validation adapter. Executes the exact production scalar HLSL bodies.
cbuffer Parameters : register(b0){float strength,radius,size,threshold;float iterations,color,seed,stability;float4 inputBounds;};
Texture2D<float4> sourceTexture : register(t0);
RWTexture2D<float4> destination : register(u0);
#define LOOP [loop]
#include "../../common/structures/Core.hlsli"
#include EFFECT_CORE
float4 rawAt(float2 p){p=clamp(p,inputBounds.xy+.5f,inputBounds.zw-.5f);return sourceTexture.Load(int3(int2(floor(p-inputBounds.xy)),0));}
Pixel originalAt(float x,float y){float4 c=rawAt(float2(x,y));Pixel p;p.r=c.r;p.g=c.g;p.b=c.b;p.a=c.a;return p;}
float4 cleanAt(float2 p){float4 c=rawAt(p);if(c.a<=0.0f)c.rgb=0.0f;return c;}
Pixel sampleAt(float x,float y){
 float2 p=clamp(float2(x,y),inputBounds.xy+.5f,inputBounds.zw-.5f),b=floor(p-.5f)+.5f,t=p-b;
 float4 c=float4(0,0,0,0);
#ifndef BASELINE
 if(t.x==0.0f&&t.y==0.0f)c=cleanAt(b);
 else
#endif
 {c=lerp(lerp(cleanAt(b),cleanAt(b+float2(1,0)),t.x),lerp(cleanAt(b+float2(0,1)),cleanAt(b+float2(1,1)),t.x),t.y);}
 Pixel r;r.r=c.r;r.g=c.g;r.b=c.b;r.a=c.a;return r;
}
[numthreads(8,8,1)] void main(uint3 p:SV_DispatchThreadID){
 uint w,h;destination.GetDimensions(w,h);if(p.x>=w||p.y>=h)return;
 Pixel q=process(float(p.x)+inputBounds.x+.5f,float(p.y)+inputBounds.y+.5f);
 destination[p.xy]=float4(q.r,q.g,q.b,q.a);
}
