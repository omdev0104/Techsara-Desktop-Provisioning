# ==========================================
# Techsara Desktop Provisioning Launcher
# ==========================================

$ErrorActionPreference = "Stop"

if ($ScriptRoot) {
    $Root = $ScriptRoot
}
elseif ($PSScriptRoot) {
    $Root = $PSScriptRoot
}
else {
    $Root = (Get-Location).Path
}

$BuildScript = Join-Path $Root "Build.ps1"

if (-not (Test-Path -LiteralPath $BuildScript)) {

    Add-Type -AssemblyName System.Windows.Forms

    [System.Windows.Forms.MessageBox]::Show(
        "Build.ps1 was not found.`r`n`r`nExpected:`r`n$BuildScript",
        "Techsara Desktop Provisioning Utility",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )

    exit 1
}

try {

    # Explicitly start PowerShell with Bypass for this
    # deployment application's child script.
    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        "`"$BuildScript`""
    )

    $process = Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList $arguments `
        -WorkingDirectory $Root `
        -Wait `
        -PassThru

    exit $process.ExitCode
}
catch {

    Add-Type -AssemblyName System.Windows.Forms

    [System.Windows.Forms.MessageBox]::Show(
        "Techsara Deployment Tool encountered an error.`r`n`r`n$($_.Exception.Message)",
        "Techsara Desktop Provisioning Utility",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )

    exit 1
}