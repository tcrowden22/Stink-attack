$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$rojo = Join-Path $projectRoot '.tools\rojo\rojo.exe'
if (-not (Test-Path -LiteralPath $rojo)) { throw 'Run scripts\Setup.ps1 first.' }
& $rojo serve (Join-Path $projectRoot 'default.project.json') --address 127.0.0.1 --port 34872
if ($LASTEXITCODE -ne 0) { throw 'Rojo sync server stopped with an error.' }
