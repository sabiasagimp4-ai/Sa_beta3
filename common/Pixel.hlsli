// Shared scalar colour primitives, compiled into each independent DLL.
#ifndef SA_PIXEL_HLSLI
#define SA_PIXEL_HLSLI
struct Pixel { float r; float g; float b; float a; };
Pixel sampleAt(float x,float y);
Pixel originalAt(float x,float y);
float channelR(Pixel p) { return p.a>0.000001f ? p.r/p.a : 0.0f; }
float channelG(Pixel p) { return p.a>0.000001f ? p.g/p.a : 0.0f; }
float channelB(Pixel p) { return p.a>0.000001f ? p.b/p.a : 0.0f; }
float lum(Pixel p) { return channelR(p)*.2126f+channelG(p)*.7152f+channelB(p)*.0722f; }
#endif
