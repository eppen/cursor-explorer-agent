#Requires -Version 5.1
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function S([int[]]$codes) {
    return -join ($codes | ForEach-Object { [char]$_ })
}

function Resolve-FolderPath {
    param([string]$RawPath)

    if ([string]::IsNullOrWhiteSpace($RawPath)) {
        throw (S 0x672A,0x63D0,0x4F9B,0x6587,0x4EF6,0x5939,0x8DEF,0x5F84,0x3002)
    }

    $normalized = $RawPath.Trim().TrimEnd('\')
    if (-not (Test-Path -LiteralPath $normalized -PathType Container)) {
        throw ((S 0x8DEF,0x5F84,0x4E0D,0x662F,0x6709,0x6548,0x6587,0x4EF6,0x5939,0x003A,0x0020) + $normalized)
    }

    return (Resolve-Path -LiteralPath $normalized).Path
}

function Find-AgentCommand {
    $fromPath = Get-Command agent.cmd -ErrorAction SilentlyContinue
    if ($fromPath) {
        return $fromPath.Source
    }

    $fallback = Join-Path $env:LOCALAPPDATA 'cursor-agent\agent.cmd'
    if (Test-Path -LiteralPath $fallback) {
        return $fallback
    }

    throw 'agent.cmd not found. Install Cursor CLI or check %LOCALAPPDATA%\cursor-agent\agent.cmd'
}

function Show-TaskDialog {
    param([string]$FolderPath)

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = (S 0x7528) + ' Cursor Agent ' + (S 0x6267,0x884C)
    $form.Size = New-Object System.Drawing.Size(520, 320)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.ShowInTaskbar = $true

    $lblPath = New-Object System.Windows.Forms.Label
    $lblPath.Text = (S 0x5DE5,0x4F5C,0x533A,0x8DEF,0x5F84,0x003A)
    $lblPath.Location = New-Object System.Drawing.Point(12, 12)
    $lblPath.AutoSize = $true

    $txtPath = New-Object System.Windows.Forms.TextBox
    $txtPath.Location = New-Object System.Drawing.Point(12, 32)
    $txtPath.Size = New-Object System.Drawing.Size(480, 23)
    $txtPath.ReadOnly = $true
    $txtPath.Text = $FolderPath

    $lblPrompt = New-Object System.Windows.Forms.Label
    $lblPrompt.Text = (S 0x4EFB,0x52A1,0x8BF4,0x660E,0x003A)
    $lblPrompt.Location = New-Object System.Drawing.Point(12, 68)
    $lblPrompt.AutoSize = $true

    $txtPrompt = New-Object System.Windows.Forms.TextBox
    $txtPrompt.Location = New-Object System.Drawing.Point(12, 88)
    $txtPrompt.Size = New-Object System.Drawing.Size(480, 140)
    $txtPrompt.Multiline = $true
    $txtPrompt.ScrollBars = 'Vertical'
    $txtPrompt.AcceptsReturn = $true

    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = (S 0x786E,0x5B9A)
    $btnOk.Location = New-Object System.Drawing.Point(316, 242)
    $btnOk.Size = New-Object System.Drawing.Size(85, 28)
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = (S 0x53D6,0x6D88)
    $btnCancel.Location = New-Object System.Drawing.Point(407, 242)
    $btnCancel.Size = New-Object System.Drawing.Size(85, 28)
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $form.Controls.AddRange(@($lblPath, $txtPath, $lblPrompt, $txtPrompt, $btnOk, $btnCancel))
    $form.AcceptButton = $btnOk
    $form.CancelButton = $btnCancel
    $form.Add_Shown({ $txtPrompt.Focus() })

    $result = $form.ShowDialog()
    $prompt = $txtPrompt.Text
    $form.Dispose()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        return $null
    }

    if ([string]::IsNullOrWhiteSpace($prompt)) {
        return $null
    }

    return $prompt.Trim()
}

try {
    $folderPath = Resolve-FolderPath -RawPath $Path
    $agentCmd = Find-AgentCommand
    $userPrompt = Show-TaskDialog -FolderPath $folderPath

    if ($null -eq $userPrompt) {
        exit 0
    }

    $fullPrompt = $userPrompt + "`n`n" + (S 0x5DE5,0x4F5C,0x533A,0x7EDD,0x5BF9,0x8DEF,0x5F84,0x003A,0x0020) + $folderPath

    $runner = Join-Path $env:TEMP ("cursor-agent-run-" + [guid]::NewGuid().ToString('N') + ".ps1")
    $runnerBody = @(
        '$ErrorActionPreference = ''Continue'''
        ('Set-Location -LiteralPath ' + "'" + $folderPath.Replace("'", "''") + "'")
        ('$agent = ' + "'" + $agentCmd.Replace("'", "''") + "'")
        ('$prompt = @''' )
        $fullPrompt
        '''@'
        'Write-Host ("Workspace: " + (Get-Location).Path)'
        'Write-Host ("Agent: " + $agent)'
        'Write-Host ""'
        '& $agent -p --force --trust --workspace (Get-Location).Path $prompt'
        '$code = $LASTEXITCODE'
        'Write-Host ""'
        'Write-Host ("Exit code: " + $code)'
        'Read-Host "Press Enter to close"'
        ('Remove-Item -LiteralPath ' + "'" + $runner.Replace("'", "''") + "' -Force -ErrorAction SilentlyContinue")
    ) -join "`r`n"

    [System.IO.File]::WriteAllText($runner, $runnerBody, (New-Object System.Text.UTF8Encoding $true))

    Start-Process -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $runner
    ) -WorkingDirectory $folderPath
}
catch {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        $_.Exception.Message,
        'Cursor Agent',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}