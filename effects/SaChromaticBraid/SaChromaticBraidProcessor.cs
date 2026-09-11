using Vortice.Direct2D1;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Player.Video;
namespace SaChromaticBraid;
internal sealed class SaChromaticBraidProcessor : IVideoEffectProcessor {
 readonly SaChromaticBraidEffect item; readonly SaChromaticBraidShader shader; readonly ID2D1Image output;
 public SaChromaticBraidProcessor(IGraphicsDevicesAndContext devices, SaChromaticBraidEffect item) {
  this.item=item;shader=new SaChromaticBraidShader(devices);
  if(!shader.IsEnabled){shader.Dispose();throw new InvalidOperationException("シェーダーを初期化できませんでした。");}
  try {output=shader.Output;} catch {shader.Dispose();throw;}
 }
 public ID2D1Image Output => output;
 public void SetInput(ID2D1Image? input) => shader.SetInput(0,input,true);
 public void ClearInput() => shader.SetInput(0,null,true);
 public DrawDescription Update(EffectDescription e) {
  var frame=e.ItemPosition.Frame;var length=e.ItemDuration.Frame;var fps=e.FPS;
  shader.SetParameter(0,(float)(Math.Clamp(item.Strength.GetValue(frame,length,fps),0,100)/100.0));
  shader.SetParameter(1,(float)Math.Clamp(item.Radius.GetValue(frame,length,fps),0,256));
  shader.SetParameter(2,(float)Math.Clamp(item.Size.GetValue(frame,length,fps),2,128));
  shader.SetParameter(3,(float)(Math.Round(Math.Clamp(item.Threshold.GetValue(frame,length,fps),0,255))/255.0));
  shader.SetParameter(4,(float)Math.Round(Math.Clamp(item.Iterations.GetValue(frame,length,fps),1,16)));
  shader.SetParameter(5,(float)(Math.Clamp(item.Color.GetValue(frame,length,fps),-180,180)*Math.PI/180.0));
  shader.SetParameter(6,(float)Math.Round(Math.Clamp(item.Seed.GetValue(frame,length,fps),0,65535)));
  return e.DrawDescription;
 }
 public void Dispose(){ClearInput();output.Dispose();shader.Dispose();}
}
