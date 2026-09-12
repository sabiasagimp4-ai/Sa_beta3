# Sa_beta3 追加5種 — 構造エフェクト

既存5種に、以下の独立した5プロジェクト・クラス・名前空間・アセンブリを追加。
方式を切り替える共通エフェクトではありません。各DLLは単独で導入できます。

| アセンブリ | YMM4の日本語名 | 処理 |
|---|---|---|
| SaContourTunnel | 輪郭の空洞化 | 対向サンプルの色差から同心状の輪郭層と陰影を作る |
| SaIrisCells | 色の虹彩細胞 | 座標ハッシュで固定した細胞に、色差で開く虹彩状の屈折を作る |
| SaFacetBloom | 結晶のせり出し | 色差のある場所へ、細長い結晶面と稜線を立ち上げる |
| SaChromaticSuture | 色境界の縫合 | 境界の反対側から採取した色を、曲がった縫い目でつなぐ |
| SaColorCilia | 色境界の繊毛 | 色差の大きいサンプルを優先し、湾曲した細線として周囲へ伸ばす |

## インストール

GitHub Actions → **YMM4 build** → 成功した実行 → **SaBeta3StructuresYmm**。
Artifact内のZIPを展開し、必要なエフェクトのフォルダーを
`YukkuriMovieMaker/user/plugin/` にコピーしてYMM4を再起動。
「フィルタ」から日本語名を選択。既存5種を含む全10種は従来の **SaBeta3Ymm** Artifact。
YMM4ホストDLLは同梱しません。

Sa_aohueの現行YMM版と同じ.NET 10、WPF、Direct2Dカスタムシェーダー、
公式YMM4 LiteのDLL参照、Windows SDK fxc（ps_4_0）、埋め込みCSO構成。

```powershell
dotnet build effects/SaIrisCells/SaIrisCells.csproj -c Release "-p:YMM4DirPath=C:\YMM4\" "-p:FxcPath=C:\SDK\fxc.exe" "-p:D2DIncludePath=C:\SDK\um"
```

## パラメータの意味と範囲

| プロパティ | 日本語UI | 範囲 | 意味 |
|---|---|---|---|
| Strength | 強さ | 0–100% | 反応部分の処理結果と原画を線形混合。0は完全無変化 |
| Radius | 変化範囲 | 0–256px | 採色・変位距離の尺度。0は完全無変化 |
| Size | 層の幅／細胞の大きさ／結晶の大きさ／縫い目の間隔／繊毛の間隔 | 4–192px | 各構造の空間尺度 |
| Threshold | しきい値 | 0–255 | アルファで重み付けしたRGB色差の抑制。内部は値/255 |
| Iterations | 探索回数／虹彩の筋数／結晶の稜線数／縫い目の細かさ | 1–24 | 空洞・繊毛はサンプル数、虹彩・結晶・縫合は模様の形状を変える |
| Color | 色相変化 | −180–180° | 反応に応じてRGB中立軸周りに回転。0は回転なし |
| Seed | 配置シード | 0–65535 | 座標ハッシュや空間位相を固定する整数 |
| Stability | 安定性 | 0–100% | 色差の立ち上がりを滑らかにする。遷移幅0.045〜0.245 |

表示範囲・Animation内部範囲・Processorのクランプは一致。
しきい値、分割・探索数、シードは整数に丸めます。
SizeとIterationsの日本語名・説明はエフェクト別に表示します。

| 初期値 | 強さ | 範囲 | サイズ | しきい値 | 分割・探索数 | 色相 | シード | 安定性 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 輪郭の空洞化 | 82 | 48 | 24 | 10 | 12 | 28 | 7 | 70 |
| 色の虹彩細胞 | 85 | 44 | 52 | 8 | 12 | 38 | 11 | 70 |
| 結晶のせり出し | 86 | 64 | 44 | 10 | 8 | 24 | 19 | 65 |
| 色境界の縫合 | 92 | 70 | 28 | 6 | 12 | 48 | 23 | 75 |
| 色境界の繊毛 | 94 | 85 | 26 | 6 | 16 | 32 | 31 | 75 |

## アルゴリズム

- **空洞化**：広い色勾配を求め、黄金角の方向成分を加えた対向2点を固定N回調べる。
  対向色差をゲートとし、距離と採色差から輪郭層の重みと陰影を計算。色を再構成する。
  正負の波の干渉や時間エコーではない。
- **虹彩細胞**：3×3の近傍セルに整数ハッシュで中心を置き、中心付近の色差から開口量を求める。
  放射状の筋と環状の隆起が採色位置を変える。セル端の重みは0へ滑らかに収束する。
  画像全体の鏡面反復やチャンネル分離はしない。
- **結晶**：固定セル内に菱形の細長い面を定義し、色差に比例する高さに従って原画を採取。
  両側の面の陰影と稜線を付ける。Voronoi分割・代表色への量子化はしない。
- **縫合**：明度・対立色の勾配から境界法線を求め、その両側の色を採取。
  シード固定方向の周期曲線で糸を作り、反対側の色を交互に運ぶ。
  勾配方向を絶対座標に掛けて位相を変える構成は避け、動画入力の揺れを増幅しにくくした。
- **繊毛**：シード固定方向の湾曲した探索経路に沿い、色差の大きい採色を滑らかな指数重みで優先。
  細線状のマスクで合成し、同じ境界から色が伸びる形を作る。流体の圧力解法・履歴・argmaxは使わない。

## アルファ・再現性・動画

入力はSDRのプリマルチプライRGBAを前提にします。色計算でアンプリマルチプライし、
出力RGBは元座標のアルファを掛け直します。出力アルファは元画素をそのまま保持。
完全透明画素の隠れたRGBもそのまま返し、近傍補間に混入する前には0へ置換します。
単色画像は色差がないため無変化。画面外は端を延長し、出力領域は拡大しません。

過去フレーム・履歴バッファ・時刻由来の乱数・フレーム最大値正規化はありません。
Seedは整数ハッシュまたは固定位相として使用。同じ入力・設定・実行系なら再現します。
動画ではSeedとIterationsを固定し、安定性75〜100から調整してください。
入力自体の激しい変化や4px間隔・最大範囲によるエイリアシングまで、履歴なしで除去できるわけではありません。
CPUとGPUの三角関数・丸めが完全一致する保証はありません。

## レンダーと検証

`common/structures/Core.hlsli` と各新規エフェクトの `Core.hlsli` を変更せずC++としてコンパイル。
添付画像の25PNGはこの本番計算を実行したものです。生成AIは不使用。
YMM4の画面キャプチャではなくCPUレンダーです。

```bash
python -m pip install numpy pillow
python tests/structures/runtime.py
OMP_NUM_THREADS=4 python tests/structures/test_core.py
OMP_NUM_THREADS=4 python tests/structures/render.py input.jpeg outputs --font /path/to/JapaneseFont.otf
```

`parameters.json` に25通りの設定と入力SHA256、`benchmark.json` に全25設定の測定値。
`tests.json` は360条件、ROI、透明色混入、Seed、強さの線形性、UI範囲、微小入力摂動の検証。
Windows Actionsでは本番C#とHLSLをビルドし、同じ計算本体をDirect3D11 WARPの
computeアダプターでも実行してCPUとの比較・GPU最適化差分・アルファを検証します。
このテストはD2D/YMM4のUI・保存再読込・ホスト固有のROI・実GPU速度の検証を代替しません。

## 最適化

正しい4点双線形補間を基準とし、アルファ判定とRGBAの読み込みを共有。
整数画素中心では寄与しない3サンプルを省略。加算順と採色座標は変更しません。
PNG出力はメモリ内で完成させてから原子的に置き換え、読み戻して完全性を検証します。

全画面中間バッファは0枚、1パス。GPUオブジェクトはProcessor内で再利用。
ガイドは各画素またはセルの処理内で再利用し、各反復で同じ情報を再計算しません。
haloは保守的に `ceil(2×Radius + 3×Size + 12)` px。
セル中心・ガイド・変位・補間の全到達範囲を覆い、無効化範囲も同じ幅で拡張します。
セル間ガイドの全画面キャッシュ化は追加パス・バッファ費用があるため未採用。
GPUのサンプル命令削減がそのまま速度改善になるとは限らず、実GPUでの計測は未実施です。

## 既存との比較

設計時に次の実装を読みました。

- Sa_aohue `e3d077f9` のYMMプロジェクト、Processor、説明、Actions。DoG線マスクとOKLab色の回り込みが主処理。
- Sa_beta3 `34266060` の既存5種類の計算本体。交互の歯・花弁・対立色の帯・膜の折返し・彩度による競合。
- Sa_beta `ymm/Shaders/RomanCore.hlsli`。明度量子化層、放射状の干渉波、色相速度場と局所圧力・粘性の流体処理。
- G'MIC community `33e732b6` の `photocomix.gmic: fx_psyglass` と `reptorian.gmic: rep_polar_kaleidoscope`。
  前者はstained_glassと合成・正規化、後者は極座標の反復・鏡像であり、新規5種の組み立てとは異なる。

商用エフェクトは公開仕様を比較。ソース非公開の実装を確認したとは主張しません。
汎用のワープ、陰影、周期模様、採色など基礎操作には共通点があり、世界初や完全非重複は保証しません。

- https://helpx.adobe.com/il_en/after-effects/desktop/apply-effects-and-animation-presets/list-of-effects/distort-effects.html
- https://borisfx.com/documentation/sapphire/ae/warpperspective/
- https://borisfx.com/documentation/optics-2026/Optics%202026.5/Filters-S_Kaleido.html
- https://aescripts.com/pixel-sorter/
- https://github.com/GreycLab/gmic-community/tree/33e732b6c0e71b859c6baed252b9938ac01a3b53/include

測定表は `performance.md`、変更ファイル一覧は `changed-files.md` を参照。
