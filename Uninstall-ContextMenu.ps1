#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$menuName = 'CursorAgent'
$targets = @(
    ("HKCU:\Software\Classes\Directory\shell\" + $menuName),
    ("HKCU:\Software\Classes\Directory\Background\shell\" + $menuName)
)

foreach ($keyPath in $targets) {
    if (Test-Path -LiteralPath $keyPath) {
        Remove-Item -LiteralPath $keyPath -Recurse -Force
        Write-Host ("已删除: " + $keyPath)
    }
    else {
        Write-Host ("不存在（跳过）: " + $keyPath)
    }
}

Write-Host '右键菜单已卸载。'