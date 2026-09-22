#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$invokeScript = Join-Path $scriptDir 'Invoke-CursorAgent.ps1'

if (-not (Test-Path -LiteralPath $invokeScript)) {
    throw "Cannot find Invoke-CursorAgent.ps1: $invokeScript"
}

$menuName = 'CursorAgent'
$menuLabel = [string]::Concat([char]0x7528, ' Cursor Agent ', [char]0x6267, [char]0x884C, '...')
$command = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $invokeScript + '" "%V"'

$targets = @(
    ("HKCU:\Software\Classes\Directory\shell\" + $menuName),
    ("HKCU:\Software\Classes\Directory\Background\shell\" + $menuName)
)

foreach ($keyPath in $targets) {
    New-Item -Path $keyPath -Force | Out-Null
    Set-Item -Path $keyPath -Value $menuLabel
    New-ItemProperty -Path $keyPath -Name 'Icon' -Value 'shell32.dll,4' -PropertyType String -Force | Out-Null

    $commandKey = Join-Path $keyPath 'command'
    New-Item -Path $commandKey -Force | Out-Null
    Set-Item -Path $commandKey -Value $command
}

Write-Host ('Installed: ' + $menuLabel)
Write-Host ('Script: ' + $invokeScript)