using System.Runtime.InteropServices;
using Vortice;
using Vortice.Direct2D1;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Player.Video;
namespace SaChromaticBraid;
internal sealed class SaChromaticBraidShader(IGraphicsDevicesAndContext devices)
 : D2D1CustomShaderEffectBase(Create<SaChromaticBraidShader.Impl>(devices)) {
 readonly float[] lastValues=new float[7];
 readonly bool[] initialized=new bool[7];
 public void SetParameter(int index,float value){
  if(initialized[index] && lastValues[index]==value)return;
  SetValue(index,value);lastValues[index]=value;initialized[index]=true;
 }
 [CustomEffect(1)]
 private sealed class Impl : D2D1CustomShaderEffectImplBase<Impl> {
  Constants constants=new(){Radius=36,Size=24,Iterations=12};
  public Impl():base(Load()){}
  static byte[] Load(){using var stream=typeof(SaChromaticBraidShader).Assembly.GetManifestResourceStream("SaChromaticBraid.Shader.cso") ?? throw new InvalidOperationException("シェーダーがありません。");using var m=new System.IO.MemoryStream();stream.CopyTo(m);return m.ToArray();}
  [CustomEffectProperty(PropertyType.Float,0)] public float Strength {get=>constants.Strength;set{constants.Strength=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,1)] public float Radius {get=>constants.Radius;set{constants.Radius=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,2)] public float Size {get=>constants.Size;set{constants.Size=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,3)] public float Threshold {get=>constants.Threshold;set{constants.Threshold=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,4)] public float Iterations {get=>constants.Iterations;set{constants.Iterations=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,5)] public float Color {get=>constants.Color;set{constants.Color=value;UpdateConstants();}}
  [CustomEffectProperty(PropertyType.Float,6)] public float Seed {get=>constants.Seed;set{constants.Seed=value;UpdateConstants();}}
  protected override void UpdateConstants(){drawInformation?.SetOutputBuffer(BufferPrecision.PerChannel32Float,ChannelDepth.Four);drawInformation?.SetPixelShaderConstantBuffer(constants);}
  // Every path is bounded by 2*Radius; add guide and bilinear footprints.
  public override void MapOutputRectToInputRects(RawRect outputRect,RawRect[] inputRects){
   int h=(int)MathF.Ceiling(2*constants.Radius+10);
   inputRects[0]=new(Safe((long)outputRect.Left-h),Safe((long)outputRect.Top-h),Safe((long)outputRect.Right+h),Safe((long)outputRect.Bottom+h));
  }
  static int Safe(long v)=>(int)Math.Clamp(v,int.MinValue,int.MaxValue);
  public override void MapInputRectsToOutputRect(RawRect[] inputRects,RawRect[] inputOpaqueSubRects,out RawRect outputRect,out RawRect outputOpaqueSubRect){
   outputRect=inputRects[0];outputOpaqueSubRect=default;
   constants.Left=outputRect.Left;constants.Top=outputRect.Top;constants.Right=outputRect.Right;constants.Bottom=outputRect.Bottom;UpdateConstants();
  }
  [StructLayout(LayoutKind.Sequential)] struct Constants {
   public float Strength,Radius,Size,Threshold,Iterations,Color,Seed,Padding;
   public float Left,Top,Right,Bottom;
  }
 }
}
