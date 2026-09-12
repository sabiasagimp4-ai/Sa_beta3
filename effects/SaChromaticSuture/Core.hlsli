// Colour boundaries are crossed by thin curved stitches carrying opposite-side colour.
Pixel process(float x,float y){
 Pixel src=originalAt(x,y);if(strength<=0.0f||radius<=0.0f||src.a<=.000001f)return src;
 Guide g=guideAt(x,y,max(1.0f,min(radius*.5f,48.0f)));
 float n=sqrt(g.nx*g.nx+g.ny*g.ny+.002f),nx=g.nx/n,ny=g.ny/n;
 float along=(-x*sin(phase())+y*cos(phase()))/size+phase();
 // Local normal drives curvature; soft periodic stitches avoid hard winner changes.
 float curve=sin(along*6.2831853f+g.rg*4.0f);
 float thread=exp(-curve*curve*(2.0f+iterations*.25f));
 Pixel a=sampleAt(x+nx*radius*.65f,y+ny*radius*.65f);
 Pixel b=sampleAt(x-nx*radius*.65f,y-ny*radius*.65f);
 float e=gate(contrast(a,b));
 float cross=.5f+.5f*sin((x*cos(phase())+y*sin(phase()))/max(radius,1.0f)*3.1415927f+g.gb*3.0f);
 Pixel q=blendColor(a,b,cross);
 q=shade(q,.28f+1.05f*sqrt(thread));
 return finish(src,q,e*sqrt(thread));
}
