// Compile once per effect together with reference.cpp through a generated wrapper.
#define NOMINMAX
#include <d3d11.h>
#include <wrl/client.h>
#include <vector>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <cstring>
using Microsoft::WRL::ComPtr;
static void check(HRESULT hr){if(FAILED(hr))throw std::runtime_error("D3D11 failure: "+std::to_string(hr));}
static std::vector<char> bytes(const char* file){std::ifstream f(file,std::ios::binary);if(!f)throw std::runtime_error("Missing shader");return {std::istreambuf_iterator<char>(f),{}};}
int main(int argc,char** argv){try{
 if(argc!=3)throw std::runtime_error("warp optimized.cso baseline.cso");
 ComPtr<ID3D11Device> device;ComPtr<ID3D11DeviceContext> context;
 check(D3D11CreateDevice(nullptr,D3D_DRIVER_TYPE_WARP,nullptr,0,nullptr,0,D3D11_SDK_VERSION,&device,nullptr,&context));
 ComPtr<ID3D11ComputeShader> shaders[2];
 for(int k=0;k<2;k++){auto code=bytes(argv[k+1]);check(device->CreateComputeShader(code.data(),code.size(),nullptr,&shaders[k]));}
 float totalMax=0,baseMax=0;double totalMae=0;int tests=0;
 for(int test=0;test<18;test++){
  UINT w=test==0?1:37,h=test==0?1:29;std::vector<float> input(w*h*4),cpu(w*h*4),output[2];
  uint32_t state=719;auto random=[&](){state=state*1664525u+1013904223u;return float(state&65535)/65535.f;};
  for(UINT i=0;i<w*h;i++){
   float alpha=test==1?0.f:(test==2?1.f:random());
   input[4*i]=test==2?.3f:random()*alpha;input[4*i+1]=test==2?.2f:random()*alpha;input[4*i+2]=test==2?.1f:random()*alpha;input[4*i+3]=alpha;
   if(test==1 || (test>2&&i%7==0)){input[4*i]=.9f;input[4*i+1]=.7f;input[4*i+2]=.8f;input[4*i+3]=0.f;}
  }
  float params[12]={.85f,36.f,24.f,10.f/255.f,12.f,.7f,7.f,.75f,-11.f,-17.f,float(w)-11.f,float(h)-17.f};
  if(test==3)params[0]=0;if(test==4)params[1]=0;
  if(test>=5){params[1]=test%2?256.f:1.f;params[2]=test%3?4.f:192.f;params[3]=test%4?0.f:1.f;params[4]=test%2?24.f:1.f;params[5]=test%2?3.1415927f:-3.1415927f;params[6]=test%2?65535.f:0.f;params[7]=test%2?0.f:1.f;}
  render(input.data(),cpu.data(),w,h,params,-11,-17);
  D3D11_TEXTURE2D_DESC desc={};desc.Width=w;desc.Height=h;desc.MipLevels=desc.ArraySize=1;desc.Format=DXGI_FORMAT_R32G32B32A32_FLOAT;desc.SampleDesc.Count=1;desc.Usage=D3D11_USAGE_DEFAULT;desc.BindFlags=D3D11_BIND_SHADER_RESOURCE;
  D3D11_SUBRESOURCE_DATA data={};data.pSysMem=input.data();data.SysMemPitch=w*16;
  ComPtr<ID3D11Texture2D> source;check(device->CreateTexture2D(&desc,&data,&source));ComPtr<ID3D11ShaderResourceView> srv;check(device->CreateShaderResourceView(source.Get(),nullptr,&srv));
  desc.BindFlags=D3D11_BIND_UNORDERED_ACCESS;ComPtr<ID3D11Texture2D> target;check(device->CreateTexture2D(&desc,nullptr,&target));ComPtr<ID3D11UnorderedAccessView> uav;check(device->CreateUnorderedAccessView(target.Get(),nullptr,&uav));
  desc.BindFlags=0;desc.Usage=D3D11_USAGE_STAGING;desc.CPUAccessFlags=D3D11_CPU_ACCESS_READ;ComPtr<ID3D11Texture2D> staging;check(device->CreateTexture2D(&desc,nullptr,&staging));
  D3D11_BUFFER_DESC bd={};bd.ByteWidth=48;bd.Usage=D3D11_USAGE_DEFAULT;bd.BindFlags=D3D11_BIND_CONSTANT_BUFFER;D3D11_SUBRESOURCE_DATA pd={};pd.pSysMem=params;ComPtr<ID3D11Buffer> cb;check(device->CreateBuffer(&bd,&pd,&cb));
  auto* cbp=cb.Get();auto* sp=srv.Get();auto* up=uav.Get();context->CSSetConstantBuffers(0,1,&cbp);context->CSSetShaderResources(0,1,&sp);context->CSSetUnorderedAccessViews(0,1,&up,nullptr);
  for(int k=0;k<2;k++){
   context->CSSetShader(shaders[k].Get(),nullptr,0);context->Dispatch((w+7)/8,(h+7)/8,1);context->CopyResource(staging.Get(),target.Get());
   D3D11_MAPPED_SUBRESOURCE mapped={};check(context->Map(staging.Get(),0,D3D11_MAP_READ,0,&mapped));output[k].resize(w*h*4);
   for(UINT y=0;y<h;y++)std::memcpy(output[k].data()+y*w*4,static_cast<const char*>(mapped.pData)+y*mapped.RowPitch,w*16);context->Unmap(staging.Get(),0);
  }
  context->ClearState();float maxerr=0;double mae=0;
  for(size_t i=0;i<cpu.size();i++){
   float a=output[0][i];if(!std::isfinite(a))throw std::runtime_error("Nonfinite GPU result");
   if(i%4==3 && a!=input[i])throw std::runtime_error("GPU alpha mismatch");
   if(input[(i/4)*4+3]==0 && a!=input[i])throw std::runtime_error("GPU hidden RGB mismatch");
   if(input[(i/4)*4+3]>0 && (a < -1e-6f || a>input[(i/4)*4+3]+1e-6f))throw std::runtime_error("GPU premultiply violation");
   float e=std::abs(a-cpu[i]);maxerr=std::max(maxerr,e);mae+=e;
   baseMax=std::max(baseMax,std::abs(a-output[1][i]));
  }
  mae/=cpu.size();if(maxerr>.03f || mae>.001)throw std::runtime_error("CPU/GPU drift: "+std::to_string(maxerr)+" mae "+std::to_string(mae));
  totalMax=std::max(totalMax,maxerr);totalMae=std::max(totalMae,mae);tests++;
 }
 if(baseMax>1e-6f)throw std::runtime_error("GPU optimization drift: "+std::to_string(baseMax));
 std::cout<<"{\"cases\":"<<tests<<",\"cpu_gpu_max\":"<<totalMax<<",\"cpu_gpu_mae_max\":"<<totalMae<<",\"gpu_baseline_max\":"<<baseMax<<",\"device\":\"D3D11 WARP software\"}\n";
 return 0;
 }catch(const std::exception& e){std::cerr<<e.what()<<"\n";return 1;}}
