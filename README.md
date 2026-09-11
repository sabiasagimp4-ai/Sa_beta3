# Sa_beta3 — YMM4独立エフェクト群

5個の独立したプロジェクト・クラス・名前空間・DLL。方式切替はありません。

| DLL | UI名 | 構造 |
|---|---|---|
| SaChromaticZipper | 色の噛み合わせ | 反対側の色差を使って境界を交互に噛み合わせる |
| SaPetalGraft | 花弁の接ぎ木 | 色差のある近傍から花弁状に色を接ぐ |
| SaChromaticBraid | 色の編み込み | 赤−緑・緑−青の差から交差する帯を変形 |
| SaMembraneFold | 膜の折り返し | 原画像の勾配を法線として膜を折り返す |
| SaPigmentRelay | 顔料の競合 | 彩度と距離による滑らかな競合で色領域を成長 |

## インストール

Actions → **YMM4 build** → 成功した実行 → **SaBeta3Ymm** Artifact。
外側ZIPとSaBeta3Ymm.zipを展開し、必要なエフェクトのフォルダーを
`YukkuriMovieMaker/user/plugin/` にコピー。YMM4を再起動し「フィルタ」から選択。
各DLLは他の4個を必要としません。ホストDLLは再配布しません。

Sa_aohue現行YMM版と同じ .NET 10 / WPF / Direct2D / Windows SDK fxc / 公式YMM4 Lite参照を使用。

```powershell
dotnet build effects/SaChromaticZipper/SaChromaticZipper.csproj -c Release "-p:YMM4DirPath=C:\YMM4\" "-p:FxcPath=C:\SDK\fxc.exe" "-p:D2DIncludePath=C:\SDK\um"
```

## パラメータ

| UI名 | 範囲 | 初期値 | 意味 |
|---|---|---|---|
| 強さ | 0–100% | 85 | 元画像との混合 |
| 変化範囲 | 0–256px | 36 | 探索・変形距離の尺度 |
| 模様の幅 | 2–128px | 24 | 模様の繰り返し幅 |
| しきい値 | 0–255 | 18 | 小さい色差・勾配を抑制。幅0.12の滑らかな遷移 |
| 探索回数 | 1–16 | 12 | 同じフレーム内での探索数・変形の加算回数 |
| 色相変化 | −180–180° | 35 | 構造反応に比例するRGB中立軸周りの回転 |
| 配置シード | 0–65535 | 7 | 空間配置。整数で固定 |

表示範囲・Animation内部範囲・Processorクランプは一致。探索回数・シード・しきい値は整数へ丸める。
強さ0、変化範囲0は元画素をそのまま返す。フレーム番号を乱数へ使わない。
シードと探索回数をアニメーションさせると配置が切り替わるため、動画では固定を推奨。

## アルファ・範囲・時間

入力sRGB相当のプリマルチプライRGBAを前提にし、色計算時にアンプリマルチプライ。
アルファは入力座標からそのまま保持し、透明画素のRGBもそのまま返す。
近傍の完全透明RGBを除いてから双線形補間する。領域外は端を延長。出力領域は拡大しない。
SDR対象。HDR・別の作業色空間は未対応。

履歴・時間乱数・過去フレーム・フレーム全体最大値による正規化はなし。
連続的な重みを使用するが、動きによる模様の移動や極端値での細部ちらつきまで保証するものではない。

## 基準実装と検証

`common/Core.hlsli` と各 `effects/*/Core.hlsli` はHLSLとC++で同じ本体を実行。
画像はこの共有コードをCPUで実際に処理した結果。画像生成AIや別の近似フィルタは使用しない。
YMM4実機・GPUのスクリーンショットではなく、GPUの補間・三角関数・丸め誤差は別途検証が必要。

```bash
python -m pip install numpy pillow
python tests/runtime.py
OMP_NUM_THREADS=4 python tests/test_core.py
OMP_NUM_THREADS=4 python tests/render.py input.jpeg outputs
```

BASELINEは各探索ごとに元座標のガイドを再計算。最適化版は同じガイドを1回計算して再利用。
加算順・サンプル位置・重み・反復回数を維持。1パス・全画面作業バッファ0枚。
ROIは2×変化範囲+10pxの保守的halo。透明RGBの混入防止のため4点補間は維持。
GPUオブジェクトはProcessor内で再利用。測定詳細はdocs/を参照。

## 実機確認が必要な項目

YMM4 UIでの適用・動画再生・保存再読込・GPU時間・GPU最適化差分。
CPU測定値はGPU速度を示しません。Windows ActionsはC#とHLSLをビルドします。


## ビジュアル調整

添付画像で25パターンを目視し、各エフェクトの初期値を個別に調整した。通常・映像向けは人物の輪郭と背景の読みやすさを優先し、極端設定だけ変形量と色相変化を大きくしている。共通仕上げは暗部を青寄り、明部をわずかに暖色寄りにする。詳細は `docs/visual-pass.md`。
