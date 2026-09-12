using System.ComponentModel.DataAnnotations;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Controls;
using YukkuriMovieMaker.Exo;
using YukkuriMovieMaker.Player.Video;
using YukkuriMovieMaker.Plugin.Effects;
namespace SaFacetBloom;
[VideoEffect("結晶のせり出し", ["フィルタ"], ["構造", "色"], IsAviUtlSupported=false)]
public sealed class SaFacetBloomEffect : VideoEffectBase {
 public override string Label => "結晶のせり出し";
 [Display(Name="強さ", Description="原画と処理結果の混合率", Order=0)]
 [AnimationSlider("F1", "%", 0, 100)]
 public Animation Strength {get;} = new(86,0,100);
 [Display(Name="変化範囲", Description="構造が色を採取する最大距離の尺度", Order=1)]
 [AnimationSlider("F1", "px", 0, 256)]
 public Animation Radius {get;} = new(64,0,256);
 [Display(Name="結晶の大きさ", Description="構造の空間的な大きさ", Order=2)]
 [AnimationSlider("F1", "px", 4, 192)]
 public Animation Size {get;} = new(44,4,192);
 [Display(Name="しきい値", Description="小さな色差による反応を抑える", Order=3)]
 [AnimationSlider("F0", "", 0, 255)]
 public Animation Threshold {get;} = new(10,0,255);
 [Display(Name="結晶の稜線数", Description="探索精度または模様の分割数。動画では固定を推奨", Order=4)]
 [AnimationSlider("F0", "", 1, 24)]
 public Animation Iterations {get;} = new(8,1,24);
 [Display(Name="色相変化", Description="構造の反応部分だけを色相回転", Order=5)]
 [AnimationSlider("F1", "°", -180, 180)]
 public Animation Color {get;} = new(24,-180,180);
 [Display(Name="配置シード", Description="同じ値で配置を固定。動画では固定を推奨", Order=6)]
 [AnimationSlider("F0", "", 0, 65535)]
 public Animation Seed {get;} = new(19,0,65535);
 [Display(Name="安定性", Description="色差しきい値の遷移幅を広げ、弱い反応の点滅を軽減", Order=7)]
 [AnimationSlider("F1", "%", 0, 100)]
 public Animation Stability {get;} = new(65,0,100);
 public override IEnumerable<string> CreateExoVideoFilters(int keyFrameIndex, ExoOutputDescription exoOutputDescription) => [];
 public override IVideoEffectProcessor CreateVideoEffect(IGraphicsDevicesAndContext devices) => new SaFacetBloomProcessor(devices,this);
 protected override IEnumerable<IAnimatable> GetAnimatables() => [Strength,Radius,Size,Threshold,Iterations,Color,Seed,Stability];
}
