#define D2D_REQUIRES_SCENE_POSITION
#define D2D_ENTRY main
#include <d2d1effecthelpers.hlsli>
float strength,radius,size,threshold;
float iterations,color,seed,stability;
float4 inputBounds;
#define LOOP [loop]
#include "../../common/structures/Core.hlsli"
#include "Core.hlsli"
float4 rawAt(float2 p){
 p=clamp(p,inputBounds.xy+.5f,inputBounds.zw-.5f);
 float4 uv=D2DGetInputCoordinate(0);
 return InputTexture0.SampleLevel(InputSampler0,uv.xy+uv.zw*(p-D2DGetScenePosition().xy),0);
}
Pixel originalAt(float x,float y){float4 c=rawAt(float2(x,y));Pixel p;p.r=c.r;p.g=c.g;p.b=c.b;p.a=c.a;return p;}
float4 cleanAt(float2 p){float4 c=rawAt(p);if(c.a<=0.0f)c.rgb=0.0f;return c;}
Pixel sampleAt(float x,float y){
 float2 p=clamp(float2(x,y),inputBounds.xy+.5f,inputBounds.zw-.5f);
 float2 b=floor(p-.5f)+.5f,t=p-b;
 float4 c=float4(0,0,0,0);
#ifndef BASELINE
 if(t.x==0.0f&&t.y==0.0f)c=cleanAt(b);
 else
#endif
 {c=lerp(lerp(cleanAt(b),cleanAt(b+float2(1,0)),t.x),lerp(cleanAt(b+float2(0,1)),cleanAt(b+float2(1,1)),t.x),t.y);}
 Pixel r;r.r=c.r;r.g=c.g;r.b=c.b;r.a=c.a;return r;
}
D2D_PS_ENTRY(main){float2 p=D2DGetScenePosition().xy;Pixel q=process(p.x,p.y);return float4(q.r,q.g,q.b,q.a);}
