using System.Runtime.InteropServices;
using Vortice;
using Vortice.Direct2D1;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Player.Video;
namespace SaChromaticSuture;
internal sealed class SaChromaticSutureShader(IGraphicsDevicesAndContext devices)
 : D2D1CustomShaderEffectBase(Create<SaChromaticSutureShader.Impl>(devices)) {
 readonly float[] lastValues=new float[8];
 readonly bool[] initialized=new bool[8];
 public void SetParameter(int index,float value){
  if(initialized[index] && lastValues[index]==value)return;
  SetValue(index,value);lastValues[index]=value;initialized[index]=true;
 }
 [CustomEffect(1)]
 private sealed class Impl : D2D1CustomShaderEffectImplBase<Impl> {
  Constants constants=new(){Radius=36,Size=24,Iterations=12};
  public Impl():base(Load()){}
  static byte[] Load(){using var stream=typeof(SaChromaticSutureShader).Assembly.GetManifestResourceStream("SaChromaticSuture.Shader.cso") ?? throw new InvalidOperationException("シェーダーがありません。");using var m=new System.IO.MemoryStream();stream.CopyTo(m);return m.ToArray();}
  [CustomEffectProperty(PropertyType.Float,0)] public float Strength {get=>constants.Strength;set{constants.Strength=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,1)] public float Radius {get=>constants.Radius;set{constants.Radius=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,2)] public float Size {get=>constants.Size;set{constants.Size=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,3)] public float Threshold {get=>constants.Threshold;set{constants.Threshold=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,4)] public float Iterations {get=>constants.Iterations;set{constants.Iterations=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,5)] public float Color {get=>constants.Color;set{constants.Color=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,6)] public float Seed {get=>constants.Seed;set{constants.Seed=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,7)] public float Stability {get=>constants.Stability;set{constants.Stability=value;UpdateConstants();}}
  protected override void UpdateConstants(){drawInformation?.SetOutputBuffer(BufferPrecision.PerChannel32Float,ChannelDepth.Four);drawInformation?.SetPixelShaderConstantBuffer(constants);}
  // Grid anchors (<=2*Size), their guides and displaced samples: conservative bound.
  public override void MapOutputRectToInputRects(RawRect outputRect,RawRect[] inputRects){
   int h=(int)MathF.Ceiling(2*constants.Radius+3*constants.Size+12);
   inputRects[0]=new(Safe((long)outputRect.Left-h),Safe((long)outputRect.Top-h),Safe((long)outputRect.Right+h),Safe((long)outputRect.Bottom+h));
  }
  public override RawRect MapInvalidRect(int inputIndex,RawRect invalidInputRect){
   int h=(int)MathF.Ceiling(2*constants.Radius+3*constants.Size+12);
   return new(Safe((long)invalidInputRect.Left-h),Safe((long)invalidInputRect.Top-h),Safe((long)invalidInputRect.Right+h),Safe((long)invalidInputRect.Bottom+h));
  }
  static int Safe(long v)=>(int)Math.Clamp(v,int.MinValue,int.MaxValue);
  public override void MapInputRectsToOutputRect(RawRect[] inputRects,RawRect[] inputOpaqueSubRects,out RawRect outputRect,out RawRect outputOpaqueSubRect){
   outputRect=inputRects[0];outputOpaqueSubRect=default;
   constants.Left=outputRect.Left;constants.Top=outputRect.Top;constants.Right=outputRect.Right;constants.Bottom=outputRect.Bottom;UpdateConstants();
  }
  [StructLayout(LayoutKind.Sequential)] struct Constants {
   public float Strength,Radius,Size,Threshold,Iterations,Color,Seed,Stability;
   public float Left,Top,Right,Bottom;
  }
 }
}
