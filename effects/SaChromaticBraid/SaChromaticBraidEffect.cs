using System.ComponentModel.DataAnnotations;
using YukkuriMovieMaker.Commons;
using YukkuriMovieMaker.Controls;
using YukkuriMovieMaker.Exo;
using YukkuriMovieMaker.Player.Video;
using YukkuriMovieMaker.Plugin.Effects;
namespace SaChromaticBraid;
[VideoEffect("色の編み込み", ["フィルタ"], ["構造", "色"], IsAviUtlSupported=false)]
public sealed class SaChromaticBraidEffect : VideoEffectBase {
 public override string Label => "色の編み込み";
 [Display(Name="強さ", Description="原画と処理結果の混合率", Order=0)]
 [AnimationSlider("F1", "%", 0, 100)]
 public Animation Strength {get;} = new(85,0,100);
 [Display(Name="変化範囲", Description="色を探す・変形させる距離", Order=1)]
 [AnimationSlider("F1", "px", 0, 256)]
 public Animation Radius {get;} = new(36,0,256);
 [Display(Name="模様の幅", Description="構造の繰り返し幅", Order=2)]
 [AnimationSlider("F1", "px", 2, 128)]
 public Animation Size {get;} = new(24,2,128);
 [Display(Name="しきい値", Description="小さい色差による反応を滑らかに抑える", Order=3)]
 [AnimationSlider("F0", "", 0, 255)]
 public Animation Threshold {get;} = new(18,0,255);
 [Display(Name="探索回数", Description="空間内の探索回数。時間方向の履歴は使用しない", Order=4)]
 [AnimationSlider("F0", "", 1, 16)]
 public Animation Iterations {get;} = new(12,1,16);
 [Display(Name="色相変化", Description="構造が変化した部分の色相回転", Order=5)]
 [AnimationSlider("F1", "°", -180, 180)]
 public Animation Color {get;} = new(35,-180,180);
 [Display(Name="配置シード", Description="配置を固定する整数。変更すると模様が切り替わる", Order=6)]
 [AnimationSlider("F0", "", 0, 65535)]
 public Animation Seed {get;} = new(7,0,65535);
 public override IEnumerable<string> CreateExoVideoFilters(int keyFrameIndex, ExoOutputDescription exoOutputDescription) => [];
 public override IVideoEffectProcessor CreateVideoEffect(IGraphicsDevicesAndContext devices) => new SaChromaticBraidProcessor(devices,this);
 protected override IEnumerable<IAnimatable> GetAnimatables() => [Strength,Radius,Size,Threshold,Iterations,Color,Seed];
}
