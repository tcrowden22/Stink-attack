$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$toolRoot = Join-Path $projectRoot '.tools'
New-Item -ItemType Directory -Force $toolRoot | Out-Null
$packages = @(
    @{ Name = 'rojo'; Url = 'https://github.com/rojo-rbx/rojo/releases/download/v7.7.1/rojo-7.7.1-windows-x86_64.zip'; Hash = 'd4dfa3493a1613a43fc87312d6dac660d7c8bf38e6a99aa5dcd0d26154ba0b82' },
    @{ Name = 'luau'; Url = 'https://github.com/luau-lang/luau/releases/download/0.742/luau-windows.zip'; Hash = '1114966cd8198f407069f07e8b4e6bacf2ded933e4a57d6ddc75617969278c75' }
)
foreach ($package in $packages) {
    $archive = Join-Path $toolRoot ($package.Name + '.zip')
    Invoke-WebRequest $package.Url -OutFile $archive
    if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $package.Hash) {
        throw "Checksum mismatch for $($package.Name)"
    }
    Expand-Archive -LiteralPath $archive -DestinationPath (Join-Path $toolRoot $package.Name) -Force
}
Write-Host 'Pinned tools installed. To install the Studio plugin: .\.tools\rojo\rojo.exe plugin install'
