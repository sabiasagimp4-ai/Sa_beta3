#define D2D_REQUIRES_SCENE_POSITION
#define D2D_ENTRY main
#include <d2d1effecthelpers.hlsli>
float strength,radius,size,threshold;
float iterations,color,seed,padding;
float4 inputBounds;
#define LOOP [loop]
#include "../../common/Core.hlsli"
#ifdef BASELINE
#define GUIDE(x,y,cached) guideAt(x,y)
#else
#define GUIDE(x,y,cached) cached
#endif
#include "Core.hlsli"
#include "../../common/Sampling.hlsli"
D2D_PS_ENTRY(main){float2 p=D2DGetScenePosition().xy;Pixel q=process(p.x,p.y);return float4(q.r,q.g,q.b,q.a);}
