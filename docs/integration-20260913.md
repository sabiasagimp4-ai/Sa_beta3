# YMM4 全ブランチ監査・統合（2026-09-13）

GitHub上の既存YMM4実装5リポジトリ・18ブランチを取得し、mainとの差分と機能の系統を確認した時点の記録。以下のSHAは作業開始時点であり、将来のブランチ更新を追跡するものではない。

## 対象と判断

| リポジトリ | 実装 | 統合判断 |
|---|---|---|
| Sa_beta | 明度層・放射状色干渉・色に従う移流 | 単独の既存DLLを維持。シーン座標宣言を修正 |
| Sa_beta2 | SaGlitchYmm：帯状グリッチ、水平RGBずれ、走査線等 | mainに未統合の実装を回収。出力COM参照を寿命管理、端の半画素補間を修正 |
| Sa_beta3 | 10個の独立した構造エフェクト | 共通Pixel/サンプラーを統合。個別コア・クラス・名前空間・アセンブリ名・保存用プロパティを維持 |
| Sa_aohue | Gaussian DoG→点除去→ぼかし→OKLab合成・色交換 | 主要YMM実装はmainに包含。未統合の提案・測定・境界色研究を履歴注記付きで回収 |
| Sa_displacedge | Scharr輪郭場＋curl noise＋スペクトル変位 | fast-flowを製品の基準に、並行ブランチの独自ベンチマーク・テストを統合 |

Sa_Plugins、Sa_sikiiti、Sa_voronize、Sabia_effects、cool_blur、sabiasagi-toolsもリポジトリの全ファイルツリーを確認したが、現行ツリーにYMM/.csproj実装は見つからなかった。これらのAE実装をYMM4へ混ぜる変更はしていない。過去のローカル作業や削除済みブランチはGitHubに存在するブランチの範囲外。

Sa_beta2の現在のGitHubブランチはSaGlitchYmmであり、構造10種があると過去の説明だけから仮定していない。

## 重複を整理した箇所

- Sa_beta3: 10箇所のDirect2D境界処理・透明RGB除去・補間を `common/Sampling.hlsli` に統合。構造5種の整数座標高速パスは限定的に維持。
- Sa_beta3: 同一のPixel型・アンプリマルチプライ・輝度計算を `common/Pixel.hlsli` に統合。各DLLに埋め込まれ、別の共通DLLのインストールは不要。
- Sa_displacedge: 旧最適化の上限・少ない色収差設定へ戻さず、800%分散・赤/青ワープ・回転・8タップ近似選択・パラメータキャッシュを保持。旧並行ブランチの追加ベンチマークとゼロ分散テストを回収。
- Sa_aohue: 研究資料の未統合/未実装記述には作成時点を明示。現行UIと過去提案を混同しない。

色収差だけを理由にグリッチ・輪郭変位を1つにしたり、見た目の異なる縫合・噛み合わせを方式切替へ置換していない。前者は帯単位の変位、後者は輪郭場からの変位。縫合は対向色を糸状に合成し、噛み合わせは多方向色差から座標を変位させる。

## ブラッシュアップ

- Sa_beta3従来5種の仕上げ処理でRGBがalphaを超える不具合を回帰テストで再現し修正。仕上げの色味も「強さ」で線形補間する。旧設定での色味がわずかに変わる意図的な修正。
- Sa_beta3全10種で同じ値のシェーダーパラメータを繰り返し送らないようにする。GPU速度の改善率は測定していない。
- 実際に使うシーン座標のDirect2D宣言を不足するシェーダーに追加。Sa_beta3のWindows CIにはコンパイル後のSCENE_POSITION/TEXCOORD検証を追加。
- Sa_beta2のOutput取得ごとのCOM参照生成を止め、Processorが1つの出力参照を所有・解放。
- Sa_displacedge/Sa_beta2のROI拡張に整数飽和処理を追加。
- Sa_displacedge CPU参照のゼロ分散を製品HLSLと一致させる。虹色ハイライトが有効なら残し、無効なら完全パススルー。
- Sa_beta3のREADMEとCPU参照の初期値を現在の各エフェクトUIに合わせる。

## 開始時点の全ブランチ

「先行 / 遅延」は当該リポジトリの開始時mainからのコミット数。包含済みブランチや元ブランチを削除せず記録する。

| リポジトリ | ブランチ | SHA | 先行 / 遅延 | 判断 |
|---|---|---|---|---|
| Sa_beta | `main` | `c0ee220133c662cb86623dd72e9db43d57ac736c` | 0 / 0 | main基準 |
| Sa_beta2 | `claude/ymm4-image-effect-plugin-1kvkpb` | `5579e67f71fb35a03570d2e5622ad77cadc3f35b` | 1 / 0 | 今回の統合対象 |
| Sa_beta2 | `main` | `8c64a33bf1c5c89b91d7f80ce4fbbce64d423fdd` | 0 / 0 | main基準 |
| Sa_beta3 | `main` | `ec97cc9438c2b24a1b22deebf87020b715514baa` | 0 / 0 | main基準 |
| Sa_aohue | `claude/plugin-feature-proposal-cwz9db` | `61eec0b6d524914b7d721b2dc3c8ad9db0e2697f` | 4 / 8 | 今回の統合対象 |
| Sa_aohue | `codex/ymm-color-bleed` | `86c0687a0e3d8ea11b9aafb9008da6b09bb645ba` | 0 / 3 | 既にmainに包含 |
| Sa_aohue | `codex/ymm-line-controls` | `e5aaf011b029613ea33fce82d812683db7a5ab6e` | 0 / 4 | 既にmainに包含 |
| Sa_aohue | `codex/ymm-v02` | `da4628aab0f9029f954d0c01163372ffc4d046b3` | 0 / 5 | 既にmainに包含 |
| Sa_aohue | `main` | `e3d077f9b4711ac8e7c2268ba777c9a4eac697c6` | 0 / 0 | main基準 |
| Sa_aohue | `master` | `88ab06d4b25a15b91eb0ade1756ceb00579a6802` | 0 / 16 | 既にmainに包含 |
| Sa_aohue | `perf/preserve-output-efficiency` | `1655f11b3a73a786b64a3877f1a92db4cb3460f2` | 0 / 15 | 既にmainに包含 |
| Sa_aohue | `research/ymm-boundary-color` | `496fdf6c99ecfe6153560d2dfccc6906c071422a` | 1 / 4 | 今回の統合対象 |
| Sa_aohue | `ymm-plugin-port` | `0fcfc6063d5d671863db1f620c0e183224b26c8d` | 0 / 14 | 既にmainに包含 |
| Sa_displacedge | `claude/ymm4-image-processing-plugin-qknux5` | `6af45212a1a3d4307e6dc756b100ddaf6790cb77` | 4 / 0 | 今回の統合対象 |
| Sa_displacedge | `codex/displacedge-fast-flow` | `f406de0f08df2c362e373297db9edad6a014c4b5` | 24 / 0 | 今回の統合対象 |
| Sa_displacedge | `codex/perf-slider-range-20260909` | `3160e208e58b28b7c7dc5e6b6e24474bc58ed762` | 14 / 0 | 今回の統合対象 |
| Sa_displacedge | `codex/sa-displacedge-optimize` | `46301959842272329365f40d97af23d746a6952b` | 17 / 0 | 今回の統合対象 |
| Sa_displacedge | `main` | `4ddd282f803262a20538623a1a8767bbe91599e3` | 0 / 0 | main基準 |

## 検証の範囲

Sa_beta3: 従来5種125条件と構造5種360条件の本番共有スカラーコア。元アルファ、透明RGB、強さの線形性、有限値、ROI、再現性を検査。CPU試験はDirect2D実機の代用ではない。
Sa_displacedge: Python参照の31テスト。Sa_aohue: 9テストと本番点除去の216600件のBFS比較。Sa_beta2: Python参照selfcheck。
Windowsビルド・HLSLレイアウト・WARPは各PRのActions結果を参照。YMM4実画面、実GPU性能、保存再読込はこのLinux環境では検証していない。
