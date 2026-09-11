# 設計比較と制約

## 確認した既存実装

- Sa_aohue: `ymm/SaAohueEffect.cs`, `SaAohueProcessor.cs`, `GaussianHorizontalEffect.cs`, `ChromaFieldEffect.cs`, `.csproj`, `.github/workflows/ymm-build.yml`。参照tree e3d077f9b4711ac8e7c2268ba777c9a4eac697c6。API構成・DLL参照・fxcビルド・インストール方式を踏襲。DoGマスクによる線周辺彩度調整は本作の主処理にはしない。
- Sa_beta: `ymm/Shaders/RomanCore.hlsli` を確認。地層の明度量子化、放射状干渉波、色相速度場と局所圧力補正による色流体。これらの処理を複製しない。
- Sa_beta2、Sa_displacedge: 確認したmainの公開treeはREADMEのみ。別ブランチの実装との比較は未実施。
- G'MIC `GreycLab/gmic-community/include/photocomix.gmic` のGraphic Novel実装（先頭100行）を確認。局所正規化、鉛筆化、異方性平滑化、合成モードの連鎖。本作の5種とは構成が異なる。
- Sapphireの公式公開一覧、Kaleido、DissolvePixelSort仕様を確認。Sapphireのソースは非公開のためコード比較はできない。画素の並べ替え、画像全体の鏡面反復、色収差分離は採用しない。

https://github.com/sabiasagimp4-ai/Sa_aohue/tree/main/ymm
https://github.com/sabiasagimp4-ai/Sa_beta/blob/main/ymm/Shaders/RomanCore.hlsli
https://github.com/GreycLab/gmic-community/blob/master/include/photocomix.gmic
https://borisfx.com/documentation/sapphire/ae/summary-index/
https://borisfx.com/documentation/sapphire/ae/dissolvepixelsort/

新規な数学原理・世界初・既存エフェクトとの完全な非重複は主張しない。
ワープや形態処理といった基礎操作自体には既存技術との共通点がある。

## 5種類の式の違い

1. **色の噛み合わせ**: 黄金角の放射状サンプル対からRGB色差と赤−青差を求める。滑らかなしきい値と交互の歯形が変位ベクトルを駆動。RGB各チャンネルを別座標へ分離しない。
2. **花弁の接ぎ木**: 異なる色の近傍を芽として、ローブ重みと接線方向のねじれで色を採取。色差がない部分には芽を作らない。平均ブラーとは異なり位置・重みが原画像の色と花弁位相に依存する。
3. **色の編み込み**: 赤−緑・緑−青の対立色成分で直交する帯の向きと強さを制御。原画から得た値に固定し、座標を進めるたび色差を再評価する不安定なフィードバックを避ける。
4. **膜の折り返し**: 元座標の局所明度勾配から法線を求め、色圧と空間位相で法線方向へ折る。反復は過去フレームではなく固定回数の変位加算。
5. **顔料の競合**: 近傍顔料の彩度による指数重みと距離減衰で、鮮やかな色を他の領域へ成長させる。勝者のハード切替をせず、連続重みで混ぜる。色相変化は競合反応に比例する。

## 安定性と最適化

- frame/timeを乱数へ入れず、Seed→固定位相。入力の微小差で勝者を突然切り替えるargmaxや二値マスクを避ける。
- ガイドは元画像から1回計算し、探索間で共有。BASELINEプリプロセッサでは各回の再計算を行い、同じコアで差を比較。
- 全画面一時バッファは0。1つのDirect2Dカスタムパスのみ。各ProcessorのGPUオブジェクトを再利用。
- ガイドの中心・4近傍採取を探索回数分繰り返さない。最大16回でも元画像依存ガイドは1回。
- 変位の成分上限・花弁採取範囲を覆う2×Radius+10のhaloを要求。CPU切り出し比較も実施。ただし実D2DのROI/デバイス別動作は未確認。
- 透明RGBを双線形補間の前に除外するためGPUは4点採取。ここは画質・アルファ正しさを優先し維持。
- 極端な幅2px・範囲256pxは細かい折り返しを生み、動く入力ではエイリアシングがありうる。時間履歴なしで全入力のちらつきを保証することはできない。
