param([string]$FxcPath)
$ErrorActionPreference = 'Stop'
$names = (Get-Content tests/structures/effects.json -Raw | ConvertFrom-Json).names
New-Item -ItemType Directory warp-results -Force | Out-Null
foreach ($name in $names) {
  $coreInclude = '#include "../../effects/' + $name + '/Core.hlsli"'
  (Get-Content tests/structures/compute.hlsl -Raw).Replace('#include EFFECT_CORE', $coreInclude) | Set-Content "tests/structures/$name.compute.hlsl"
  @"
#define EFFECT_CORE "../../effects/$name/Core.hlsli"
#include "reference.cpp"
#include "warp.cpp"
"@ | Set-Content "tests/structures/$name.warp.cpp"
  & $FxcPath /nologo /WX /T cs_5_0 /E main /Fo "warp-results/$name.cso" "tests/structures/$name.compute.hlsl"
  if ($LASTEXITCODE -ne 0) { throw "$name compute compile failed" }
  & $FxcPath /nologo /WX /D BASELINE=1 /T cs_5_0 /E main /Fo "warp-results/$name.baseline.cso" "tests/structures/$name.compute.hlsl"
  if ($LASTEXITCODE -ne 0) { throw "$name baseline compile failed" }
  & cl /nologo /EHsc /O2 /std:c++17 /fp:precise "tests/structures/$name.warp.cpp" /Fe:"warp-results/$name.exe" /Fo:"warp-results/$name.obj" /link d3d11.lib
  if ($LASTEXITCODE -ne 0) { throw "$name WARP runner build failed" }
  & "./warp-results/$name.exe" "warp-results/$name.cso" "warp-results/$name.baseline.cso" | Tee-Object "warp-results/$name.json"
  if ($LASTEXITCODE -ne 0) { throw "$name WARP validation failed" }
}
