$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot
try {
    $rojo = Join-Path $projectRoot '.tools\rojo\rojo.exe'
    $compiler = Join-Path $projectRoot '.tools\luau\luau-compile.exe'
    $luau = Join-Path $projectRoot '.tools\luau\luau.exe'
    foreach ($tool in @($rojo, $compiler, $luau)) {
        if (-not (Test-Path -LiteralPath $tool)) { throw 'Run scripts\Setup.ps1 first.' }
    }
    Get-ChildItem src,tests -Recurse -Filter '*.luau' | ForEach-Object {
        & $compiler --null $_.FullName
        if ($LASTEXITCODE -ne 0) { throw "Luau compile failed: $($_.FullName)" }
    }
    & $luau tests\TeamPolicy.spec.luau
    if ($LASTEXITCODE -ne 0) { throw 'Team policy tests failed' }
    & $luau tests\BugGait.spec.luau
    if ($LASTEXITCODE -ne 0) { throw 'Bug gait tests failed' }
    & $luau tests\SoloRules.spec.luau
    if ($LASTEXITCODE -ne 0) { throw 'Solo rules tests failed' }
    & $luau tests\FlightRules.spec.luau
    if ($LASTEXITCODE -ne 0) { throw 'Flight rules tests failed' }
    & $luau tests\ClimbRules.spec.luau
    if ($LASTEXITCODE -ne 0) { throw 'Climb rules tests failed' }
    New-Item -ItemType Directory -Force build | Out-Null
    & $rojo build default.project.json --output build\StinkBugsVsVacuums.rbxlx
    if ($LASTEXITCODE -ne 0) { throw 'Rojo build failed' }
    Write-Host 'Build passed. Studio runtime and multiplayer acceptance tests are still required.'
} finally {
    Pop-Location
}
