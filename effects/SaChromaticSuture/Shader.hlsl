#define D2D_REQUIRES_SCENE_POSITION
#define D2D_ENTRY main
#include <d2d1effecthelpers.hlsli>
float strength,radius,size,threshold;
float iterations,color,seed,stability;
float4 inputBounds;
#define LOOP [loop]
#include "../../common/structures/Core.hlsli"
#include "Core.hlsli"
#define SA_EXACT_TEXEL_FAST_PATH
#include "../../common/Sampling.hlsli"
D2D_PS_ENTRY(main){float2 p=D2DGetScenePosition().xy;Pixel q=process(p.x,p.y);return float4(q.r,q.g,q.b,q.a);}
